import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:share_plus/share_plus.dart';

import '../database/app_database.dart';
import '../files/pick_file.dart';
import '../database/tables.dart';

class BackupException implements Exception {
  const BackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

class BackupSummary {
  const BackupSummary({
    required this.readings,
    required this.recitatives,
    required this.prayers,
    required this.notes,
  });

  final int readings;
  final int recitatives;
  final int prayers;
  final int notes;

  String get description =>
      '$readings leituras, $recitatives recitativos, $prayers pedidos de oração e $notes anotações';
}

/// Exporta/importa todos os dados do usuário (não o texto bíblico) em JSON.
///
/// Funciona igual no Android e na Web: o arquivo é montado em memória e
/// entregue à folha de compartilhamento (no navegador, vira um download).
class BackupService {
  BackupService(this._db);

  /// Identificador do formato. Mantido do nome antigo do app para que backups antigos continuem válidos.
  static const String format = 'devocional-backup';

  /// v1: ids inteiros (até o app 1.1). v2: ids UUID e colunas de sincronização.
  static const int version = 2;

  /// Preferências internas da sincronização: pertencem ao aparelho, não ao backup.
  static const String _syncSettingsPrefix = 'sync.';

  final AppDatabase _db;

  Future<Map<String, Object?>> buildBackup() async {
    Future<List<Map<String, dynamic>>> active<T extends Table, D extends DataClass>(TableInfo<T, D> table) async {
      final rows = await _db.customSelect(
        'SELECT * FROM ${table.actualTableName} WHERE deleted_at IS NULL',
        readsFrom: {table},
      ).get();
      return [for (final r in rows) (await table.map(r.data)).toJson()];
    }

    return {
      'format': format,
      'version': version,
      'exportedAt': DateTime.now().toIso8601String(),
      'readingCycles': await active(_db.readingCycles),
      'readingLogs': await active(_db.readingLogs),
      'recitatives': await active(_db.recitatives),
      'prayerRequests': await active(_db.prayerRequests),
      'verseNotes': await active(_db.verseNotes),
      'settings': [
        for (final r in await _db.select(_db.appSettingsEntries).get())
          if (!r.key.startsWith(_syncSettingsPrefix)) r.toJson(),
      ],
      'planEnrollments': await active(_db.planEnrollments),
    };
  }

  /// Gera o arquivo e abre a folha de compartilhamento do sistema.
  Future<void> shareBackup() async {
    final backup = await buildBackup();
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    final name = 'lumen-backup-${now.year}${two(now.month)}${two(now.day)}-${two(now.hour)}${two(now.minute)}.json';
    final bytes = utf8.encode(const JsonEncoder.withIndent('  ').convert(backup));
    await SharePlus.instance.share(ShareParams(
      files: [XFile.fromData(bytes, name: name, mimeType: 'application/json')],
      fileNameOverrides: [name],
      subject: 'Backup do Lumen',
      text: 'Backup do Lumen (leituras, recitativos, orações e anotações).',
    ));
  }

  /// Abre o seletor de arquivos e restaura. `null` se o usuário cancelar.
  Future<BackupSummary?> pickAndRestore() async {
    final file = await pickFile(dialogTitle: 'Selecione o backup do Lumen (.json)');
    if (file == null) return null;
    return restore(utf8.decode(file.bytes));
  }

  /// Substitui os dados do usuário pelos do backup (transação única).
  ///
  /// Os dados atuais recebem exclusão lógica e os do backup entram como
  /// alterações pendentes: com uma conta conectada, a nuvem passa a refletir
  /// exatamente o backup na próxima sincronização.
  Future<BackupSummary> restore(String raw) async {
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      throw const BackupException('O arquivo não é um JSON válido.');
    }
    if (decoded is! Map<String, dynamic> || decoded['format'] != format) {
      throw const BackupException('Este arquivo não é um backup do Lumen.');
    }
    final fileVersion = decoded['version'] as int? ?? 0;
    if (fileVersion > version) {
      throw const BackupException('Backup criado por uma versão mais nova do app. Atualize o app.');
    }
    final data = fileVersion < 2 ? upgradeV1(decoded) : decoded;

    final now = DateTime.now();
    List<T> rows<T>(String key, T Function(Map<String, dynamic>) fromJson) => [
          for (final m in data[key] as List<dynamic>? ?? const [])
            fromJson({...m as Map<String, dynamic>, 'updatedAt': now.millisecondsSinceEpoch, 'isSynced': false}),
        ];

    final List<ReadingCycle> cycles;
    final List<ReadingLog> logs;
    final List<Recitative> recitatives;
    final List<PrayerRequest> prayers;
    final List<VerseNote> notes;
    final List<PlanEnrollment> plans;
    final List<AppSettingEntry> settings;
    try {
      cycles = rows('readingCycles', ReadingCycle.fromJson);
      logs = rows('readingLogs', ReadingLog.fromJson);
      recitatives = rows('recitatives', Recitative.fromJson);
      prayers = rows('prayerRequests', PrayerRequest.fromJson);
      notes = rows('verseNotes', VerseNote.fromJson);
      plans = rows('planEnrollments', PlanEnrollment.fromJson);
      settings = [
        for (final m in data['settings'] as List<dynamic>? ?? const [])
          if (!(m['key'] as String).startsWith(_syncSettingsPrefix)) AppSettingEntry.fromJson(m as Map<String, dynamic>),
      ];
    } on TypeError {
      throw const BackupException('O backup está incompleto ou corrompido.');
    }

    final List<TableInfo<Table, Object?>> userTables = [
      _db.readingLogs,
      _db.readingCycles,
      _db.recitatives,
      _db.prayerRequests,
      _db.verseNotes,
      _db.planEnrollments,
    ];
    await _db.transaction(() async {
      for (final t in userTables) {
        await _db.customUpdate(
          'UPDATE ${t.actualTableName} SET deleted_at = ?, updated_at = ?, is_synced = 0 WHERE deleted_at IS NULL',
          variables: [Variable.withDateTime(now), Variable.withDateTime(now)],
          updates: {t},
          updateKind: UpdateKind.update,
        );
      }
      await (_db.delete(_db.appSettingsEntries)..where((s) => s.key.like('$_syncSettingsPrefix%').not())).go();
      await _db.batch((b) {
        b.insertAll(_db.readingCycles, cycles, mode: InsertMode.insertOrReplace);
        b.insertAll(_db.readingLogs, logs, mode: InsertMode.insertOrReplace);
        b.insertAll(_db.recitatives, recitatives, mode: InsertMode.insertOrReplace);
        b.insertAll(_db.prayerRequests, prayers, mode: InsertMode.insertOrReplace);
        b.insertAll(_db.verseNotes, notes, mode: InsertMode.insertOrReplace);
        b.insertAll(_db.planEnrollments, plans, mode: InsertMode.insertOrReplace);
        b.insertAll(_db.appSettingsEntries, settings, mode: InsertMode.insertOrReplace);
      });
    });

    return BackupSummary(
      readings: logs.length,
      recitatives: recitatives.length,
      prayers: prayers.length,
      notes: notes.length,
    );
  }

  /// Converte um backup v1 (ids inteiros) para o formato v2 (UUID), mantendo
  /// o vínculo entre leituras e ciclos.
  static Map<String, dynamic> upgradeV1(Map<String, dynamic> v1) {
    List<Map<String, dynamic>> list(String key) =>
        [for (final m in v1[key] as List<dynamic>? ?? const []) Map<String, dynamic>.from(m as Map)];

    final cycleIds = <Object?, String>{};
    final cycles = [
      for (final c in list('readingCycles')) {...c, 'id': cycleIds.putIfAbsent(c['id'], newId)},
    ];
    final logs = <Map<String, dynamic>>[];
    for (final l in list('readingLogs')) {
      var cycleId = cycleIds[l['cycleId']];
      if (cycleId == null) {
        // Leitura de um ciclo ausente no arquivo: cria o ciclo para não perdê-la.
        cycleId = cycleIds.putIfAbsent(l['cycleId'], newId);
        cycles.add({'id': cycleId, 'startedAt': l['readAt'], 'endedAt': l['readAt']});
      }
      logs.add({...l, 'id': newId(), 'cycleId': cycleId});
    }
    List<Map<String, dynamic>> withNewIds(String key) => [for (final m in list(key)) {...m, 'id': newId()}];

    return {
      ...v1,
      'version': 2,
      'readingCycles': cycles,
      'readingLogs': logs,
      'recitatives': withNewIds('recitatives'),
      'prayerRequests': withNewIds('prayerRequests'),
      'verseNotes': withNewIds('verseNotes'),
      'planEnrollments': withNewIds('planEnrollments'),
    };
  }
}

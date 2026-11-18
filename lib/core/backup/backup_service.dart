import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../database/app_database.dart';

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
class BackupService {
  BackupService(this._db);

  /// Identificador do formato. Mantido do nome antigo do app para que backups antigos continuem válidos.
  static const String format = 'devocional-backup';
  static const int version = 1;

  final AppDatabase _db;

  Future<Map<String, Object?>> buildBackup() async => {
        'format': format,
        'version': version,
        'exportedAt': DateTime.now().toIso8601String(),
        'readingCycles': [for (final r in await _db.select(_db.readingCycles).get()) r.toJson()],
        'readingLogs': [for (final r in await _db.select(_db.readingLogs).get()) r.toJson()],
        'recitatives': [for (final r in await _db.select(_db.recitatives).get()) r.toJson()],
        'prayerRequests': [for (final r in await _db.select(_db.prayerRequests).get()) r.toJson()],
        'verseNotes': [for (final r in await _db.select(_db.verseNotes).get()) r.toJson()],
        'settings': [for (final r in await _db.select(_db.appSettingsEntries).get()) r.toJson()],
        'planEnrollments': [for (final r in await _db.select(_db.planEnrollments).get()) r.toJson()],
      };

  Future<File> exportToFile() async {
    final backup = await buildBackup();
    final dir = await getTemporaryDirectory();
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    final name = 'lumen-backup-${now.year}${two(now.month)}${two(now.day)}-${two(now.hour)}${two(now.minute)}.json';
    final file = File(p.join(dir.path, name));
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(backup));
    return file;
  }

  /// Gera o arquivo e abre a folha de compartilhamento do sistema.
  Future<void> shareBackup() async {
    final file = await exportToFile();
    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path, mimeType: 'application/json')],
      subject: 'Backup do Lumen',
      text: 'Backup do Lumen (leituras, recitativos, orações e anotações).',
    ));
  }

  /// Abre o seletor de arquivos e restaura. `null` se o usuário cancelar.
  Future<BackupSummary?> pickAndRestore() async {
    final file = await FilePicker.pickFile(dialogTitle: 'Selecione o backup do Lumen (.json)');
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    return restore(utf8.decode(bytes));
  }

  /// Substitui todos os dados do usuário pelos do backup (transação única).
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
    if ((decoded['version'] as int? ?? 0) > version) {
      throw const BackupException('Backup criado por uma versão mais nova do app. Atualize o app.');
    }

    List<T> rows<T>(String key, T Function(Map<String, dynamic>) fromJson) =>
        [for (final m in (decoded as Map<String, dynamic>)[key] as List<dynamic>? ?? const []) fromJson(m as Map<String, dynamic>)];

    final cycles = rows('readingCycles', ReadingCycle.fromJson);
    final logs = rows('readingLogs', ReadingLog.fromJson);
    final recitatives = rows('recitatives', Recitative.fromJson);
    final prayers = rows('prayerRequests', PrayerRequest.fromJson);
    final notes = rows('verseNotes', VerseNote.fromJson);
    final settings = rows('settings', AppSettingEntry.fromJson);
    final plans = rows('planEnrollments', PlanEnrollment.fromJson);

    await _db.transaction(() async {
      await _db.delete(_db.readingLogs).go();
      await _db.delete(_db.recitatives).go();
      await _db.delete(_db.prayerRequests).go();
      await _db.delete(_db.verseNotes).go();
      await _db.delete(_db.appSettingsEntries).go();
      await _db.delete(_db.planEnrollments).go();
      await _db.delete(_db.readingCycles).go();
      await _db.batch((b) {
        b.insertAll(_db.readingCycles, cycles);
        b.insertAll(_db.readingLogs, logs);
        b.insertAll(_db.recitatives, recitatives);
        b.insertAll(_db.prayerRequests, prayers);
        b.insertAll(_db.verseNotes, notes);
        b.insertAll(_db.appSettingsEntries, settings, mode: InsertMode.insertOrReplace);
        b.insertAll(_db.planEnrollments, plans);
      });
    });

    return BackupSummary(
      readings: logs.length,
      recitatives: recitatives.length,
      prayers: prayers.length,
      notes: notes.length,
    );
  }
}

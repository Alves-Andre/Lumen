import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/settings_dao.dart';
import '../../../core/database/daos/sync_dao.dart';
import 'sync_remote.dart';

/// Como uma tabela local (Drift) é espelhada numa tabela do Supabase.
///
/// A lógica de envio/recebimento fica aqui, dentro da classe genérica, para
/// que o tipo da linha ([D]) nunca precise ser conhecido por quem chama.
final class SyncTableSpec<D> {
  const SyncTableSpec({
    required this.remoteTable,
    required this.table,
    required this.toRemote,
    required this.fromRemote,
    required this.idOf,
    required this.updatedAtOf,
    this.ownerColumn = 'user_id',
  });

  final String remoteTable;
  final TableInfo<Table, D> table;

  /// Coluna que identifica o dono na nuvem (`id` no perfil).
  final String ownerColumn;
  final RemoteRow Function(D row) toRemote;

  /// Linha da nuvem → linha local já marcada como sincronizada.
  final Insertable<D> Function(RemoteRow row) fromRemote;
  final String Function(D row) idOf;
  final DateTime Function(D row) updatedAtOf;

  static const int pushBatchSize = 200;
  static const int pullPageSize = 500;

  String get cursorKey => '${SyncKeys.cursorPrefix}$remoteTable';

  /// Envia as alterações pendentes. Retorna quantas linhas subiram.
  Future<int> push(SyncDao dao, SyncRemote remote, String userId) async {
    var rows = await dao.pendingRows(table);
    if (ownerColumn == 'id') rows = [for (final r in rows) if (idOf(r) == userId) r];
    for (var i = 0; i < rows.length; i += pushBatchSize) {
      final chunk = rows.sublist(i, i + pushBatchSize > rows.length ? rows.length : i + pushBatchSize);
      await remote.upsert(remoteTable, [
        for (final r in chunk) {...toRemote(r), if (ownerColumn == 'user_id') 'user_id': userId},
      ]);
      await dao.markSynced(table, [for (final r in chunk) (id: idOf(r), updatedAt: updatedAtOf(r))]);
    }
    return rows.length;
  }

  /// Baixa o que mudou na nuvem desde o último cursor e mescla no banco local.
  /// Retorna quantas linhas foram gravadas localmente.
  Future<int> pull(SyncDao dao, SettingsDao settings, SyncRemote remote, String userId) async {
    var cursor = SyncCursor.parse(await settings.getValue(cursorKey));
    var applied = 0;
    while (true) {
      final page = await remote.fetchSince(
        remoteTable,
        ownerColumn: ownerColumn,
        userId: userId,
        after: cursor,
        limit: pullPageSize,
      );
      if (page.isEmpty) break;
      applied += await _merge(dao, page);
      cursor = SyncCursor.ofRow(page.last);
      await settings.setValue(cursorKey, cursor.serialize());
      if (page.length < pullPageSize) break;
    }
    return applied;
  }

  /// Last-Write-Wins: a versão da nuvem só é descartada quando existe uma
  /// alteração local ainda não enviada e não mais antiga que ela. No empate
  /// (o banco local guarda segundos) vence a pendência local, que é a edição
  /// feita depois da última sincronização deste aparelho.
  Future<int> _merge(SyncDao dao, List<RemoteRow> page) async {
    final local = await dao.localStates(table, [for (final r in page) r['id'] as String]);
    final accepted = <Insertable<D>>[];
    for (final row in page) {
      final state = local[row['id'] as String];
      final remoteUpdatedAt = parseRemoteDate(row['updated_at'])!;
      final keepLocal = state != null && !state.isSynced && !state.updatedAt.isBefore(remoteUpdatedAt);
      if (!keepLocal) accepted.add(fromRemote(row));
    }
    await dao.upsertAll(table, accepted);
    return accepted.length;
  }
}

/// Chaves (em `app_settings_entries`) usadas pela sincronização. O prefixo
/// `sync.` as mantém fora do backup: pertencem ao aparelho, não aos dados.
abstract final class SyncKeys {
  static const String prefix = 'sync.';
  static const String cursorPrefix = 'sync.cursor.';

  /// Conta à qual os dados locais pertencem.
  static const String ownerId = 'sync.ownerId';

  /// Momento da última sincronização concluída (ISO 8601).
  static const String lastSyncAt = 'sync.lastSyncAt';

  /// Usuário escolheu "Continuar sem conta".
  static const String guestMode = 'sync.guestMode';
}

String? remoteDate(DateTime? value) => value?.toUtc().toIso8601String();

DateTime? parseRemoteDate(Object? value) => value == null ? null : DateTime.parse(value as String).toLocal();

DateTime _date(Object? value) => parseRemoteDate(value)!;

/// Especificações de todas as tabelas sincronizadas, na ordem de envio.
List<SyncTableSpec<Object?>> buildSyncSpecs(AppDatabase db) => [
      SyncTableSpec<UserProfile>(
        remoteTable: 'profiles',
        table: db.userProfiles,
        ownerColumn: 'id',
        idOf: (r) => r.id,
        updatedAtOf: (r) => r.updatedAt,
        toRemote: (r) => {
          'id': r.id,
          'full_name': r.fullName,
          'age': r.age,
          'church_name': r.churchName,
          'created_at': remoteDate(r.createdAt),
          'updated_at': remoteDate(r.updatedAt),
        },
        fromRemote: (m) => UserProfilesCompanion.insert(
          id: Value(m['id'] as String),
          fullName: m['full_name'] as String,
          age: (m['age'] as num?)?.toInt() ?? 0,
          churchName: m['church_name'] as String,
          createdAt: Value(_date(m['created_at'])),
          updatedAt: Value(_date(m['updated_at'])),
          isSynced: const Value(true),
          deletedAt: const Value(null),
        ),
      ),
      SyncTableSpec<ReadingCycle>(
        remoteTable: 'reading_cycles',
        table: db.readingCycles,
        idOf: (r) => r.id,
        updatedAtOf: (r) => r.updatedAt,
        toRemote: (r) => {
          'id': r.id,
          'started_at': remoteDate(r.startedAt),
          'ended_at': remoteDate(r.endedAt),
          'updated_at': remoteDate(r.updatedAt),
          'deleted_at': remoteDate(r.deletedAt),
        },
        fromRemote: (m) => ReadingCyclesCompanion.insert(
          id: Value(m['id'] as String),
          startedAt: _date(m['started_at']),
          endedAt: Value(parseRemoteDate(m['ended_at'])),
          updatedAt: Value(_date(m['updated_at'])),
          deletedAt: Value(parseRemoteDate(m['deleted_at'])),
          isSynced: const Value(true),
        ),
      ),
      SyncTableSpec<ReadingLog>(
        remoteTable: 'reading_logs',
        table: db.readingLogs,
        idOf: (r) => r.id,
        updatedAtOf: (r) => r.updatedAt,
        toRemote: (r) => {
          'id': r.id,
          'book_id': r.bookId,
          'chapter': r.chapter,
          'read_at': remoteDate(r.readAt),
          'source': r.source.value,
          'cycle_id': r.cycleId,
          'updated_at': remoteDate(r.updatedAt),
          'deleted_at': remoteDate(r.deletedAt),
        },
        fromRemote: (m) => ReadingLogsCompanion.insert(
          id: Value(m['id'] as String),
          bookId: (m['book_id'] as num).toInt(),
          chapter: (m['chapter'] as num).toInt(),
          readAt: _date(m['read_at']),
          source: ReadingSource.fromValue(m['source'] as String),
          cycleId: m['cycle_id'] as String,
          updatedAt: Value(_date(m['updated_at'])),
          deletedAt: Value(parseRemoteDate(m['deleted_at'])),
          isSynced: const Value(true),
        ),
      ),
      SyncTableSpec<Recitative>(
        remoteTable: 'recitatives',
        table: db.recitatives,
        idOf: (r) => r.id,
        updatedAtOf: (r) => r.updatedAt,
        toRemote: (r) => {
          'id': r.id,
          'book_id': r.bookId,
          'chapter': r.chapter,
          'verse_start': r.verseStart,
          'verse_end': r.verseEnd,
          'verse_text_snapshot': r.verseTextSnapshot,
          'service_date': remoteDate(r.serviceDate),
          'congregation': r.congregation,
          'notes': r.notes,
          'status': r.status.name,
          'created_at': remoteDate(r.createdAt),
          'updated_at': remoteDate(r.updatedAt),
          'deleted_at': remoteDate(r.deletedAt),
        },
        fromRemote: (m) => RecitativesCompanion.insert(
          id: Value(m['id'] as String),
          bookId: (m['book_id'] as num).toInt(),
          chapter: (m['chapter'] as num).toInt(),
          verseStart: (m['verse_start'] as num).toInt(),
          verseEnd: Value((m['verse_end'] as num?)?.toInt()),
          verseTextSnapshot: m['verse_text_snapshot'] as String,
          serviceDate: _date(m['service_date']),
          congregation: Value(m['congregation'] as String?),
          notes: Value(m['notes'] as String?),
          status: RecitativeStatus.values.asNameMap()[m['status']] ?? RecitativeStatus.pending,
          createdAt: Value(_date(m['created_at'])),
          updatedAt: Value(_date(m['updated_at'])),
          deletedAt: Value(parseRemoteDate(m['deleted_at'])),
          isSynced: const Value(true),
        ),
      ),
      SyncTableSpec<PrayerRequest>(
        remoteTable: 'prayer_requests',
        table: db.prayerRequests,
        idOf: (r) => r.id,
        updatedAtOf: (r) => r.updatedAt,
        toRemote: (r) => {
          'id': r.id,
          'title': r.title,
          'description': r.description,
          'category': r.category.name,
          'status': r.status.name,
          'pray_count': r.prayCount,
          'last_prayed_at': remoteDate(r.lastPrayedAt),
          'answered_at': remoteDate(r.answeredAt),
          'answer_testimony': r.answerTestimony,
          'created_at': remoteDate(r.createdAt),
          'updated_at': remoteDate(r.updatedAt),
          'deleted_at': remoteDate(r.deletedAt),
        },
        fromRemote: (m) => PrayerRequestsCompanion.insert(
          id: Value(m['id'] as String),
          title: m['title'] as String,
          description: Value(m['description'] as String?),
          category: PrayerCategory.values.asNameMap()[m['category']] ?? PrayerCategory.personal,
          status: PrayerStatus.values.asNameMap()[m['status']] ?? PrayerStatus.active,
          prayCount: Value((m['pray_count'] as num?)?.toInt() ?? 0),
          lastPrayedAt: Value(parseRemoteDate(m['last_prayed_at'])),
          answeredAt: Value(parseRemoteDate(m['answered_at'])),
          answerTestimony: Value(m['answer_testimony'] as String?),
          createdAt: Value(_date(m['created_at'])),
          updatedAt: Value(_date(m['updated_at'])),
          deletedAt: Value(parseRemoteDate(m['deleted_at'])),
          isSynced: const Value(true),
        ),
      ),
      SyncTableSpec<VerseNote>(
        remoteTable: 'verse_notes',
        table: db.verseNotes,
        idOf: (r) => r.id,
        updatedAtOf: (r) => r.updatedAt,
        toRemote: (r) => {
          'id': r.id,
          'book_id': r.bookId,
          'chapter': r.chapter,
          'verse': r.verse,
          'content': r.content,
          'created_at': remoteDate(r.createdAt),
          'updated_at': remoteDate(r.updatedAt),
          'deleted_at': remoteDate(r.deletedAt),
        },
        fromRemote: (m) => VerseNotesCompanion.insert(
          id: Value(m['id'] as String),
          bookId: (m['book_id'] as num).toInt(),
          chapter: (m['chapter'] as num).toInt(),
          verse: Value((m['verse'] as num?)?.toInt()),
          content: m['content'] as String,
          createdAt: Value(_date(m['created_at'])),
          updatedAt: Value(_date(m['updated_at'])),
          deletedAt: Value(parseRemoteDate(m['deleted_at'])),
          isSynced: const Value(true),
        ),
      ),
      SyncTableSpec<PlanEnrollment>(
        remoteTable: 'plan_enrollments',
        table: db.planEnrollments,
        idOf: (r) => r.id,
        updatedAtOf: (r) => r.updatedAt,
        toRemote: (r) => {
          'id': r.id,
          'plan_id': r.planId,
          'started_at': remoteDate(r.startedAt),
          'ended_at': remoteDate(r.endedAt),
          'completed': r.completed,
          'updated_at': remoteDate(r.updatedAt),
          'deleted_at': remoteDate(r.deletedAt),
        },
        fromRemote: (m) => PlanEnrollmentsCompanion.insert(
          id: Value(m['id'] as String),
          planId: m['plan_id'] as String,
          startedAt: _date(m['started_at']),
          endedAt: Value(parseRemoteDate(m['ended_at'])),
          completed: Value(m['completed'] as bool? ?? false),
          updatedAt: Value(_date(m['updated_at'])),
          deletedAt: Value(parseRemoteDate(m['deleted_at'])),
          isSynced: const Value(true),
        ),
      ),
    ];

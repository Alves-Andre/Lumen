import 'package:drift/drift.dart';

import 'connection/database_connection.dart';
import 'converters.dart';
import 'daos/bible_dao.dart';
import 'daos/notes_dao.dart';
import 'daos/plans_dao.dart';
import 'daos/prayer_dao.dart';
import 'daos/reading_dao.dart';
import 'daos/recitatives_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/sync_dao.dart';
import 'enums.dart';
import 'tables.dart';

export 'enums.dart';
export 'models.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Books,
    Verses,
    ReadingCycles,
    ReadingLogs,
    Recitatives,
    PrayerRequests,
    VerseNotes,
    AppSettingsEntries,
    PlanEnrollments,
    UserProfiles,
  ],
  daos: [
    BibleDao,
    ReadingDao,
    RecitativesDao,
    PrayerDao,
    NotesDao,
    SettingsDao,
    PlansDao,
    SyncDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Para testes: `AppDatabase.forTesting(NativeDatabase.memory())`.
  AppDatabase.forTesting(super.executor);

  static const String fileName = 'devocional';

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await createSearchIndex();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.createTable(appSettingsEntries);
          if (from < 3) {
            // Versículos existentes são da ARC (única versão até a v2).
            await customStatement('DROP INDEX IF EXISTS idx_verses_book_chapter_verse');
            await m.addColumn(verses, verses.translation);
            await m.createIndex(idxVersesRef);
          }
          if (from < 4) {
            // Criada já no formato da v5 (UUID + colunas de sincronização).
            await m.createTable(planEnrollments);
            await createSearchIndex();
            await rebuildSearchIndex();
          }
          if (from < 5) await _migrateToSyncSchema(m, copyPlans: from >= 4);
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Índice de busca (FTS5) sobre `verses.text`, sem diferenciar acentos nem
  /// maiúsculas: "fe" encontra "fé", "senhor" encontra "SENHOR". Tabela de
  /// conteúdo externo: guarda só o índice, o texto continua em `verses`.
  Future<void> createSearchIndex() => customStatement(
        "CREATE VIRTUAL TABLE IF NOT EXISTS verses_fts USING fts5(text, content='verses', "
        "content_rowid='id', tokenize='unicode61 remove_diacritics 2')",
      );

  /// Reconstrói o índice a partir de `verses` (após carregar uma versão).
  Future<void> rebuildSearchIndex() => customStatement("INSERT INTO verses_fts(verses_fts) VALUES('rebuild')");

  static QueryExecutor _openConnection() => openAppDatabase(fileName);

  /// v4 → v5: ids inteiros viram UUID e as tabelas do usuário ganham
  /// `updated_at`, `is_synced` e `deleted_at`. Tudo que já existe fica marcado
  /// como não sincronizado, para subir à nuvem no primeiro login.
  Future<void> _migrateToSyncSchema(Migrator m, {required bool copyPlans}) async {
    // UUID v4 gerado pelo próprio SQLite (um por linha).
    const uuid = "(lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || "
        "substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', 1 + (abs(random()) % 4), 1) || "
        "substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))";
    final tables = [
      'reading_cycles',
      'reading_logs',
      'recitatives',
      'prayer_requests',
      'verse_notes',
      if (copyPlans) 'plan_enrollments',
    ];
    // Os índices acompanham a tabela renomeada; apagá-los libera os nomes.
    for (final index in const [
      'idx_reading_logs_read_at',
      'idx_reading_logs_book_chapter',
      'idx_reading_logs_cycle',
      'idx_recitatives_service_date',
      'idx_recitatives_status_date',
      'idx_prayer_requests_status',
      'idx_verse_notes_book_chapter',
    ]) {
      await customStatement('DROP INDEX IF EXISTS $index');
    }
    for (final table in tables) {
      await customStatement('ALTER TABLE $table RENAME TO _v4_$table');
    }

    await m.createTable(readingCycles);
    await m.createTable(readingLogs);
    await m.createTable(recitatives);
    await m.createTable(prayerRequests);
    await m.createTable(verseNotes);
    if (copyPlans) await m.createTable(planEnrollments);
    await m.createTable(userProfiles);
    for (final index in [
      idxReadingLogsReadAt,
      idxReadingLogsBookChapter,
      idxReadingLogsCycle,
      idxRecitativesServiceDate,
      idxRecitativesStatusDate,
      idxPrayerRequestsStatus,
      idxVerseNotesBookChapter,
    ]) {
      await m.createIndex(index);
    }

    await customStatement('CREATE TEMP TABLE _cycle_map AS SELECT id AS old_id, $uuid AS new_id FROM _v4_reading_cycles');
    await customStatement(
      'INSERT INTO reading_cycles (id, started_at, ended_at, updated_at, is_synced) '
      'SELECT m.new_id, c.started_at, c.ended_at, COALESCE(c.ended_at, c.started_at), 0 '
      'FROM _v4_reading_cycles c JOIN _cycle_map m ON m.old_id = c.id',
    );
    await customStatement(
      'INSERT INTO reading_logs (id, book_id, chapter, read_at, source, cycle_id, updated_at, is_synced) '
      'SELECT $uuid, l.book_id, l.chapter, l.read_at, l.source, m.new_id, l.read_at, 0 '
      'FROM _v4_reading_logs l JOIN _cycle_map m ON m.old_id = l.cycle_id',
    );
    await customStatement(
      'INSERT INTO recitatives (id, book_id, chapter, verse_start, verse_end, verse_text_snapshot, service_date, '
      'congregation, notes, status, created_at, updated_at, is_synced) '
      'SELECT $uuid, book_id, chapter, verse_start, verse_end, verse_text_snapshot, service_date, '
      'congregation, notes, status, created_at, created_at, 0 FROM _v4_recitatives',
    );
    await customStatement(
      'INSERT INTO prayer_requests (id, title, description, category, status, pray_count, last_prayed_at, '
      'answered_at, answer_testimony, created_at, updated_at, is_synced) '
      'SELECT $uuid, title, description, category, status, pray_count, last_prayed_at, answered_at, '
      'answer_testimony, created_at, '
      'MAX(created_at, COALESCE(last_prayed_at, created_at), COALESCE(answered_at, created_at)), 0 '
      'FROM _v4_prayer_requests',
    );
    await customStatement(
      'INSERT INTO verse_notes (id, book_id, chapter, verse, content, created_at, updated_at, is_synced) '
      'SELECT $uuid, book_id, chapter, verse, content, created_at, created_at, 0 FROM _v4_verse_notes',
    );
    if (copyPlans) {
      await customStatement(
        'INSERT INTO plan_enrollments (id, plan_id, started_at, ended_at, completed, updated_at, is_synced) '
        'SELECT $uuid, plan_id, started_at, ended_at, completed, COALESCE(ended_at, started_at), 0 '
        'FROM _v4_plan_enrollments',
      );
    }

    await customStatement('DROP TABLE _cycle_map');
    // Registros antes dos ciclos (o antigo reading_logs referenciava reading_cycles).
    for (final table in tables.reversed) {
      await customStatement('DROP TABLE _v4_$table');
    }
  }
}

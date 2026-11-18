import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'converters.dart';
import 'daos/bible_dao.dart';
import 'daos/notes_dao.dart';
import 'daos/plans_dao.dart';
import 'daos/prayer_dao.dart';
import 'daos/reading_dao.dart';
import 'daos/recitatives_dao.dart';
import 'daos/settings_dao.dart';
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
  ],
  daos: [
    BibleDao,
    ReadingDao,
    RecitativesDao,
    PrayerDao,
    NotesDao,
    SettingsDao,
    PlansDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Para testes: `AppDatabase.forTesting(NativeDatabase.memory())`.
  AppDatabase.forTesting(super.executor);

  static const String fileName = 'devocional';

  @override
  int get schemaVersion => 4;

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
            await m.createTable(planEnrollments);
            await createSearchIndex();
            await rebuildSearchIndex();
          }
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

  static QueryExecutor _openConnection() => driftDatabase(name: fileName);
}

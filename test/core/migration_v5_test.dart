import 'dart:convert';

import 'package:devocional/core/backup/backup_service.dart';
import 'package:devocional/core/database/app_database.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Esquema da versão 4 (app 1.1, ids inteiros), como o drift o criava.
const _v4Schema = [
  'CREATE TABLE books (id INTEGER NOT NULL PRIMARY KEY, name TEXT NOT NULL, abbrev TEXT NOT NULL, '
      'testament TEXT NOT NULL, chapters_count INTEGER NOT NULL)',
  "CREATE TABLE verses (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, translation TEXT NOT NULL DEFAULT 'arc', "
      'book_id INTEGER NOT NULL REFERENCES books (id), chapter INTEGER NOT NULL, verse INTEGER NOT NULL, text TEXT NOT NULL)',
  'CREATE UNIQUE INDEX idx_verses_ref ON verses (translation, book_id, chapter, verse)',
  'CREATE TABLE reading_cycles (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, started_at INTEGER NOT NULL, ended_at INTEGER NULL)',
  'CREATE TABLE reading_logs (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, book_id INTEGER NOT NULL REFERENCES books (id), '
      'chapter INTEGER NOT NULL, read_at INTEGER NOT NULL, source TEXT NOT NULL, '
      'cycle_id INTEGER NOT NULL REFERENCES reading_cycles (id))',
  'CREATE INDEX idx_reading_logs_read_at ON reading_logs (read_at)',
  'CREATE INDEX idx_reading_logs_book_chapter ON reading_logs (book_id, chapter)',
  'CREATE INDEX idx_reading_logs_cycle ON reading_logs (cycle_id, book_id, chapter)',
  'CREATE TABLE recitatives (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, book_id INTEGER NOT NULL REFERENCES books (id), '
      'chapter INTEGER NOT NULL, verse_start INTEGER NOT NULL, verse_end INTEGER NULL, verse_text_snapshot TEXT NOT NULL, '
      'service_date INTEGER NOT NULL, congregation TEXT NULL, notes TEXT NULL, status TEXT NOT NULL, created_at INTEGER NOT NULL)',
  'CREATE INDEX idx_recitatives_service_date ON recitatives (service_date)',
  'CREATE INDEX idx_recitatives_status_date ON recitatives (status, service_date)',
  'CREATE TABLE prayer_requests (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, description TEXT NULL, '
      'category TEXT NOT NULL, status TEXT NOT NULL, pray_count INTEGER NOT NULL DEFAULT 0, last_prayed_at INTEGER NULL, '
      'answered_at INTEGER NULL, answer_testimony TEXT NULL, created_at INTEGER NOT NULL)',
  'CREATE INDEX idx_prayer_requests_status ON prayer_requests (status)',
  'CREATE TABLE verse_notes (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, book_id INTEGER NOT NULL REFERENCES books (id), '
      'chapter INTEGER NOT NULL, verse INTEGER NULL, content TEXT NOT NULL, created_at INTEGER NOT NULL)',
  'CREATE INDEX idx_verse_notes_book_chapter ON verse_notes (book_id, chapter)',
  'CREATE TABLE app_settings_entries (key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL)',
  'CREATE TABLE plan_enrollments (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, plan_id TEXT NOT NULL, '
      'started_at INTEGER NOT NULL, ended_at INTEGER NULL, completed INTEGER NOT NULL DEFAULT 0 CHECK (completed IN (0, 1)))',
  "CREATE VIRTUAL TABLE verses_fts USING fts5(text, content='verses', content_rowid='id', "
      "tokenize='unicode61 remove_diacritics 2')",
];

int _s(DateTime d) => d.millisecondsSinceEpoch ~/ 1000;

final _uuidPattern = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$');

void main() {
  test('migração v4 → v5 converte ids em UUID e preserva todos os dados', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory(setup: (raw) {
      for (final sql in _v4Schema) {
        raw.execute(sql);
      }
      raw.execute("INSERT INTO books VALUES (45, 'Romanos', 'Rm', 'NT', 16)");
      raw.execute("INSERT INTO verses (book_id, chapter, verse, text) VALUES (45, 8, 1, 'Verso 1.')");
      raw.execute('INSERT INTO reading_cycles VALUES (1, ${_s(DateTime(2025, 1, 1))}, ${_s(DateTime(2025, 12, 31))})');
      raw.execute('INSERT INTO reading_cycles VALUES (2, ${_s(DateTime(2026, 1, 1))}, NULL)');
      raw.execute("INSERT INTO reading_logs VALUES (1, 45, 1, ${_s(DateTime(2025, 6, 1))}, 'app', 1)");
      raw.execute("INSERT INTO reading_logs VALUES (2, 45, 8, ${_s(DateTime(2026, 11, 1, 8))}, 'physical_bible', 2)");
      raw.execute("INSERT INTO reading_logs VALUES (3, 45, 9, ${_s(DateTime(2026, 11, 2, 8))}, 'app', 2)");
      raw.execute("INSERT INTO recitatives VALUES (1, 45, 8, 1, NULL, 'Verso 1.', ${_s(DateTime(2026, 11, 22))}, "
          "'Central', NULL, 'pending', ${_s(DateTime(2026, 11, 1))})");
      raw.execute("INSERT INTO prayer_requests VALUES (1, 'Família', NULL, 'Família', 'active', 3, "
          '${_s(DateTime(2026, 11, 20))}, NULL, NULL, ${_s(DateTime(2026, 11, 1))})');
      raw.execute("INSERT INTO verse_notes VALUES (1, 45, 8, 1, 'Nenhuma condenação', ${_s(DateTime(2026, 11, 1))})");
      raw.execute("INSERT INTO plan_enrollments VALUES (1, 'nt-90-dias', ${_s(DateTime(2026, 11, 1))}, NULL, 0)");
      raw.execute("INSERT INTO app_settings_entries VALUES ('user_name', 'André')");
      raw.execute('PRAGMA user_version = 4');
    }));
    addTearDown(db.close);

    final logs = await db.select(db.readingLogs).get();
    expect(logs, hasLength(3));
    expect(logs.every((l) => _uuidPattern.hasMatch(l.id)), isTrue);
    expect(logs.map((l) => l.id).toSet(), hasLength(3));

    final active = await db.readingDao.getActiveCycle();
    expect(active!.startedAt, DateTime(2026, 1, 1));
    expect(await db.readingDao.countUniqueChaptersInCycle(active.id), 2, reason: 'leituras seguem no ciclo certo');
    expect((await db.readingDao.watchCycles().first), hasLength(2));
    expect(logs.firstWhere((l) => l.chapter == 8).source, ReadingSource.physicalBible);

    final rec = (await db.recitativesDao.getAll()).single.recitative;
    expect(rec.congregation, 'Central');
    expect(_uuidPattern.hasMatch(rec.id), isTrue);
    final prayer = (await db.prayerDao.watchActive().first).single;
    expect(prayer.prayCount, 3);
    expect(prayer.updatedAt, DateTime(2026, 11, 20), reason: 'updated_at = alteração mais recente conhecida');
    expect((await db.notesDao.watchAll().first).single.reference, 'Romanos 8:1');
    expect((await db.plansDao.watchActive().first)!.planId, 'nt-90-dias');
    expect(await db.settingsDao.getValue('user_name'), 'André');
    // v6: as traduções que já tinham texto passam a constar como instaladas.
    expect(await db.bibleDao.getInstalled(), [BibleTranslation.arc]);

    // Tudo fica pendente para subir à nuvem no primeiro login (2 ciclos + 3 leituras + 1 + 1 + 1 + 1).
    expect(await db.syncDao.countPending(), 9);
    // Novas escritas funcionam no esquema novo.
    expect(await db.readingDao.logChapter(bookId: 45, chapter: 10, readAt: DateTime(2026, 11, 3)), isTrue);
    expect(await db.bibleDao.search(BibleTranslation.arc, 'verso').then((r) => r.total), 0,
        reason: 'índice de busca intacto (vazio: não foi reconstruído neste banco de teste)');
  });

  test('backup v1 (ids inteiros) é importado no formato novo', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await db.into(db.books).insert(BooksCompanion.insert(id: const Value(45), name: 'Romanos', abbrev: 'Rm', testament: 'NT', chaptersCount: 16));

    int ms(DateTime d) => d.millisecondsSinceEpoch;
    final v1 = {
      'format': 'devocional-backup',
      'version': 1,
      'readingCycles': [
        {'id': 1, 'startedAt': ms(DateTime(2026, 1, 1)), 'endedAt': null},
      ],
      'readingLogs': [
        {'id': 1, 'bookId': 45, 'chapter': 8, 'readAt': ms(DateTime(2026, 11, 1)), 'source': 'app', 'cycleId': 1},
        {'id': 2, 'bookId': 45, 'chapter': 9, 'readAt': ms(DateTime(2026, 11, 2)), 'source': 'physical_bible', 'cycleId': 1},
        // Ciclo ausente no arquivo: a leitura não pode se perder.
        {'id': 3, 'bookId': 45, 'chapter': 1, 'readAt': ms(DateTime(2024, 1, 1)), 'source': 'app', 'cycleId': 99},
      ],
      'recitatives': [
        {
          'id': 7, 'bookId': 45, 'chapter': 8, 'verseStart': 1, 'verseEnd': null, 'verseTextSnapshot': 'Verso 1.',
          'serviceDate': ms(DateTime(2026, 11, 22)), 'congregation': null, 'notes': null, 'status': 'recited',
          'createdAt': ms(DateTime(2026, 11, 1)),
        },
      ],
      'prayerRequests': [
        {
          'id': 3, 'title': 'Igreja', 'description': null, 'category': 'Igreja', 'status': 'active', 'prayCount': 2,
          'lastPrayedAt': null, 'answeredAt': null, 'answerTestimony': null, 'createdAt': ms(DateTime(2026, 11, 1)),
        },
      ],
      'verseNotes': [
        {'id': 4, 'bookId': 45, 'chapter': 8, 'verse': null, 'content': 'Nota', 'createdAt': ms(DateTime(2026, 11, 1))},
      ],
      'settings': [
        {'key': 'user_name', 'value': 'André'},
      ],
      'planEnrollments': [
        {'id': 1, 'planId': 'nt-90-dias', 'startedAt': ms(DateTime(2026, 11, 1)), 'endedAt': null, 'completed': false},
      ],
    };

    final summary = await BackupService(db).restore(jsonEncode(v1));
    expect(summary.readings, 3);
    final active = await db.readingDao.getActiveCycle();
    expect(await db.readingDao.countUniqueChaptersInCycle(active!.id), 2);
    expect(await db.readingDao.getAllReadDates(), hasLength(3));
    expect((await db.recitativesDao.getAll()).single.recitative.status, RecitativeStatus.recited);
    expect((await db.prayerDao.watchActive().first).single.category, PrayerCategory.church);
    expect(await db.settingsDao.getValue('user_name'), 'André');
    expect(await db.syncDao.countPending(), greaterThan(0), reason: 'restauração sobe para a nuvem');
  });

  test('restaurar backup substitui os dados atuais com exclusão lógica (sincronizável)', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await db.into(db.books).insert(BooksCompanion.insert(id: const Value(45), name: 'Romanos', abbrev: 'Rm', testament: 'NT', chaptersCount: 16));
    final keep = await db.notesDao.createNote(bookId: 45, chapter: 8, content: 'No backup');
    final raw = jsonEncode(await BackupService(db).buildBackup());
    final gone = await db.notesDao.createNote(bookId: 45, chapter: 8, content: 'Depois do backup');
    await db.settingsDao.setValue('sync.ownerId', 'conta');

    await BackupService(db).restore(raw);
    final visible = await db.notesDao.watchAll().first;
    expect(visible.map((n) => n.note.id), [keep]);
    final deleted = await (db.select(db.verseNotes)..where((n) => n.id.equals(gone))).getSingle();
    expect(deleted.deletedAt, isNotNull);
    expect(deleted.isSynced, isFalse);
    expect(await db.settingsDao.getValue('sync.ownerId'), 'conta', reason: 'estado da sincronização é do aparelho');
  });
}

import 'dart:convert';

import 'package:devocional/core/backup/backup_service.dart';
import 'package:devocional/core/database/app_database.dart';
import 'package:devocional/core/settings/app_settings.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _seedMinimalBible(AppDatabase db) async {
  await db.batch((b) {
    b.insert(db.books, const BooksCompanion(
      id: Value(45),
      name: Value('Romanos'),
      abbrev: Value('Rm'),
      testament: Value('NT'),
      chaptersCount: Value(16),
    ));
    b.insertAll(db.verses, [
      for (var v = 1; v <= 3; v++)
        VersesCompanion(bookId: const Value(45), chapter: const Value(8), verse: Value(v), verseText: Value('Verso $v.')),
    ]);
  });
}

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await _seedMinimalBible(db);
  });

  tearDown(() => db.close());

  test('leitura no mesmo dia não duplica; releitura em outro dia conta como registro', () async {
    final day = DateTime(2026, 11, 18, 9);
    expect(await db.readingDao.logChapter(bookId: 45, chapter: 8, readAt: day), isTrue);
    expect(await db.readingDao.logChapter(bookId: 45, chapter: 8, readAt: day.add(const Duration(hours: 5))), isFalse);
    expect(await db.readingDao.logChapter(bookId: 45, chapter: 8, readAt: day.add(const Duration(days: 1))), isTrue);
    final cycle = await db.readingDao.getOrCreateActiveCycle();
    expect(await db.readingDao.countUniqueChaptersInCycle(cycle.id), 1);
  });

  test('novo ciclo zera a contagem sem apagar o histórico', () async {
    await db.readingDao.logChapter(bookId: 45, chapter: 8, readAt: DateTime(2026, 11, 1));
    final next = await db.readingDao.startNewCycle();
    expect(await db.readingDao.countUniqueChaptersInCycle(next.id), 0);
    expect(await db.readingDao.getAllReadDates(), hasLength(1));
  });

  test('ARC e NVI convivem; recitativo usa sempre a ARC', () async {
    await db.batch((b) => b.insertAll(db.verses, [
          for (var v = 1; v <= 4; v++)
            VersesCompanion(
              translation: const Value(BibleTranslation.nvi),
              bookId: const Value(45),
              chapter: const Value(8),
              verse: Value(v),
              verseText: Value('NVI $v.'),
            ),
        ]));
    expect(await db.bibleDao.isSeeded(BibleTranslation.nvi), isFalse); // livros incompletos neste teste
    expect((await db.bibleDao.getChapter(BibleTranslation.arc, 45, 8)).length, 3);
    expect((await db.bibleDao.getChapter(BibleTranslation.nvi, 45, 8)).length, 4);
    expect(await db.bibleDao.getPassageText(BibleTranslation.nvi, 45, 8, 1), 'NVI 1.');
    final id = await db.recitativesDao.createRecitative(
      bookId: 45,
      chapter: 8,
      verseStart: 1,
      serviceDate: DateTime(2026, 11, 22),
    );
    expect((await db.recitativesDao.getById(id))!.recitative.verseTextSnapshot, 'Verso 1.');
  });

  test('busca ignora acentos e maiúsculas, aceita prefixo e filtra a versão', () async {
    await db.batch((b) => b.insertAll(db.verses, [
          VersesCompanion(
            translation: const Value(BibleTranslation.arc),
            bookId: const Value(45),
            chapter: const Value(9),
            verse: const Value(1),
            verseText: const Value('O justo viverá da fé; o SENHOR é o meu pastor.'),
          ),
          VersesCompanion(
            translation: const Value(BibleTranslation.nvi),
            bookId: const Value(45),
            chapter: const Value(9),
            verse: const Value(1),
            verseText: const Value('O justo viverá pela fé.'),
          ),
        ]));
    await db.rebuildSearchIndex();

    final fe = await db.bibleDao.search(BibleTranslation.arc, 'FE');
    expect(fe.total, 1);
    expect(fe.hits.single.reference, 'Romanos 9:1');
    expect(fe.hits.single.highlighted, contains('${SearchHit.markStart}fé${SearchHit.markEnd}'));

    expect((await db.bibleDao.search(BibleTranslation.arc, 'senhor pastor')).total, 1);
    expect((await db.bibleDao.search(BibleTranslation.arc, 'past')).total, 1); // prefixo
    expect((await db.bibleDao.search(BibleTranslation.arc, 'senhor ovelha')).total, 0); // todas as palavras
    expect((await db.bibleDao.search(BibleTranslation.nvi, 'pela')).total, 1);
    expect((await db.bibleDao.search(BibleTranslation.arc, 'pela')).total, 0);
    expect((await db.bibleDao.search(BibleTranslation.arc, '  "*)( ')).total, 0); // só pontuação
  });

  test('inscrição em plano: iniciar outro encerra o anterior', () async {
    final first = await db.plansDao.start('nt-90-dias', at: DateTime(2026, 11, 1));
    final second = await db.plansDao.start('evangelhos-30-dias', at: DateTime(2026, 11, 2));
    final active = await db.plansDao.watchActive().first;
    expect(active!.id, second);
    final old = await (db.select(db.planEnrollments)..where((p) => p.id.equals(first))).getSingle();
    expect(old.endedAt, isNotNull);
    expect(old.completed, isFalse);
  });

  test('capítulos lidos desde uma data (base do progresso do plano)', () async {
    await db.readingDao.logChapter(bookId: 45, chapter: 8, readAt: DateTime(2026, 11, 1));
    await db.readingDao.logChapter(bookId: 45, chapter: 9, readAt: DateTime(2026, 11, 5));
    expect(await db.readingDao.getChaptersReadSince(DateTime(2026, 11, 3)), {(bookId: 45, chapter: 9)});
  });

  test('recitativo puxa o texto da ARC automaticamente', () async {
    final id = await db.recitativesDao.createRecitative(
      bookId: 45,
      chapter: 8,
      verseStart: 1,
      verseEnd: 2,
      serviceDate: DateTime(2026, 11, 22),
    );
    final r = await db.recitativesDao.getById(id);
    expect(r!.recitative.verseTextSnapshot, 'Verso 1. Verso 2.');
    expect(r.reference, 'Romanos 8:1-2');
  });

  test('dias com leitura e com devocional alimentam o calendário da ofensiva', () async {
    await db.readingDao.logChapter(bookId: 45, chapter: 8, readAt: DateTime(2026, 11, 17, 22, 30));
    await db.readingDao.logChapter(bookId: 45, chapter: 9, readAt: DateTime(2026, 11, 18, 7));
    await db.into(db.verseNotes).insert(VerseNotesCompanion.insert(
      bookId: 45,
      chapter: 8,
      verse: const Value(1),
      content: 'Nenhuma condenação há',
      createdAt: Value(DateTime(2026, 11, 18, 7, 15)),
    ));
    expect(await db.readingDao.watchReadDays().first, {DateTime(2026, 11, 17), DateTime(2026, 11, 18)});
    expect(await db.notesDao.watchNoteDays().first, {DateTime(2026, 11, 18)});
    final notes = await db.notesDao.watchOnDay(DateTime(2026, 11, 18)).first;
    expect(notes.single.reference, 'Romanos 8:1');
    expect(await db.notesDao.watchOnDay(DateTime(2026, 11, 17)).first, isEmpty);
  });

  test('"Orei hoje" conta uma vez por dia', () async {
    final id = await db.prayerDao.createRequest(title: 'Família', category: PrayerCategory.family);
    final now = DateTime(2026, 11, 18, 8);
    expect(await db.prayerDao.registerPrayer(id, at: now), isTrue);
    expect(await db.prayerDao.registerPrayer(id, at: now.add(const Duration(hours: 3))), isFalse);
    expect(await db.prayerDao.registerPrayer(id, at: now.add(const Duration(days: 1))), isTrue);
  });

  test('configurações persistem e são lidas com valores padrão', () async {
    expect(AppSettings.fromMap(await db.settingsDao.getAll()).graceEnabled, isTrue);
    await db.settingsDao.setValue(AppSettings.kGraceEnabled, 'false');
    await db.settingsDao.setValue(AppSettings.kReaderTheme, ReaderTheme.sepia.name);
    final s = AppSettings.fromMap(await db.settingsDao.getAll());
    expect(s.graceEnabled, isFalse);
    expect(s.readerTheme, ReaderTheme.sepia);
  });

  test('backup exporta e restaura todos os dados do usuário', () async {
    await db.readingDao.logChapter(
      bookId: 45,
      chapter: 8,
      readAt: DateTime(2026, 11, 18, 9),
      source: ReadingSource.physicalBible,
    );
    await db.recitativesDao.createRecitative(bookId: 45, chapter: 8, verseStart: 3, serviceDate: DateTime(2025, 11, 18));
    final prayerId = await db.prayerDao.createRequest(title: 'Igreja', category: PrayerCategory.church);
    await db.prayerDao.markAnswered(prayerId, testimony: 'Deus respondeu');
    await db.notesDao.createNote(bookId: 45, chapter: 8, verse: 1, content: 'Nota');
    await db.settingsDao.setValue(AppSettings.kUserName, 'André');

    final service = BackupService(db);
    final raw = jsonEncode(await service.buildBackup());

    final other = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(other.close);
    await _seedMinimalBible(other);
    final summary = await BackupService(other).restore(raw);

    expect(summary.readings, 1);
    expect(summary.recitatives, 1);
    expect(summary.prayers, 1);
    expect(summary.notes, 1);
    final log = (await other.select(other.readingLogs).get()).single;
    expect(log.source, ReadingSource.physicalBible);
    expect(log.readAt, DateTime(2026, 11, 18, 9));
    final prayer = (await other.select(other.prayerRequests).get()).single;
    expect(prayer.status, PrayerStatus.answered);
    expect(prayer.category, PrayerCategory.church);
    expect(prayer.answerTestimony, 'Deus respondeu');
    expect(AppSettings.fromMap(await other.settingsDao.getAll()).userName, 'André');
  });

  test('backup rejeita arquivo de outro formato', () {
    expect(() => BackupService(db).restore('{"format":"x"}'), throwsA(isA<BackupException>()));
    expect(() => BackupService(db).restore('não é json'), throwsA(isA<BackupException>()));
  });
}

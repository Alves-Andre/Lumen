import 'package:drift/drift.dart';

import '../../utils/day_utils.dart';
import '../app_database.dart';
import '../tables.dart';

part 'notes_dao.g.dart';

@DriftAccessor(tables: [VerseNotes, Books])
class NotesDao extends DatabaseAccessor<AppDatabase> with _$NotesDaoMixin {
  NotesDao(super.attachedDatabase);

  Future<int> createNote({
    required int bookId,
    required int chapter,
    int? verse,
    required String content,
  }) =>
      into(verseNotes).insert(VerseNotesCompanion.insert(
        bookId: bookId,
        chapter: chapter,
        verse: Value(verse),
        content: content.trim(),
      ));

  Future<void> updateContent(int id, String content) => (update(verseNotes)..where((n) => n.id.equals(id)))
      .write(VerseNotesCompanion(content: Value(content.trim())));

  Future<int> deleteNote(int id) => (delete(verseNotes)..where((n) => n.id.equals(id))).go();

  /// Notas de um capítulo (inclui as vinculadas a versículos específicos).
  Stream<List<VerseNote>> watchForChapter(int bookId, int chapter) => (select(verseNotes)
        ..where((n) => n.bookId.equals(bookId) & n.chapter.equals(chapter))
        ..orderBy([
          (n) => OrderingTerm(expression: n.verse, nulls: NullsOrder.first),
          (n) => OrderingTerm.desc(n.createdAt),
        ]))
      .watch();

  /// Diário completo, mais recentes primeiro.
  Stream<List<VerseNoteWithBook>> watchAll() {
    final query = select(verseNotes).join([innerJoin(books, books.id.equalsExp(verseNotes.bookId))])
      ..orderBy([OrderingTerm.desc(verseNotes.createdAt)]);
    return query.map((row) => VerseNoteWithBook(row.readTable(verseNotes), row.readTable(books))).watch();
  }

  /// Dias (meia-noite local) em que alguma anotação devocional foi criada.
  Stream<Set<DateTime>> watchNoteDays() {
    final query = selectOnly(verseNotes)..addColumns([verseNotes.createdAt]);
    return query.map((r) => dateOnly(r.read(verseNotes.createdAt)!)).watch().map((days) => days.toSet());
  }

  /// Anotações criadas no dia de [day].
  Stream<List<VerseNoteWithBook>> watchOnDay(DateTime day) {
    final start = dateOnly(day);
    final query = select(verseNotes).join([innerJoin(books, books.id.equalsExp(verseNotes.bookId))])
      ..where(verseNotes.createdAt.isBiggerOrEqualValue(start) &
          verseNotes.createdAt.isSmallerThanValue(addDays(start, 1)))
      ..orderBy([OrderingTerm.asc(verseNotes.createdAt)]);
    return query.map((row) => VerseNoteWithBook(row.readTable(verseNotes), row.readTable(books))).watch();
  }
}

import 'package:drift/drift.dart';

import '../../utils/day_utils.dart';
import '../app_database.dart';
import '../tables.dart';

part 'notes_dao.g.dart';

@DriftAccessor(tables: [VerseNotes, Books])
class NotesDao extends DatabaseAccessor<AppDatabase> with _$NotesDaoMixin {
  NotesDao(super.attachedDatabase);

  /// Cria a anotação e retorna o id (UUID).
  Future<String> createNote({
    required int bookId,
    required int chapter,
    int? verse,
    required String content,
  }) async {
    final row = await into(verseNotes).insertReturning(VerseNotesCompanion.insert(
      bookId: bookId,
      chapter: chapter,
      verse: Value(verse),
      content: content.trim(),
    ));
    return row.id;
  }

  Future<void> updateContent(String id, String content) =>
      _write(id, VerseNotesCompanion(content: Value(content.trim())));

  /// Exclusão lógica (sincronizada com a nuvem).
  Future<void> deleteNote(String id) => _write(id, VerseNotesCompanion(deletedAt: Value(DateTime.now())));

  Future<void> _write(String id, VerseNotesCompanion changes) =>
      (update(verseNotes)..where((n) => n.id.equals(id) & n.deletedAt.isNull()))
          .write(changes.copyWith(updatedAt: Value(DateTime.now()), isSynced: const Value(false)));

  /// Notas de um capítulo (inclui as vinculadas a versículos específicos).
  Stream<List<VerseNote>> watchForChapter(int bookId, int chapter) => (select(verseNotes)
        ..where((n) => n.deletedAt.isNull() & n.bookId.equals(bookId) & n.chapter.equals(chapter))
        ..orderBy([
          (n) => OrderingTerm(expression: n.verse, nulls: NullsOrder.first),
          (n) => OrderingTerm.desc(n.createdAt),
        ]))
      .watch();

  /// Diário completo, mais recentes primeiro.
  Stream<List<VerseNoteWithBook>> watchAll() {
    final query = select(verseNotes).join([innerJoin(books, books.id.equalsExp(verseNotes.bookId))])
      ..where(verseNotes.deletedAt.isNull())
      ..orderBy([OrderingTerm.desc(verseNotes.createdAt)]);
    return query.map((row) => VerseNoteWithBook(row.readTable(verseNotes), row.readTable(books))).watch();
  }

  /// Dias (meia-noite local) em que alguma anotação devocional foi criada.
  Stream<Set<DateTime>> watchNoteDays() {
    final query = selectOnly(verseNotes)
      ..addColumns([verseNotes.createdAt])
      ..where(verseNotes.deletedAt.isNull());
    return query.map((r) => dateOnly(r.read(verseNotes.createdAt)!)).watch().map((days) => days.toSet());
  }

  /// Anotações criadas no dia de [day].
  Stream<List<VerseNoteWithBook>> watchOnDay(DateTime day) {
    final start = dateOnly(day);
    final query = select(verseNotes).join([innerJoin(books, books.id.equalsExp(verseNotes.bookId))])
      ..where(verseNotes.deletedAt.isNull() &
          verseNotes.createdAt.isBiggerOrEqualValue(start) &
          verseNotes.createdAt.isSmallerThanValue(addDays(start, 1)))
      ..orderBy([OrderingTerm.asc(verseNotes.createdAt)]);
    return query.map((row) => VerseNoteWithBook(row.readTable(verseNotes), row.readTable(books))).watch();
  }
}

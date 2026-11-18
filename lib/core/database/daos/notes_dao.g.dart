// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_dao.dart';

// ignore_for_file: type=lint
mixin _$NotesDaoMixin on DatabaseAccessor<AppDatabase> {
  $BooksTable get books => attachedDatabase.books;
  $VerseNotesTable get verseNotes => attachedDatabase.verseNotes;
  NotesDaoManager get managers => NotesDaoManager(this);
}

class NotesDaoManager {
  final _$NotesDaoMixin _db;
  NotesDaoManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db.attachedDatabase, _db.books);
  $$VerseNotesTableTableManager get verseNotes =>
      $$VerseNotesTableTableManager(_db.attachedDatabase, _db.verseNotes);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_dao.dart';

// ignore_for_file: type=lint
mixin _$NotesDaoMixin on DatabaseAccessor<AppDatabase> {
  $VerseNotesTable get verseNotes => attachedDatabase.verseNotes;
  $BooksTable get books => attachedDatabase.books;
  NotesDaoManager get managers => NotesDaoManager(this);
}

class NotesDaoManager {
  final _$NotesDaoMixin _db;
  NotesDaoManager(this._db);
  $$VerseNotesTableTableManager get verseNotes =>
      $$VerseNotesTableTableManager(_db.attachedDatabase, _db.verseNotes);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db.attachedDatabase, _db.books);
}

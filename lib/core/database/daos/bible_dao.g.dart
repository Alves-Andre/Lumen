// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bible_dao.dart';

// ignore_for_file: type=lint
mixin _$BibleDaoMixin on DatabaseAccessor<AppDatabase> {
  $BooksTable get books => attachedDatabase.books;
  $VersesTable get verses => attachedDatabase.verses;
  BibleDaoManager get managers => BibleDaoManager(this);
}

class BibleDaoManager {
  final _$BibleDaoMixin _db;
  BibleDaoManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db.attachedDatabase, _db.books);
  $$VersesTableTableManager get verses =>
      $$VersesTableTableManager(_db.attachedDatabase, _db.verses);
}

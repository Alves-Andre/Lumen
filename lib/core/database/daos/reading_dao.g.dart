// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_dao.dart';

// ignore_for_file: type=lint
mixin _$ReadingDaoMixin on DatabaseAccessor<AppDatabase> {
  $BooksTable get books => attachedDatabase.books;
  $ReadingCyclesTable get readingCycles => attachedDatabase.readingCycles;
  $ReadingLogsTable get readingLogs => attachedDatabase.readingLogs;
  ReadingDaoManager get managers => ReadingDaoManager(this);
}

class ReadingDaoManager {
  final _$ReadingDaoMixin _db;
  ReadingDaoManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db.attachedDatabase, _db.books);
  $$ReadingCyclesTableTableManager get readingCycles =>
      $$ReadingCyclesTableTableManager(_db.attachedDatabase, _db.readingCycles);
  $$ReadingLogsTableTableManager get readingLogs =>
      $$ReadingLogsTableTableManager(_db.attachedDatabase, _db.readingLogs);
}

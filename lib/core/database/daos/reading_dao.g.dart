// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_dao.dart';

// ignore_for_file: type=lint
mixin _$ReadingDaoMixin on DatabaseAccessor<AppDatabase> {
  $ReadingLogsTable get readingLogs => attachedDatabase.readingLogs;
  $ReadingCyclesTable get readingCycles => attachedDatabase.readingCycles;
  $BooksTable get books => attachedDatabase.books;
  ReadingDaoManager get managers => ReadingDaoManager(this);
}

class ReadingDaoManager {
  final _$ReadingDaoMixin _db;
  ReadingDaoManager(this._db);
  $$ReadingLogsTableTableManager get readingLogs =>
      $$ReadingLogsTableTableManager(_db.attachedDatabase, _db.readingLogs);
  $$ReadingCyclesTableTableManager get readingCycles =>
      $$ReadingCyclesTableTableManager(_db.attachedDatabase, _db.readingCycles);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db.attachedDatabase, _db.books);
}

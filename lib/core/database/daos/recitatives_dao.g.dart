// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recitatives_dao.dart';

// ignore_for_file: type=lint
mixin _$RecitativesDaoMixin on DatabaseAccessor<AppDatabase> {
  $BooksTable get books => attachedDatabase.books;
  $RecitativesTable get recitatives => attachedDatabase.recitatives;
  RecitativesDaoManager get managers => RecitativesDaoManager(this);
}

class RecitativesDaoManager {
  final _$RecitativesDaoMixin _db;
  RecitativesDaoManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db.attachedDatabase, _db.books);
  $$RecitativesTableTableManager get recitatives =>
      $$RecitativesTableTableManager(_db.attachedDatabase, _db.recitatives);
}

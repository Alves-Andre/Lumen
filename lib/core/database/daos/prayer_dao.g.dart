// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_dao.dart';

// ignore_for_file: type=lint
mixin _$PrayerDaoMixin on DatabaseAccessor<AppDatabase> {
  $PrayerRequestsTable get prayerRequests => attachedDatabase.prayerRequests;
  PrayerDaoManager get managers => PrayerDaoManager(this);
}

class PrayerDaoManager {
  final _$PrayerDaoMixin _db;
  PrayerDaoManager(this._db);
  $$PrayerRequestsTableTableManager get prayerRequests =>
      $$PrayerRequestsTableTableManager(
        _db.attachedDatabase,
        _db.prayerRequests,
      );
}

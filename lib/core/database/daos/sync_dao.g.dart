// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_dao.dart';

// ignore_for_file: type=lint
mixin _$SyncDaoMixin on DatabaseAccessor<AppDatabase> {
  $ReadingCyclesTable get readingCycles => attachedDatabase.readingCycles;
  $ReadingLogsTable get readingLogs => attachedDatabase.readingLogs;
  $RecitativesTable get recitatives => attachedDatabase.recitatives;
  $PrayerRequestsTable get prayerRequests => attachedDatabase.prayerRequests;
  $VerseNotesTable get verseNotes => attachedDatabase.verseNotes;
  $PlanEnrollmentsTable get planEnrollments => attachedDatabase.planEnrollments;
  $UserProfilesTable get userProfiles => attachedDatabase.userProfiles;
  SyncDaoManager get managers => SyncDaoManager(this);
}

class SyncDaoManager {
  final _$SyncDaoMixin _db;
  SyncDaoManager(this._db);
  $$ReadingCyclesTableTableManager get readingCycles =>
      $$ReadingCyclesTableTableManager(_db.attachedDatabase, _db.readingCycles);
  $$ReadingLogsTableTableManager get readingLogs =>
      $$ReadingLogsTableTableManager(_db.attachedDatabase, _db.readingLogs);
  $$RecitativesTableTableManager get recitatives =>
      $$RecitativesTableTableManager(_db.attachedDatabase, _db.recitatives);
  $$PrayerRequestsTableTableManager get prayerRequests =>
      $$PrayerRequestsTableTableManager(
        _db.attachedDatabase,
        _db.prayerRequests,
      );
  $$VerseNotesTableTableManager get verseNotes =>
      $$VerseNotesTableTableManager(_db.attachedDatabase, _db.verseNotes);
  $$PlanEnrollmentsTableTableManager get planEnrollments =>
      $$PlanEnrollmentsTableTableManager(
        _db.attachedDatabase,
        _db.planEnrollments,
      );
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db.attachedDatabase, _db.userProfiles);
}

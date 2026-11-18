// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plans_dao.dart';

// ignore_for_file: type=lint
mixin _$PlansDaoMixin on DatabaseAccessor<AppDatabase> {
  $PlanEnrollmentsTable get planEnrollments => attachedDatabase.planEnrollments;
  PlansDaoManager get managers => PlansDaoManager(this);
}

class PlansDaoManager {
  final _$PlansDaoMixin _db;
  PlansDaoManager(this._db);
  $$PlanEnrollmentsTableTableManager get planEnrollments =>
      $$PlanEnrollmentsTableTableManager(
        _db.attachedDatabase,
        _db.planEnrollments,
      );
}

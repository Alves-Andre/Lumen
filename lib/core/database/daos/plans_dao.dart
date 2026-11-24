import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'plans_dao.g.dart';

@DriftAccessor(tables: [PlanEnrollments])
class PlansDao extends DatabaseAccessor<AppDatabase> with _$PlansDaoMixin {
  PlansDao(super.attachedDatabase);

  Stream<PlanEnrollment?> watchActive() => (select(planEnrollments)
        ..where((p) => p.endedAt.isNull() & p.deletedAt.isNull())
        ..orderBy([(p) => OrderingTerm.desc(p.startedAt)])
        ..limit(1))
      .watchSingleOrNull();

  /// Inicia [planId], encerrando (sem concluir) o plano ativo, se houver.
  /// Retorna o id (UUID) da nova inscrição.
  Future<String> start(String planId, {DateTime? at}) => transaction(() async {
        final now = at ?? DateTime.now();
        await (update(planEnrollments)..where((p) => p.endedAt.isNull() & p.deletedAt.isNull())).write(
          PlanEnrollmentsCompanion(endedAt: Value(now), updatedAt: Value(DateTime.now()), isSynced: const Value(false)),
        );
        final row = await into(planEnrollments)
            .insertReturning(PlanEnrollmentsCompanion.insert(planId: planId, startedAt: now));
        return row.id;
      });

  Future<void> end(String id, {required bool completed, DateTime? at}) =>
      (update(planEnrollments)..where((p) => p.id.equals(id))).write(PlanEnrollmentsCompanion(
        endedAt: Value(at ?? DateTime.now()),
        completed: Value(completed),
        updatedAt: Value(DateTime.now()),
        isSynced: const Value(false),
      ));

  Stream<Set<TableUpdate>> watchChanges() =>
      attachedDatabase.tableUpdates(TableUpdateQuery.onAllTables([planEnrollments]));
}

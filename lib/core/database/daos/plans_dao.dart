import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'plans_dao.g.dart';

@DriftAccessor(tables: [PlanEnrollments])
class PlansDao extends DatabaseAccessor<AppDatabase> with _$PlansDaoMixin {
  PlansDao(super.attachedDatabase);

  Stream<PlanEnrollment?> watchActive() => (select(planEnrollments)
        ..where((p) => p.endedAt.isNull())
        ..orderBy([(p) => OrderingTerm.desc(p.id)])
        ..limit(1))
      .watchSingleOrNull();

  /// Inicia [planId], encerrando (sem concluir) o plano ativo, se houver.
  Future<int> start(String planId, {DateTime? at}) => transaction(() async {
        final now = at ?? DateTime.now();
        await (update(planEnrollments)..where((p) => p.endedAt.isNull()))
            .write(PlanEnrollmentsCompanion(endedAt: Value(now)));
        return into(planEnrollments).insert(PlanEnrollmentsCompanion.insert(planId: planId, startedAt: now));
      });

  Future<void> end(int id, {required bool completed, DateTime? at}) =>
      (update(planEnrollments)..where((p) => p.id.equals(id))).write(PlanEnrollmentsCompanion(
        endedAt: Value(at ?? DateTime.now()),
        completed: Value(completed),
      ));

  Stream<Set<TableUpdate>> watchChanges() =>
      attachedDatabase.tableUpdates(TableUpdateQuery.onAllTables([planEnrollments]));
}

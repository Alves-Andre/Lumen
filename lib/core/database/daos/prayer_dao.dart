import 'package:drift/drift.dart';

import '../../utils/day_utils.dart';
import '../app_database.dart';
import '../tables.dart';

part 'prayer_dao.g.dart';

@DriftAccessor(tables: [PrayerRequests])
class PrayerDao extends DatabaseAccessor<AppDatabase> with _$PrayerDaoMixin {
  PrayerDao(super.attachedDatabase);

  Future<int> createRequest({
    required String title,
    String? description,
    required PrayerCategory category,
  }) =>
      into(prayerRequests).insert(PrayerRequestsCompanion.insert(
        title: title.trim(),
        description: Value(_blankToNull(description)),
        category: category,
        status: PrayerStatus.active,
      ));

  Future<void> updateRequest({
    required int id,
    required String title,
    String? description,
    required PrayerCategory category,
  }) =>
      (update(prayerRequests)..where((p) => p.id.equals(id))).write(PrayerRequestsCompanion(
        title: Value(title.trim()),
        description: Value(_blankToNull(description)),
        category: Value(category),
      ));

  Future<int> deleteRequest(int id) => (delete(prayerRequests)..where((p) => p.id.equals(id))).go();

  /// "Orei hoje (+1)". Retorna `false` se já foi registrado hoje.
  Future<bool> registerPrayer(int id, {DateTime? at}) => transaction(() async {
        final now = at ?? DateTime.now();
        final request = await (select(prayerRequests)..where((p) => p.id.equals(id))).getSingle();
        final last = request.lastPrayedAt;
        if (last != null && isSameDay(last, now)) return false;
        await (update(prayerRequests)..where((p) => p.id.equals(id))).write(PrayerRequestsCompanion.custom(
          prayCount: prayerRequests.prayCount + const Constant(1),
          lastPrayedAt: Variable(now),
        ));
        return true;
      });

  Future<void> markAnswered(int id, {String? testimony, DateTime? at}) =>
      (update(prayerRequests)..where((p) => p.id.equals(id))).write(PrayerRequestsCompanion(
        status: const Value(PrayerStatus.answered),
        answeredAt: Value(at ?? DateTime.now()),
        answerTestimony: Value(_blankToNull(testimony)),
      ));

  Future<void> reopen(int id) =>
      (update(prayerRequests)..where((p) => p.id.equals(id))).write(const PrayerRequestsCompanion(
        status: Value(PrayerStatus.active),
        answeredAt: Value(null),
        answerTestimony: Value(null),
      ));

  /// Ativos: os que não foram orados há mais tempo aparecem primeiro.
  Stream<List<PrayerRequest>> watchActive({PrayerCategory? category}) {
    final query = select(prayerRequests)
      ..where((p) {
        final active = p.status.equalsValue(PrayerStatus.active);
        return category == null ? active : active & p.category.equalsValue(category);
      })
      ..orderBy([
        (p) => OrderingTerm(expression: p.lastPrayedAt, mode: OrderingMode.asc, nulls: NullsOrder.first),
        (p) => OrderingTerm.desc(p.createdAt),
      ]);
    return query.watch();
  }

  Stream<List<PrayerRequest>> watchAnswered() => (select(prayerRequests)
        ..where((p) => p.status.equalsValue(PrayerStatus.answered))
        ..orderBy([(p) => OrderingTerm.desc(p.answeredAt)]))
      .watch();

  static String? _blankToNull(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();
}

import 'package:drift/drift.dart';

import '../../utils/day_utils.dart';
import '../app_database.dart';
import '../tables.dart';

part 'prayer_dao.g.dart';

@DriftAccessor(tables: [PrayerRequests])
class PrayerDao extends DatabaseAccessor<AppDatabase> with _$PrayerDaoMixin {
  PrayerDao(super.attachedDatabase);

  /// Cria o pedido e retorna o id (UUID).
  Future<String> createRequest({
    required String title,
    String? description,
    required PrayerCategory category,
  }) async {
    final row = await into(prayerRequests).insertReturning(PrayerRequestsCompanion.insert(
      title: title.trim(),
      description: Value(_blankToNull(description)),
      category: category,
      status: PrayerStatus.active,
    ));
    return row.id;
  }

  Future<void> updateRequest({
    required String id,
    required String title,
    String? description,
    required PrayerCategory category,
  }) =>
      _write(
        id,
        PrayerRequestsCompanion(
          title: Value(title.trim()),
          description: Value(_blankToNull(description)),
          category: Value(category),
        ),
      );

  /// Exclusão lógica (sincronizada com a nuvem).
  Future<void> deleteRequest(String id) => _write(id, PrayerRequestsCompanion(deletedAt: Value(DateTime.now())));

  /// "Orei hoje (+1)". Retorna `false` se já foi registrado hoje.
  Future<bool> registerPrayer(String id, {DateTime? at}) => transaction(() async {
        final now = at ?? DateTime.now();
        final request = await (select(prayerRequests)..where((p) => p.id.equals(id))).getSingle();
        final last = request.lastPrayedAt;
        if (last != null && isSameDay(last, now)) return false;
        await _write(
          id,
          PrayerRequestsCompanion(prayCount: Value(request.prayCount + 1), lastPrayedAt: Value(now)),
        );
        return true;
      });

  Future<void> markAnswered(String id, {String? testimony, DateTime? at}) => _write(
        id,
        PrayerRequestsCompanion(
          status: const Value(PrayerStatus.answered),
          answeredAt: Value(at ?? DateTime.now()),
          answerTestimony: Value(_blankToNull(testimony)),
        ),
      );

  Future<void> reopen(String id) => _write(
        id,
        const PrayerRequestsCompanion(
          status: Value(PrayerStatus.active),
          answeredAt: Value(null),
          answerTestimony: Value(null),
        ),
      );

  /// Aplica [changes] marcando a linha como alterada e pendente de envio.
  Future<void> _write(String id, PrayerRequestsCompanion changes) =>
      (update(prayerRequests)..where((p) => p.id.equals(id) & p.deletedAt.isNull()))
          .write(changes.copyWith(updatedAt: Value(DateTime.now()), isSynced: const Value(false)));

  /// Ativos: os que não foram orados há mais tempo aparecem primeiro.
  Stream<List<PrayerRequest>> watchActive({PrayerCategory? category}) {
    final query = select(prayerRequests)
      ..where((p) {
        final active = p.deletedAt.isNull() & p.status.equalsValue(PrayerStatus.active);
        return category == null ? active : active & p.category.equalsValue(category);
      })
      ..orderBy([
        (p) => OrderingTerm(expression: p.lastPrayedAt, mode: OrderingMode.asc, nulls: NullsOrder.first),
        (p) => OrderingTerm.desc(p.createdAt),
      ]);
    return query.watch();
  }

  Stream<List<PrayerRequest>> watchAnswered() => (select(prayerRequests)
        ..where((p) => p.deletedAt.isNull() & p.status.equalsValue(PrayerStatus.answered))
        ..orderBy([(p) => OrderingTerm.desc(p.answeredAt)]))
      .watch();

  static String? _blankToNull(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();
}

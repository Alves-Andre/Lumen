import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/utils/day_utils.dart';
import '../../../../core/utils/streams.dart';
import '../../../bible/presentation/providers/bible_providers.dart';
import '../../domain/models/plan_progress.dart';
import '../../domain/models/reading_plan.dart';

// Escritos à mão: PlanEnrollment é gerado pelo Drift (ver bible_providers.dart).

final readingPlansProvider = FutureProvider<List<ReadingPlan>>(
  (ref) async => ReadingPlans.all(await ref.watch(allBooksProvider.future)),
);

final activePlanEnrollmentProvider = StreamProvider<PlanEnrollment?>(
  (ref) => ref.watch(appDatabaseProvider).plansDao.watchActive(),
);

/// Progresso do plano ativo; recalculado a cada leitura registrada ou removida.
final planProgressProvider = StreamProvider<PlanProgress?>((ref) async* {
  final enrollment = await ref.watch(activePlanEnrollmentProvider.future);
  if (enrollment == null) {
    yield null;
    return;
  }
  final plans = await ref.watch(readingPlansProvider.future);
  final plan = plans.where((p) => p.id == enrollment.planId).firstOrNull;
  if (plan == null) {
    yield null;
    return;
  }
  final dao = ref.watch(appDatabaseProvider).readingDao;
  yield* recomputeOn(
    dao.watchChanges(),
    () async => PlanProgress.compute(
      enrollmentId: enrollment.id,
      plan: plan,
      startedAt: enrollment.startedAt,
      // Conta desde o início do dia: o que foi lido hoje antes de começar o plano vale.
      read: await dao.getChaptersReadSince(dateOnly(enrollment.startedAt)),
      now: DateTime.now(),
    ),
  );
});

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/day_utils.dart';
import 'reading_plan.dart';

/// Situação de um plano ativo, calculada a partir das leituras registradas
/// desde o início do plano (em qualquer ordem e por qualquer caminho do app).
class PlanProgress {
  const PlanProgress({
    required this.enrollmentId,
    required this.plan,
    required this.startedAt,
    required this.readChapters,
    required this.currentDayIndex,
    required this.expectedDayIndex,
  });

  /// Calcula o progresso. [read] são os capítulos lidos desde [startedAt].
  factory PlanProgress.compute({
    required String enrollmentId,
    required ReadingPlan plan,
    required DateTime startedAt,
    required Set<ChapterRef> read,
    required DateTime now,
  }) {
    final inPlan = {for (final day in plan.days) ...day}.where(read.contains).toSet();
    final current = plan.days.indexWhere((day) => !day.every(inPlan.contains));
    return PlanProgress(
      enrollmentId: enrollmentId,
      plan: plan,
      startedAt: startedAt,
      readChapters: inPlan,
      currentDayIndex: current == -1 ? null : current,
      expectedDayIndex: daysBetween(startedAt, now).clamp(0, plan.totalDays - 1),
    );
  }

  final String enrollmentId;
  final ReadingPlan plan;
  final DateTime startedAt;

  /// Capítulos do plano já lidos.
  final Set<ChapterRef> readChapters;

  /// Primeiro dia com capítulo pendente (0-based); `null` quando o plano foi concluído.
  final int? currentDayIndex;

  /// Dia em que o calendário diz que o usuário deveria estar (0-based).
  final int expectedDayIndex;

  bool get isComplete => currentDayIndex == null;

  double get progress => plan.totalChapters == 0 ? 0 : readChapters.length / plan.totalChapters;

  /// Capítulos do dia atual (lidos e pendentes).
  List<ChapterRef> get todayChapters => isComplete ? const [] : plan.days[currentDayIndex!];

  /// Capítulos do dia atual ainda não lidos, na ordem do plano.
  List<ChapterRef> get todayRemaining => todayChapters.where((c) => !readChapters.contains(c)).toList();

  /// Dias de atraso (positivo) ou de adiantamento (negativo) em relação ao calendário.
  int get daysBehind => isComplete ? 0 : expectedDayIndex - currentDayIndex!;

  /// Próximo capítulo pendente do dia atual depois de [current] (para "Concluir e ir para").
  ChapterRef? nextAfter(ChapterRef current) {
    for (final c in todayRemaining) {
      if (c != current) return c;
    }
    return null;
  }

  String get statusLabel {
    if (isComplete) return 'Plano concluído!';
    final behind = daysBehind;
    if (behind > 0) return behind == 1 ? '1 dia de atraso' : '$behind dias de atraso';
    if (behind < 0) return -behind == 1 ? '1 dia adiantado' : '${-behind} dias adiantados';
    return 'Em dia';
  }
}

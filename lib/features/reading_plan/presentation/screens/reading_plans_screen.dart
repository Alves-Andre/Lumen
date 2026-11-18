import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/providers/database_providers.dart';
import '../../../../core/theme/duo_colors.dart';
import '../../../../core/widgets/duo_button.dart';
import '../../../../core/widgets/duo_widgets.dart';
import '../../domain/models/plan_progress.dart';
import '../../domain/models/reading_plan.dart';
import '../providers/plan_providers.dart';
import '../widgets/plan_today_card.dart';

/// Planos de leitura opcionais. Tudo o que é lido conta para a ofensiva e a jornada.
class ReadingPlansScreen extends ConsumerWidget {
  const ReadingPlansScreen({super.key});

  Future<void> _start(BuildContext context, WidgetRef ref, ReadingPlan plan, PlanProgress? active) async {
    if (active != null) {
      final ok = await confirmDialog(
        context,
        title: 'Trocar de plano?',
        message: 'O plano "${active.plan.name}" será encerrado. Suas leituras continuam registradas '
            'e contam para a ofensiva e a jornada.',
        confirmLabel: 'Trocar',
      );
      if (!ok) return;
    }
    await ref.read(appDatabaseProvider).plansDao.start(plan.id);
    if (context.mounted) showDuoSnack(context, 'Plano "${plan.name}" iniciado. Boa leitura!');
  }

  Future<void> _end(BuildContext context, WidgetRef ref, PlanProgress active) async {
    final ok = await confirmDialog(
      context,
      title: 'Encerrar plano?',
      message: 'O plano "${active.plan.name}" sairá da tela inicial. Suas leituras continuam registradas.',
      confirmLabel: 'Encerrar',
      destructive: true,
    );
    if (ok) await ref.read(appDatabaseProvider).plansDao.end(active.enrollmentId, completed: false);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = DuoColors.of(context);
    final plans = ref.watch(readingPlansProvider);
    final active = ref.watch(planProgressProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Planos de leitura')),
      body: AsyncView<List<ReadingPlan>>(
        value: plans,
        builder: (all) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (active != null) ...[
              const SectionTitle('Seu plano'),
              PlanTodayCard(progress: active),
              if (!active.isComplete)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _end(context, ref, active),
                    icon: Icon(Icons.close_rounded, color: c.danger.fill),
                    label: Text('Encerrar plano', style: TextStyle(color: c.danger.fill, fontWeight: FontWeight.w800)),
                  ),
                ),
              const SizedBox(height: 8),
            ] else
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Escolha um plano para saber o que ler a cada dia. É opcional: tudo o que você ler, '
                  'dentro ou fora do plano, continua contando para a ofensiva e a jornada.',
                  style: TextStyle(color: c.textMuted, height: 1.4),
                ),
              ),
            SectionTitle(active == null ? 'Planos disponíveis' : 'Outros planos'),
            for (final plan in all.where((p) => p.id != active?.plan.id))
              DuoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        DuoIconBadge(icon: Icons.event_note_rounded, tone: c.primary),
                        const SizedBox(width: 12),
                        Expanded(child: Text(plan.name, style: Theme.of(context).textTheme.titleMedium)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(plan.description, style: TextStyle(color: c.text, height: 1.4)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        DuoChip(label: '${plan.totalDays} dias', tone: c.primary, icon: Icons.calendar_month_rounded),
                        const SizedBox(width: 8),
                        DuoChip(
                          label: '~${plan.chaptersPerDay} ${plan.chaptersPerDay == 1 ? 'capítulo' : 'capítulos'}/dia',
                          tone: c.success,
                          icon: Icons.auto_stories_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    DuoButton(
                      label: active == null ? 'Começar' : 'Trocar para este plano',
                      style: active == null ? DuoButtonStyle.primary : DuoButtonStyle.neutral,
                      compact: true,
                      onPressed: () => _start(context, ref, plan, active),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

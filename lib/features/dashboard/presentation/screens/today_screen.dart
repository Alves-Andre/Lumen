import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/duo_colors.dart';
import '../../../../core/utils/day_utils.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/duo_button.dart';
import '../../../../core/widgets/duo_widgets.dart';
import '../../../reading_plan/domain/models/reading_projection.dart';
import '../../../reading_plan/domain/models/streak_status.dart';
import '../../../reading_plan/presentation/providers/plan_providers.dart';
import '../../../reading_plan/presentation/providers/reading_plan_providers.dart';
import '../../../reading_plan/presentation/widgets/plan_today_card.dart';
import '../../../recitatives/presentation/providers/recitatives_providers.dart';
import '../../../recitatives/presentation/widgets/recitative_widgets.dart';
import '../widgets/streak_widgets.dart';

/// Aba 1 — Hoje.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakStatusProvider);
    final memories = ref.watch(recitativeMemoriesProvider);
    final userName = ref.watch(appSettingsProvider.select((s) => s.value?.userName ?? ''));
    final c = DuoColors.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    userName.isEmpty ? '${greeting()}!' : '${greeting()}, $userName!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                if (streak.value case final s?) ...[
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.streak),
                    child: Row(children: [StreakChip(status: s), const SizedBox(width: 12), ShieldCountChip(status: s)]),
                  ),
                ],
                IconButton(
                  tooltip: 'Configurações',
                  onPressed: () => context.push(AppRoutes.settings),
                  icon: Icon(Icons.settings_rounded, color: c.textFaint),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AsyncView(value: streak, builder: (s) => _StreakCard(status: s)),
            const _PlanSection(),
            const _ProgressCard(),
            if (memories.value?.highlight case final memory?) RecitativeMemoryCard(memory: memory),
            const _NextRecitativeCard(),
          ],
        ),
      ),
    );
  }
}

class _StreakCard extends ConsumerWidget {
  const _StreakCard({required this.status});

  final StreakStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = DuoColors.of(context);
    final week = ref.watch(weekActivityProvider).value ?? const {};
    final days = status.currentStreak;
    final subtitle = status.readToday
        ? 'Você já leu hoje. Glória a Deus!'
        : status.isActive
            ? 'Leia hoje para manter sua ofensiva.'
            : 'Leia um capítulo para começar sua ofensiva.';

    return DuoCard(
      onTap: () => context.push(AppRoutes.streak),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$days',
                      style: TextStyle(
                        fontSize: 44,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        color: status.readToday ? c.streak.fill : c.textFaint,
                      ),
                    ),
                    Text(
                      days == 1 ? 'dia de ofensiva' : 'dias de ofensiva',
                      style: TextStyle(fontWeight: FontWeight.w800, color: c.streak.fill, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: c.textMuted)),
                  ],
                ),
              ),
              Icon(
                Icons.local_fire_department_rounded,
                size: 84,
                color: status.readToday ? c.streak.fill : c.border,
              ),
            ],
          ),
          const SizedBox(height: 16),
          WeekStreakStrip(activity: week, status: status, today: DateTime.now()),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: c.grace.soft, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                Icon(status.shields > 0 ? Icons.shield_rounded : Icons.shield_outlined, color: c.grace.fill),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    switch ((status.shields, status.nextShieldIn)) {
                      (_, null) => 'Escudos desativados nas configurações.',
                      (0, final next?) => 'Sem escudos. Leia mais $next ${next == 1 ? 'dia' : 'dias'} seguidos para ganhar 1.',
                      (1, final next?) => 'Você tem 1 escudo: se faltar 1 dia, sua ofensiva continua. '
                          'Próximo em $next ${next == 1 ? 'dia' : 'dias'}.',
                      (final n, final next?) => 'Você tem $n escudos: protegem $n dias sem leitura. '
                          'Próximo em $next ${next == 1 ? 'dia' : 'dias'}.',
                    },
                    style: TextStyle(color: c.text, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (status.longestStreak > 0)
                Text(
                  'Recorde: ${status.longestStreak} ${status.longestStreak == 1 ? 'dia' : 'dias'}',
                  style: TextStyle(color: c.textMuted, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              const Spacer(),
              Text('Ver histórico', style: TextStyle(color: c.primary.fill, fontWeight: FontWeight.w800, fontSize: 13)),
              Icon(Icons.chevron_right_rounded, color: c.primary.fill, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends ConsumerWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = DuoColors.of(context);
    final projection = ref.watch(readingProjectionProvider);
    final target = ref.watch(continueReadingProvider).value;

    return DuoCard(
      child: AsyncView<ReadingProjection>(
        value: projection,
        builder: (p) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DuoIconBadge(icon: Icons.auto_stories_rounded, tone: c.success),
                const SizedBox(width: 12),
                Expanded(child: Text('Jornada Bíblica', style: Theme.of(context).textTheme.titleLarge)),
                Text(
                  '${(p.progress * 100).toStringAsFixed(p.progress < 0.1 ? 1 : 0)}%',
                  style: TextStyle(fontWeight: FontWeight.w800, color: c.success.fill, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 14),
            DuoProgressBar(value: p.progress),
            const SizedBox(height: 8),
            Text(
              '${thousands(p.chaptersReadInCycle)} de ${thousands(p.totalChapters)} capítulos',
              style: TextStyle(fontWeight: FontWeight.w800, color: c.textMuted),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: DuoStatBox(label: 'Média/dia', value: p.dailyAverageLabel, tone: c.primary, icon: Icons.speed_rounded),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DuoStatBox(
                    label: 'Faltam',
                    value: p.estimatedDays == null ? '—' : '${thousands(p.estimatedDays!)} d',
                    tone: c.streak,
                    icon: Icons.flag_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(p.message, style: TextStyle(color: c.text, height: 1.4)),
            if (target != null) ...[
              const SizedBox(height: 16),
              DuoButton(
                label: 'Continuar: ${target.label}',
                style: DuoButtonStyle.success,
                icon: Icons.play_arrow_rounded,
                onPressed: () => context.push(AppRoutes.reader(target.book.id, target.chapter)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NextRecitativeCard extends ConsumerWidget {
  const _NextRecitativeCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = DuoColors.of(context);
    final next = ref.watch(nextPendingRecitativeProvider);
    return DuoCard(
      child: AsyncView(
        value: next,
        builder: (item) {
          if (item == null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    DuoIconBadge(icon: Icons.record_voice_over_rounded, tone: c.gold),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Próximo recitativo', style: Theme.of(context).textTheme.titleLarge)),
                  ],
                ),
                const SizedBox(height: 10),
                Text('Nenhum recitativo agendado. Recebeu um verso para o culto?', style: TextStyle(color: c.textMuted)),
                const SizedBox(height: 14),
                DuoButton(
                  label: 'Novo recitativo',
                  style: DuoButtonStyle.neutral,
                  icon: Icons.add_rounded,
                  onPressed: () => context.push(AppRoutes.newRecitative),
                ),
              ],
            );
          }
          final r = item.recitative;
          final days = daysBetween(DateTime.now(), r.serviceDate);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  DuoIconBadge(icon: Icons.record_voice_over_rounded, tone: c.gold),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Próximo recitativo', style: Theme.of(context).textTheme.titleLarge)),
                  DuoChip(label: days == 0 ? 'Hoje!' : relativeDay(r.serviceDate), tone: days <= 1 ? c.streak : c.primary),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => context.push(AppRoutes.recitative(r.id)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.reference, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(
                      r.verseTextSnapshot,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: c.textMuted, height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      [fullDate(r.serviceDate), if (r.congregation != null) r.congregation!].join(' · '),
                      style: TextStyle(color: c.textFaint, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              DuoButton(
                label: 'Modo treino',
                style: DuoButtonStyle.gold,
                icon: Icons.psychology_rounded,
                onPressed: () => context.push(AppRoutes.train(r.id)),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Plano ativo (leitura de hoje) ou um convite discreto para escolher um plano.
class _PlanSection extends ConsumerWidget {
  const _PlanSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = DuoColors.of(context);
    final progress = ref.watch(planProgressProvider);
    if (progress.isLoading && !progress.hasValue) return const SizedBox.shrink();
    final active = progress.value;
    if (active != null) {
      return PlanTodayCard(progress: active, onTapTitle: () => context.push(AppRoutes.plans));
    }
    return DuoCard(
      onTap: () => context.push(AppRoutes.plans),
      child: Row(
        children: [
          DuoIconBadge(icon: Icons.event_note_rounded, tone: c.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Planos de leitura', style: Theme.of(context).textTheme.titleMedium),
                Text(
                  'Bíblia em 1 ano, Novo Testamento em 90 dias e outros',
                  style: TextStyle(color: c.textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: c.textFaint),
        ],
      ),
    );
  }
}


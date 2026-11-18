import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/duo_colors.dart';
import '../../../../core/widgets/duo_button.dart';
import '../../../../core/widgets/duo_widgets.dart';
import '../../../bible/presentation/providers/bible_providers.dart';
import '../../domain/models/plan_progress.dart';

/// Card do plano ativo: dia atual, situação, leitura de hoje e botão para ler.
class PlanTodayCard extends ConsumerWidget {
  const PlanTodayCard({super.key, required this.progress, this.onTapTitle});

  final PlanProgress progress;

  /// Ação ao tocar no cabeçalho (ex.: abrir a tela de planos).
  final VoidCallback? onTapTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = DuoColors.of(context);
    final books = ref.watch(allBooksProvider).value;
    final byId = {for (final b in books ?? const <Book>[]) b.id: b};
    final p = progress;
    final behind = p.daysBehind;
    final statusTone = p.isComplete ? c.success : (behind > 0 ? c.streak : c.success);

    String name(ChapterRef r) => byId[r.bookId] == null ? '' : '${byId[r.bookId]!.name} ${r.chapter}';

    return DuoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTapTitle,
            child: Row(
              children: [
                DuoIconBadge(icon: Icons.event_note_rounded, tone: c.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.plan.name, style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        p.isComplete
                            ? '${p.plan.totalDays} dias concluídos'
                            : 'Dia ${p.currentDayIndex! + 1} de ${p.plan.totalDays}',
                        style: TextStyle(color: c.textMuted, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                DuoChip(label: p.statusLabel, tone: statusTone),
              ],
            ),
          ),
          const SizedBox(height: 14),
          DuoProgressBar(value: p.progress, color: c.primary.fill, height: 12),
          const SizedBox(height: 6),
          Text(
            '${p.readChapters.length} de ${p.plan.totalChapters} capítulos do plano',
            style: TextStyle(color: c.textMuted, fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 14),
          if (p.isComplete) ...[
            Text('Glória a Deus! Você concluiu este plano.', style: TextStyle(color: c.text, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            DuoButton(
              label: 'Encerrar plano',
              style: DuoButtonStyle.success,
              icon: Icons.emoji_events_rounded,
              onPressed: () => ref.read(appDatabaseProvider).plansDao.end(p.enrollmentId, completed: true),
            ),
          ] else ...[
            Text('Leitura de hoje', style: TextStyle(color: c.textMuted, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final chapter in p.todayChapters)
                  _ChapterPill(label: name(chapter), done: p.readChapters.contains(chapter)),
              ],
            ),
            if (p.todayRemaining.isNotEmpty && books != null) ...[
              const SizedBox(height: 14),
              DuoButton(
                label: 'Ler agora: ${name(p.todayRemaining.first)}',
                style: DuoButtonStyle.primary,
                icon: Icons.play_arrow_rounded,
                onPressed: () => context.push(
                  AppRoutes.reader(p.todayRemaining.first.bookId, p.todayRemaining.first.chapter, plan: true),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _ChapterPill extends StatelessWidget {
  const _ChapterPill({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: done ? c.success.soft : c.neutral.soft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: done ? c.success.fill : c.border, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 16,
            color: done ? c.success.fill : c.textFaint,
          ),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontWeight: FontWeight.w800, color: done ? c.success.fill : c.text)),
        ],
      ),
    );
  }
}

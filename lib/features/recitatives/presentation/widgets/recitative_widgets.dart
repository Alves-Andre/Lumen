import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/duo_colors.dart';
import '../../../../core/utils/day_utils.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/duo_widgets.dart';
import '../../domain/models/recitative_memory.dart';

/// Card dourado de "Lembrança de Recitativo".
class RecitativeMemoryCard extends StatelessWidget {
  const RecitativeMemoryCard({super.key, required this.memory});

  final RecitativeMemory memory;

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    final r = memory.item.recitative;
    return DuoCard(
      color: c.gold.soft,
      borderColor: c.gold.shadow,
      onTap: () => context.push(AppRoutes.recitative(r.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DuoIconBadge(icon: Icons.auto_awesome_rounded, tone: c.gold, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  memory.headline,
                  style: TextStyle(fontWeight: FontWeight.w800, color: c.text, fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            memory.item.reference,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: c.text),
          ),
          const SizedBox(height: 6),
          Text(
            '“${r.verseTextSnapshot}”',
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontStyle: FontStyle.italic, color: c.text, height: 1.45),
          ),
          const SizedBox(height: 10),
          Text(
            [fullDate(r.serviceDate), if (r.congregation != null) r.congregation!].join(' · '),
            style: TextStyle(color: c.textMuted, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// Item de lista de recitativo.
class RecitativeTile extends StatelessWidget {
  const RecitativeTile({super.key, required this.item});

  final RecitativeWithBook item;

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    final r = item.recitative;
    final pending = r.status == RecitativeStatus.pending;
    final diff = daysBetween(DateTime.now(), r.serviceDate);
    final (chipLabel, chipTone) = !pending
        ? ('Recitado', c.success)
        : diff < 0
            ? ('Atrasado', c.danger)
            : diff == 0
                ? ('Hoje!', c.streak)
                : (relativeDay(r.serviceDate), c.primary);

    return DuoCard(
      onTap: () => context.push(AppRoutes.recitative(r.id)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DuoIconBadge(icon: pending ? Icons.record_voice_over_rounded : Icons.check_rounded, tone: pending ? c.gold : c.success),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(item.reference, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    ),
                    DuoChip(label: chipLabel, tone: chipTone),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  r.verseTextSnapshot,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: c.textMuted, height: 1.35),
                ),
                const SizedBox(height: 8),
                Text(
                  [fullDate(r.serviceDate), if (r.congregation != null) r.congregation!].join(' · '),
                  style: TextStyle(color: c.textFaint, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

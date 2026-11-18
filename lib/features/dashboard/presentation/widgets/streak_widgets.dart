import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/duo_colors.dart';
import '../../../../core/utils/day_utils.dart';
import '../../../reading_plan/domain/models/streak_status.dart';

/// Chip do topo: chama + número de dias.
class StreakChip extends StatelessWidget {
  const StreakChip({super.key, required this.status});

  final StreakStatus status;

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    final active = status.readToday;
    return Tooltip(
      message: 'Ofensiva: ${status.currentStreak} dias',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_rounded, color: active ? c.streak.fill : c.textFaint, size: 28),
          Text(
            '${status.currentStreak}',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: active ? c.streak.fill : c.textFaint),
          ),
        ],
      ),
    );
  }
}

/// Chip do topo: escudos acumulados.
class ShieldCountChip extends StatelessWidget {
  const ShieldCountChip({super.key, required this.status});

  final StreakStatus status;

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    final has = status.shields > 0;
    return Tooltip(
      message: '${status.shields} ${status.shields == 1 ? 'escudo' : 'escudos'}',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(has ? Icons.shield_rounded : Icons.shield_outlined, color: has ? c.grace.fill : c.textFaint, size: 26),
          const SizedBox(width: 2),
          Text(
            '${status.shields}',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: has ? c.grace.fill : c.textFaint),
          ),
        ],
      ),
    );
  }
}

/// Faixa da semana (domingo a sábado) com o estado de cada dia.
class WeekStreakStrip extends StatelessWidget {
  const WeekStreakStrip({super.key, required this.activity, required this.status, required this.today});

  final Map<DateTime, int> activity;
  final StreakStatus status;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    final start = startOfWeek(today);
    const letters = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < 7; i++)
          Builder(builder: (context) {
            final day = addDays(start, i);
            final read = (activity[day] ?? 0) > 0;
            final grace = status.shieldDays.contains(day);
            final isToday = isSameDay(day, today);
            final future = day.isAfter(today);

            final Color fill;
            final Color border;
            Widget? inner;
            if (read) {
              fill = c.streak.fill;
              border = c.streak.shadow;
              inner = const Icon(Icons.check_rounded, color: Colors.white, size: 20);
            } else if (grace) {
              fill = c.grace.fill;
              border = c.grace.shadow;
              inner = const Icon(Icons.shield_rounded, color: Colors.white, size: 18);
            } else {
              fill = c.neutral.soft;
              border = isToday ? c.streak.fill : c.border;
            }

            return Column(
              children: [
                Text(
                  letters[i],
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: isToday ? c.streak.fill : c.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Opacity(
                  opacity: future ? 0.5 : 1,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: fill,
                      shape: BoxShape.circle,
                      border: Border.all(color: border, width: isToday && !read ? 3 : 2),
                    ),
                    child: inner,
                  ),
                ),
              ],
            );
          }),
      ],
    );
  }
}

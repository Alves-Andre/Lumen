import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/bible_constants.dart';
import '../../../../core/theme/duo_colors.dart';
import '../../../../core/utils/day_utils.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/duo_widgets.dart';
import '../../domain/models/streak_status.dart';
import '../providers/reading_plan_providers.dart';
import '../widgets/day_reading_summary.dart';

/// Histórico completo da ofensiva: todos os dias lidos, dias protegidos por
/// escudo e dias com devocional, mês a mês.
class StreakHistoryScreen extends ConsumerWidget {
  const StreakHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakStatusProvider);
    final readDays = ref.watch(readDaysProvider).value ?? const <DateTime>{};
    final noteDays = ref.watch(noteDaysProvider).value ?? const <DateTime>{};
    final today = dateOnly(DateTime.now());

    final first = readDays.isEmpty ? today : readDays.reduce((a, b) => a.isBefore(b) ? a : b);
    final monthCount = (today.year - first.year) * 12 + today.month - first.month + 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Sua ofensiva')),
      body: AsyncView<StreakStatus>(
        value: streak,
        builder: (s) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: monthCount + 2,
          itemBuilder: (context, i) {
            if (i == 0) return _Header(status: s);
            if (i == 1) return const _Legend();
            final month = DateTime(today.year, today.month - (i - 2));
            return _MonthCalendar(
              month: month,
              today: today,
              readDays: readDays,
              shieldDays: s.shieldDays,
              noteDays: noteDays,
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.status});

  final StreakStatus status;

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    final next = status.nextShieldIn;
    const every = BibleConstants.shieldEarnEveryDays;
    return Column(
      children: [
        DuoCard(
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    size: 64,
                    color: status.readToday ? c.streak.fill : c.border,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${status.currentStreak}',
                          style: TextStyle(fontSize: 40, height: 1, fontWeight: FontWeight.w800, color: c.streak.fill),
                        ),
                        Text(
                          status.currentStreak == 1 ? 'dia de ofensiva' : 'dias de ofensiva',
                          style: TextStyle(fontWeight: FontWeight.w800, color: c.streak.fill),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DuoStatBox(
                      label: 'Recorde',
                      value: '${status.longestStreak}',
                      tone: c.streak,
                      icon: Icons.emoji_events_rounded,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DuoStatBox(
                      label: 'Dias lidos',
                      value: thousands(status.totalDaysRead),
                      tone: c.success,
                      icon: Icons.auto_stories_rounded,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DuoStatBox(
                      label: 'Escudos',
                      value: '${status.shields}',
                      tone: c.grace,
                      icon: Icons.shield_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (next != null)
          DuoCard(
            color: c.grace.soft,
            borderColor: c.grace.shadow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield_rounded, color: c.grace.fill),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        next == 1 ? 'Leia amanhã para ganhar um escudo!' : 'Próximo escudo em $next dias de leitura',
                        style: TextStyle(fontWeight: FontWeight.w800, color: c.text),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DuoProgressBar(value: (every - next) / every, color: c.grace.fill, height: 12),
                const SizedBox(height: 10),
                Text(
                  'A cada $every dias seguidos de leitura você ganha 1 escudo. '
                  'Cada escudo protege sua ofensiva em 1 dia sem leitura. Os escudos se acumulam.',
                  style: TextStyle(color: c.textMuted, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    Widget item(Widget mark, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [mark, const SizedBox(width: 6), Text(label, style: TextStyle(color: c.textMuted, fontWeight: FontWeight.w700, fontSize: 12))],
        );
    Widget dot(Color color, [IconData? icon]) => Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: icon == null ? null : Icon(icon, size: 12, color: Colors.white),
        );
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: [
          item(dot(c.streak.fill), 'Leitura'),
          item(dot(c.grace.fill, Icons.shield_rounded), 'Escudo usado'),
          item(Icon(Icons.edit_note_rounded, size: 18, color: c.gold.fill), 'Devocional'),
        ],
      ),
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.month,
    required this.today,
    required this.readDays,
    required this.shieldDays,
    required this.noteDays,
  });

  final DateTime month;
  final DateTime today;
  final Set<DateTime> readDays;
  final Set<DateTime> shieldDays;
  final Set<DateTime> noteDays;

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    final offset = DateTime(month.year, month.month).weekday % 7;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final readCount = readDays.where((d) => d.year == month.year && d.month == month.month).length;

    return DuoCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(monthYear(month), style: Theme.of(context).textTheme.titleMedium)),
              Text(
                '$readCount ${readCount == 1 ? 'dia' : 'dias'}',
                style: TextStyle(color: c.streak.fill, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final l in const ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'])
                Expanded(
                  child: Text(
                    l,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w800, color: c.textFaint, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            children: [
              for (var i = 0; i < offset; i++) const SizedBox.shrink(),
              for (var d = 1; d <= daysInMonth; d++)
                _DayCell(
                  day: DateTime(month.year, month.month, d),
                  today: today,
                  read: readDays.contains(DateTime(month.year, month.month, d)),
                  shield: shieldDays.contains(DateTime(month.year, month.month, d)),
                  note: noteDays.contains(DateTime(month.year, month.month, d)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.today, required this.read, required this.shield, required this.note});

  final DateTime day;
  final DateTime today;
  final bool read;
  final bool shield;
  final bool note;

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    final future = day.isAfter(today);
    final isToday = isSameDay(day, today);
    final fill = read ? c.streak.fill : (shield ? c.grace.fill : Colors.transparent);
    final textColor = future ? c.textFaint : (read || shield ? Colors.white : c.text);

    return GestureDetector(
      onTap: future ? null : () => _openDay(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: fill,
                shape: BoxShape.circle,
                border: isToday ? Border.all(color: c.streak.fill, width: 2.5) : null,
              ),
              child: shield && !read
                  ? const Icon(Icons.shield_rounded, color: Colors.white, size: 18)
                  : Text('${day.day}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: textColor)),
            ),
          ),
          if (note)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(color: c.card, shape: BoxShape.circle),
                child: Icon(Icons.edit_note_rounded, size: 16, color: c.gold.fill),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openDay(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(fullDate(day), style: Theme.of(sheetContext).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  DayReadingSummary(day: day, protectedByShield: shield),
                ],
              ),
            ),
          ),
        ),
      );
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/duo_colors.dart';
import '../../../../core/utils/day_utils.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/duo_widgets.dart';
import '../providers/reading_plan_providers.dart';
import 'day_reading_summary.dart';

/// Calendário mensal com a intensidade de leitura de cada dia.
/// Tocar num dia lista os capítulos lidos ("Neste dia você leu…").
class ReadingHeatmap extends ConsumerStatefulWidget {
  const ReadingHeatmap({super.key});

  @override
  ConsumerState<ReadingHeatmap> createState() => _ReadingHeatmapState();
}

class _ReadingHeatmapState extends ConsumerState<ReadingHeatmap> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selected = dateOnly(DateTime.now());

  void _shiftMonth(int delta) => setState(() => _month = DateTime(_month.year, _month.month + delta));

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    final activity = ref.watch(monthActivityProvider(_month)).value ?? const {};
    final noteDays = ref.watch(noteDaysProvider).value ?? const <DateTime>{};
    final today = dateOnly(DateTime.now());
    final firstWeekday = DateTime(_month.year, _month.month).weekday % 7; // domingo = 0
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final monthTotal = activity.values.fold<int>(0, (a, b) => a + b);
    final daysRead = activity.values.where((v) => v > 0).length;
    final isCurrentMonth = _month.year == today.year && _month.month == today.month;

    Color cellColor(int count) => switch (count) {
      0 => c.neutral.soft,
      1 => c.success.fill.withValues(alpha: 0.35),
      2 || 3 => c.success.fill.withValues(alpha: 0.65),
      _ => c.success.fill,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DuoCard(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Mês anterior',
                    onPressed: () => _shiftMonth(-1),
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  Expanded(
                    child: Text(
                      monthYear(_month),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Próximo mês',
                    onPressed: isCurrentMonth ? null : () => _shiftMonth(1),
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
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
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                children: [
                  for (var i = 0; i < firstWeekday; i++) const SizedBox.shrink(),
                  for (var d = 1; d <= daysInMonth; d++)
                    Builder(
                      builder: (_) {
                        final day = DateTime(_month.year, _month.month, d);
                        final count = activity[day] ?? 0;
                        final selected = isSameDay(day, _selected);
                        final future = day.isAfter(today);
                        return GestureDetector(
                          onTap: future ? null : () => setState(() => _selected = day),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned.fill(
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: future ? Colors.transparent : cellColor(count),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: selected
                                          ? c.primary.fill
                                          : (isSameDay(day, today) ? c.streak.fill : Colors.transparent),
                                      width: 2.5,
                                    ),
                                  ),
                                  child: Text(
                                    '$d',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: future ? c.textFaint : (count >= 2 ? Colors.white : c.text),
                                    ),
                                  ),
                                ),
                              ),
                              if (noteDays.contains(day))
                                Positioned(
                                  right: -3,
                                  top: -3,
                                  child: Container(
                                    padding: const EdgeInsets.all(1),
                                    decoration: BoxDecoration(color: c.card, shape: BoxShape.circle),
                                    child: Icon(Icons.edit_note_rounded, size: 14, color: c.gold.fill),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '$monthTotal ${monthTotal == 1 ? 'capítulo' : 'capítulos'} em $daysRead ${daysRead == 1 ? 'dia' : 'dias'}',
                style: TextStyle(fontWeight: FontWeight.w800, color: c.textMuted),
              ),
            ],
          ),
        ),
        _DayDetail(day: _selected),
      ],
    );
  }
}

class _DayDetail extends StatelessWidget {
  const _DayDetail({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) => DuoCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(fullDate(day), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        DayReadingSummary(day: day),
      ],
    ),
  );
}

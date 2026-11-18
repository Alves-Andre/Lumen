import 'dart:math';

import '../../../../core/constants/bible_constants.dart';
import '../../../../core/database/daos/reading_dao.dart';
import '../../../../core/utils/day_utils.dart';
import '../../../../core/utils/streams.dart';
import '../models/streak_status.dart';

/// Cálculo puro da ofensiva com Escudos.
///
/// Regras:
/// * Um dia conta se tiver ao menos 1 registro em ReadingLogs.
/// * Hoje sem leitura não quebra nada (o dia ainda está em aberto).
/// * A cada [shieldEarnEvery] dias de leitura na sequência atual (15, 30, 45…)
///   o usuário ganha 1 escudo. Escudos são cumulativos e sem limite.
/// * Um dia passado sem leitura consome 1 escudo e a sequência continua
///   (sem somar o dia). Sem escudo, a sequência é zerada — o histórico de
///   leituras continua no calendário.
class StreakCalculator {
  const StreakCalculator({
    this.shieldsEnabled = true,
    this.shieldEarnEvery = BibleConstants.shieldEarnEveryDays,
  });

  final bool shieldsEnabled;
  final int shieldEarnEvery;

  StreakStatus calculate(Iterable<DateTime> readTimestamps, DateTime now) {
    final today = dateOnly(now);
    final readDays = readTimestamps.map(dateOnly).where((d) => !d.isAfter(today)).toSet();
    if (readDays.isEmpty) {
      return StreakStatus.empty.copyWithNextShield(shieldsEnabled ? shieldEarnEvery : null);
    }

    final firstDay = readDays.reduce((a, b) => a.isBefore(b) ? a : b);
    var run = 0;
    var longest = 0;
    var shields = 0;
    final shieldDays = <DateTime>{};

    for (var day = firstDay; !day.isAfter(today); day = addDays(day, 1)) {
      if (readDays.contains(day)) {
        run++;
        longest = max(longest, run);
        if (shieldsEnabled && run % shieldEarnEvery == 0) shields++;
        continue;
      }
      if (isSameDay(day, today)) break; // dia em aberto
      if (shields > 0) {
        shields--;
        shieldDays.add(day);
      } else {
        run = 0;
      }
    }

    return StreakStatus(
      currentStreak: run,
      longestStreak: longest,
      readToday: readDays.contains(today),
      shields: shields,
      shieldDays: shieldDays,
      totalDaysRead: readDays.length,
      nextShieldIn: shieldsEnabled ? shieldEarnEvery - run % shieldEarnEvery : null,
    );
  }
}

class StreakService {
  StreakService(this._dao, {Clock? clock, this.calculator = const StreakCalculator()})
      : _clock = clock ?? DateTime.now;

  final ReadingDao _dao;
  final Clock _clock;
  final StreakCalculator calculator;

  Future<StreakStatus> compute() async {
    final dates = await _dao.getAllReadDates();
    return calculator.calculate(dates, _clock());
  }

  Stream<StreakStatus> watch() => recomputeOn(_dao.watchChanges(), compute);
}

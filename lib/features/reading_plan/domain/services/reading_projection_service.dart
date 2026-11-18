import '../../../../core/constants/bible_constants.dart';
import '../../../../core/database/daos/reading_dao.dart';
import '../../../../core/utils/day_utils.dart';
import '../../../../core/utils/streams.dart';
import '../models/reading_projection.dart';

/// Cálculo puro (sem banco) da projeção de término — testável isoladamente.
abstract final class ReadingProjectionCalculator {
  /// [recentReadDates]: `readAt` dos registros recentes (podem vir além da janela; são filtrados aqui).
  /// [firstReadAt]: primeiro registro de leitura do usuário (qualquer ciclo).
  static ReadingProjection calculate({
    required int uniqueChaptersReadInCycle,
    required Iterable<DateTime> recentReadDates,
    required DateTime? firstReadAt,
    required DateTime now,
    int windowDays = BibleConstants.projectionWindowDays,
    int totalChapters = BibleConstants.totalChapters,
  }) {
    final today = dateOnly(now);
    final read = uniqueChaptersReadInCycle.clamp(0, totalChapters);
    final remaining = totalChapters - read;

    // Janela: últimos 14 dias corridos (incluindo hoje) ou desde o primeiro dia de leitura.
    var effectiveWindow = 0;
    if (firstReadAt != null) {
      effectiveWindow = (daysBetween(firstReadAt, today) + 1).clamp(1, windowDays);
    }

    var dailyAverage = 0.0;
    if (effectiveWindow > 0) {
      final windowStart = addDays(today, -(effectiveWindow - 1));
      final chaptersInWindow = recentReadDates.where((d) {
        final day = dateOnly(d);
        return !day.isBefore(windowStart) && !day.isAfter(today);
      }).length;
      dailyAverage = chaptersInWindow / effectiveWindow;
    }

    int? estimatedDays;
    DateTime? finishDate;
    if (remaining == 0) {
      estimatedDays = 0;
      finishDate = today;
    } else if (dailyAverage > 0) {
      estimatedDays = (remaining / dailyAverage).ceil();
      finishDate = addDays(today, estimatedDays);
    }

    return ReadingProjection(
      totalChapters: totalChapters,
      chaptersReadInCycle: read,
      dailyAverage: dailyAverage,
      windowDays: effectiveWindow == 0 ? windowDays : effectiveWindow,
      hasAnyReading: firstReadAt != null,
      estimatedDays: estimatedDays,
      estimatedFinishDate: finishDate,
    );
  }
}

class ReadingProjectionService {
  ReadingProjectionService(this._dao, {Clock? clock}) : _clock = clock ?? DateTime.now;

  final ReadingDao _dao;
  final Clock _clock;

  Future<ReadingProjection> compute() async {
    final now = _clock();
    final today = dateOnly(now);
    final cycle = await _dao.getOrCreateActiveCycle();
    final unique = await _dao.countUniqueChaptersInCycle(cycle.id);
    final firstReadAt = await _dao.getFirstReadAt();
    final recent = await _dao.getReadDatesBetween(
      addDays(today, -(BibleConstants.projectionWindowDays - 1)),
      addDays(today, 1),
    );
    return ReadingProjectionCalculator.calculate(
      uniqueChaptersReadInCycle: unique,
      recentReadDates: recent,
      firstReadAt: firstReadAt,
      now: now,
    );
  }

  /// Recalcula a cada leitura registrada/removida ou troca de ciclo.
  Stream<ReadingProjection> watch() => recomputeOn(_dao.watchChanges(), compute);
}

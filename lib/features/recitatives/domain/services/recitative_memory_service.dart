import '../../../../core/constants/bible_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/recitatives_dao.dart';
import '../../../../core/utils/day_utils.dart';
import '../../../../core/utils/streams.dart';
import '../models/recitative_memory.dart';

/// Lógica pura de "Nesse mesmo dia".
///
/// 1. Exato: `serviceDate.month == hoje.month && serviceDate.day == hoje.day && serviceDate.year < hoje.year`.
/// 2. Fallback (só se não houver exato): cultos a até ±[windowDays] dias do
///    aniversário de hoje em anos anteriores (trata viradas de ano, ex.: 30/12 ↔ 01/01).
abstract final class RecitativeMemoryMatcher {
  static RecitativeMemoryResult match(
    Iterable<RecitativeWithBook> candidates,
    DateTime now, {
    int windowDays = BibleConstants.memoryWindowDays,
  }) {
    final today = dateOnly(now);
    final exact = <RecitativeMemory>[];
    final nearby = <RecitativeMemory>[];

    for (final item in candidates) {
      final service = dateOnly(item.recitative.serviceDate);
      if (service.year < today.year && service.month == today.month && service.day == today.day) {
        exact.add(RecitativeMemory(
          item: item,
          yearsAgo: today.year - service.year,
          dayOffset: 0,
          isExactDay: true,
        ));
        continue;
      }
      final closest = _closestAnniversary(service, today);
      if (closest != null && closest.offset.abs() <= windowDays) {
        nearby.add(RecitativeMemory(
          item: item,
          yearsAgo: closest.yearsAgo,
          dayOffset: closest.offset,
          isExactDay: false,
        ));
      }
    }

    if (exact.isNotEmpty) {
      exact.sort((a, b) => a.yearsAgo.compareTo(b.yearsAgo));
      return RecitativeMemoryResult(exact);
    }
    nearby.sort((a, b) {
      final byDistance = a.dayOffset.abs().compareTo(b.dayOffset.abs());
      return byDistance != 0 ? byDistance : a.yearsAgo.compareTo(b.yearsAgo);
    });
    return RecitativeMemoryResult(nearby);
  }

  /// Compara a data do culto com o "hoje" de 1+ anos atrás mais próximo.
  static ({int yearsAgo, int offset})? _closestAnniversary(DateTime service, DateTime today) {
    final base = today.year - service.year;
    ({int yearsAgo, int offset})? best;
    for (final k in [base - 1, base, base + 1]) {
      if (k < 1) continue;
      final anniversary = DateTime(today.year - k, today.month, today.day);
      final offset = daysBetween(anniversary, service);
      if (best == null || offset.abs() < best.offset.abs()) best = (yearsAgo: k, offset: offset);
    }
    return best;
  }
}

class RecitativeMemoryService {
  RecitativeMemoryService(
    this._dao, {
    Clock? clock,
    this.windowDays = BibleConstants.memoryWindowDays,
  }) : _clock = clock ?? DateTime.now;

  final RecitativesDao _dao;
  final Clock _clock;
  final int windowDays;

  Future<RecitativeMemoryResult> getMemories() async {
    final today = dateOnly(_clock());
    // Tudo que pode estar a ≤ windowDays do aniversário de 1+ ano atrás.
    final cutoff = DateTime(today.year - 1, today.month, today.day + windowDays + 1);
    final candidates = await _dao.getByServiceDateBefore(cutoff);
    return RecitativeMemoryMatcher.match(candidates, today, windowDays: windowDays);
  }

  Stream<RecitativeMemoryResult> watch() => recomputeOn(_dao.watchChanges(), getMemories);
}

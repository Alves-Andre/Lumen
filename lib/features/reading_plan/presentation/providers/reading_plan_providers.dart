import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/utils/day_utils.dart';
import '../../../../core/utils/streams.dart';
import '../../domain/models/reading_projection.dart';
import '../../domain/models/streak_status.dart';
import '../../domain/services/reading_projection_service.dart';
import '../../domain/services/streak_service.dart';

part 'reading_plan_providers.g.dart';

@Riverpod(keepAlive: true)
ReadingProjectionService readingProjectionService(Ref ref) =>
    ReadingProjectionService(ref.watch(appDatabaseProvider).readingDao);

@Riverpod(keepAlive: true)
StreakService streakService(Ref ref) {
  final graceEnabled = ref.watch(appSettingsProvider.select((s) => s.value?.graceEnabled ?? true));
  return StreakService(
    ref.watch(appDatabaseProvider).readingDao,
    calculator: StreakCalculator(shieldsEnabled: graceEnabled),
  );
}

@riverpod
Stream<ReadingProjection> readingProjection(Ref ref) => ref.watch(readingProjectionServiceProvider).watch();

@riverpod
Stream<StreakStatus> streakStatus(Ref ref) => ref.watch(streakServiceProvider).watch();

// Escritos à mão: ReadingCycle é gerado pelo Drift (ver bible_providers.dart).
final activeCycleProvider = StreamProvider<ReadingCycle?>(
  (ref) => ref.watch(appDatabaseProvider).readingDao.watchActiveCycle(),
);

final readingCyclesProvider = StreamProvider.autoDispose<List<ReadingCycle>>(
  (ref) => ref.watch(appDatabaseProvider).readingDao.watchCycles(),
);

/// Capítulos únicos lidos no ciclo ativo, por livro.
@riverpod
Stream<Map<int, int>> readCountsPerBook(Ref ref) async* {
  final cycle = await ref.watch(activeCycleProvider.future);
  if (cycle == null) {
    yield const {};
    return;
  }
  yield* ref.watch(appDatabaseProvider).readingDao.watchReadCountsPerBook(cycle.id);
}

/// Capítulos de um livro já lidos no ciclo ativo.
@riverpod
Stream<Set<int>> readChaptersOfBook(Ref ref, int bookId) async* {
  final cycle = await ref.watch(activeCycleProvider.future);
  if (cycle == null) {
    yield const {};
    return;
  }
  yield* ref.watch(appDatabaseProvider).readingDao.watchReadChaptersOfBook(bookId, cycle.id);
}

class ContinueReading {
  const ContinueReading(this.book, this.chapter);

  final Book book;
  final int chapter;

  String get label => '${book.name} $chapter';
}

/// Alvo do botão "Continuar leitura".
@riverpod
Stream<ContinueReading> continueReading(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return recomputeOn(db.readingDao.watchChanges(), () async {
    final target = await db.readingDao.getContinueReadingTarget();
    return ContinueReading(await db.bibleDao.getBook(target.bookId), target.chapter);
  });
}

/// Capítulos por dia em um mês (heatmap). [month] é qualquer dia do mês.
@riverpod
Stream<Map<DateTime, int>> monthActivity(Ref ref, DateTime month) {
  final first = DateTime(month.year, month.month);
  final next = DateTime(month.year, month.month + 1);
  return ref.watch(appDatabaseProvider).readingDao.watchChaptersPerDay(first, next);
}

/// Semana atual (domingo a sábado) para a faixa de ofensiva do painel.
@riverpod
Stream<Map<DateTime, int>> weekActivity(Ref ref) {
  final start = startOfWeek(DateTime.now());
  return ref.watch(appDatabaseProvider).readingDao.watchChaptersPerDay(start, addDays(start, 7));
}

@riverpod
Stream<List<ReadingLogWithBook>> logsOnDay(Ref ref, DateTime day) =>
    ref.watch(appDatabaseProvider).readingDao.watchLogsOnDay(day);

/// Todos os dias com leitura (calendário de histórico da ofensiva).
@riverpod
Stream<Set<DateTime>> readDays(Ref ref) => ref.watch(appDatabaseProvider).readingDao.watchReadDays();

/// Dias em que um devocional (anotação) foi criado.
@riverpod
Stream<Set<DateTime>> noteDays(Ref ref) => ref.watch(appDatabaseProvider).notesDao.watchNoteDays();

@riverpod
Stream<List<VerseNoteWithBook>> notesOnDay(Ref ref, DateTime day) =>
    ref.watch(appDatabaseProvider).notesDao.watchOnDay(day);

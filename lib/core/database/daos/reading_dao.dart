import 'package:drift/drift.dart';

import '../../utils/day_utils.dart';
import '../app_database.dart';
import '../tables.dart';

part 'reading_dao.g.dart';

@DriftAccessor(tables: [ReadingLogs, ReadingCycles, Books])
class ReadingDao extends DatabaseAccessor<AppDatabase> with _$ReadingDaoMixin {
  ReadingDao(super.attachedDatabase);

  // ---------------------------------------------------------------- Ciclos

  /// Ciclo ativo. Se a sincronização trouxer mais de um ativo, vale o mais
  /// recente (até [SyncDao.consolidateActiveRows] juntá-los).
  Future<ReadingCycle?> getActiveCycle() => _activeCycleQuery().getSingleOrNull();

  Stream<ReadingCycle?> watchActiveCycle() => _activeCycleQuery().watchSingleOrNull();

  SimpleSelectStatement<$ReadingCyclesTable, ReadingCycle> _activeCycleQuery() => select(readingCycles)
    ..where((c) => c.endedAt.isNull() & c.deletedAt.isNull())
    ..orderBy([(c) => OrderingTerm.desc(c.startedAt)])
    ..limit(1);

  Future<ReadingCycle> getOrCreateActiveCycle() => transaction(() async {
        final active = await getActiveCycle();
        if (active != null) return active;
        return into(readingCycles).insertReturning(ReadingCyclesCompanion.insert(startedAt: DateTime.now()));
      });

  /// Encerra o ciclo ativo e abre outro. O histórico de leituras é preservado.
  Future<ReadingCycle> startNewCycle({DateTime? at}) => transaction(() async {
        final now = at ?? DateTime.now();
        await (update(readingCycles)..where((c) => c.endedAt.isNull() & c.deletedAt.isNull())).write(
          ReadingCyclesCompanion(endedAt: Value(now), updatedAt: Value(DateTime.now()), isSynced: const Value(false)),
        );
        return into(readingCycles).insertReturning(ReadingCyclesCompanion.insert(startedAt: now));
      });

  Stream<List<ReadingCycle>> watchCycles() => (select(readingCycles)
        ..where((c) => c.deletedAt.isNull())
        ..orderBy([(c) => OrderingTerm.desc(c.startedAt)]))
      .watch();

  // -------------------------------------------------------------- Registros

  /// Registra a leitura de um capítulo. Retorna `false` (sem inserir) se o
  /// mesmo capítulo já foi marcado no mesmo dia de [readAt].
  Future<bool> logChapter({
    required int bookId,
    required int chapter,
    required DateTime readAt,
    ReadingSource source = ReadingSource.app,
  }) =>
      transaction(() async {
        final book = await attachedDatabase.bibleDao.getBook(bookId);
        if (chapter < 1 || chapter > book.chaptersCount) {
          throw ArgumentError.value(chapter, 'chapter', '${book.name} tem ${book.chaptersCount} capítulos');
        }
        if (await _existsOnDay(bookId, chapter, readAt)) return false;
        final cycle = await getOrCreateActiveCycle();
        await into(readingLogs).insert(ReadingLogsCompanion.insert(
          bookId: bookId,
          chapter: chapter,
          readAt: readAt,
          source: source,
          cycleId: cycle.id,
        ));
        return true;
      });

  /// Registro retroativo / Bíblia física: vários capítulos numa mesma data.
  /// Retorna quantos foram efetivamente inseridos.
  Future<int> logChapters(
    List<ChapterRef> chapters, {
    required DateTime readAt,
    ReadingSource source = ReadingSource.physicalBible,
  }) =>
      transaction(() async {
        var inserted = 0;
        for (final ref in chapters) {
          final ok = await logChapter(bookId: ref.bookId, chapter: ref.chapter, readAt: readAt, source: source);
          if (ok) inserted++;
        }
        return inserted;
      });

  /// Desmarca um capítulo lido no dia de [day] (exclusão lógica, sincronizada).
  Future<int> unmarkChapter({required int bookId, required int chapter, required DateTime day}) {
    final start = dateOnly(day);
    final end = addDays(start, 1);
    return (update(readingLogs)
          ..where((l) =>
              l.deletedAt.isNull() &
              l.bookId.equals(bookId) &
              l.chapter.equals(chapter) &
              l.readAt.isBiggerOrEqualValue(start) &
              l.readAt.isSmallerThanValue(end)))
        .write(_deleted());
  }

  Future<int> deleteLog(String id) =>
      (update(readingLogs)..where((l) => l.id.equals(id) & l.deletedAt.isNull())).write(_deleted());

  static ReadingLogsCompanion _deleted() {
    final now = DateTime.now();
    return ReadingLogsCompanion(deletedAt: Value(now), updatedAt: Value(now), isSynced: const Value(false));
  }

  Future<bool> _existsOnDay(int bookId, int chapter, DateTime day) async {
    final start = dateOnly(day);
    final end = addDays(start, 1);
    final existing = await (select(readingLogs)
          ..where((l) =>
              l.deletedAt.isNull() &
              l.bookId.equals(bookId) &
              l.chapter.equals(chapter) &
              l.readAt.isBiggerOrEqualValue(start) &
              l.readAt.isSmallerThanValue(end))
          ..limit(1))
        .getSingleOrNull();
    return existing != null;
  }

  // ------------------------------------------------------------- Consultas

  /// Registros não excluídos.
  Expression<bool> get _active => readingLogs.deletedAt.isNull();

  Future<int> countUniqueChaptersInCycle(String cycleId) => _uniqueChaptersQuery(cycleId).getSingle();

  Stream<int> watchUniqueChaptersInCycle(String cycleId) => _uniqueChaptersQuery(cycleId).watchSingle();

  Selectable<int> _uniqueChaptersQuery(String cycleId) => customSelect(
        'SELECT COUNT(*) AS total FROM '
        '(SELECT DISTINCT book_id, chapter FROM reading_logs WHERE cycle_id = ? AND deleted_at IS NULL)',
        variables: [Variable.withString(cycleId)],
        readsFrom: {readingLogs},
      ).map((row) => row.read<int>('total'));

  /// Capítulos de um livro já lidos no ciclo (para marcar o grid de capítulos).
  Stream<Set<int>> watchReadChaptersOfBook(int bookId, String cycleId) {
    final query = selectOnly(readingLogs, distinct: true)
      ..addColumns([readingLogs.chapter])
      ..where(_active & readingLogs.bookId.equals(bookId) & readingLogs.cycleId.equals(cycleId));
    return query.map((r) => r.read(readingLogs.chapter)!).watch().map((list) => list.toSet());
  }

  /// Capítulos únicos lidos no ciclo, por livro (barra de progresso de cada livro).
  Stream<Map<int, int>> watchReadCountsPerBook(String cycleId) => customSelect(
        'SELECT book_id, COUNT(DISTINCT chapter) AS total FROM reading_logs '
        'WHERE cycle_id = ? AND deleted_at IS NULL GROUP BY book_id',
        variables: [Variable.withString(cycleId)],
        readsFrom: {readingLogs},
      ).watch().map((rows) => {for (final r in rows) r.read<int>('book_id'): r.read<int>('total')});

  /// Dias (meia-noite local) com ao menos uma leitura, em todo o histórico.
  Stream<Set<DateTime>> watchReadDays() {
    final query = selectOnly(readingLogs)
      ..addColumns([readingLogs.readAt])
      ..where(_active);
    return query.map((r) => dateOnly(r.read(readingLogs.readAt)!)).watch().map((days) => days.toSet());
  }

  /// Capítulos com leitura registrada a partir de [since] (progresso dos planos).
  Future<Set<ChapterRef>> getChaptersReadSince(DateTime since) async {
    final query = selectOnly(readingLogs, distinct: true)
      ..addColumns([readingLogs.bookId, readingLogs.chapter])
      ..where(_active & readingLogs.readAt.isBiggerOrEqualValue(since));
    final rows = await query.get();
    return {
      for (final r in rows) (bookId: r.read(readingLogs.bookId)!, chapter: r.read(readingLogs.chapter)!),
    };
  }

  /// Datas/horas de todos os registros (base da ofensiva).
  Future<List<DateTime>> getAllReadDates() {
    final query = selectOnly(readingLogs)
      ..addColumns([readingLogs.readAt])
      ..where(_active);
    return query.map((r) => r.read(readingLogs.readAt)!).get();
  }

  /// Datas/horas dos registros em [from, to).
  Future<List<DateTime>> getReadDatesBetween(DateTime from, DateTime to) {
    final query = selectOnly(readingLogs)
      ..addColumns([readingLogs.readAt])
      ..where(_active & readingLogs.readAt.isBiggerOrEqualValue(from) & readingLogs.readAt.isSmallerThanValue(to));
    return query.map((r) => r.read(readingLogs.readAt)!).get();
  }

  Future<DateTime?> getFirstReadAt() async {
    final first = await (select(readingLogs)
          ..where((l) => l.deletedAt.isNull())
          ..orderBy([(l) => OrderingTerm.asc(l.readAt)])
          ..limit(1))
        .getSingleOrNull();
    return first?.readAt;
  }

  Future<ReadingLog?> getLastLog() => (select(readingLogs)
        ..where((l) => l.deletedAt.isNull())
        ..orderBy([(l) => OrderingTerm.desc(l.readAt), (l) => OrderingTerm.desc(l.updatedAt)])
        ..limit(1))
      .getSingleOrNull();

  /// Alvo do botão "Continuar leitura": capítulo seguinte ao último registrado
  /// (Gênesis 1 se não houver registros; volta a Gênesis 1 após Apocalipse 22).
  Future<ChapterRef> getContinueReadingTarget() async {
    final last = await getLastLog();
    if (last == null) return (bookId: 1, chapter: 1);
    return await attachedDatabase.bibleDao.nextChapter(last.bookId, last.chapter) ?? (bookId: 1, chapter: 1);
  }

  /// "Neste dia você leu: Romanos 8, Romanos 9".
  Stream<List<ReadingLogWithBook>> watchLogsOnDay(DateTime day) {
    final start = dateOnly(day);
    final end = addDays(start, 1);
    final query = select(readingLogs).join([innerJoin(books, books.id.equalsExp(readingLogs.bookId))])
      ..where(_active & readingLogs.readAt.isBiggerOrEqualValue(start) & readingLogs.readAt.isSmallerThanValue(end))
      ..orderBy([OrderingTerm.asc(readingLogs.readAt), OrderingTerm.asc(readingLogs.updatedAt)]);
    return query.map((row) => ReadingLogWithBook(row.readTable(readingLogs), row.readTable(books))).watch();
  }

  /// Quantidade de capítulos por dia em [from, to) — base do heatmap.
  Stream<Map<DateTime, int>> watchChaptersPerDay(DateTime from, DateTime to) {
    final query = selectOnly(readingLogs)
      ..addColumns([readingLogs.readAt])
      ..where(_active & readingLogs.readAt.isBiggerOrEqualValue(from) & readingLogs.readAt.isSmallerThanValue(to));
    return query.map((r) => r.read(readingLogs.readAt)!).watch().map((dates) {
      final counts = <DateTime, int>{};
      for (final d in dates) {
        final key = dateOnly(d);
        counts[key] = (counts[key] ?? 0) + 1;
      }
      return counts;
    });
  }

  /// Dispara a cada escrita em registros ou ciclos.
  Stream<Set<TableUpdate>> watchChanges() =>
      attachedDatabase.tableUpdates(TableUpdateQuery.onAllTables([readingLogs, readingCycles]));
}

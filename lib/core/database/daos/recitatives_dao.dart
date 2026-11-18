import 'package:drift/drift.dart';

import '../../utils/day_utils.dart';
import '../app_database.dart';
import '../tables.dart';

part 'recitatives_dao.g.dart';

@DriftAccessor(tables: [Recitatives, Books])
class RecitativesDao extends DatabaseAccessor<AppDatabase> with _$RecitativesDaoMixin {
  RecitativesDao(super.attachedDatabase);

  /// Cria um recitativo puxando o texto exato da ARC para `verseTextSnapshot`.
  Future<int> createRecitative({
    required int bookId,
    required int chapter,
    required int verseStart,
    int? verseEnd,
    required DateTime serviceDate,
    String? congregation,
    String? notes,
    RecitativeStatus status = RecitativeStatus.pending,
  }) async {
    final snapshot = await _snapshot(bookId, chapter, verseStart, verseEnd);
    return into(recitatives).insert(RecitativesCompanion.insert(
      bookId: bookId,
      chapter: chapter,
      verseStart: verseStart,
      verseEnd: Value(_normalizedEnd(verseStart, verseEnd)),
      verseTextSnapshot: snapshot,
      serviceDate: serviceDate,
      congregation: Value(_blankToNull(congregation)),
      notes: Value(_blankToNull(notes)),
      status: status,
    ));
  }

  /// Atualiza todos os campos editáveis e regenera o texto da ARC.
  Future<void> updateRecitative({
    required int id,
    required int bookId,
    required int chapter,
    required int verseStart,
    int? verseEnd,
    required DateTime serviceDate,
    String? congregation,
    String? notes,
  }) async {
    final snapshot = await _snapshot(bookId, chapter, verseStart, verseEnd);
    await (update(recitatives)..where((r) => r.id.equals(id))).write(RecitativesCompanion(
      bookId: Value(bookId),
      chapter: Value(chapter),
      verseStart: Value(verseStart),
      verseEnd: Value(_normalizedEnd(verseStart, verseEnd)),
      verseTextSnapshot: Value(snapshot),
      serviceDate: Value(serviceDate),
      congregation: Value(_blankToNull(congregation)),
      notes: Value(_blankToNull(notes)),
    ));
  }

  Future<void> markAsRecited(int id, {String? notes}) =>
      (update(recitatives)..where((r) => r.id.equals(id))).write(RecitativesCompanion(
        status: const Value(RecitativeStatus.recited),
        notes: notes == null ? const Value.absent() : Value(_blankToNull(notes)),
      ));

  Future<void> markAsPending(int id) => (update(recitatives)..where((r) => r.id.equals(id)))
      .write(const RecitativesCompanion(status: Value(RecitativeStatus.pending)));

  Future<int> deleteRecitative(int id) => (delete(recitatives)..where((r) => r.id.equals(id))).go();

  Future<RecitativeWithBook?> getById(int id) =>
      (_joined()..where(recitatives.id.equals(id))).map(_map).getSingleOrNull();

  Stream<RecitativeWithBook?> watchById(int id) =>
      (_joined()..where(recitatives.id.equals(id))).map(_map).watchSingleOrNull();

  /// Aba "Próximos": pendentes por data do culto (mais próxima primeiro).
  Stream<List<RecitativeWithBook>> watchPending() => (_joined()
        ..where(recitatives.status.equalsValue(RecitativeStatus.pending))
        ..orderBy([OrderingTerm.asc(recitatives.serviceDate)]))
      .map(_map)
      .watch();

  /// Aba "Histórico": recitados, do mais recente ao mais antigo.
  Stream<List<RecitativeWithBook>> watchRecited() => (_joined()
        ..where(recitatives.status.equalsValue(RecitativeStatus.recited))
        ..orderBy([OrderingTerm.desc(recitatives.serviceDate)]))
      .map(_map)
      .watch();

  /// Próximo recitativo pendente com culto a partir de hoje.
  Stream<RecitativeWithBook?> watchNextPending(DateTime today) => (_joined()
        ..where(recitatives.status.equalsValue(RecitativeStatus.pending) &
            recitatives.serviceDate.isBiggerOrEqualValue(dateOnly(today)))
        ..orderBy([OrderingTerm.asc(recitatives.serviceDate)])
        ..limit(1))
      .map(_map)
      .watchSingleOrNull();

  Future<List<RecitativeWithBook>> getAll() =>
      (_joined()..orderBy([OrderingTerm.asc(recitatives.serviceDate)])).map(_map).get();

  /// Candidatos às "Lembranças": cultos anteriores a [cutoff].
  Future<List<RecitativeWithBook>> getByServiceDateBefore(DateTime cutoff) => (_joined()
        ..where(recitatives.serviceDate.isSmallerThanValue(cutoff))
        ..orderBy([OrderingTerm.desc(recitatives.serviceDate)]))
      .map(_map)
      .get();

  Stream<Set<TableUpdate>> watchChanges() =>
      attachedDatabase.tableUpdates(TableUpdateQuery.onAllTables([recitatives]));

  JoinedSelectStatement<HasResultSet, dynamic> _joined() =>
      select(recitatives).join([innerJoin(books, books.id.equalsExp(recitatives.bookId))]);

  RecitativeWithBook _map(TypedResult row) =>
      RecitativeWithBook(row.readTable(recitatives), row.readTable(books));

  Future<String> _snapshot(int bookId, int chapter, int verseStart, int? verseEnd) async {
    if (verseEnd != null && verseEnd < verseStart) {
      throw ArgumentError.value(verseEnd, 'verseEnd', 'deve ser maior ou igual ao versículo inicial');
    }
    // Recitativos usam sempre a ARC, independentemente da versão escolhida para leitura.
    final text = await attachedDatabase.bibleDao
        .getPassageText(BibleTranslation.primary, bookId, chapter, verseStart, verseEnd);
    if (text.isEmpty) {
      throw ArgumentError('Referência inexistente na ARC: livro $bookId, $chapter:$verseStart-${verseEnd ?? verseStart}');
    }
    return text;
  }

  static int? _normalizedEnd(int start, int? end) => (end == null || end == start) ? null : end;

  static String? _blankToNull(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();
}

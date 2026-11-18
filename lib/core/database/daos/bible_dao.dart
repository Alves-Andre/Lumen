import 'package:drift/drift.dart';

import '../../constants/bible_constants.dart';
import '../app_database.dart';
import '../tables.dart';

part 'bible_dao.g.dart';

@DriftAccessor(tables: [Books, Verses])
class BibleDao extends DatabaseAccessor<AppDatabase> with _$BibleDaoMixin {
  BibleDao(super.attachedDatabase);

  /// Livros carregados e ao menos um versículo de [translation].
  Future<bool> isSeeded(BibleTranslation translation) async {
    final bookCount = books.id.count();
    final verseCount = verses.id.count();
    final booksTotal =
        await (selectOnly(books)..addColumns([bookCount])).map((r) => r.read(bookCount) ?? 0).getSingle();
    if (booksTotal != BibleConstants.totalBooks) return false;
    final versesTotal = await (selectOnly(verses)
          ..addColumns([verseCount])
          ..where(verses.translation.equalsValue(translation)))
        .map((r) => r.read(verseCount) ?? 0)
        .getSingle();
    return versesTotal > 0;
  }

  Future<List<Book>> getAllBooks() => (select(books)..orderBy([(b) => OrderingTerm.asc(b.id)])).get();

  Stream<List<Book>> watchAllBooks() => (select(books)..orderBy([(b) => OrderingTerm.asc(b.id)])).watch();

  Future<Book> getBook(int bookId) => (select(books)..where((b) => b.id.equals(bookId))).getSingle();

  Future<List<Verse>> getChapter(BibleTranslation translation, int bookId, int chapter) => (select(verses)
        ..where((v) => v.translation.equalsValue(translation) & v.bookId.equals(bookId) & v.chapter.equals(chapter))
        ..orderBy([(v) => OrderingTerm.asc(v.verse)]))
      .get();

  /// Versículos [verseStart]..[verseEnd] (inclusive). Sem [verseEnd], apenas um versículo.
  Future<List<Verse>> getPassage(
    BibleTranslation translation,
    int bookId,
    int chapter,
    int verseStart, [
    int? verseEnd,
  ]) =>
      (select(verses)
            ..where((v) =>
                v.translation.equalsValue(translation) &
                v.bookId.equals(bookId) &
                v.chapter.equals(chapter) &
                v.verse.isBetweenValues(verseStart, verseEnd ?? verseStart))
            ..orderBy([(v) => OrderingTerm.asc(v.verse)]))
          .get();

  /// Texto corrido da passagem (sem números de versículo). Vazio se a referência não existir.
  Future<String> getPassageText(
    BibleTranslation translation,
    int bookId,
    int chapter,
    int verseStart, [
    int? verseEnd,
  ]) async {
    final passage = await getPassage(translation, bookId, chapter, verseStart, verseEnd);
    return passage.map((v) => v.verseText.trim()).join(' ');
  }

  Future<int> countVerses(BibleTranslation translation, int bookId, int chapter) async {
    final c = verses.id.count();
    return (selectOnly(verses)
          ..addColumns([c])
          ..where(verses.translation.equalsValue(translation) &
              verses.bookId.equals(bookId) &
              verses.chapter.equals(chapter)))
        .map((r) => r.read(c) ?? 0)
        .getSingle();
  }

  /// Próximo capítulo canônico; `null` após Apocalipse 22.
  Future<ChapterRef?> nextChapter(int bookId, int chapter) async {
    final book = await getBook(bookId);
    if (chapter < book.chaptersCount) return (bookId: bookId, chapter: chapter + 1);
    if (bookId < BibleConstants.lastBookId) return (bookId: bookId + 1, chapter: 1);
    return null;
  }

  /// Busca no índice FTS5: todas as palavras precisam aparecer (prefixos valem:
  /// "pastor" encontra "pastores"), sem diferenciar acentos nem maiúsculas.
  /// Resultados em ordem canônica. Os trechos encontrados vêm entre
  /// [SearchHit.markStart] e [SearchHit.markEnd] em [SearchHit.highlighted].
  Future<SearchResult> search(BibleTranslation translation, String input, {int limit = 300}) async {
    final match = buildFtsQuery(input);
    if (match == null) return const SearchResult(hits: [], total: 0);

    final total = await customSelect(
      'SELECT COUNT(*) AS c FROM verses_fts JOIN verses v ON v.id = verses_fts.rowid '
      'WHERE verses_fts MATCH ? AND v."translation" = ?',
      variables: [Variable.withString(match), Variable.withString(translation.name)],
      readsFrom: {verses},
    ).map((r) => r.read<int>('c')).getSingle();

    final rows = await customSelect(
      'SELECT v.book_id, v.chapter, v.verse, b.name AS book_name, b.abbrev AS book_abbrev, '
      'highlight(verses_fts, 0, char(1), char(2)) AS hl '
      'FROM verses_fts JOIN verses v ON v.id = verses_fts.rowid JOIN books b ON b.id = v.book_id '
      'WHERE verses_fts MATCH ? AND v."translation" = ? ORDER BY v.id LIMIT ?',
      variables: [Variable.withString(match), Variable.withString(translation.name), Variable.withInt(limit)],
      readsFrom: {verses, books},
    ).get();

    return SearchResult(
      total: total,
      hits: [
        for (final r in rows)
          SearchHit(
            bookId: r.read<int>('book_id'),
            bookName: r.read<String>('book_name'),
            chapter: r.read<int>('chapter'),
            verse: r.read<int>('verse'),
            highlighted: r.read<String>('hl'),
          ),
      ],
    );
  }

  /// Converte o que o usuário digitou numa consulta FTS5 segura: cada palavra
  /// vira um prefixo entre aspas (`"senhor"* "pastor"*`). `null` se não houver palavras.
  static String? buildFtsQuery(String input) {
    final words = input
        .toLowerCase()
        .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return null;
    return words.map((w) => '"$w"*').join(' ');
  }
}

import '../utils/bible_reference.dart';
import 'app_database.dart';

typedef ChapterRef = ({int bookId, int chapter});

class VerseWithBook {
  const VerseWithBook(this.verse, this.book);

  final Verse verse;
  final Book book;

  String get reference => formatReference(book.name, verse.chapter, verse.verse);
}

class ReadingLogWithBook {
  const ReadingLogWithBook(this.log, this.book);

  final ReadingLog log;
  final Book book;

  String get reference => formatReference(book.name, log.chapter);
}

class RecitativeWithBook {
  const RecitativeWithBook(this.recitative, this.book);

  final Recitative recitative;
  final Book book;

  String get reference =>
      formatReference(book.name, recitative.chapter, recitative.verseStart, recitative.verseEnd);

  String get shortReference =>
      formatReference(book.abbrev, recitative.chapter, recitative.verseStart, recitative.verseEnd);
}

class VerseNoteWithBook {
  const VerseNoteWithBook(this.note, this.book);

  final VerseNote note;
  final Book book;

  String get reference => formatReference(book.name, note.chapter, note.verse);
}

/// Leituras de um livro num mesmo dia, para exibir "Gênesis 1-3".
class ReadingDayGroup {
  const ReadingDayGroup(this.book, this.logs);

  final Book book;

  /// Registros do livro no dia, por capítulo.
  final List<ReadingLog> logs;

  String get label => '${book.name} ${formatChapterRanges(logs.map((l) => l.chapter))}';

  /// Todos os capítulos registrados pelo app, todos na Bíblia física, ou misto (`null`).
  ReadingSource? get source {
    final sources = logs.map((l) => l.source).toSet();
    return sources.length == 1 ? sources.single : null;
  }
}

/// Agrupa os registros de um dia por livro, em ordem canônica.
List<ReadingDayGroup> groupLogsByBook(Iterable<ReadingLogWithBook> items) {
  final byBook = <int, (Book, List<ReadingLog>)>{};
  for (final item in items) {
    byBook.putIfAbsent(item.book.id, () => (item.book, <ReadingLog>[])).$2.add(item.log);
  }
  final ids = byBook.keys.toList()..sort();
  return [
    for (final id in ids)
      ReadingDayGroup(byBook[id]!.$1, byBook[id]!.$2..sort((a, b) => a.chapter.compareTo(b.chapter))),
  ];
}

/// Versículo encontrado na busca.
class SearchHit {
  const SearchHit({
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.highlighted,
  });

  static const String markStart = '';
  static const String markEnd = '';

  final int bookId;
  final String bookName;
  final int chapter;
  final int verse;

  /// Texto do versículo com os trechos encontrados entre [markStart] e [markEnd].
  final String highlighted;

  String get reference => formatReference(bookName, chapter, verse);
}

class SearchResult {
  const SearchResult({required this.hits, required this.total});

  final List<SearchHit> hits;

  /// Total de versículos encontrados (pode ser maior que [hits], que é limitado).
  final int total;
}

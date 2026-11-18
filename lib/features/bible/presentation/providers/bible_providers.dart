import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/bible_reference.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/database_providers.dart';

// Providers escritos à mão: o riverpod_generator não resolve os tipos gerados
// pelo Drift (Book, Verse, …), que vivem num arquivo `part`.

final allBooksProvider = FutureProvider<List<Book>>(
  (ref) => ref.watch(appDatabaseProvider).bibleDao.getAllBooks(),
);

final bookProvider = FutureProvider.family<Book, int>(
  (ref, bookId) => ref.watch(appDatabaseProvider).bibleDao.getBook(bookId),
);

/// Versículos do capítulo na versão de leitura atual.
final chapterVersesProvider = FutureProvider.autoDispose.family<List<Verse>, ChapterRef>((ref, c) {
  final translation = ref.watch(readingTranslationProvider);
  return ref.watch(appDatabaseProvider).bibleDao.getChapter(translation, c.bookId, c.chapter);
});

/// Quantidade de versículos na ARC (base do formulário de recitativo).
final arcVerseCountProvider = FutureProvider.autoDispose.family<int, ChapterRef>(
  (ref, c) => ref.watch(appDatabaseProvider).bibleDao.countVerses(BibleTranslation.primary, c.bookId, c.chapter),
);

final chapterNotesProvider = StreamProvider.autoDispose.family<List<VerseNote>, ChapterRef>(
  (ref, c) => ref.watch(appDatabaseProvider).notesDao.watchForChapter(c.bookId, c.chapter),
);

/// Capítulos concluídos na sessão de leitura atual (sequência de "Próximo
/// capítulo" no leitor). Resumidos na comemoração ao parar.
class ReadingSession extends Notifier<List<ChapterRef>> {
  @override
  List<ChapterRef> build() => const [];

  void add(ChapterRef chapter) {
    if (!state.contains(chapter)) state = [...state, chapter];
  }

  void reset() => state = const [];
}

final readingSessionProvider = NotifierProvider<ReadingSession, List<ChapterRef>>(ReadingSession.new);

/// "Gênesis 1-3, Êxodo 1", na ordem em que os livros foram lidos.
String describeSession(List<ChapterRef> chapters, Map<int, Book> books) {
  final byBook = <int, List<int>>{};
  for (final c in chapters) {
    byBook.putIfAbsent(c.bookId, () => []).add(c.chapter);
  }
  return byBook.entries.map((e) => '${books[e.key]!.name} ${formatChapterRanges(e.value)}').join(', ');
}

import 'package:devocional/core/database/app_database.dart';
import 'package:devocional/core/utils/bible_reference.dart';
import 'package:flutter_test/flutter_test.dart';

const _gn = Book(id: 1, name: 'Gênesis', abbrev: 'Gn', testament: 'AT', chaptersCount: 50);
const _sl = Book(id: 19, name: 'Salmos', abbrev: 'Sl', testament: 'AT', chaptersCount: 150);

ReadingLogWithBook _log(Book book, int chapter, [ReadingSource source = ReadingSource.app]) => ReadingLogWithBook(
      ReadingLog(
        id: '${book.id}-$chapter',
        bookId: book.id,
        chapter: chapter,
        readAt: DateTime(2026, 11, 18),
        source: source,
        cycleId: 'ciclo',
        updatedAt: DateTime(2026, 11, 18),
        isSynced: false,
      ),
      book,
    );

void main() {
  test('compacta capítulos em intervalos', () {
    expect(formatChapterRanges([1, 2, 3]), '1-3');
    expect(formatChapterRanges([3, 1, 2, 5, 7, 8]), '1-3, 5, 7-8');
    expect(formatChapterRanges([23]), '23');
    expect(formatChapterRanges([]), '');
  });

  test('agrupa leituras do dia por livro, em ordem canônica', () {
    final groups = groupLogsByBook([_log(_sl, 23), _log(_gn, 3), _log(_gn, 1), _log(_gn, 2)]);
    expect(groups.map((g) => g.label), ['Gênesis 1-3', 'Salmos 23']);
    expect(groups.first.source, ReadingSource.app);
  });

  test('origem mista no mesmo livro', () {
    final groups = groupLogsByBook([_log(_gn, 1), _log(_gn, 2, ReadingSource.physicalBible)]);
    expect(groups.single.source, isNull);
  });
}

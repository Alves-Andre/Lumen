import 'package:devocional/core/database/app_database.dart';
import 'package:devocional/features/recitatives/domain/services/recitative_memory_service.dart';
import 'package:flutter_test/flutter_test.dart';

const _romanos = Book(id: 45, name: 'Romanos', abbrev: 'Rm', testament: 'NT', chaptersCount: 16);

RecitativeWithBook rec(int id, DateTime serviceDate) => RecitativeWithBook(
      Recitative(
        id: id,
        bookId: 45,
        chapter: 8,
        verseStart: 28,
        verseEnd: null,
        verseTextSnapshot: 'E sabemos que todas as coisas contribuem juntamente para bem...',
        serviceDate: serviceDate,
        congregation: null,
        notes: null,
        status: RecitativeStatus.recited,
        createdAt: serviceDate,
      ),
      _romanos,
    );

void main() {
  final today = DateTime(2026, 11, 18, 10);

  test('mesmo dia em anos anteriores tem prioridade sobre a semana', () {
    final result = RecitativeMemoryMatcher.match([
      rec(1, DateTime(2025, 11, 18, 19, 30)),
      rec(2, DateTime(2023, 11, 18, 19, 30)),
      rec(3, DateTime(2025, 11, 16, 19, 30)),
    ], today);
    expect(result.isExactDay, isTrue);
    expect(result.memories.map((m) => m.item.recitative.id), [1, 2]);
    expect(result.highlight!.headline, 'Há 1 ano, neste mesmo dia, você recitou');
    expect(result.highlight!.notificationText, 'Há 1 ano você recitou Romanos 8:28');
  });

  test('fallback ±3 dias quando não há data exata', () {
    final result = RecitativeMemoryMatcher.match([
      rec(1, DateTime(2024, 11, 21, 19)),
      rec(2, DateTime(2025, 11, 25, 19)), // 7 dias: fora
    ], today);
    expect(result.isExactDay, isFalse);
    expect(result.memories.single.item.recitative.id, 1);
    expect(result.memories.single.yearsAgo, 2);
    expect(result.memories.single.dayOffset, 3);
    expect(result.highlight!.headline, 'Há 2 anos, nesta semana, você recitou');
  });

  test('janela atravessa a virada do ano', () {
    final result = RecitativeMemoryMatcher.match([rec(1, DateTime(2024, 12, 30, 19))], DateTime(2026, 1, 1));
    expect(result.memories.single.yearsAgo, 1);
    expect(result.memories.single.dayOffset, -2);
  });

  test('recitativos recentes (menos de ~1 ano) não viram lembrança', () {
    final result = RecitativeMemoryMatcher.match([
      rec(1, DateTime(2026, 11, 18, 8)),
      rec(2, DateTime(2025, 12, 30)),
    ], DateTime(2026, 1, 1));
    expect(result.memories.map((m) => m.item.recitative.id), isNot(contains(1)));
    expect(result.memories.map((m) => m.item.recitative.id), isNot(contains(2)));
  });
}

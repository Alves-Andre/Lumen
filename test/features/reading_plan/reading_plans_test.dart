import 'package:devocional/core/database/app_database.dart';
import 'package:devocional/features/reading_plan/domain/models/plan_progress.dart';
import 'package:devocional/features/reading_plan/domain/models/reading_plan.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contagem canônica de capítulos (Gn..Ap) — 1.189 no total.
const _counts = [
  50, 40, 27, 36, 34, 24, 21, 4, 31, 24, 22, 25, 29, 36, 10, 13, 10, 42, 150, 31, 12, 8, 66, 52, 5, 48, 12, 14, 3, 9, //
  1, 4, 7, 3, 3, 3, 2, 14, 4, 28, 16, 24, 21, 28, 16, 16, 13, 6, 6, 4, 4, 5, 3, 6, 4, 3, 1, 13, 5, 5, 3, 5, 1, 1, 1, 22,
];

final _books = [
  for (var i = 0; i < 66; i++)
    Book(id: i + 1, name: 'Livro ${i + 1}', abbrev: 'L${i + 1}', testament: i < 39 ? 'AT' : 'NT', chaptersCount: _counts[i]),
];

ReadingPlan _plan(String id) => ReadingPlans.byId(_books, id)!;

void main() {
  test('contagem canônica usada nos testes soma 1.189', () {
    expect(_counts.fold<int>(0, (a, b) => a + b), 1189);
  });

  test('Bíblia em 1 ano: 365 dias, todos os 1.189 capítulos uma vez, em ordem', () {
    final plan = _plan(ReadingPlans.bible1Year);
    expect(plan.totalDays, 365);
    expect(plan.totalChapters, 1189);
    final flat = plan.days.expand((d) => d).toList();
    expect(flat.toSet().length, 1189);
    expect(flat.first, (bookId: 1, chapter: 1));
    expect(flat.last, (bookId: 66, chapter: 22));
    expect(plan.days.every((d) => d.length >= 3 && d.length <= 4), isTrue);
  });

  test('Novo Testamento em 90 dias cobre Mateus a Apocalipse (260 capítulos)', () {
    final plan = _plan(ReadingPlans.nt90);
    expect(plan.totalDays, 90);
    expect(plan.totalChapters, 260);
    expect(plan.days.first.first, (bookId: 40, chapter: 1));
  });

  test('Evangelhos em 30 dias: 89 capítulos', () {
    expect(_plan(ReadingPlans.gospels30).totalChapters, 89);
  });

  test('Salmos e Provérbios: Provérbios d + 5 Salmos; os 150 Salmos uma vez', () {
    final plan = _plan(ReadingPlans.psalmsProverbs31);
    expect(plan.totalDays, 31);
    expect(plan.days.first, [
      (bookId: 20, chapter: 1),
      (bookId: 19, chapter: 1),
      (bookId: 19, chapter: 31),
      (bookId: 19, chapter: 61),
      (bookId: 19, chapter: 91),
      (bookId: 19, chapter: 121),
    ]);
    final psalms = plan.days.expand((d) => d).where((c) => c.bookId == 19).toSet();
    expect(psalms.length, 150);
    expect(plan.days.last.length, 5); // Pv 31 + Sl 31, 61, 91, 121
  });

  group('progresso', () {
    final plan = _plan(ReadingPlans.gospels30); // dia 1 = Mt 1-2, dia 2 = Mt 3-5…
    final start = DateTime(2026, 11, 10, 9);

    PlanProgress progress(Set<ChapterRef> read, DateTime now) =>
        PlanProgress.compute(enrollmentId: 1, plan: plan, startedAt: start, read: read, now: now);

    test('dia atual é o primeiro com capítulo pendente', () {
      final p = progress({(bookId: 40, chapter: 1)}, DateTime(2026, 11, 10, 20));
      expect(p.currentDayIndex, 0);
      expect(p.todayRemaining, [(bookId: 40, chapter: 2)]);
      expect(p.statusLabel, 'Em dia');
    });

    test('atraso e adiantamento comparam com o calendário', () {
      expect(progress({}, DateTime(2026, 11, 13)).statusLabel, '3 dias de atraso');
      final ahead = {for (final c in [...plan.days[0], ...plan.days[1]]) c};
      expect(progress(ahead, DateTime(2026, 11, 10, 21)).statusLabel, '2 dias adiantados');
    });

    test('leituras fora do plano não contam no progresso do plano', () {
      final p = progress({(bookId: 1, chapter: 1)}, DateTime(2026, 11, 10));
      expect(p.readChapters, isEmpty);
    });

    test('próximo capítulo do dia ignora o atual e os já lidos', () {
      final p = progress({}, DateTime(2026, 11, 10));
      expect(p.nextAfter((bookId: 40, chapter: 1)), (bookId: 40, chapter: 2));
      expect(p.nextAfter((bookId: 40, chapter: 2)), (bookId: 40, chapter: 1));
    });

    test('plano concluído', () {
      final all = {for (final d in plan.days) ...d};
      final p = progress(all, DateTime(2026, 12, 20));
      expect(p.isComplete, isTrue);
      expect(p.progress, 1);
      expect(p.todayRemaining, isEmpty);
    });
  });
}

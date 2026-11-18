import 'package:devocional/features/reading_plan/domain/services/reading_projection_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 18, 21);

  test('menos de 14 dias de leitura: média desde o primeiro dia', () {
    // Primeiro registro há 4 dias -> janela de 5 dias; 10 capítulos -> 2/dia.
    final first = DateTime(2026, 11, 14, 8);
    final dates = [for (var i = 0; i < 10; i++) DateTime(2026, 11, 14 + (i % 5), 8)];
    final p = ReadingProjectionCalculator.calculate(
      uniqueChaptersReadInCycle: 189,
      recentReadDates: dates,
      firstReadAt: first,
      now: now,
    );
    expect(p.windowDays, 5);
    expect(p.dailyAverage, 2);
    expect(p.chaptersRemaining, 1000);
    expect(p.estimatedDays, 500);
    expect(p.estimatedFinishDate, DateTime(2028, 4, 1));
    expect(
      p.message,
      'Você está lendo em média 2 capítulos por dia. '
      'Continuando assim, concluirá a Bíblia em 500 dias (01/04/2028).',
    );
  });

  test('janela de 14 dias ignora registros mais antigos', () {
    final dates = [
      DateTime(2026, 11, 4, 7), // fora (15 dias atrás)
      for (var i = 0; i < 21; i++) DateTime(2026, 11, 5 + (i % 14), 7),
    ];
    final p = ReadingProjectionCalculator.calculate(
      uniqueChaptersReadInCycle: 1000,
      recentReadDates: dates,
      firstReadAt: DateTime(2025, 1, 1),
      now: now,
    );
    expect(p.windowDays, 14);
    expect(p.dailyAverage, 1.5);
    expect(p.estimatedDays, 126); // 189 / 1.5
    expect(p.dailyAverageLabel, '1,5');
  });

  test('mensagem agrupa milhares', () {
    final p = ReadingProjectionCalculator.calculate(
      uniqueChaptersReadInCycle: 1,
      recentReadDates: [now],
      firstReadAt: now,
      now: now,
    );
    expect(p.message, contains('em 1.188 dias'));
  });

  test('sem nenhuma leitura', () {
    final p = ReadingProjectionCalculator.calculate(
      uniqueChaptersReadInCycle: 0,
      recentReadDates: const [],
      firstReadAt: null,
      now: now,
    );
    expect(p.estimatedDays, isNull);
    expect(p.message, contains('primeira leitura'));
  });

  test('leituras antigas, nada nos últimos 14 dias: sem projeção', () {
    final p = ReadingProjectionCalculator.calculate(
      uniqueChaptersReadInCycle: 300,
      recentReadDates: const [],
      firstReadAt: DateTime(2026, 1, 1),
      now: now,
    );
    expect(p.dailyAverage, 0);
    expect(p.estimatedDays, isNull);
    expect(p.message, contains('últimos 14 dias'));
  });

  test('ciclo concluído', () {
    final p = ReadingProjectionCalculator.calculate(
      uniqueChaptersReadInCycle: 1189,
      recentReadDates: [now],
      firstReadAt: DateTime(2026, 1, 1),
      now: now,
    );
    expect(p.isCycleComplete, isTrue);
    expect(p.estimatedDays, 0);
    expect(p.progress, 1);
  });
}

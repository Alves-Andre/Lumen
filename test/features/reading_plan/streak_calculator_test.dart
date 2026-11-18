import 'package:devocional/core/utils/day_utils.dart';
import 'package:devocional/features/reading_plan/domain/services/streak_service.dart';
import 'package:flutter_test/flutter_test.dart';

final _start = DateTime(2026, 9, 1);

/// Dia [n] a partir de 01/09/2026 (n = 0 é o primeiro dia), às 20h.
DateTime d(int n, [int hour = 20]) => addDays(_start, n).add(Duration(hours: hour));

/// Leituras nos dias [from]..[to] (inclusive).
List<DateTime> range(int from, int to) => [for (var i = from; i <= to; i++) d(i)];

void main() {
  const calc = StreakCalculator();

  test('sem leituras: ofensiva zerada, sem escudos, próximo em 15 dias', () {
    final s = calc.calculate(const [], d(0));
    expect(s.currentStreak, 0);
    expect(s.shields, 0);
    expect(s.nextShieldIn, 15);
  });

  test('7 dias lidos e 1 falta: perde a ofensiva, histórico continua', () {
    // Dias 0..6 lidos, dia 7 sem leitura, dia 8 lido (hoje).
    final s = calc.calculate([...range(0, 6), d(8)], d(8));
    expect(s.currentStreak, 1);
    expect(s.longestStreak, 7);
    expect(s.totalDaysRead, 8);
    expect(s.shieldDays, isEmpty);
  });

  test('15 dias lidos ganham 1 escudo; 1 falta é protegida e a ofensiva continua', () {
    // Dias 0..14 lidos (ganha escudo no 15º), dia 15 sem leitura, dia 16 é hoje sem leitura ainda.
    final s = calc.calculate(range(0, 14), d(16, 9));
    expect(s.currentStreak, 15);
    expect(s.shields, 0);
    expect(s.shieldDays, {dateOnly(d(15))});
    expect(s.atRisk, isTrue);
  });

  test('o 15º dia de leitura entrega o escudo', () {
    expect(calc.calculate(range(0, 13), d(13)).shields, 0);
    expect(calc.calculate(range(0, 14), d(14)).shields, 1);
    expect(calc.calculate(range(0, 14), d(14)).nextShieldIn, 15);
    expect(calc.calculate(range(0, 9), d(9)).nextShieldIn, 5);
  });

  test('escudos são cumulativos: 45 dias = 3 escudos', () {
    final s = calc.calculate(range(0, 44), d(44));
    expect(s.shields, 3);
  });

  test('2 escudos cobrem 2 dias seguidos sem leitura', () {
    // 30 dias lidos (2 escudos), dias 30 e 31 sem leitura, dia 32 lido.
    final s = calc.calculate([...range(0, 29), d(32)], d(32));
    expect(s.currentStreak, 31);
    expect(s.shields, 0);
    expect(s.shieldDays, {dateOnly(d(30)), dateOnly(d(31))});
  });

  test('1 escudo não cobre 2 faltas seguidas', () {
    final s = calc.calculate([...range(0, 14), d(17)], d(17));
    expect(s.currentStreak, 1);
    expect(s.longestStreak, 15);
    expect(s.shieldDays, {dateOnly(d(15))});
  });

  test('ao zerar a ofensiva, a contagem para o próximo escudo recomeça', () {
    final s = calc.calculate([...range(0, 9), ...range(11, 25)], d(25));
    expect(s.currentStreak, 15); // dias 11..25
    expect(s.shields, 1);
  });

  test('hoje sem leitura não consome escudo', () {
    final s = calc.calculate(range(0, 14), d(15, 9));
    expect(s.shields, 1);
    expect(s.shieldDays, isEmpty);
    expect(s.atRisk, isTrue);
  });

  test('vários registros no mesmo dia contam como um dia', () {
    final s = calc.calculate([d(0, 7), d(0, 8), d(0, 21), d(1, 6)], d(1, 10));
    expect(s.currentStreak, 2);
    expect(s.totalDaysRead, 2);
  });

  test('escudos desativados: qualquer falta zera', () {
    const strict = StreakCalculator(shieldsEnabled: false);
    final s = strict.calculate([...range(0, 14), d(16)], d(16));
    expect(s.currentStreak, 1);
    expect(s.shields, 0);
    expect(s.nextShieldIn, isNull);
  });
}

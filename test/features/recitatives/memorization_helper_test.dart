import 'package:devocional/features/recitatives/domain/services/memorization_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const verse = 'E sabemos que todas as coisas contribuem juntamente para bem daqueles que amam a Deus, '
      'daqueles que são chamados por seu decreto.';

  test('tokenização preserva a pontuação fora da palavra', () {
    final tokens = MemorizationHelper.tokenize('a Deus, daqueles');
    expect(tokens[1].word, 'Deus');
    expect(tokens[1].suffix, ',');
  });

  test('nível 1 não oculta nada', () {
    final stage = MemorizationHelper.buildStages(verse)[0];
    expect(stage.hiddenCount, 0);
  });

  test('nível 2 oculta ~35% apenas palavras com mais de 3 letras', () {
    final stage = MemorizationHelper.buildStages(verse)[1];
    expect(stage.hiddenCount, (stage.wordCount * 0.35).round());
    for (final t in stage.tokens.where((t) => t.hidden)) {
      expect(t.word.length, greaterThan(3));
    }
  });

  test('nível 3 oculta mais e contém todas as lacunas do nível 2', () {
    final stages = MemorizationHelper.buildStages(verse);
    final l2 = {for (var i = 0; i < stages[1].tokens.length; i++) if (stages[1].tokens[i].hidden) i};
    final l3 = {for (var i = 0; i < stages[2].tokens.length; i++) if (stages[2].tokens[i].hidden) i};
    expect(l3.containsAll(l2), isTrue);
    expect(l3.length, greaterThan(l2.length));
    expect(l3.length, lessThanOrEqualTo((stages[2].wordCount * 0.70).round()));
  });

  test('artigos e preposições nunca são ocultados', () {
    final stage = MemorizationHelper.buildStages(verse)[2];
    const keep = {'e', 'que', 'as', 'para', 'a', 'por'};
    for (final t in stage.tokens.where((t) => t.hidden)) {
      expect(keep.contains(t.word.toLowerCase()), isFalse);
    }
  });

  test('seleção determinística por texto e dica da primeira letra', () {
    final a = MemorizationHelper.buildStages(verse)[2].tokens.map((t) => t.hidden).toList();
    final b = MemorizationHelper.buildStages(verse)[2].tokens.map((t) => t.hidden).toList();
    expect(a, b);
    const token = MemorizationToken(prefix: '', word: 'Deus', suffix: ',', hidden: true);
    expect(token.display(), '_____,');
    expect(token.display(showHint: true), 'D___,');
    expect(token.display(revealed: true), 'Deus,');
  });
}

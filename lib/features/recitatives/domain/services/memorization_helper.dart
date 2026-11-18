import 'dart:math';

enum MemorizationLevel {
  reading('Leitura', 0.0),
  lightGaps('Lacunas leves', 0.35),
  challenge('Desafio', 0.70);

  const MemorizationLevel(this.label, this.hiddenRatio);

  final String label;
  final double hiddenRatio;
}

class MemorizationToken {
  const MemorizationToken({
    required this.prefix,
    required this.word,
    required this.suffix,
    required this.hidden,
  });

  static const String placeholder = '_____';

  /// Pontuação antes/depois da palavra — sempre visível.
  final String prefix;
  final String word;
  final String suffix;
  final bool hidden;

  bool get isWord => word.isNotEmpty;

  /// "S_____" para "Senhor".
  String get firstLetterHint => word.isEmpty ? '' : '${word[0]}${'_' * (word.length - 1)}';

  String display({bool revealed = false, bool showHint = false}) {
    if (!hidden || revealed) return '$prefix$word$suffix';
    return '$prefix${showHint ? firstLetterHint : placeholder}$suffix';
  }
}

class MemorizationStage {
  const MemorizationStage(this.level, this.tokens);

  final MemorizationLevel level;
  final List<MemorizationToken> tokens;

  int get hiddenCount => tokens.where((t) => t.hidden).length;
  int get wordCount => tokens.where((t) => t.isWord).length;
}

/// Gera os 3 estágios de memorização. O Nível 3 sempre contém as lacunas do
/// Nível 2 (progressão). A seleção é determinística por texto, a menos que um
/// [seed] diferente seja passado ("embaralhar lacunas").
abstract final class MemorizationHelper {
  static const Set<String> _stopwords = {
    'a', 'o', 'as', 'os', 'um', 'uma', 'uns', 'umas', 'e', 'é', 'ou', 'de', 'da', 'do', 'das', 'dos',
    'em', 'na', 'no', 'nas', 'nos', 'ao', 'aos', 'à', 'às', 'por', 'pelo', 'pela', 'pelos', 'pelas',
    'para', 'pra', 'com', 'que', 'se', 'me', 'te', 'lhe', 'nem', 'mas', 'num', 'numa',
  };

  static final RegExp _split = RegExp(r'\s+');
  static final RegExp _token = RegExp(r'^([^\p{L}\p{N}]*)(.*?)([^\p{L}\p{N}]*)$', unicode: true);

  static List<MemorizationStage> buildStages(String text, {int? seed}) {
    final base = tokenize(text);
    final wordIdx = [for (var i = 0; i < base.length; i++) if (base[i].isWord) i];
    final total = wordIdx.length;
    final random = Random(seed ?? _stableHash(text));

    bool isStop(int i) => _stopwords.contains(base[i].word.toLowerCase());

    final longWords = wordIdx.where((i) => !isStop(i) && base[i].word.length > 3).toList()..shuffle(random);
    final level2Count = min((total * MemorizationLevel.lightGaps.hiddenRatio).round(), longWords.length);
    final level2 = longWords.take(level2Count).toSet();

    final remainingLong = longWords.skip(level2Count).toList();
    final shortWords = wordIdx.where((i) => !isStop(i) && base[i].word.length <= 3).toList()..shuffle(random);
    final extras = [...remainingLong, ...shortWords];
    final level3Target = min((total * MemorizationLevel.challenge.hiddenRatio).round(), level2.length + extras.length);
    final level3 = {...level2, ...extras.take(max(0, level3Target - level2.length))};

    List<MemorizationToken> withHidden(Set<int> hidden) => [
          for (var i = 0; i < base.length; i++)
            MemorizationToken(
              prefix: base[i].prefix,
              word: base[i].word,
              suffix: base[i].suffix,
              hidden: hidden.contains(i),
            ),
        ];

    return [
      MemorizationStage(MemorizationLevel.reading, base),
      MemorizationStage(MemorizationLevel.lightGaps, withHidden(level2)),
      MemorizationStage(MemorizationLevel.challenge, withHidden(level3)),
    ];
  }

  static MemorizationStage buildStage(String text, MemorizationLevel level, {int? seed}) =>
      buildStages(text, seed: seed)[level.index];

  static List<MemorizationToken> tokenize(String text) => [
        for (final piece in text.trim().split(_split))
          if (piece.isNotEmpty) _parse(piece),
      ];

  static MemorizationToken _parse(String piece) {
    final m = _token.firstMatch(piece);
    if (m == null || (m.group(2) ?? '').isEmpty) {
      return MemorizationToken(prefix: piece, word: '', suffix: '', hidden: false);
    }
    return MemorizationToken(prefix: m.group(1)!, word: m.group(2)!, suffix: m.group(3)!, hidden: false);
  }

  /// FNV-1a: estável entre execuções (diferente de `String.hashCode`).
  static int _stableHash(String s) {
    var hash = 0x811c9dc5;
    for (final unit in s.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash;
  }
}

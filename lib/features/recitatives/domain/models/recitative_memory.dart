import '../../../../core/database/app_database.dart';

class RecitativeMemory {
  const RecitativeMemory({
    required this.item,
    required this.yearsAgo,
    required this.dayOffset,
    required this.isExactDay,
  });

  final RecitativeWithBook item;
  final int yearsAgo;

  /// Dias entre o aniversário de hoje naquele ano e a data do culto (negativo = antes).
  final int dayOffset;
  final bool isExactDay;

  String get headline {
    final when = yearsAgo == 1 ? 'Há 1 ano' : 'Há $yearsAgo anos';
    return isExactDay ? '$when, neste mesmo dia, você recitou' : '$when, nesta semana, você recitou';
  }

  /// Texto curto para notificação: "Há 1 ano você recitou Romanos 8:28".
  String get notificationText {
    final when = yearsAgo == 1 ? 'Há 1 ano' : 'Há $yearsAgo anos';
    return '$when você recitou ${item.reference}';
  }
}

class RecitativeMemoryResult {
  const RecitativeMemoryResult(this.memories);

  static const empty = RecitativeMemoryResult([]);

  final List<RecitativeMemory> memories;

  bool get hasMemories => memories.isNotEmpty;
  bool get isExactDay => memories.isNotEmpty && memories.first.isExactDay;
  RecitativeMemory? get highlight => memories.isEmpty ? null : memories.first;
}

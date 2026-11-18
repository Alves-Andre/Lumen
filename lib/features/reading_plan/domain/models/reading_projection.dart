import '../../../../core/utils/day_utils.dart';

class ReadingProjection {
  const ReadingProjection({
    required this.totalChapters,
    required this.chaptersReadInCycle,
    required this.dailyAverage,
    required this.windowDays,
    required this.hasAnyReading,
    this.estimatedDays,
    this.estimatedFinishDate,
  });

  final int totalChapters;
  final int chaptersReadInCycle;

  /// Média de capítulos/dia na janela móvel.
  final double dailyAverage;

  /// Dias efetivamente considerados na média (até 14).
  final int windowDays;

  final bool hasAnyReading;

  /// `null` quando não há média para projetar.
  final int? estimatedDays;
  final DateTime? estimatedFinishDate;

  int get chaptersRemaining => totalChapters - chaptersReadInCycle;
  bool get isCycleComplete => chaptersRemaining <= 0;
  double get progress => totalChapters == 0 ? 0 : chaptersReadInCycle / totalChapters;

  /// "3,2" / "1" / "0,07".
  String get dailyAverageLabel {
    final fixed = dailyAverage < 0.1 ? dailyAverage.toStringAsFixed(2) : dailyAverage.toStringAsFixed(1);
    final trimmed = fixed.replaceFirst(RegExp(r'\.?0+$'), '');
    return (trimmed.isEmpty ? '0' : trimmed).replaceAll('.', ',');
  }

  String get message {
    if (isCycleComplete) {
      return 'Glória a Deus! Você concluiu a leitura da Bíblia neste ciclo.';
    }
    if (!hasAnyReading) {
      return 'Registre sua primeira leitura para ver a projeção de término.';
    }
    if (estimatedDays == null || estimatedFinishDate == null) {
      return 'Você não registrou leituras nos últimos $windowDays dias. '
          'Retome a leitura para ver a projeção de término.';
    }
    final chapterWord = dailyAverage == 1 ? 'capítulo' : 'capítulos';
    final dayWord = estimatedDays == 1 ? 'dia' : 'dias';
    return 'Você está lendo em média $dailyAverageLabel $chapterWord por dia. '
        'Continuando assim, concluirá a Bíblia em ${_grouped(estimatedDays!)} $dayWord '
        '(${formatDateBr(estimatedFinishDate!)}).';
  }

  /// 1188 → "1.188" (sem depender do locale do `intl`).
  static String _grouped(int v) =>
      v.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
}

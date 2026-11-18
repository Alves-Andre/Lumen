import '../../../../core/database/app_database.dart';

/// Um plano de leitura: [days] lista os capítulos de cada dia, em ordem.
class ReadingPlan {
  const ReadingPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.days,
  });

  /// Identificador estável, gravado em `plan_enrollments.plan_id`.
  final String id;
  final String name;
  final String description;
  final List<List<ChapterRef>> days;

  int get totalDays => days.length;
  int get totalChapters => days.fold(0, (sum, d) => sum + d.length);

  /// Média de capítulos por dia, arredondada (ex.: "~3 capítulos/dia").
  int get chaptersPerDay => (totalChapters / totalDays).round();
}

/// Catálogo de planos. Gerados a partir dos livros do banco (contagem de capítulos).
abstract final class ReadingPlans {
  static const bible1Year = 'biblia-1-ano';
  static const bible2Years = 'biblia-2-anos';
  static const nt90 = 'nt-90-dias';
  static const gospels30 = 'evangelhos-30-dias';
  static const psalmsProverbs31 = 'salmos-proverbios-31-dias';

  static const _ntFirstBook = 40; // Mateus
  static const _gospelsLastBook = 43; // João
  static const _psalms = 19;
  static const _proverbs = 20;

  static List<ReadingPlan> all(List<Book> books) {
    final sorted = [...books]..sort((a, b) => a.id.compareTo(b.id));
    List<ChapterRef> chaptersOf(bool Function(Book) include) => [
          for (final b in sorted.where(include))
            for (var c = 1; c <= b.chaptersCount; c++) (bookId: b.id, chapter: c),
        ];

    final whole = chaptersOf((_) => true);
    return [
      ReadingPlan(
        id: bible1Year,
        name: 'Bíblia em 1 ano',
        description: 'De Gênesis a Apocalipse, em ordem, em 365 dias.',
        days: distribute(whole, 365),
      ),
      ReadingPlan(
        id: bible2Years,
        name: 'Bíblia em 2 anos',
        description: 'A Bíblia toda em ritmo tranquilo, cerca de 1 a 2 capítulos por dia.',
        days: distribute(whole, 730),
      ),
      ReadingPlan(
        id: nt90,
        name: 'Novo Testamento em 90 dias',
        description: 'De Mateus a Apocalipse em três meses.',
        days: distribute(chaptersOf((b) => b.id >= _ntFirstBook), 90),
      ),
      ReadingPlan(
        id: gospels30,
        name: 'Evangelhos em 30 dias',
        description: 'Mateus, Marcos, Lucas e João: a vida de Jesus em um mês.',
        days: distribute(chaptersOf((b) => b.id >= _ntFirstBook && b.id <= _gospelsLastBook), 30),
      ),
      ReadingPlan(
        id: psalmsProverbs31,
        name: 'Salmos e Provérbios em 31 dias',
        description: 'Um capítulo de Provérbios e cinco Salmos por dia.',
        days: _psalmsAndProverbs(sorted),
      ),
    ];
  }

  static ReadingPlan? byId(List<Book> books, String id) {
    for (final plan in all(books)) {
      if (plan.id == id) return plan;
    }
    return null;
  }

  /// Divide [chapters] em [days] dias consecutivos, o mais equilibrado possível.
  static List<List<ChapterRef>> distribute(List<ChapterRef> chapters, int days) => [
        for (var i = 0; i < days; i++)
          chapters.sublist((i * chapters.length) ~/ days, ((i + 1) * chapters.length) ~/ days),
      ];

  /// Dia d: Provérbios d e Salmos d, d+30, d+60, d+90, d+120 (os 150 Salmos uma vez).
  static List<List<ChapterRef>> _psalmsAndProverbs(List<Book> books) {
    final psalms = books.firstWhere((b) => b.id == _psalms).chaptersCount;
    final proverbs = books.firstWhere((b) => b.id == _proverbs).chaptersCount;
    return [
      for (var d = 1; d <= proverbs; d++)
        [
          (bookId: _proverbs, chapter: d),
          for (var k = 0; k < 5; k++)
            if (d + 30 * k <= psalms) (bookId: _psalms, chapter: d + 30 * k),
        ],
    ];
  }
}

abstract final class BibleConstants {
  static const String versionName = 'Almeida Revista e Corrigida';
  static const String versionAbbrev = 'ARC';

  static const int totalBooks = 66;
  static const int oldTestamentBooks = 39;
  static const int totalChapters = 1189;

  /// Capítulos de cada livro (Gênesis..Apocalipse) na numeração das Bíblias
  /// protestantes em português. Soma: [totalChapters].
  static const List<int> chaptersPerBook = [
    50, 40, 27, 36, 34, 24, 21, 4, 31, 24, 22, 25, 29, 36, 10, 13, 10, 42, 150, 31, 12, 8, 66, 52, 5, 48, 12, 14, //
    3, 9, 1, 4, 7, 3, 3, 3, 2, 14, 4, 28, 16, 24, 21, 28, 16, 16, 13, 6, 6, 4, 4, 5, 3, 6, 4, 3, 1, 13, 5, 5, 3, 5, //
    1, 1, 1, 22,
  ];
  static const int firstBookId = 1;
  static const int lastBookId = 66;

  /// Abreviações canônicas, na ordem dos livros (usadas quando o JSON não as traz).
  static const List<String> bookAbbreviations = [
    'Gn', 'Êx', 'Lv', 'Nm', 'Dt', 'Js', 'Jz', 'Rt', '1Sm', '2Sm', '1Rs', '2Rs', '1Cr', '2Cr', 'Ed', 'Ne', //
    'Et', 'Jó', 'Sl', 'Pv', 'Ec', 'Ct', 'Is', 'Jr', 'Lm', 'Ez', 'Dn', 'Os', 'Jl', 'Am', 'Ob', 'Jn', 'Mq', //
    'Na', 'Hc', 'Sf', 'Ag', 'Zc', 'Ml', 'Mt', 'Mc', 'Lc', 'Jo', 'At', 'Rm', '1Co', '2Co', 'Gl', 'Ef', 'Fp', //
    'Cl', '1Ts', '2Ts', '1Tm', '2Tm', 'Tt', 'Fm', 'Hb', 'Tg', '1Pe', '2Pe', '1Jo', '2Jo', '3Jo', 'Jd', 'Ap',
  ];

  /// Onde baixar os arquivos .json das versões (mostrado na tela de importação).
  static const String biblesSourcePage = 'https://github.com/MaatheusGois/bible/tree/main/versions/pt-br';

  /// Janela (em dias corridos) da média móvel usada na projeção de término.
  static const int projectionWindowDays = 14;

  /// Dias de leitura seguidos para ganhar 1 Escudo da ofensiva.
  static const int shieldEarnEveryDays = 15;

  /// Janela (±dias) do fallback de "Lembranças de Recitativos".
  static const int memoryWindowDays = 3;
}

/// Versões bíblicas suportadas (importadas pelo usuário). Persistido pelo nome do enum: `'arc'` / `'nvi'`.
enum BibleTranslation {
  arc('ARC', 'Almeida Revista e Corrigida', 'arc.json'),
  nvi('NVI', 'Nova Versão Internacional', 'nvi.json');

  const BibleTranslation(this.abbrev, this.fullName, this.sourceFileName);

  final String abbrev;
  final String fullName;

  /// Nome do arquivo no repositório indicado em `BibleConstants.biblesSourcePage`.
  final String sourceFileName;

  /// Download direto do .json (o usuário baixa e importa no app).
  String get downloadUrl =>
      'https://raw.githubusercontent.com/MaatheusGois/bible/main/versions/pt-br/$sourceFileName';

  /// Versão usada nos recitativos (prática da CCB) e obrigatória no app.
  static const BibleTranslation primary = BibleTranslation.arc;

  static BibleTranslation fromName(String? name) =>
      values.firstWhere((t) => t.name == name, orElse: () => primary);
}

/// Origem do registro de leitura. Persistido como `'app'` / `'physical_bible'`.
enum ReadingSource {
  app('app', 'No aplicativo'),
  physicalBible('physical_bible', 'Bíblia física');

  const ReadingSource(this.value, this.label);

  final String value;
  final String label;

  static ReadingSource fromValue(String value) =>
      values.firstWhere((e) => e.value == value, orElse: () => ReadingSource.app);
}

/// Persistido pelo nome do enum: `'pending'` / `'recited'`.
enum RecitativeStatus {
  pending('A recitar'),
  recited('Recitado');

  const RecitativeStatus(this.label);

  final String label;
}

/// Persistido pelo nome do enum: `'active'` / `'answered'`.
enum PrayerStatus {
  active('Em oração'),
  answered('Respondida');

  const PrayerStatus(this.label);

  final String label;
}

/// Persistido pelo rótulo em português (ex.: `'Família'`).
enum PrayerCategory {
  family('Família'),
  church('Igreja'),
  personal('Pessoal'),
  intercession('Intercessão'),
  gratitude('Gratidão');

  const PrayerCategory(this.label);

  final String label;

  static PrayerCategory fromLabel(String label) =>
      values.firstWhere((e) => e.label == label, orElse: () => PrayerCategory.personal);
}

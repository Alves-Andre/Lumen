import 'package:flutter/foundation.dart' show immutable;

/// Tradução da Bíblia. O texto nunca é empacotado com o app: o usuário importa
/// o `.json` de cada tradução. Persistida pelo [code] (`'arc'`, `'nvi'`,
/// `'u-minha-traducao'`…) em `verses.translation` e nas preferências.
///
/// As do [catalog] têm nome conhecido; as que têm [sourceFileName] também têm
/// link de download no repositório indicado em `BibleConstants.biblesSourcePage`.
/// Qualquer outra pode ser importada como personalizada ([BibleTranslation.custom]).
@immutable
class BibleTranslation {
  const BibleTranslation({
    required this.code,
    required this.abbrev,
    required this.fullName,
    this.sourceFileName,
    this.isCustom = false,
  });

  final String code;
  final String abbrev;
  final String fullName;

  /// Nome do arquivo no repositório de origem (`null`: o usuário usa um arquivo próprio).
  final String? sourceFileName;

  /// Importada pelo usuário com sigla e nome livres.
  final bool isCustom;

  /// Download direto do .json (o usuário baixa e importa no app).
  String? get downloadUrl => sourceFileName == null
      ? null
      : 'https://raw.githubusercontent.com/MaatheusGois/bible/main/versions/pt-br/$sourceFileName';

  static const arc = BibleTranslation(
    code: 'arc',
    abbrev: 'ARC',
    fullName: 'Almeida Revista e Corrigida',
    sourceFileName: 'arc.json',
  );
  static const ara = BibleTranslation(code: 'ara', abbrev: 'ARA', fullName: 'Almeida Revista e Atualizada');
  static const acf = BibleTranslation(
    code: 'acf',
    abbrev: 'ACF',
    fullName: 'Almeida Corrigida Fiel',
    sourceFileName: 'acf.json',
  );
  static const aa = BibleTranslation(
    code: 'aa',
    abbrev: 'AA',
    fullName: 'Almeida Revisada Imprensa Bíblica',
    sourceFileName: 'aa.json',
  );
  static const naa = BibleTranslation(code: 'naa', abbrev: 'NAA', fullName: 'Nova Almeida Atualizada');
  static const nvi = BibleTranslation(
    code: 'nvi',
    abbrev: 'NVI',
    fullName: 'Nova Versão Internacional',
    sourceFileName: 'nvi.json',
  );
  static const nvt = BibleTranslation(code: 'nvt', abbrev: 'NVT', fullName: 'Nova Versão Transformadora');
  static const ntlh = BibleTranslation(
    code: 'ntlh',
    abbrev: 'NTLH',
    fullName: 'Nova Tradução na Linguagem de Hoje',
  );
  static const kja = BibleTranslation(
    code: 'kja',
    abbrev: 'KJA',
    fullName: 'King James Atualizada',
    sourceFileName: 'kja.json',
  );

  /// Traduções mais comuns em português, na ordem exibida no app.
  static const List<BibleTranslation> catalog = [arc, ara, acf, aa, naa, nvi, nvt, ntlh, kja];

  /// Preferida como principal (recitativos) quando o usuário não escolheu outra:
  /// a ARC é a usada nos cultos da CCB.
  static const BibleTranslation preferredPrimary = arc;

  static BibleTranslation? fromCatalog(String code) {
    for (final t in catalog) {
      if (t.code == code) return t;
    }
    return null;
  }

  /// Tradução fora do catálogo. Se a sigla for de uma do catálogo, usa a do catálogo.
  factory BibleTranslation.custom({required String abbrev, required String fullName}) {
    final cleanAbbrev = abbrev.trim().toUpperCase();
    for (final t in catalog) {
      if (t.abbrev == cleanAbbrev) return t;
    }
    return BibleTranslation(
      code: 'u-${slug(cleanAbbrev)}',
      abbrev: cleanAbbrev,
      fullName: fullName.trim(),
      isCustom: true,
    );
  }

  /// Tradução registrada no banco ([code] + nome gravado na importação).
  factory BibleTranslation.stored({required String code, required String abbrev, required String fullName}) =>
      fromCatalog(code) ??
      BibleTranslation(code: code, abbrev: abbrev, fullName: fullName, isCustom: code.startsWith('u-'));

  /// Escolhe a tradução principal entre as instaladas: a escolhida, senão a
  /// [preferredPrimary], senão a primeira. `null` se nada estiver instalado.
  static BibleTranslation? pickPrimary(List<BibleTranslation> installed, String? chosenCode) {
    if (installed.isEmpty) return null;
    for (final t in installed) {
      if (t.code == chosenCode) return t;
    }
    return installed.contains(preferredPrimary) ? preferredPrimary : installed.first;
  }

  /// `"Nova Versão!"` → `nova-versao`.
  static String slug(String value) {
    const from = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
    const to = 'aaaaaeeeeiiiiooooouuuucn';
    final buffer = StringBuffer();
    for (final ch in value.toLowerCase().split('')) {
      final i = from.indexOf(ch);
      buffer.write(i >= 0 ? to[i] : ch);
    }
    return buffer.toString().replaceAll(RegExp('[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');
  }

  @override
  bool operator ==(Object other) => other is BibleTranslation && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => abbrev;
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

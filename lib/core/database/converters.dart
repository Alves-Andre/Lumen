import 'package:drift/drift.dart';

import 'enums.dart';

class ReadingSourceConverter extends TypeConverter<ReadingSource, String>
    with JsonTypeConverter<ReadingSource, String> {
  const ReadingSourceConverter();

  @override
  ReadingSource fromSql(String fromDb) => ReadingSource.fromValue(fromDb);

  @override
  String toSql(ReadingSource value) => value.value;
}

class PrayerCategoryConverter extends TypeConverter<PrayerCategory, String>
    with JsonTypeConverter<PrayerCategory, String> {
  const PrayerCategoryConverter();

  @override
  PrayerCategory fromSql(String fromDb) => PrayerCategory.fromLabel(fromDb);

  @override
  String toSql(PrayerCategory value) => value.label;
}

/// `verses.translation` guarda o código da tradução (`'arc'`, `'nvi'`, `'u-…'`).
/// Fora do catálogo, o nome completo vem da tabela `installed_translations`.
class BibleTranslationConverter extends TypeConverter<BibleTranslation, String>
    with JsonTypeConverter<BibleTranslation, String> {
  const BibleTranslationConverter();

  @override
  BibleTranslation fromSql(String fromDb) =>
      BibleTranslation.stored(code: fromDb, abbrev: fromDb.replaceFirst('u-', '').toUpperCase(), fullName: fromDb);

  @override
  String toSql(BibleTranslation value) => value.code;
}

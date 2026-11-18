import 'package:drift/drift.dart';

import 'converters.dart';
import 'enums.dart';

/// Livros da Bíblia (id canônico 1..66).
@DataClassName('Book')
class Books extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get abbrev => text()();

  /// 'AT' ou 'NT'.
  TextColumn get testament => text().withLength(min: 2, max: 2)();
  IntColumn get chaptersCount => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Texto bíblico, uma linha por versículo e por versão (ARC, NVI…).
///
/// O índice único (translation, book_id, chapter, verse) também atende às
/// consultas por (translation, book_id, chapter), pois o SQLite usa o prefixo de
/// um índice composto — ler um capítulo inteiro é um range scan nesse índice.
/// As versões não são casadas versículo a versículo: a numeração difere em
/// alguns capítulos (ex.: Ap 12 tem 17 versículos na ARC e 18 na NVI).
@DataClassName('Verse')
@TableIndex(name: 'idx_verses_ref', columns: {#translation, #bookId, #chapter, #verse}, unique: true)
class Verses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get translation => textEnum<BibleTranslation>().withDefault(const Constant('arc'))();
  IntColumn get bookId => integer().references(Books, #id)();
  IntColumn get chapter => integer()();
  IntColumn get verse => integer()();

  /// Coluna SQL `text` (o getter não pode se chamar `text`, pois colidiria com o builder do Drift).
  TextColumn get verseText => text().named('text')();
}

/// Ciclos de leitura. Iniciar um novo ciclo zera a contagem de capítulos únicos
/// sem apagar o histórico de [ReadingLogs].
@DataClassName('ReadingCycle')
class ReadingCycles extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startedAt => dateTime()();

  /// Nulo enquanto o ciclo estiver ativo.
  DateTimeColumn get endedAt => dateTime().nullable()();
}

/// Registro de capítulos lidos. Releituras em dias diferentes são permitidas;
/// a duplicidade no mesmo dia é bloqueada em [ReadingDao.logChapter].
@DataClassName('ReadingLog')
@TableIndex(name: 'idx_reading_logs_read_at', columns: {#readAt})
@TableIndex(name: 'idx_reading_logs_book_chapter', columns: {#bookId, #chapter})
@TableIndex(name: 'idx_reading_logs_cycle', columns: {#cycleId, #bookId, #chapter})
class ReadingLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer().references(Books, #id)();
  IntColumn get chapter => integer()();
  DateTimeColumn get readAt => dateTime()();
  TextColumn get source => text().map(const ReadingSourceConverter())();

  /// Ciclo ativo no momento do registro.
  IntColumn get cycleId => integer().references(ReadingCycles, #id)();
}

/// Recitativos (Culto de Jovens e Menores).
@DataClassName('Recitative')
@TableIndex(name: 'idx_recitatives_service_date', columns: {#serviceDate})
@TableIndex(name: 'idx_recitatives_status_date', columns: {#status, #serviceDate})
class Recitatives extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer().references(Books, #id)();
  IntColumn get chapter => integer()();
  IntColumn get verseStart => integer()();
  IntColumn get verseEnd => integer().nullable()();
  TextColumn get verseTextSnapshot => text()();
  DateTimeColumn get serviceDate => dateTime()();
  TextColumn get congregation => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get status => textEnum<RecitativeStatus>()();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now())();
}

/// Caderno de oração.
@DataClassName('PrayerRequest')
@TableIndex(name: 'idx_prayer_requests_status', columns: {#status})
class PrayerRequests extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  TextColumn get category => text().map(const PrayerCategoryConverter())();
  TextColumn get status => textEnum<PrayerStatus>()();
  IntColumn get prayCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPrayedAt => dateTime().nullable()();
  DateTimeColumn get answeredAt => dateTime().nullable()();
  TextColumn get answerTestimony => text().nullable()();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now())();
}

/// Anotações devocionais vinculadas a um capítulo ou versículo.
@DataClassName('VerseNote')
@TableIndex(name: 'idx_verse_notes_book_chapter', columns: {#bookId, #chapter})
class VerseNotes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer().references(Books, #id)();
  IntColumn get chapter => integer()();
  IntColumn get verse => integer().nullable()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now())();
}

/// Preferências do usuário (chave/valor), para sobreviver a backups e reinstalações.
@DataClassName('AppSettingEntry')
class AppSettingsEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Planos de leitura iniciados pelo usuário. Só um fica ativo por vez
/// ([endedAt] nulo); o progresso vem das leituras registradas desde [startedAt].
@DataClassName('PlanEnrollment')
class PlanEnrollments extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Identificador estável do plano (ex.: 'nt-90-dias').
  TextColumn get planId => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
}

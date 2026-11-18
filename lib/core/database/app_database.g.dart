// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BooksTable extends Books with TableInfo<$BooksTable, Book> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _abbrevMeta = const VerificationMeta('abbrev');
  @override
  late final GeneratedColumn<String> abbrev = GeneratedColumn<String>(
    'abbrev',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _testamentMeta = const VerificationMeta(
    'testament',
  );
  @override
  late final GeneratedColumn<String> testament = GeneratedColumn<String>(
    'testament',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 2,
      maxTextLength: 2,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chaptersCountMeta = const VerificationMeta(
    'chaptersCount',
  );
  @override
  late final GeneratedColumn<int> chaptersCount = GeneratedColumn<int>(
    'chapters_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    abbrev,
    testament,
    chaptersCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(
    Insertable<Book> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('abbrev')) {
      context.handle(
        _abbrevMeta,
        abbrev.isAcceptableOrUnknown(data['abbrev']!, _abbrevMeta),
      );
    } else if (isInserting) {
      context.missing(_abbrevMeta);
    }
    if (data.containsKey('testament')) {
      context.handle(
        _testamentMeta,
        testament.isAcceptableOrUnknown(data['testament']!, _testamentMeta),
      );
    } else if (isInserting) {
      context.missing(_testamentMeta);
    }
    if (data.containsKey('chapters_count')) {
      context.handle(
        _chaptersCountMeta,
        chaptersCount.isAcceptableOrUnknown(
          data['chapters_count']!,
          _chaptersCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chaptersCountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Book map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Book(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      abbrev: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}abbrev'],
      )!,
      testament: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}testament'],
      )!,
      chaptersCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapters_count'],
      )!,
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class Book extends DataClass implements Insertable<Book> {
  final int id;
  final String name;
  final String abbrev;

  /// 'AT' ou 'NT'.
  final String testament;
  final int chaptersCount;
  const Book({
    required this.id,
    required this.name,
    required this.abbrev,
    required this.testament,
    required this.chaptersCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['abbrev'] = Variable<String>(abbrev);
    map['testament'] = Variable<String>(testament);
    map['chapters_count'] = Variable<int>(chaptersCount);
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      name: Value(name),
      abbrev: Value(abbrev),
      testament: Value(testament),
      chaptersCount: Value(chaptersCount),
    );
  }

  factory Book.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Book(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      abbrev: serializer.fromJson<String>(json['abbrev']),
      testament: serializer.fromJson<String>(json['testament']),
      chaptersCount: serializer.fromJson<int>(json['chaptersCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'abbrev': serializer.toJson<String>(abbrev),
      'testament': serializer.toJson<String>(testament),
      'chaptersCount': serializer.toJson<int>(chaptersCount),
    };
  }

  Book copyWith({
    int? id,
    String? name,
    String? abbrev,
    String? testament,
    int? chaptersCount,
  }) => Book(
    id: id ?? this.id,
    name: name ?? this.name,
    abbrev: abbrev ?? this.abbrev,
    testament: testament ?? this.testament,
    chaptersCount: chaptersCount ?? this.chaptersCount,
  );
  Book copyWithCompanion(BooksCompanion data) {
    return Book(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      abbrev: data.abbrev.present ? data.abbrev.value : this.abbrev,
      testament: data.testament.present ? data.testament.value : this.testament,
      chaptersCount: data.chaptersCount.present
          ? data.chaptersCount.value
          : this.chaptersCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Book(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('abbrev: $abbrev, ')
          ..write('testament: $testament, ')
          ..write('chaptersCount: $chaptersCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, abbrev, testament, chaptersCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Book &&
          other.id == this.id &&
          other.name == this.name &&
          other.abbrev == this.abbrev &&
          other.testament == this.testament &&
          other.chaptersCount == this.chaptersCount);
}

class BooksCompanion extends UpdateCompanion<Book> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> abbrev;
  final Value<String> testament;
  final Value<int> chaptersCount;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.abbrev = const Value.absent(),
    this.testament = const Value.absent(),
    this.chaptersCount = const Value.absent(),
  });
  BooksCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String abbrev,
    required String testament,
    required int chaptersCount,
  }) : name = Value(name),
       abbrev = Value(abbrev),
       testament = Value(testament),
       chaptersCount = Value(chaptersCount);
  static Insertable<Book> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? abbrev,
    Expression<String>? testament,
    Expression<int>? chaptersCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (abbrev != null) 'abbrev': abbrev,
      if (testament != null) 'testament': testament,
      if (chaptersCount != null) 'chapters_count': chaptersCount,
    });
  }

  BooksCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? abbrev,
    Value<String>? testament,
    Value<int>? chaptersCount,
  }) {
    return BooksCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      abbrev: abbrev ?? this.abbrev,
      testament: testament ?? this.testament,
      chaptersCount: chaptersCount ?? this.chaptersCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (abbrev.present) {
      map['abbrev'] = Variable<String>(abbrev.value);
    }
    if (testament.present) {
      map['testament'] = Variable<String>(testament.value);
    }
    if (chaptersCount.present) {
      map['chapters_count'] = Variable<int>(chaptersCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('abbrev: $abbrev, ')
          ..write('testament: $testament, ')
          ..write('chaptersCount: $chaptersCount')
          ..write(')'))
        .toString();
  }
}

class $VersesTable extends Verses with TableInfo<$VersesTable, Verse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VersesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<BibleTranslation, String>
  translation = GeneratedColumn<String>(
    'translation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('arc'),
  ).withConverter<BibleTranslation>($VersesTable.$convertertranslation);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  static const VerificationMeta _chapterMeta = const VerificationMeta(
    'chapter',
  );
  @override
  late final GeneratedColumn<int> chapter = GeneratedColumn<int>(
    'chapter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseMeta = const VerificationMeta('verse');
  @override
  late final GeneratedColumn<int> verse = GeneratedColumn<int>(
    'verse',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseTextMeta = const VerificationMeta(
    'verseText',
  );
  @override
  late final GeneratedColumn<String> verseText = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    translation,
    bookId,
    chapter,
    verse,
    verseText,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'verses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Verse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter')) {
      context.handle(
        _chapterMeta,
        chapter.isAcceptableOrUnknown(data['chapter']!, _chapterMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterMeta);
    }
    if (data.containsKey('verse')) {
      context.handle(
        _verseMeta,
        verse.isAcceptableOrUnknown(data['verse']!, _verseMeta),
      );
    } else if (isInserting) {
      context.missing(_verseMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _verseTextMeta,
        verseText.isAcceptableOrUnknown(data['text']!, _verseTextMeta),
      );
    } else if (isInserting) {
      context.missing(_verseTextMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Verse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Verse(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      translation: $VersesTable.$convertertranslation.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}translation'],
        )!,
      ),
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      chapter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter'],
      )!,
      verse: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verse'],
      )!,
      verseText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
    );
  }

  @override
  $VersesTable createAlias(String alias) {
    return $VersesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BibleTranslation, String, String>
  $convertertranslation = const EnumNameConverter<BibleTranslation>(
    BibleTranslation.values,
  );
}

class Verse extends DataClass implements Insertable<Verse> {
  final int id;
  final BibleTranslation translation;
  final int bookId;
  final int chapter;
  final int verse;

  /// Coluna SQL `text` (o getter não pode se chamar `text`, pois colidiria com o builder do Drift).
  final String verseText;
  const Verse({
    required this.id,
    required this.translation,
    required this.bookId,
    required this.chapter,
    required this.verse,
    required this.verseText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['translation'] = Variable<String>(
        $VersesTable.$convertertranslation.toSql(translation),
      );
    }
    map['book_id'] = Variable<int>(bookId);
    map['chapter'] = Variable<int>(chapter);
    map['verse'] = Variable<int>(verse);
    map['text'] = Variable<String>(verseText);
    return map;
  }

  VersesCompanion toCompanion(bool nullToAbsent) {
    return VersesCompanion(
      id: Value(id),
      translation: Value(translation),
      bookId: Value(bookId),
      chapter: Value(chapter),
      verse: Value(verse),
      verseText: Value(verseText),
    );
  }

  factory Verse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Verse(
      id: serializer.fromJson<int>(json['id']),
      translation: $VersesTable.$convertertranslation.fromJson(
        serializer.fromJson<String>(json['translation']),
      ),
      bookId: serializer.fromJson<int>(json['bookId']),
      chapter: serializer.fromJson<int>(json['chapter']),
      verse: serializer.fromJson<int>(json['verse']),
      verseText: serializer.fromJson<String>(json['verseText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'translation': serializer.toJson<String>(
        $VersesTable.$convertertranslation.toJson(translation),
      ),
      'bookId': serializer.toJson<int>(bookId),
      'chapter': serializer.toJson<int>(chapter),
      'verse': serializer.toJson<int>(verse),
      'verseText': serializer.toJson<String>(verseText),
    };
  }

  Verse copyWith({
    int? id,
    BibleTranslation? translation,
    int? bookId,
    int? chapter,
    int? verse,
    String? verseText,
  }) => Verse(
    id: id ?? this.id,
    translation: translation ?? this.translation,
    bookId: bookId ?? this.bookId,
    chapter: chapter ?? this.chapter,
    verse: verse ?? this.verse,
    verseText: verseText ?? this.verseText,
  );
  Verse copyWithCompanion(VersesCompanion data) {
    return Verse(
      id: data.id.present ? data.id.value : this.id,
      translation: data.translation.present
          ? data.translation.value
          : this.translation,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      chapter: data.chapter.present ? data.chapter.value : this.chapter,
      verse: data.verse.present ? data.verse.value : this.verse,
      verseText: data.verseText.present ? data.verseText.value : this.verseText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Verse(')
          ..write('id: $id, ')
          ..write('translation: $translation, ')
          ..write('bookId: $bookId, ')
          ..write('chapter: $chapter, ')
          ..write('verse: $verse, ')
          ..write('verseText: $verseText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, translation, bookId, chapter, verse, verseText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Verse &&
          other.id == this.id &&
          other.translation == this.translation &&
          other.bookId == this.bookId &&
          other.chapter == this.chapter &&
          other.verse == this.verse &&
          other.verseText == this.verseText);
}

class VersesCompanion extends UpdateCompanion<Verse> {
  final Value<int> id;
  final Value<BibleTranslation> translation;
  final Value<int> bookId;
  final Value<int> chapter;
  final Value<int> verse;
  final Value<String> verseText;
  const VersesCompanion({
    this.id = const Value.absent(),
    this.translation = const Value.absent(),
    this.bookId = const Value.absent(),
    this.chapter = const Value.absent(),
    this.verse = const Value.absent(),
    this.verseText = const Value.absent(),
  });
  VersesCompanion.insert({
    this.id = const Value.absent(),
    this.translation = const Value.absent(),
    required int bookId,
    required int chapter,
    required int verse,
    required String verseText,
  }) : bookId = Value(bookId),
       chapter = Value(chapter),
       verse = Value(verse),
       verseText = Value(verseText);
  static Insertable<Verse> custom({
    Expression<int>? id,
    Expression<String>? translation,
    Expression<int>? bookId,
    Expression<int>? chapter,
    Expression<int>? verse,
    Expression<String>? verseText,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (translation != null) 'translation': translation,
      if (bookId != null) 'book_id': bookId,
      if (chapter != null) 'chapter': chapter,
      if (verse != null) 'verse': verse,
      if (verseText != null) 'text': verseText,
    });
  }

  VersesCompanion copyWith({
    Value<int>? id,
    Value<BibleTranslation>? translation,
    Value<int>? bookId,
    Value<int>? chapter,
    Value<int>? verse,
    Value<String>? verseText,
  }) {
    return VersesCompanion(
      id: id ?? this.id,
      translation: translation ?? this.translation,
      bookId: bookId ?? this.bookId,
      chapter: chapter ?? this.chapter,
      verse: verse ?? this.verse,
      verseText: verseText ?? this.verseText,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (translation.present) {
      map['translation'] = Variable<String>(
        $VersesTable.$convertertranslation.toSql(translation.value),
      );
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (chapter.present) {
      map['chapter'] = Variable<int>(chapter.value);
    }
    if (verse.present) {
      map['verse'] = Variable<int>(verse.value);
    }
    if (verseText.present) {
      map['text'] = Variable<String>(verseText.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VersesCompanion(')
          ..write('id: $id, ')
          ..write('translation: $translation, ')
          ..write('bookId: $bookId, ')
          ..write('chapter: $chapter, ')
          ..write('verse: $verse, ')
          ..write('verseText: $verseText')
          ..write(')'))
        .toString();
  }
}

class $ReadingCyclesTable extends ReadingCycles
    with TableInfo<$ReadingCyclesTable, ReadingCycle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingCyclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, startedAt, endedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_cycles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingCycle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingCycle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingCycle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
    );
  }

  @override
  $ReadingCyclesTable createAlias(String alias) {
    return $ReadingCyclesTable(attachedDatabase, alias);
  }
}

class ReadingCycle extends DataClass implements Insertable<ReadingCycle> {
  final int id;
  final DateTime startedAt;

  /// Nulo enquanto o ciclo estiver ativo.
  final DateTime? endedAt;
  const ReadingCycle({required this.id, required this.startedAt, this.endedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    return map;
  }

  ReadingCyclesCompanion toCompanion(bool nullToAbsent) {
    return ReadingCyclesCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
    );
  }

  factory ReadingCycle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingCycle(
      id: serializer.fromJson<int>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
    };
  }

  ReadingCycle copyWith({
    int? id,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
  }) => ReadingCycle(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
  );
  ReadingCycle copyWithCompanion(ReadingCyclesCompanion data) {
    return ReadingCycle(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingCycle(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, startedAt, endedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingCycle &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt);
}

class ReadingCyclesCompanion extends UpdateCompanion<ReadingCycle> {
  final Value<int> id;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  const ReadingCyclesCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
  });
  ReadingCyclesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
  }) : startedAt = Value(startedAt);
  static Insertable<ReadingCycle> custom({
    Expression<int>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
    });
  }

  ReadingCyclesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
  }) {
    return ReadingCyclesCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingCyclesCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt')
          ..write(')'))
        .toString();
  }
}

class $ReadingLogsTable extends ReadingLogs
    with TableInfo<$ReadingLogsTable, ReadingLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  static const VerificationMeta _chapterMeta = const VerificationMeta(
    'chapter',
  );
  @override
  late final GeneratedColumn<int> chapter = GeneratedColumn<int>(
    'chapter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
    'read_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ReadingSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ReadingSource>($ReadingLogsTable.$convertersource);
  static const VerificationMeta _cycleIdMeta = const VerificationMeta(
    'cycleId',
  );
  @override
  late final GeneratedColumn<int> cycleId = GeneratedColumn<int>(
    'cycle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES reading_cycles (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    chapter,
    readAt,
    source,
    cycleId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter')) {
      context.handle(
        _chapterMeta,
        chapter.isAcceptableOrUnknown(data['chapter']!, _chapterMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterMeta);
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    } else if (isInserting) {
      context.missing(_readAtMeta);
    }
    if (data.containsKey('cycle_id')) {
      context.handle(
        _cycleIdMeta,
        cycleId.isAcceptableOrUnknown(data['cycle_id']!, _cycleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cycleIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      chapter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter'],
      )!,
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}read_at'],
      )!,
      source: $ReadingLogsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      cycleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cycle_id'],
      )!,
    );
  }

  @override
  $ReadingLogsTable createAlias(String alias) {
    return $ReadingLogsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ReadingSource, String, String> $convertersource =
      const ReadingSourceConverter();
}

class ReadingLog extends DataClass implements Insertable<ReadingLog> {
  final int id;
  final int bookId;
  final int chapter;
  final DateTime readAt;
  final ReadingSource source;

  /// Ciclo ativo no momento do registro.
  final int cycleId;
  const ReadingLog({
    required this.id,
    required this.bookId,
    required this.chapter,
    required this.readAt,
    required this.source,
    required this.cycleId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['chapter'] = Variable<int>(chapter);
    map['read_at'] = Variable<DateTime>(readAt);
    {
      map['source'] = Variable<String>(
        $ReadingLogsTable.$convertersource.toSql(source),
      );
    }
    map['cycle_id'] = Variable<int>(cycleId);
    return map;
  }

  ReadingLogsCompanion toCompanion(bool nullToAbsent) {
    return ReadingLogsCompanion(
      id: Value(id),
      bookId: Value(bookId),
      chapter: Value(chapter),
      readAt: Value(readAt),
      source: Value(source),
      cycleId: Value(cycleId),
    );
  }

  factory ReadingLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingLog(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      chapter: serializer.fromJson<int>(json['chapter']),
      readAt: serializer.fromJson<DateTime>(json['readAt']),
      source: $ReadingLogsTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      cycleId: serializer.fromJson<int>(json['cycleId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'chapter': serializer.toJson<int>(chapter),
      'readAt': serializer.toJson<DateTime>(readAt),
      'source': serializer.toJson<String>(
        $ReadingLogsTable.$convertersource.toJson(source),
      ),
      'cycleId': serializer.toJson<int>(cycleId),
    };
  }

  ReadingLog copyWith({
    int? id,
    int? bookId,
    int? chapter,
    DateTime? readAt,
    ReadingSource? source,
    int? cycleId,
  }) => ReadingLog(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    chapter: chapter ?? this.chapter,
    readAt: readAt ?? this.readAt,
    source: source ?? this.source,
    cycleId: cycleId ?? this.cycleId,
  );
  ReadingLog copyWithCompanion(ReadingLogsCompanion data) {
    return ReadingLog(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      chapter: data.chapter.present ? data.chapter.value : this.chapter,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
      source: data.source.present ? data.source.value : this.source,
      cycleId: data.cycleId.present ? data.cycleId.value : this.cycleId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingLog(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapter: $chapter, ')
          ..write('readAt: $readAt, ')
          ..write('source: $source, ')
          ..write('cycleId: $cycleId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookId, chapter, readAt, source, cycleId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingLog &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.chapter == this.chapter &&
          other.readAt == this.readAt &&
          other.source == this.source &&
          other.cycleId == this.cycleId);
}

class ReadingLogsCompanion extends UpdateCompanion<ReadingLog> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<int> chapter;
  final Value<DateTime> readAt;
  final Value<ReadingSource> source;
  final Value<int> cycleId;
  const ReadingLogsCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.chapter = const Value.absent(),
    this.readAt = const Value.absent(),
    this.source = const Value.absent(),
    this.cycleId = const Value.absent(),
  });
  ReadingLogsCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required int chapter,
    required DateTime readAt,
    required ReadingSource source,
    required int cycleId,
  }) : bookId = Value(bookId),
       chapter = Value(chapter),
       readAt = Value(readAt),
       source = Value(source),
       cycleId = Value(cycleId);
  static Insertable<ReadingLog> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<int>? chapter,
    Expression<DateTime>? readAt,
    Expression<String>? source,
    Expression<int>? cycleId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (chapter != null) 'chapter': chapter,
      if (readAt != null) 'read_at': readAt,
      if (source != null) 'source': source,
      if (cycleId != null) 'cycle_id': cycleId,
    });
  }

  ReadingLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? bookId,
    Value<int>? chapter,
    Value<DateTime>? readAt,
    Value<ReadingSource>? source,
    Value<int>? cycleId,
  }) {
    return ReadingLogsCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      chapter: chapter ?? this.chapter,
      readAt: readAt ?? this.readAt,
      source: source ?? this.source,
      cycleId: cycleId ?? this.cycleId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (chapter.present) {
      map['chapter'] = Variable<int>(chapter.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $ReadingLogsTable.$convertersource.toSql(source.value),
      );
    }
    if (cycleId.present) {
      map['cycle_id'] = Variable<int>(cycleId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingLogsCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapter: $chapter, ')
          ..write('readAt: $readAt, ')
          ..write('source: $source, ')
          ..write('cycleId: $cycleId')
          ..write(')'))
        .toString();
  }
}

class $RecitativesTable extends Recitatives
    with TableInfo<$RecitativesTable, Recitative> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecitativesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  static const VerificationMeta _chapterMeta = const VerificationMeta(
    'chapter',
  );
  @override
  late final GeneratedColumn<int> chapter = GeneratedColumn<int>(
    'chapter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseStartMeta = const VerificationMeta(
    'verseStart',
  );
  @override
  late final GeneratedColumn<int> verseStart = GeneratedColumn<int>(
    'verse_start',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseEndMeta = const VerificationMeta(
    'verseEnd',
  );
  @override
  late final GeneratedColumn<int> verseEnd = GeneratedColumn<int>(
    'verse_end',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _verseTextSnapshotMeta = const VerificationMeta(
    'verseTextSnapshot',
  );
  @override
  late final GeneratedColumn<String> verseTextSnapshot =
      GeneratedColumn<String>(
        'verse_text_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _serviceDateMeta = const VerificationMeta(
    'serviceDate',
  );
  @override
  late final GeneratedColumn<DateTime> serviceDate = GeneratedColumn<DateTime>(
    'service_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _congregationMeta = const VerificationMeta(
    'congregation',
  );
  @override
  late final GeneratedColumn<String> congregation = GeneratedColumn<String>(
    'congregation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RecitativeStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RecitativeStatus>($RecitativesTable.$converterstatus);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    chapter,
    verseStart,
    verseEnd,
    verseTextSnapshot,
    serviceDate,
    congregation,
    notes,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recitatives';
  @override
  VerificationContext validateIntegrity(
    Insertable<Recitative> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter')) {
      context.handle(
        _chapterMeta,
        chapter.isAcceptableOrUnknown(data['chapter']!, _chapterMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterMeta);
    }
    if (data.containsKey('verse_start')) {
      context.handle(
        _verseStartMeta,
        verseStart.isAcceptableOrUnknown(data['verse_start']!, _verseStartMeta),
      );
    } else if (isInserting) {
      context.missing(_verseStartMeta);
    }
    if (data.containsKey('verse_end')) {
      context.handle(
        _verseEndMeta,
        verseEnd.isAcceptableOrUnknown(data['verse_end']!, _verseEndMeta),
      );
    }
    if (data.containsKey('verse_text_snapshot')) {
      context.handle(
        _verseTextSnapshotMeta,
        verseTextSnapshot.isAcceptableOrUnknown(
          data['verse_text_snapshot']!,
          _verseTextSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_verseTextSnapshotMeta);
    }
    if (data.containsKey('service_date')) {
      context.handle(
        _serviceDateMeta,
        serviceDate.isAcceptableOrUnknown(
          data['service_date']!,
          _serviceDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serviceDateMeta);
    }
    if (data.containsKey('congregation')) {
      context.handle(
        _congregationMeta,
        congregation.isAcceptableOrUnknown(
          data['congregation']!,
          _congregationMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Recitative map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recitative(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      chapter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter'],
      )!,
      verseStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verse_start'],
      )!,
      verseEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verse_end'],
      ),
      verseTextSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verse_text_snapshot'],
      )!,
      serviceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}service_date'],
      )!,
      congregation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}congregation'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      status: $RecitativesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RecitativesTable createAlias(String alias) {
    return $RecitativesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RecitativeStatus, String, String> $converterstatus =
      const EnumNameConverter<RecitativeStatus>(RecitativeStatus.values);
}

class Recitative extends DataClass implements Insertable<Recitative> {
  final int id;
  final int bookId;
  final int chapter;
  final int verseStart;
  final int? verseEnd;
  final String verseTextSnapshot;
  final DateTime serviceDate;
  final String? congregation;
  final String? notes;
  final RecitativeStatus status;
  final DateTime createdAt;
  const Recitative({
    required this.id,
    required this.bookId,
    required this.chapter,
    required this.verseStart,
    this.verseEnd,
    required this.verseTextSnapshot,
    required this.serviceDate,
    this.congregation,
    this.notes,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['chapter'] = Variable<int>(chapter);
    map['verse_start'] = Variable<int>(verseStart);
    if (!nullToAbsent || verseEnd != null) {
      map['verse_end'] = Variable<int>(verseEnd);
    }
    map['verse_text_snapshot'] = Variable<String>(verseTextSnapshot);
    map['service_date'] = Variable<DateTime>(serviceDate);
    if (!nullToAbsent || congregation != null) {
      map['congregation'] = Variable<String>(congregation);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    {
      map['status'] = Variable<String>(
        $RecitativesTable.$converterstatus.toSql(status),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RecitativesCompanion toCompanion(bool nullToAbsent) {
    return RecitativesCompanion(
      id: Value(id),
      bookId: Value(bookId),
      chapter: Value(chapter),
      verseStart: Value(verseStart),
      verseEnd: verseEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(verseEnd),
      verseTextSnapshot: Value(verseTextSnapshot),
      serviceDate: Value(serviceDate),
      congregation: congregation == null && nullToAbsent
          ? const Value.absent()
          : Value(congregation),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory Recitative.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recitative(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      chapter: serializer.fromJson<int>(json['chapter']),
      verseStart: serializer.fromJson<int>(json['verseStart']),
      verseEnd: serializer.fromJson<int?>(json['verseEnd']),
      verseTextSnapshot: serializer.fromJson<String>(json['verseTextSnapshot']),
      serviceDate: serializer.fromJson<DateTime>(json['serviceDate']),
      congregation: serializer.fromJson<String?>(json['congregation']),
      notes: serializer.fromJson<String?>(json['notes']),
      status: $RecitativesTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'chapter': serializer.toJson<int>(chapter),
      'verseStart': serializer.toJson<int>(verseStart),
      'verseEnd': serializer.toJson<int?>(verseEnd),
      'verseTextSnapshot': serializer.toJson<String>(verseTextSnapshot),
      'serviceDate': serializer.toJson<DateTime>(serviceDate),
      'congregation': serializer.toJson<String?>(congregation),
      'notes': serializer.toJson<String?>(notes),
      'status': serializer.toJson<String>(
        $RecitativesTable.$converterstatus.toJson(status),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Recitative copyWith({
    int? id,
    int? bookId,
    int? chapter,
    int? verseStart,
    Value<int?> verseEnd = const Value.absent(),
    String? verseTextSnapshot,
    DateTime? serviceDate,
    Value<String?> congregation = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    RecitativeStatus? status,
    DateTime? createdAt,
  }) => Recitative(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    chapter: chapter ?? this.chapter,
    verseStart: verseStart ?? this.verseStart,
    verseEnd: verseEnd.present ? verseEnd.value : this.verseEnd,
    verseTextSnapshot: verseTextSnapshot ?? this.verseTextSnapshot,
    serviceDate: serviceDate ?? this.serviceDate,
    congregation: congregation.present ? congregation.value : this.congregation,
    notes: notes.present ? notes.value : this.notes,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  Recitative copyWithCompanion(RecitativesCompanion data) {
    return Recitative(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      chapter: data.chapter.present ? data.chapter.value : this.chapter,
      verseStart: data.verseStart.present
          ? data.verseStart.value
          : this.verseStart,
      verseEnd: data.verseEnd.present ? data.verseEnd.value : this.verseEnd,
      verseTextSnapshot: data.verseTextSnapshot.present
          ? data.verseTextSnapshot.value
          : this.verseTextSnapshot,
      serviceDate: data.serviceDate.present
          ? data.serviceDate.value
          : this.serviceDate,
      congregation: data.congregation.present
          ? data.congregation.value
          : this.congregation,
      notes: data.notes.present ? data.notes.value : this.notes,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Recitative(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapter: $chapter, ')
          ..write('verseStart: $verseStart, ')
          ..write('verseEnd: $verseEnd, ')
          ..write('verseTextSnapshot: $verseTextSnapshot, ')
          ..write('serviceDate: $serviceDate, ')
          ..write('congregation: $congregation, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    chapter,
    verseStart,
    verseEnd,
    verseTextSnapshot,
    serviceDate,
    congregation,
    notes,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recitative &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.chapter == this.chapter &&
          other.verseStart == this.verseStart &&
          other.verseEnd == this.verseEnd &&
          other.verseTextSnapshot == this.verseTextSnapshot &&
          other.serviceDate == this.serviceDate &&
          other.congregation == this.congregation &&
          other.notes == this.notes &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class RecitativesCompanion extends UpdateCompanion<Recitative> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<int> chapter;
  final Value<int> verseStart;
  final Value<int?> verseEnd;
  final Value<String> verseTextSnapshot;
  final Value<DateTime> serviceDate;
  final Value<String?> congregation;
  final Value<String?> notes;
  final Value<RecitativeStatus> status;
  final Value<DateTime> createdAt;
  const RecitativesCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.chapter = const Value.absent(),
    this.verseStart = const Value.absent(),
    this.verseEnd = const Value.absent(),
    this.verseTextSnapshot = const Value.absent(),
    this.serviceDate = const Value.absent(),
    this.congregation = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RecitativesCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required int chapter,
    required int verseStart,
    this.verseEnd = const Value.absent(),
    required String verseTextSnapshot,
    required DateTime serviceDate,
    this.congregation = const Value.absent(),
    this.notes = const Value.absent(),
    required RecitativeStatus status,
    this.createdAt = const Value.absent(),
  }) : bookId = Value(bookId),
       chapter = Value(chapter),
       verseStart = Value(verseStart),
       verseTextSnapshot = Value(verseTextSnapshot),
       serviceDate = Value(serviceDate),
       status = Value(status);
  static Insertable<Recitative> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<int>? chapter,
    Expression<int>? verseStart,
    Expression<int>? verseEnd,
    Expression<String>? verseTextSnapshot,
    Expression<DateTime>? serviceDate,
    Expression<String>? congregation,
    Expression<String>? notes,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (chapter != null) 'chapter': chapter,
      if (verseStart != null) 'verse_start': verseStart,
      if (verseEnd != null) 'verse_end': verseEnd,
      if (verseTextSnapshot != null) 'verse_text_snapshot': verseTextSnapshot,
      if (serviceDate != null) 'service_date': serviceDate,
      if (congregation != null) 'congregation': congregation,
      if (notes != null) 'notes': notes,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RecitativesCompanion copyWith({
    Value<int>? id,
    Value<int>? bookId,
    Value<int>? chapter,
    Value<int>? verseStart,
    Value<int?>? verseEnd,
    Value<String>? verseTextSnapshot,
    Value<DateTime>? serviceDate,
    Value<String?>? congregation,
    Value<String?>? notes,
    Value<RecitativeStatus>? status,
    Value<DateTime>? createdAt,
  }) {
    return RecitativesCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      chapter: chapter ?? this.chapter,
      verseStart: verseStart ?? this.verseStart,
      verseEnd: verseEnd ?? this.verseEnd,
      verseTextSnapshot: verseTextSnapshot ?? this.verseTextSnapshot,
      serviceDate: serviceDate ?? this.serviceDate,
      congregation: congregation ?? this.congregation,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (chapter.present) {
      map['chapter'] = Variable<int>(chapter.value);
    }
    if (verseStart.present) {
      map['verse_start'] = Variable<int>(verseStart.value);
    }
    if (verseEnd.present) {
      map['verse_end'] = Variable<int>(verseEnd.value);
    }
    if (verseTextSnapshot.present) {
      map['verse_text_snapshot'] = Variable<String>(verseTextSnapshot.value);
    }
    if (serviceDate.present) {
      map['service_date'] = Variable<DateTime>(serviceDate.value);
    }
    if (congregation.present) {
      map['congregation'] = Variable<String>(congregation.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $RecitativesTable.$converterstatus.toSql(status.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecitativesCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapter: $chapter, ')
          ..write('verseStart: $verseStart, ')
          ..write('verseEnd: $verseEnd, ')
          ..write('verseTextSnapshot: $verseTextSnapshot, ')
          ..write('serviceDate: $serviceDate, ')
          ..write('congregation: $congregation, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PrayerRequestsTable extends PrayerRequests
    with TableInfo<$PrayerRequestsTable, PrayerRequest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrayerRequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PrayerCategory, String> category =
      GeneratedColumn<String>(
        'category',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PrayerCategory>($PrayerRequestsTable.$convertercategory);
  @override
  late final GeneratedColumnWithTypeConverter<PrayerStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PrayerStatus>($PrayerRequestsTable.$converterstatus);
  static const VerificationMeta _prayCountMeta = const VerificationMeta(
    'prayCount',
  );
  @override
  late final GeneratedColumn<int> prayCount = GeneratedColumn<int>(
    'pray_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPrayedAtMeta = const VerificationMeta(
    'lastPrayedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPrayedAt = GeneratedColumn<DateTime>(
    'last_prayed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _answeredAtMeta = const VerificationMeta(
    'answeredAt',
  );
  @override
  late final GeneratedColumn<DateTime> answeredAt = GeneratedColumn<DateTime>(
    'answered_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _answerTestimonyMeta = const VerificationMeta(
    'answerTestimony',
  );
  @override
  late final GeneratedColumn<String> answerTestimony = GeneratedColumn<String>(
    'answer_testimony',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    category,
    status,
    prayCount,
    lastPrayedAt,
    answeredAt,
    answerTestimony,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prayer_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrayerRequest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('pray_count')) {
      context.handle(
        _prayCountMeta,
        prayCount.isAcceptableOrUnknown(data['pray_count']!, _prayCountMeta),
      );
    }
    if (data.containsKey('last_prayed_at')) {
      context.handle(
        _lastPrayedAtMeta,
        lastPrayedAt.isAcceptableOrUnknown(
          data['last_prayed_at']!,
          _lastPrayedAtMeta,
        ),
      );
    }
    if (data.containsKey('answered_at')) {
      context.handle(
        _answeredAtMeta,
        answeredAt.isAcceptableOrUnknown(data['answered_at']!, _answeredAtMeta),
      );
    }
    if (data.containsKey('answer_testimony')) {
      context.handle(
        _answerTestimonyMeta,
        answerTestimony.isAcceptableOrUnknown(
          data['answer_testimony']!,
          _answerTestimonyMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PrayerRequest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrayerRequest(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      category: $PrayerRequestsTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      status: $PrayerRequestsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      prayCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pray_count'],
      )!,
      lastPrayedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_prayed_at'],
      ),
      answeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}answered_at'],
      ),
      answerTestimony: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answer_testimony'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PrayerRequestsTable createAlias(String alias) {
    return $PrayerRequestsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PrayerCategory, String, String> $convertercategory =
      const PrayerCategoryConverter();
  static JsonTypeConverter2<PrayerStatus, String, String> $converterstatus =
      const EnumNameConverter<PrayerStatus>(PrayerStatus.values);
}

class PrayerRequest extends DataClass implements Insertable<PrayerRequest> {
  final int id;
  final String title;
  final String? description;
  final PrayerCategory category;
  final PrayerStatus status;
  final int prayCount;
  final DateTime? lastPrayedAt;
  final DateTime? answeredAt;
  final String? answerTestimony;
  final DateTime createdAt;
  const PrayerRequest({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.status,
    required this.prayCount,
    this.lastPrayedAt,
    this.answeredAt,
    this.answerTestimony,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    {
      map['category'] = Variable<String>(
        $PrayerRequestsTable.$convertercategory.toSql(category),
      );
    }
    {
      map['status'] = Variable<String>(
        $PrayerRequestsTable.$converterstatus.toSql(status),
      );
    }
    map['pray_count'] = Variable<int>(prayCount);
    if (!nullToAbsent || lastPrayedAt != null) {
      map['last_prayed_at'] = Variable<DateTime>(lastPrayedAt);
    }
    if (!nullToAbsent || answeredAt != null) {
      map['answered_at'] = Variable<DateTime>(answeredAt);
    }
    if (!nullToAbsent || answerTestimony != null) {
      map['answer_testimony'] = Variable<String>(answerTestimony);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PrayerRequestsCompanion toCompanion(bool nullToAbsent) {
    return PrayerRequestsCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      category: Value(category),
      status: Value(status),
      prayCount: Value(prayCount),
      lastPrayedAt: lastPrayedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPrayedAt),
      answeredAt: answeredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(answeredAt),
      answerTestimony: answerTestimony == null && nullToAbsent
          ? const Value.absent()
          : Value(answerTestimony),
      createdAt: Value(createdAt),
    );
  }

  factory PrayerRequest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrayerRequest(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      category: $PrayerRequestsTable.$convertercategory.fromJson(
        serializer.fromJson<String>(json['category']),
      ),
      status: $PrayerRequestsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      prayCount: serializer.fromJson<int>(json['prayCount']),
      lastPrayedAt: serializer.fromJson<DateTime?>(json['lastPrayedAt']),
      answeredAt: serializer.fromJson<DateTime?>(json['answeredAt']),
      answerTestimony: serializer.fromJson<String?>(json['answerTestimony']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'category': serializer.toJson<String>(
        $PrayerRequestsTable.$convertercategory.toJson(category),
      ),
      'status': serializer.toJson<String>(
        $PrayerRequestsTable.$converterstatus.toJson(status),
      ),
      'prayCount': serializer.toJson<int>(prayCount),
      'lastPrayedAt': serializer.toJson<DateTime?>(lastPrayedAt),
      'answeredAt': serializer.toJson<DateTime?>(answeredAt),
      'answerTestimony': serializer.toJson<String?>(answerTestimony),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PrayerRequest copyWith({
    int? id,
    String? title,
    Value<String?> description = const Value.absent(),
    PrayerCategory? category,
    PrayerStatus? status,
    int? prayCount,
    Value<DateTime?> lastPrayedAt = const Value.absent(),
    Value<DateTime?> answeredAt = const Value.absent(),
    Value<String?> answerTestimony = const Value.absent(),
    DateTime? createdAt,
  }) => PrayerRequest(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    category: category ?? this.category,
    status: status ?? this.status,
    prayCount: prayCount ?? this.prayCount,
    lastPrayedAt: lastPrayedAt.present ? lastPrayedAt.value : this.lastPrayedAt,
    answeredAt: answeredAt.present ? answeredAt.value : this.answeredAt,
    answerTestimony: answerTestimony.present
        ? answerTestimony.value
        : this.answerTestimony,
    createdAt: createdAt ?? this.createdAt,
  );
  PrayerRequest copyWithCompanion(PrayerRequestsCompanion data) {
    return PrayerRequest(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      category: data.category.present ? data.category.value : this.category,
      status: data.status.present ? data.status.value : this.status,
      prayCount: data.prayCount.present ? data.prayCount.value : this.prayCount,
      lastPrayedAt: data.lastPrayedAt.present
          ? data.lastPrayedAt.value
          : this.lastPrayedAt,
      answeredAt: data.answeredAt.present
          ? data.answeredAt.value
          : this.answeredAt,
      answerTestimony: data.answerTestimony.present
          ? data.answerTestimony.value
          : this.answerTestimony,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrayerRequest(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('status: $status, ')
          ..write('prayCount: $prayCount, ')
          ..write('lastPrayedAt: $lastPrayedAt, ')
          ..write('answeredAt: $answeredAt, ')
          ..write('answerTestimony: $answerTestimony, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    category,
    status,
    prayCount,
    lastPrayedAt,
    answeredAt,
    answerTestimony,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrayerRequest &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.category == this.category &&
          other.status == this.status &&
          other.prayCount == this.prayCount &&
          other.lastPrayedAt == this.lastPrayedAt &&
          other.answeredAt == this.answeredAt &&
          other.answerTestimony == this.answerTestimony &&
          other.createdAt == this.createdAt);
}

class PrayerRequestsCompanion extends UpdateCompanion<PrayerRequest> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<PrayerCategory> category;
  final Value<PrayerStatus> status;
  final Value<int> prayCount;
  final Value<DateTime?> lastPrayedAt;
  final Value<DateTime?> answeredAt;
  final Value<String?> answerTestimony;
  final Value<DateTime> createdAt;
  const PrayerRequestsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.status = const Value.absent(),
    this.prayCount = const Value.absent(),
    this.lastPrayedAt = const Value.absent(),
    this.answeredAt = const Value.absent(),
    this.answerTestimony = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PrayerRequestsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required PrayerCategory category,
    required PrayerStatus status,
    this.prayCount = const Value.absent(),
    this.lastPrayedAt = const Value.absent(),
    this.answeredAt = const Value.absent(),
    this.answerTestimony = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title),
       category = Value(category),
       status = Value(status);
  static Insertable<PrayerRequest> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? category,
    Expression<String>? status,
    Expression<int>? prayCount,
    Expression<DateTime>? lastPrayedAt,
    Expression<DateTime>? answeredAt,
    Expression<String>? answerTestimony,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (status != null) 'status': status,
      if (prayCount != null) 'pray_count': prayCount,
      if (lastPrayedAt != null) 'last_prayed_at': lastPrayedAt,
      if (answeredAt != null) 'answered_at': answeredAt,
      if (answerTestimony != null) 'answer_testimony': answerTestimony,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PrayerRequestsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<PrayerCategory>? category,
    Value<PrayerStatus>? status,
    Value<int>? prayCount,
    Value<DateTime?>? lastPrayedAt,
    Value<DateTime?>? answeredAt,
    Value<String?>? answerTestimony,
    Value<DateTime>? createdAt,
  }) {
    return PrayerRequestsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      prayCount: prayCount ?? this.prayCount,
      lastPrayedAt: lastPrayedAt ?? this.lastPrayedAt,
      answeredAt: answeredAt ?? this.answeredAt,
      answerTestimony: answerTestimony ?? this.answerTestimony,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(
        $PrayerRequestsTable.$convertercategory.toSql(category.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $PrayerRequestsTable.$converterstatus.toSql(status.value),
      );
    }
    if (prayCount.present) {
      map['pray_count'] = Variable<int>(prayCount.value);
    }
    if (lastPrayedAt.present) {
      map['last_prayed_at'] = Variable<DateTime>(lastPrayedAt.value);
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<DateTime>(answeredAt.value);
    }
    if (answerTestimony.present) {
      map['answer_testimony'] = Variable<String>(answerTestimony.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrayerRequestsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('status: $status, ')
          ..write('prayCount: $prayCount, ')
          ..write('lastPrayedAt: $lastPrayedAt, ')
          ..write('answeredAt: $answeredAt, ')
          ..write('answerTestimony: $answerTestimony, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $VerseNotesTable extends VerseNotes
    with TableInfo<$VerseNotesTable, VerseNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VerseNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  static const VerificationMeta _chapterMeta = const VerificationMeta(
    'chapter',
  );
  @override
  late final GeneratedColumn<int> chapter = GeneratedColumn<int>(
    'chapter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseMeta = const VerificationMeta('verse');
  @override
  late final GeneratedColumn<int> verse = GeneratedColumn<int>(
    'verse',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    chapter,
    verse,
    content,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'verse_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<VerseNote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter')) {
      context.handle(
        _chapterMeta,
        chapter.isAcceptableOrUnknown(data['chapter']!, _chapterMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterMeta);
    }
    if (data.containsKey('verse')) {
      context.handle(
        _verseMeta,
        verse.isAcceptableOrUnknown(data['verse']!, _verseMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VerseNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VerseNote(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      chapter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter'],
      )!,
      verse: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verse'],
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VerseNotesTable createAlias(String alias) {
    return $VerseNotesTable(attachedDatabase, alias);
  }
}

class VerseNote extends DataClass implements Insertable<VerseNote> {
  final int id;
  final int bookId;
  final int chapter;
  final int? verse;
  final String content;
  final DateTime createdAt;
  const VerseNote({
    required this.id,
    required this.bookId,
    required this.chapter,
    this.verse,
    required this.content,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['chapter'] = Variable<int>(chapter);
    if (!nullToAbsent || verse != null) {
      map['verse'] = Variable<int>(verse);
    }
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VerseNotesCompanion toCompanion(bool nullToAbsent) {
    return VerseNotesCompanion(
      id: Value(id),
      bookId: Value(bookId),
      chapter: Value(chapter),
      verse: verse == null && nullToAbsent
          ? const Value.absent()
          : Value(verse),
      content: Value(content),
      createdAt: Value(createdAt),
    );
  }

  factory VerseNote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VerseNote(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      chapter: serializer.fromJson<int>(json['chapter']),
      verse: serializer.fromJson<int?>(json['verse']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'chapter': serializer.toJson<int>(chapter),
      'verse': serializer.toJson<int?>(verse),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  VerseNote copyWith({
    int? id,
    int? bookId,
    int? chapter,
    Value<int?> verse = const Value.absent(),
    String? content,
    DateTime? createdAt,
  }) => VerseNote(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    chapter: chapter ?? this.chapter,
    verse: verse.present ? verse.value : this.verse,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
  );
  VerseNote copyWithCompanion(VerseNotesCompanion data) {
    return VerseNote(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      chapter: data.chapter.present ? data.chapter.value : this.chapter,
      verse: data.verse.present ? data.verse.value : this.verse,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VerseNote(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapter: $chapter, ')
          ..write('verse: $verse, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, bookId, chapter, verse, content, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VerseNote &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.chapter == this.chapter &&
          other.verse == this.verse &&
          other.content == this.content &&
          other.createdAt == this.createdAt);
}

class VerseNotesCompanion extends UpdateCompanion<VerseNote> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<int> chapter;
  final Value<int?> verse;
  final Value<String> content;
  final Value<DateTime> createdAt;
  const VerseNotesCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.chapter = const Value.absent(),
    this.verse = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  VerseNotesCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required int chapter,
    this.verse = const Value.absent(),
    required String content,
    this.createdAt = const Value.absent(),
  }) : bookId = Value(bookId),
       chapter = Value(chapter),
       content = Value(content);
  static Insertable<VerseNote> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<int>? chapter,
    Expression<int>? verse,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (chapter != null) 'chapter': chapter,
      if (verse != null) 'verse': verse,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  VerseNotesCompanion copyWith({
    Value<int>? id,
    Value<int>? bookId,
    Value<int>? chapter,
    Value<int?>? verse,
    Value<String>? content,
    Value<DateTime>? createdAt,
  }) {
    return VerseNotesCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      chapter: chapter ?? this.chapter,
      verse: verse ?? this.verse,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (chapter.present) {
      map['chapter'] = Variable<int>(chapter.value);
    }
    if (verse.present) {
      map['verse'] = Variable<int>(verse.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VerseNotesCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapter: $chapter, ')
          ..write('verse: $verse, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsEntriesTable extends AppSettingsEntries
    with TableInfo<$AppSettingsEntriesTable, AppSettingEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsEntriesTable createAlias(String alias) {
    return $AppSettingsEntriesTable(attachedDatabase, alias);
  }
}

class AppSettingEntry extends DataClass implements Insertable<AppSettingEntry> {
  final String key;
  final String value;
  const AppSettingEntry({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsEntriesCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsEntriesCompanion(key: Value(key), value: Value(value));
  }

  factory AppSettingEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSettingEntry copyWith({String? key, String? value}) =>
      AppSettingEntry(key: key ?? this.key, value: value ?? this.value);
  AppSettingEntry copyWithCompanion(AppSettingsEntriesCompanion data) {
    return AppSettingEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingEntry(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingEntry &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsEntriesCompanion extends UpdateCompanion<AppSettingEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsEntriesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSettingEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanEnrollmentsTable extends PlanEnrollments
    with TableInfo<$PlanEnrollmentsTable, PlanEnrollment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanEnrollmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    planId,
    startedAt,
    endedAt,
    completed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_enrollments';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanEnrollment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanEnrollment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanEnrollment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
    );
  }

  @override
  $PlanEnrollmentsTable createAlias(String alias) {
    return $PlanEnrollmentsTable(attachedDatabase, alias);
  }
}

class PlanEnrollment extends DataClass implements Insertable<PlanEnrollment> {
  final int id;

  /// Identificador estável do plano (ex.: 'nt-90-dias').
  final String planId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final bool completed;
  const PlanEnrollment({
    required this.id,
    required this.planId,
    required this.startedAt,
    this.endedAt,
    required this.completed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plan_id'] = Variable<String>(planId);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['completed'] = Variable<bool>(completed);
    return map;
  }

  PlanEnrollmentsCompanion toCompanion(bool nullToAbsent) {
    return PlanEnrollmentsCompanion(
      id: Value(id),
      planId: Value(planId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      completed: Value(completed),
    );
  }

  factory PlanEnrollment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanEnrollment(
      id: serializer.fromJson<int>(json['id']),
      planId: serializer.fromJson<String>(json['planId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      completed: serializer.fromJson<bool>(json['completed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'planId': serializer.toJson<String>(planId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'completed': serializer.toJson<bool>(completed),
    };
  }

  PlanEnrollment copyWith({
    int? id,
    String? planId,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    bool? completed,
  }) => PlanEnrollment(
    id: id ?? this.id,
    planId: planId ?? this.planId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    completed: completed ?? this.completed,
  );
  PlanEnrollment copyWithCompanion(PlanEnrollmentsCompanion data) {
    return PlanEnrollment(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      completed: data.completed.present ? data.completed.value : this.completed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanEnrollment(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('completed: $completed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, planId, startedAt, endedAt, completed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanEnrollment &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.completed == this.completed);
}

class PlanEnrollmentsCompanion extends UpdateCompanion<PlanEnrollment> {
  final Value<int> id;
  final Value<String> planId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<bool> completed;
  const PlanEnrollmentsCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.completed = const Value.absent(),
  });
  PlanEnrollmentsCompanion.insert({
    this.id = const Value.absent(),
    required String planId,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.completed = const Value.absent(),
  }) : planId = Value(planId),
       startedAt = Value(startedAt);
  static Insertable<PlanEnrollment> custom({
    Expression<int>? id,
    Expression<String>? planId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<bool>? completed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (completed != null) 'completed': completed,
    });
  }

  PlanEnrollmentsCompanion copyWith({
    Value<int>? id,
    Value<String>? planId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<bool>? completed,
  }) {
    return PlanEnrollmentsCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      completed: completed ?? this.completed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<String>(planId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanEnrollmentsCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('completed: $completed')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BooksTable books = $BooksTable(this);
  late final $VersesTable verses = $VersesTable(this);
  late final $ReadingCyclesTable readingCycles = $ReadingCyclesTable(this);
  late final $ReadingLogsTable readingLogs = $ReadingLogsTable(this);
  late final $RecitativesTable recitatives = $RecitativesTable(this);
  late final $PrayerRequestsTable prayerRequests = $PrayerRequestsTable(this);
  late final $VerseNotesTable verseNotes = $VerseNotesTable(this);
  late final $AppSettingsEntriesTable appSettingsEntries =
      $AppSettingsEntriesTable(this);
  late final $PlanEnrollmentsTable planEnrollments = $PlanEnrollmentsTable(
    this,
  );
  late final Index idxVersesRef = Index(
    'idx_verses_ref',
    'CREATE UNIQUE INDEX idx_verses_ref ON verses (translation, book_id, chapter, verse)',
  );
  late final Index idxReadingLogsReadAt = Index(
    'idx_reading_logs_read_at',
    'CREATE INDEX idx_reading_logs_read_at ON reading_logs (read_at)',
  );
  late final Index idxReadingLogsBookChapter = Index(
    'idx_reading_logs_book_chapter',
    'CREATE INDEX idx_reading_logs_book_chapter ON reading_logs (book_id, chapter)',
  );
  late final Index idxReadingLogsCycle = Index(
    'idx_reading_logs_cycle',
    'CREATE INDEX idx_reading_logs_cycle ON reading_logs (cycle_id, book_id, chapter)',
  );
  late final Index idxRecitativesServiceDate = Index(
    'idx_recitatives_service_date',
    'CREATE INDEX idx_recitatives_service_date ON recitatives (service_date)',
  );
  late final Index idxRecitativesStatusDate = Index(
    'idx_recitatives_status_date',
    'CREATE INDEX idx_recitatives_status_date ON recitatives (status, service_date)',
  );
  late final Index idxPrayerRequestsStatus = Index(
    'idx_prayer_requests_status',
    'CREATE INDEX idx_prayer_requests_status ON prayer_requests (status)',
  );
  late final Index idxVerseNotesBookChapter = Index(
    'idx_verse_notes_book_chapter',
    'CREATE INDEX idx_verse_notes_book_chapter ON verse_notes (book_id, chapter)',
  );
  late final BibleDao bibleDao = BibleDao(this as AppDatabase);
  late final ReadingDao readingDao = ReadingDao(this as AppDatabase);
  late final RecitativesDao recitativesDao = RecitativesDao(
    this as AppDatabase,
  );
  late final PrayerDao prayerDao = PrayerDao(this as AppDatabase);
  late final NotesDao notesDao = NotesDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  late final PlansDao plansDao = PlansDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    books,
    verses,
    readingCycles,
    readingLogs,
    recitatives,
    prayerRequests,
    verseNotes,
    appSettingsEntries,
    planEnrollments,
    idxVersesRef,
    idxReadingLogsReadAt,
    idxReadingLogsBookChapter,
    idxReadingLogsCycle,
    idxRecitativesServiceDate,
    idxRecitativesStatusDate,
    idxPrayerRequestsStatus,
    idxVerseNotesBookChapter,
  ];
}

typedef $$BooksTableCreateCompanionBuilder = BooksCompanion Function({
  Value<int> id,
  required String name,
  required String abbrev,
  required String testament,
  required int chaptersCount,
});
typedef $$BooksTableUpdateCompanionBuilder = BooksCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> abbrev,
  Value<String> testament,
  Value<int> chaptersCount,
});

final class $$BooksTableReferences
    extends BaseReferences<_$AppDatabase, $BooksTable, Book> {
  $$BooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VersesTable, List<Verse>> _versesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.verses,
    aliasName: 'books__id__verses__book_id',
  );

  $$VersesTableProcessedTableManager get versesRefs {
    final manager = $$VersesTableTableManager(
      $_db,
      $_db.verses,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_versesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReadingLogsTable, List<ReadingLog>>
  _readingLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.readingLogs,
    aliasName: 'books__id__reading_logs__book_id',
  );

  $$ReadingLogsTableProcessedTableManager get readingLogsRefs {
    final manager = $$ReadingLogsTableTableManager(
      $_db,
      $_db.readingLogs,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_readingLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RecitativesTable, List<Recitative>>
  _recitativesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.recitatives,
    aliasName: 'books__id__recitatives__book_id',
  );

  $$RecitativesTableProcessedTableManager get recitativesRefs {
    final manager = $$RecitativesTableTableManager(
      $_db,
      $_db.recitatives,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_recitativesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$VerseNotesTable, List<VerseNote>>
  _verseNotesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.verseNotes,
    aliasName: 'books__id__verse_notes__book_id',
  );

  $$VerseNotesTableProcessedTableManager get verseNotesRefs {
    final manager = $$VerseNotesTableTableManager(
      $_db,
      $_db.verseNotes,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_verseNotesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get abbrev => $composableBuilder(
    column: $table.abbrev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get testament => $composableBuilder(
    column: $table.testament,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chaptersCount => $composableBuilder(
    column: $table.chaptersCount,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> versesRefs(
    Expression<bool> Function($$VersesTableFilterComposer f) f,
  ) {
    final $$VersesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.verses,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VersesTableFilterComposer(
            $db: $db,
            $table: $db.verses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> readingLogsRefs(
    Expression<bool> Function($$ReadingLogsTableFilterComposer f) f,
  ) {
    final $$ReadingLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingLogs,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingLogsTableFilterComposer(
            $db: $db,
            $table: $db.readingLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recitativesRefs(
    Expression<bool> Function($$RecitativesTableFilterComposer f) f,
  ) {
    final $$RecitativesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recitatives,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecitativesTableFilterComposer(
            $db: $db,
            $table: $db.recitatives,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> verseNotesRefs(
    Expression<bool> Function($$VerseNotesTableFilterComposer f) f,
  ) {
    final $$VerseNotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.verseNotes,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VerseNotesTableFilterComposer(
            $db: $db,
            $table: $db.verseNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get abbrev => $composableBuilder(
    column: $table.abbrev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get testament => $composableBuilder(
    column: $table.testament,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chaptersCount => $composableBuilder(
    column: $table.chaptersCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get abbrev =>
      $composableBuilder(column: $table.abbrev, builder: (column) => column);

  GeneratedColumn<String> get testament =>
      $composableBuilder(column: $table.testament, builder: (column) => column);

  GeneratedColumn<int> get chaptersCount => $composableBuilder(
    column: $table.chaptersCount,
    builder: (column) => column,
  );

  Expression<T> versesRefs<T extends Object>(
    Expression<T> Function($$VersesTableAnnotationComposer a) f,
  ) {
    final $$VersesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.verses,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VersesTableAnnotationComposer(
            $db: $db,
            $table: $db.verses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> readingLogsRefs<T extends Object>(
    Expression<T> Function($$ReadingLogsTableAnnotationComposer a) f,
  ) {
    final $$ReadingLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingLogs,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.readingLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> recitativesRefs<T extends Object>(
    Expression<T> Function($$RecitativesTableAnnotationComposer a) f,
  ) {
    final $$RecitativesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recitatives,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecitativesTableAnnotationComposer(
            $db: $db,
            $table: $db.recitatives,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> verseNotesRefs<T extends Object>(
    Expression<T> Function($$VerseNotesTableAnnotationComposer a) f,
  ) {
    final $$VerseNotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.verseNotes,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VerseNotesTableAnnotationComposer(
            $db: $db,
            $table: $db.verseNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BooksTable,
          Book,
          $$BooksTableFilterComposer,
          $$BooksTableOrderingComposer,
          $$BooksTableAnnotationComposer,
          $$BooksTableCreateCompanionBuilder,
          $$BooksTableUpdateCompanionBuilder,
          (Book, $$BooksTableReferences),
          Book,
          PrefetchHooks Function({
            bool versesRefs,
            bool readingLogsRefs,
            bool recitativesRefs,
            bool verseNotesRefs,
          })
        > {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> abbrev = const Value.absent(),
                Value<String> testament = const Value.absent(),
                Value<int> chaptersCount = const Value.absent(),
              }) => BooksCompanion(
                id: id,
                name: name,
                abbrev: abbrev,
                testament: testament,
                chaptersCount: chaptersCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String abbrev,
                required String testament,
                required int chaptersCount,
              }) => BooksCompanion.insert(
                id: id,
                name: name,
                abbrev: abbrev,
                testament: testament,
                chaptersCount: chaptersCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BooksTable, Book>(table),
                  $$BooksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                versesRefs = false,
                readingLogsRefs = false,
                recitativesRefs = false,
                verseNotesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (versesRefs) db.verses,
                    if (readingLogsRefs) db.readingLogs,
                    if (recitativesRefs) db.recitatives,
                    if (verseNotesRefs) db.verseNotes,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (versesRefs)
                        await $_getPrefetchedDataByColumns<
                          Book,
                          $BooksTable,
                          Verse,
                          $VersesTable
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._versesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(db, table, p0).versesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'book_id',
                          typedResults: items,
                        ),
                      if (readingLogsRefs)
                        await $_getPrefetchedDataByColumns<
                          Book,
                          $BooksTable,
                          ReadingLog,
                          $ReadingLogsTable
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._readingLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).readingLogsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'book_id',
                          typedResults: items,
                        ),
                      if (recitativesRefs)
                        await $_getPrefetchedDataByColumns<
                          Book,
                          $BooksTable,
                          Recitative,
                          $RecitativesTable
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._recitativesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).recitativesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'book_id',
                          typedResults: items,
                        ),
                      if (verseNotesRefs)
                        await $_getPrefetchedDataByColumns<
                          Book,
                          $BooksTable,
                          VerseNote,
                          $VerseNotesTable
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._verseNotesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).verseNotesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'book_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BooksTable,
      Book,
      $$BooksTableFilterComposer,
      $$BooksTableOrderingComposer,
      $$BooksTableAnnotationComposer,
      $$BooksTableCreateCompanionBuilder,
      $$BooksTableUpdateCompanionBuilder,
      (Book, $$BooksTableReferences),
      Book,
      PrefetchHooks Function({
        bool versesRefs,
        bool readingLogsRefs,
        bool recitativesRefs,
        bool verseNotesRefs,
      })
    >;
typedef $$VersesTableCreateCompanionBuilder = VersesCompanion Function({
  Value<int> id,
  Value<BibleTranslation> translation,
  required int bookId,
  required int chapter,
  required int verse,
  required String verseText,
});
typedef $$VersesTableUpdateCompanionBuilder = VersesCompanion Function({
  Value<int> id,
  Value<BibleTranslation> translation,
  Value<int> bookId,
  Value<int> chapter,
  Value<int> verse,
  Value<String> verseText,
});

final class $$VersesTableReferences
    extends BaseReferences<_$AppDatabase, $VersesTable, Verse> {
  $$VersesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('verses__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VersesTableFilterComposer
    extends Composer<_$AppDatabase, $VersesTable> {
  $$VersesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<BibleTranslation, BibleTranslation, String>
  get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verse => $composableBuilder(
    column: $table.verse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verseText => $composableBuilder(
    column: $table.verseText,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VersesTableOrderingComposer
    extends Composer<_$AppDatabase, $VersesTable> {
  $$VersesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verse => $composableBuilder(
    column: $table.verse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verseText => $composableBuilder(
    column: $table.verseText,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VersesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VersesTable> {
  $$VersesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BibleTranslation, String> get translation =>
      $composableBuilder(
        column: $table.translation,
        builder: (column) => column,
      );

  GeneratedColumn<int> get chapter =>
      $composableBuilder(column: $table.chapter, builder: (column) => column);

  GeneratedColumn<int> get verse =>
      $composableBuilder(column: $table.verse, builder: (column) => column);

  GeneratedColumn<String> get verseText =>
      $composableBuilder(column: $table.verseText, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VersesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VersesTable,
          Verse,
          $$VersesTableFilterComposer,
          $$VersesTableOrderingComposer,
          $$VersesTableAnnotationComposer,
          $$VersesTableCreateCompanionBuilder,
          $$VersesTableUpdateCompanionBuilder,
          (Verse, $$VersesTableReferences),
          Verse,
          PrefetchHooks Function({bool bookId})
        > {
  $$VersesTableTableManager(_$AppDatabase db, $VersesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VersesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VersesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VersesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<BibleTranslation> translation = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<int> chapter = const Value.absent(),
                Value<int> verse = const Value.absent(),
                Value<String> verseText = const Value.absent(),
              }) => VersesCompanion(
                id: id,
                translation: translation,
                bookId: bookId,
                chapter: chapter,
                verse: verse,
                verseText: verseText,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<BibleTranslation> translation = const Value.absent(),
                required int bookId,
                required int chapter,
                required int verse,
                required String verseText,
              }) => VersesCompanion.insert(
                id: id,
                translation: translation,
                bookId: bookId,
                chapter: chapter,
                verse: verse,
                verseText: verseText,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VersesTable, Verse>(table),
                  $$VersesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bookId,
                        referencedTable: $$VersesTableReferences._bookIdTable(
                          db,
                        ),
                        referencedColumn: $$VersesTableReferences
                            ._bookIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$VersesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VersesTable,
      Verse,
      $$VersesTableFilterComposer,
      $$VersesTableOrderingComposer,
      $$VersesTableAnnotationComposer,
      $$VersesTableCreateCompanionBuilder,
      $$VersesTableUpdateCompanionBuilder,
      (Verse, $$VersesTableReferences),
      Verse,
      PrefetchHooks Function({bool bookId})
    >;
typedef $$ReadingCyclesTableCreateCompanionBuilder =
    ReadingCyclesCompanion Function({
      Value<int> id,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
    });
typedef $$ReadingCyclesTableUpdateCompanionBuilder =
    ReadingCyclesCompanion Function({
      Value<int> id,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
    });

final class $$ReadingCyclesTableReferences
    extends BaseReferences<_$AppDatabase, $ReadingCyclesTable, ReadingCycle> {
  $$ReadingCyclesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ReadingLogsTable, List<ReadingLog>>
  _readingLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.readingLogs,
    aliasName: 'reading_cycles__id__reading_logs__cycle_id',
  );

  $$ReadingLogsTableProcessedTableManager get readingLogsRefs {
    final manager = $$ReadingLogsTableTableManager(
      $_db,
      $_db.readingLogs,
    ).filter((f) => f.cycleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_readingLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ReadingCyclesTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingCyclesTable> {
  $$ReadingCyclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> readingLogsRefs(
    Expression<bool> Function($$ReadingLogsTableFilterComposer f) f,
  ) {
    final $$ReadingLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingLogs,
      getReferencedColumn: (t) => t.cycleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingLogsTableFilterComposer(
            $db: $db,
            $table: $db.readingLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReadingCyclesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingCyclesTable> {
  $$ReadingCyclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingCyclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingCyclesTable> {
  $$ReadingCyclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  Expression<T> readingLogsRefs<T extends Object>(
    Expression<T> Function($$ReadingLogsTableAnnotationComposer a) f,
  ) {
    final $$ReadingLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingLogs,
      getReferencedColumn: (t) => t.cycleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.readingLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReadingCyclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingCyclesTable,
          ReadingCycle,
          $$ReadingCyclesTableFilterComposer,
          $$ReadingCyclesTableOrderingComposer,
          $$ReadingCyclesTableAnnotationComposer,
          $$ReadingCyclesTableCreateCompanionBuilder,
          $$ReadingCyclesTableUpdateCompanionBuilder,
          (ReadingCycle, $$ReadingCyclesTableReferences),
          ReadingCycle,
          PrefetchHooks Function({bool readingLogsRefs})
        > {
  $$ReadingCyclesTableTableManager(_$AppDatabase db, $ReadingCyclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingCyclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingCyclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingCyclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
              }) => ReadingCyclesCompanion(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
              }) => ReadingCyclesCompanion.insert(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReadingCyclesTable, ReadingCycle>(table),
                  $$ReadingCyclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({readingLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (readingLogsRefs) db.readingLogs],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (readingLogsRefs)
                    await $_getPrefetchedDataByColumns<
                      ReadingCycle,
                      $ReadingCyclesTable,
                      ReadingLog,
                      $ReadingLogsTable
                    >(
                      currentTable: table,
                      referencedTable: $$ReadingCyclesTableReferences
                          ._readingLogsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ReadingCyclesTableReferences(
                            db,
                            table,
                            p0,
                          ).readingLogsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'cycle_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ReadingCyclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingCyclesTable,
      ReadingCycle,
      $$ReadingCyclesTableFilterComposer,
      $$ReadingCyclesTableOrderingComposer,
      $$ReadingCyclesTableAnnotationComposer,
      $$ReadingCyclesTableCreateCompanionBuilder,
      $$ReadingCyclesTableUpdateCompanionBuilder,
      (ReadingCycle, $$ReadingCyclesTableReferences),
      ReadingCycle,
      PrefetchHooks Function({bool readingLogsRefs})
    >;
typedef $$ReadingLogsTableCreateCompanionBuilder =
    ReadingLogsCompanion Function({
      Value<int> id,
      required int bookId,
      required int chapter,
      required DateTime readAt,
      required ReadingSource source,
      required int cycleId,
    });
typedef $$ReadingLogsTableUpdateCompanionBuilder =
    ReadingLogsCompanion Function({
      Value<int> id,
      Value<int> bookId,
      Value<int> chapter,
      Value<DateTime> readAt,
      Value<ReadingSource> source,
      Value<int> cycleId,
    });

final class $$ReadingLogsTableReferences
    extends BaseReferences<_$AppDatabase, $ReadingLogsTable, ReadingLog> {
  $$ReadingLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('reading_logs__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ReadingCyclesTable _cycleIdTable(_$AppDatabase db) => db.readingCycles
      .createAlias('reading_logs__cycle_id__reading_cycles__id');

  $$ReadingCyclesTableProcessedTableManager get cycleId {
    final $_column = $_itemColumn<int>('cycle_id')!;

    final manager = $$ReadingCyclesTableTableManager(
      $_db,
      $_db.readingCycles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cycleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReadingLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingLogsTable> {
  $$ReadingLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ReadingSource, ReadingSource, String>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ReadingCyclesTableFilterComposer get cycleId {
    final $$ReadingCyclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cycleId,
      referencedTable: $db.readingCycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingCyclesTableFilterComposer(
            $db: $db,
            $table: $db.readingCycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingLogsTable> {
  $$ReadingLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ReadingCyclesTableOrderingComposer get cycleId {
    final $$ReadingCyclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cycleId,
      referencedTable: $db.readingCycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingCyclesTableOrderingComposer(
            $db: $db,
            $table: $db.readingCycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingLogsTable> {
  $$ReadingLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get chapter =>
      $composableBuilder(column: $table.chapter, builder: (column) => column);

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ReadingSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ReadingCyclesTableAnnotationComposer get cycleId {
    final $$ReadingCyclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cycleId,
      referencedTable: $db.readingCycles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingCyclesTableAnnotationComposer(
            $db: $db,
            $table: $db.readingCycles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingLogsTable,
          ReadingLog,
          $$ReadingLogsTableFilterComposer,
          $$ReadingLogsTableOrderingComposer,
          $$ReadingLogsTableAnnotationComposer,
          $$ReadingLogsTableCreateCompanionBuilder,
          $$ReadingLogsTableUpdateCompanionBuilder,
          (ReadingLog, $$ReadingLogsTableReferences),
          ReadingLog,
          PrefetchHooks Function({bool bookId, bool cycleId})
        > {
  $$ReadingLogsTableTableManager(_$AppDatabase db, $ReadingLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<int> chapter = const Value.absent(),
                Value<DateTime> readAt = const Value.absent(),
                Value<ReadingSource> source = const Value.absent(),
                Value<int> cycleId = const Value.absent(),
              }) => ReadingLogsCompanion(
                id: id,
                bookId: bookId,
                chapter: chapter,
                readAt: readAt,
                source: source,
                cycleId: cycleId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bookId,
                required int chapter,
                required DateTime readAt,
                required ReadingSource source,
                required int cycleId,
              }) => ReadingLogsCompanion.insert(
                id: id,
                bookId: bookId,
                chapter: chapter,
                readAt: readAt,
                source: source,
                cycleId: cycleId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReadingLogsTable, ReadingLog>(table),
                  $$ReadingLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false, cycleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bookId,
                        referencedTable: $$ReadingLogsTableReferences
                            ._bookIdTable(db),
                        referencedColumn: $$ReadingLogsTableReferences
                            ._bookIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (cycleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.cycleId,
                        referencedTable: $$ReadingLogsTableReferences
                            ._cycleIdTable(db),
                        referencedColumn: $$ReadingLogsTableReferences
                            ._cycleIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReadingLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingLogsTable,
      ReadingLog,
      $$ReadingLogsTableFilterComposer,
      $$ReadingLogsTableOrderingComposer,
      $$ReadingLogsTableAnnotationComposer,
      $$ReadingLogsTableCreateCompanionBuilder,
      $$ReadingLogsTableUpdateCompanionBuilder,
      (ReadingLog, $$ReadingLogsTableReferences),
      ReadingLog,
      PrefetchHooks Function({bool bookId, bool cycleId})
    >;
typedef $$RecitativesTableCreateCompanionBuilder =
    RecitativesCompanion Function({
      Value<int> id,
      required int bookId,
      required int chapter,
      required int verseStart,
      Value<int?> verseEnd,
      required String verseTextSnapshot,
      required DateTime serviceDate,
      Value<String?> congregation,
      Value<String?> notes,
      required RecitativeStatus status,
      Value<DateTime> createdAt,
    });
typedef $$RecitativesTableUpdateCompanionBuilder =
    RecitativesCompanion Function({
      Value<int> id,
      Value<int> bookId,
      Value<int> chapter,
      Value<int> verseStart,
      Value<int?> verseEnd,
      Value<String> verseTextSnapshot,
      Value<DateTime> serviceDate,
      Value<String?> congregation,
      Value<String?> notes,
      Value<RecitativeStatus> status,
      Value<DateTime> createdAt,
    });

final class $$RecitativesTableReferences
    extends BaseReferences<_$AppDatabase, $RecitativesTable, Recitative> {
  $$RecitativesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('recitatives__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecitativesTableFilterComposer
    extends Composer<_$AppDatabase, $RecitativesTable> {
  $$RecitativesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verseStart => $composableBuilder(
    column: $table.verseStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verseEnd => $composableBuilder(
    column: $table.verseEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verseTextSnapshot => $composableBuilder(
    column: $table.verseTextSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serviceDate => $composableBuilder(
    column: $table.serviceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get congregation => $composableBuilder(
    column: $table.congregation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RecitativeStatus, RecitativeStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecitativesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecitativesTable> {
  $$RecitativesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verseStart => $composableBuilder(
    column: $table.verseStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verseEnd => $composableBuilder(
    column: $table.verseEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verseTextSnapshot => $composableBuilder(
    column: $table.verseTextSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serviceDate => $composableBuilder(
    column: $table.serviceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get congregation => $composableBuilder(
    column: $table.congregation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecitativesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecitativesTable> {
  $$RecitativesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get chapter =>
      $composableBuilder(column: $table.chapter, builder: (column) => column);

  GeneratedColumn<int> get verseStart => $composableBuilder(
    column: $table.verseStart,
    builder: (column) => column,
  );

  GeneratedColumn<int> get verseEnd =>
      $composableBuilder(column: $table.verseEnd, builder: (column) => column);

  GeneratedColumn<String> get verseTextSnapshot => $composableBuilder(
    column: $table.verseTextSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get serviceDate => $composableBuilder(
    column: $table.serviceDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get congregation => $composableBuilder(
    column: $table.congregation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RecitativeStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecitativesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecitativesTable,
          Recitative,
          $$RecitativesTableFilterComposer,
          $$RecitativesTableOrderingComposer,
          $$RecitativesTableAnnotationComposer,
          $$RecitativesTableCreateCompanionBuilder,
          $$RecitativesTableUpdateCompanionBuilder,
          (Recitative, $$RecitativesTableReferences),
          Recitative,
          PrefetchHooks Function({bool bookId})
        > {
  $$RecitativesTableTableManager(_$AppDatabase db, $RecitativesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecitativesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecitativesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecitativesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<int> chapter = const Value.absent(),
                Value<int> verseStart = const Value.absent(),
                Value<int?> verseEnd = const Value.absent(),
                Value<String> verseTextSnapshot = const Value.absent(),
                Value<DateTime> serviceDate = const Value.absent(),
                Value<String?> congregation = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<RecitativeStatus> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RecitativesCompanion(
                id: id,
                bookId: bookId,
                chapter: chapter,
                verseStart: verseStart,
                verseEnd: verseEnd,
                verseTextSnapshot: verseTextSnapshot,
                serviceDate: serviceDate,
                congregation: congregation,
                notes: notes,
                status: status,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bookId,
                required int chapter,
                required int verseStart,
                Value<int?> verseEnd = const Value.absent(),
                required String verseTextSnapshot,
                required DateTime serviceDate,
                Value<String?> congregation = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required RecitativeStatus status,
                Value<DateTime> createdAt = const Value.absent(),
              }) => RecitativesCompanion.insert(
                id: id,
                bookId: bookId,
                chapter: chapter,
                verseStart: verseStart,
                verseEnd: verseEnd,
                verseTextSnapshot: verseTextSnapshot,
                serviceDate: serviceDate,
                congregation: congregation,
                notes: notes,
                status: status,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecitativesTable, Recitative>(table),
                  $$RecitativesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bookId,
                        referencedTable: $$RecitativesTableReferences
                            ._bookIdTable(db),
                        referencedColumn: $$RecitativesTableReferences
                            ._bookIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RecitativesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecitativesTable,
      Recitative,
      $$RecitativesTableFilterComposer,
      $$RecitativesTableOrderingComposer,
      $$RecitativesTableAnnotationComposer,
      $$RecitativesTableCreateCompanionBuilder,
      $$RecitativesTableUpdateCompanionBuilder,
      (Recitative, $$RecitativesTableReferences),
      Recitative,
      PrefetchHooks Function({bool bookId})
    >;
typedef $$PrayerRequestsTableCreateCompanionBuilder =
    PrayerRequestsCompanion Function({
      Value<int> id,
      required String title,
      Value<String?> description,
      required PrayerCategory category,
      required PrayerStatus status,
      Value<int> prayCount,
      Value<DateTime?> lastPrayedAt,
      Value<DateTime?> answeredAt,
      Value<String?> answerTestimony,
      Value<DateTime> createdAt,
    });
typedef $$PrayerRequestsTableUpdateCompanionBuilder =
    PrayerRequestsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String?> description,
      Value<PrayerCategory> category,
      Value<PrayerStatus> status,
      Value<int> prayCount,
      Value<DateTime?> lastPrayedAt,
      Value<DateTime?> answeredAt,
      Value<String?> answerTestimony,
      Value<DateTime> createdAt,
    });

class $$PrayerRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $PrayerRequestsTable> {
  $$PrayerRequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PrayerCategory, PrayerCategory, String>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<PrayerStatus, PrayerStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get prayCount => $composableBuilder(
    column: $table.prayCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPrayedAt => $composableBuilder(
    column: $table.lastPrayedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answerTestimony => $composableBuilder(
    column: $table.answerTestimony,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PrayerRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $PrayerRequestsTable> {
  $$PrayerRequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get prayCount => $composableBuilder(
    column: $table.prayCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPrayedAt => $composableBuilder(
    column: $table.lastPrayedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answerTestimony => $composableBuilder(
    column: $table.answerTestimony,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PrayerRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrayerRequestsTable> {
  $$PrayerRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PrayerCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PrayerStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get prayCount =>
      $composableBuilder(column: $table.prayCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPrayedAt => $composableBuilder(
    column: $table.lastPrayedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get answerTestimony => $composableBuilder(
    column: $table.answerTestimony,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PrayerRequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrayerRequestsTable,
          PrayerRequest,
          $$PrayerRequestsTableFilterComposer,
          $$PrayerRequestsTableOrderingComposer,
          $$PrayerRequestsTableAnnotationComposer,
          $$PrayerRequestsTableCreateCompanionBuilder,
          $$PrayerRequestsTableUpdateCompanionBuilder,
          (
            PrayerRequest,
            BaseReferences<_$AppDatabase, $PrayerRequestsTable, PrayerRequest>,
          ),
          PrayerRequest,
          PrefetchHooks Function()
        > {
  $$PrayerRequestsTableTableManager(
    _$AppDatabase db,
    $PrayerRequestsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrayerRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrayerRequestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrayerRequestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<PrayerCategory> category = const Value.absent(),
                Value<PrayerStatus> status = const Value.absent(),
                Value<int> prayCount = const Value.absent(),
                Value<DateTime?> lastPrayedAt = const Value.absent(),
                Value<DateTime?> answeredAt = const Value.absent(),
                Value<String?> answerTestimony = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PrayerRequestsCompanion(
                id: id,
                title: title,
                description: description,
                category: category,
                status: status,
                prayCount: prayCount,
                lastPrayedAt: lastPrayedAt,
                answeredAt: answeredAt,
                answerTestimony: answerTestimony,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                required PrayerCategory category,
                required PrayerStatus status,
                Value<int> prayCount = const Value.absent(),
                Value<DateTime?> lastPrayedAt = const Value.absent(),
                Value<DateTime?> answeredAt = const Value.absent(),
                Value<String?> answerTestimony = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PrayerRequestsCompanion.insert(
                id: id,
                title: title,
                description: description,
                category: category,
                status: status,
                prayCount: prayCount,
                lastPrayedAt: lastPrayedAt,
                answeredAt: answeredAt,
                answerTestimony: answerTestimony,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PrayerRequestsTable, PrayerRequest>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PrayerRequestsTable,
                    PrayerRequest
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PrayerRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrayerRequestsTable,
      PrayerRequest,
      $$PrayerRequestsTableFilterComposer,
      $$PrayerRequestsTableOrderingComposer,
      $$PrayerRequestsTableAnnotationComposer,
      $$PrayerRequestsTableCreateCompanionBuilder,
      $$PrayerRequestsTableUpdateCompanionBuilder,
      (
        PrayerRequest,
        BaseReferences<_$AppDatabase, $PrayerRequestsTable, PrayerRequest>,
      ),
      PrayerRequest,
      PrefetchHooks Function()
    >;
typedef $$VerseNotesTableCreateCompanionBuilder = VerseNotesCompanion Function({
  Value<int> id,
  required int bookId,
  required int chapter,
  Value<int?> verse,
  required String content,
  Value<DateTime> createdAt,
});
typedef $$VerseNotesTableUpdateCompanionBuilder = VerseNotesCompanion Function({
  Value<int> id,
  Value<int> bookId,
  Value<int> chapter,
  Value<int?> verse,
  Value<String> content,
  Value<DateTime> createdAt,
});

final class $$VerseNotesTableReferences
    extends BaseReferences<_$AppDatabase, $VerseNotesTable, VerseNote> {
  $$VerseNotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('verse_notes__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VerseNotesTableFilterComposer
    extends Composer<_$AppDatabase, $VerseNotesTable> {
  $$VerseNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verse => $composableBuilder(
    column: $table.verse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VerseNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $VerseNotesTable> {
  $$VerseNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verse => $composableBuilder(
    column: $table.verse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VerseNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VerseNotesTable> {
  $$VerseNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get chapter =>
      $composableBuilder(column: $table.chapter, builder: (column) => column);

  GeneratedColumn<int> get verse =>
      $composableBuilder(column: $table.verse, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VerseNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VerseNotesTable,
          VerseNote,
          $$VerseNotesTableFilterComposer,
          $$VerseNotesTableOrderingComposer,
          $$VerseNotesTableAnnotationComposer,
          $$VerseNotesTableCreateCompanionBuilder,
          $$VerseNotesTableUpdateCompanionBuilder,
          (VerseNote, $$VerseNotesTableReferences),
          VerseNote,
          PrefetchHooks Function({bool bookId})
        > {
  $$VerseNotesTableTableManager(_$AppDatabase db, $VerseNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VerseNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VerseNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VerseNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<int> chapter = const Value.absent(),
                Value<int?> verse = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => VerseNotesCompanion(
                id: id,
                bookId: bookId,
                chapter: chapter,
                verse: verse,
                content: content,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bookId,
                required int chapter,
                Value<int?> verse = const Value.absent(),
                required String content,
                Value<DateTime> createdAt = const Value.absent(),
              }) => VerseNotesCompanion.insert(
                id: id,
                bookId: bookId,
                chapter: chapter,
                verse: verse,
                content: content,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VerseNotesTable, VerseNote>(table),
                  $$VerseNotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bookId,
                        referencedTable: $$VerseNotesTableReferences
                            ._bookIdTable(db),
                        referencedColumn: $$VerseNotesTableReferences
                            ._bookIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$VerseNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VerseNotesTable,
      VerseNote,
      $$VerseNotesTableFilterComposer,
      $$VerseNotesTableOrderingComposer,
      $$VerseNotesTableAnnotationComposer,
      $$VerseNotesTableCreateCompanionBuilder,
      $$VerseNotesTableUpdateCompanionBuilder,
      (VerseNote, $$VerseNotesTableReferences),
      VerseNote,
      PrefetchHooks Function({bool bookId})
    >;
typedef $$AppSettingsEntriesTableCreateCompanionBuilder =
    AppSettingsEntriesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsEntriesTableUpdateCompanionBuilder =
    AppSettingsEntriesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsEntriesTable> {
  $$AppSettingsEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsEntriesTable> {
  $$AppSettingsEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsEntriesTable> {
  $$AppSettingsEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsEntriesTable,
          AppSettingEntry,
          $$AppSettingsEntriesTableFilterComposer,
          $$AppSettingsEntriesTableOrderingComposer,
          $$AppSettingsEntriesTableAnnotationComposer,
          $$AppSettingsEntriesTableCreateCompanionBuilder,
          $$AppSettingsEntriesTableUpdateCompanionBuilder,
          (
            AppSettingEntry,
            BaseReferences<
              _$AppDatabase,
              $AppSettingsEntriesTable,
              AppSettingEntry
            >,
          ),
          AppSettingEntry,
          PrefetchHooks Function()
        > {
  $$AppSettingsEntriesTableTableManager(
    _$AppDatabase db,
    $AppSettingsEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsEntriesCompanion(
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsEntriesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsEntriesTable, AppSettingEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AppSettingsEntriesTable,
                    AppSettingEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsEntriesTable,
      AppSettingEntry,
      $$AppSettingsEntriesTableFilterComposer,
      $$AppSettingsEntriesTableOrderingComposer,
      $$AppSettingsEntriesTableAnnotationComposer,
      $$AppSettingsEntriesTableCreateCompanionBuilder,
      $$AppSettingsEntriesTableUpdateCompanionBuilder,
      (
        AppSettingEntry,
        BaseReferences<
          _$AppDatabase,
          $AppSettingsEntriesTable,
          AppSettingEntry
        >,
      ),
      AppSettingEntry,
      PrefetchHooks Function()
    >;
typedef $$PlanEnrollmentsTableCreateCompanionBuilder =
    PlanEnrollmentsCompanion Function({
      Value<int> id,
      required String planId,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<bool> completed,
    });
typedef $$PlanEnrollmentsTableUpdateCompanionBuilder =
    PlanEnrollmentsCompanion Function({
      Value<int> id,
      Value<String> planId,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<bool> completed,
    });

class $$PlanEnrollmentsTableFilterComposer
    extends Composer<_$AppDatabase, $PlanEnrollmentsTable> {
  $$PlanEnrollmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlanEnrollmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanEnrollmentsTable> {
  $$PlanEnrollmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlanEnrollmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanEnrollmentsTable> {
  $$PlanEnrollmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get planId =>
      $composableBuilder(column: $table.planId, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);
}

class $$PlanEnrollmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanEnrollmentsTable,
          PlanEnrollment,
          $$PlanEnrollmentsTableFilterComposer,
          $$PlanEnrollmentsTableOrderingComposer,
          $$PlanEnrollmentsTableAnnotationComposer,
          $$PlanEnrollmentsTableCreateCompanionBuilder,
          $$PlanEnrollmentsTableUpdateCompanionBuilder,
          (
            PlanEnrollment,
            BaseReferences<
              _$AppDatabase,
              $PlanEnrollmentsTable,
              PlanEnrollment
            >,
          ),
          PlanEnrollment,
          PrefetchHooks Function()
        > {
  $$PlanEnrollmentsTableTableManager(
    _$AppDatabase db,
    $PlanEnrollmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanEnrollmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanEnrollmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanEnrollmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> planId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<bool> completed = const Value.absent(),
              }) => PlanEnrollmentsCompanion(
                id: id,
                planId: planId,
                startedAt: startedAt,
                endedAt: endedAt,
                completed: completed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String planId,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<bool> completed = const Value.absent(),
              }) => PlanEnrollmentsCompanion.insert(
                id: id,
                planId: planId,
                startedAt: startedAt,
                endedAt: endedAt,
                completed: completed,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlanEnrollmentsTable, PlanEnrollment>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PlanEnrollmentsTable,
                    PlanEnrollment
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlanEnrollmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanEnrollmentsTable,
      PlanEnrollment,
      $$PlanEnrollmentsTableFilterComposer,
      $$PlanEnrollmentsTableOrderingComposer,
      $$PlanEnrollmentsTableAnnotationComposer,
      $$PlanEnrollmentsTableCreateCompanionBuilder,
      $$PlanEnrollmentsTableUpdateCompanionBuilder,
      (
        PlanEnrollment,
        BaseReferences<_$AppDatabase, $PlanEnrollmentsTable, PlanEnrollment>,
      ),
      PlanEnrollment,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$VersesTableTableManager get verses =>
      $$VersesTableTableManager(_db, _db.verses);
  $$ReadingCyclesTableTableManager get readingCycles =>
      $$ReadingCyclesTableTableManager(_db, _db.readingCycles);
  $$ReadingLogsTableTableManager get readingLogs =>
      $$ReadingLogsTableTableManager(_db, _db.readingLogs);
  $$RecitativesTableTableManager get recitatives =>
      $$RecitativesTableTableManager(_db, _db.recitatives);
  $$PrayerRequestsTableTableManager get prayerRequests =>
      $$PrayerRequestsTableTableManager(_db, _db.prayerRequests);
  $$VerseNotesTableTableManager get verseNotes =>
      $$VerseNotesTableTableManager(_db, _db.verseNotes);
  $$AppSettingsEntriesTableTableManager get appSettingsEntries =>
      $$AppSettingsEntriesTableTableManager(_db, _db.appSettingsEntries);
  $$PlanEnrollmentsTableTableManager get planEnrollments =>
      $$PlanEnrollmentsTableTableManager(_db, _db.planEnrollments);
}

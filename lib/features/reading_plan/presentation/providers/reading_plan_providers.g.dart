// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_plan_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(readingProjectionService)
final readingProjectionServiceProvider = ReadingProjectionServiceProvider._();

final class ReadingProjectionServiceProvider
    extends
        $FunctionalProvider<
          ReadingProjectionService,
          ReadingProjectionService,
          ReadingProjectionService
        >
    with $Provider<ReadingProjectionService> {
  ReadingProjectionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readingProjectionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingProjectionServiceHash();

  @$internal
  @override
  $ProviderElement<ReadingProjectionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReadingProjectionService create(Ref ref) {
    return readingProjectionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadingProjectionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadingProjectionService>(value),
    );
  }
}

String _$readingProjectionServiceHash() =>
    r'eb3fe87f92e1b22ce5cf2e3f668ad9747ecaf652';

@ProviderFor(streakService)
final streakServiceProvider = StreakServiceProvider._();

final class StreakServiceProvider
    extends $FunctionalProvider<StreakService, StreakService, StreakService>
    with $Provider<StreakService> {
  StreakServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'streakServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$streakServiceHash();

  @$internal
  @override
  $ProviderElement<StreakService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StreakService create(Ref ref) {
    return streakService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StreakService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StreakService>(value),
    );
  }
}

String _$streakServiceHash() => r'bc53c7a4694b5d30a86bb19a348dbb7644434b81';

@ProviderFor(readingProjection)
final readingProjectionProvider = ReadingProjectionProvider._();

final class ReadingProjectionProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReadingProjection>,
          ReadingProjection,
          Stream<ReadingProjection>
        >
    with
        $FutureModifier<ReadingProjection>,
        $StreamProvider<ReadingProjection> {
  ReadingProjectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readingProjectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingProjectionHash();

  @$internal
  @override
  $StreamProviderElement<ReadingProjection> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ReadingProjection> create(Ref ref) {
    return readingProjection(ref);
  }
}

String _$readingProjectionHash() => r'3bc5120a734f8a30b6f614e4121835334e14326f';

@ProviderFor(streakStatus)
final streakStatusProvider = StreakStatusProvider._();

final class StreakStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<StreakStatus>,
          StreakStatus,
          Stream<StreakStatus>
        >
    with $FutureModifier<StreakStatus>, $StreamProvider<StreakStatus> {
  StreakStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'streakStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$streakStatusHash();

  @$internal
  @override
  $StreamProviderElement<StreakStatus> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<StreakStatus> create(Ref ref) {
    return streakStatus(ref);
  }
}

String _$streakStatusHash() => r'5aed2ec9f3a334771ff2399358f94b928696ee50';

/// Capítulos únicos lidos no ciclo ativo, por livro.

@ProviderFor(readCountsPerBook)
final readCountsPerBookProvider = ReadCountsPerBookProvider._();

/// Capítulos únicos lidos no ciclo ativo, por livro.

final class ReadCountsPerBookProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<int, int>>,
          Map<int, int>,
          Stream<Map<int, int>>
        >
    with $FutureModifier<Map<int, int>>, $StreamProvider<Map<int, int>> {
  /// Capítulos únicos lidos no ciclo ativo, por livro.
  ReadCountsPerBookProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readCountsPerBookProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readCountsPerBookHash();

  @$internal
  @override
  $StreamProviderElement<Map<int, int>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<int, int>> create(Ref ref) {
    return readCountsPerBook(ref);
  }
}

String _$readCountsPerBookHash() => r'3a77ae1ed9a3e33956541b8192d849c37f62b514';

/// Capítulos de um livro já lidos no ciclo ativo.

@ProviderFor(readChaptersOfBook)
final readChaptersOfBookProvider = ReadChaptersOfBookFamily._();

/// Capítulos de um livro já lidos no ciclo ativo.

final class ReadChaptersOfBookProvider
    extends
        $FunctionalProvider<AsyncValue<Set<int>>, Set<int>, Stream<Set<int>>>
    with $FutureModifier<Set<int>>, $StreamProvider<Set<int>> {
  /// Capítulos de um livro já lidos no ciclo ativo.
  ReadChaptersOfBookProvider._({
    required ReadChaptersOfBookFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'readChaptersOfBookProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$readChaptersOfBookHash();

  @override
  String toString() {
    return r'readChaptersOfBookProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Set<int>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Set<int>> create(Ref ref) {
    final argument = this.argument as int;
    return readChaptersOfBook(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ReadChaptersOfBookProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$readChaptersOfBookHash() =>
    r'1550c57aba8271c8d23b759130103d3452ef7e5a';

/// Capítulos de um livro já lidos no ciclo ativo.

final class ReadChaptersOfBookFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Set<int>>, int> {
  ReadChaptersOfBookFamily._()
    : super(
        retry: null,
        name: r'readChaptersOfBookProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Capítulos de um livro já lidos no ciclo ativo.

  ReadChaptersOfBookProvider call(int bookId) =>
      ReadChaptersOfBookProvider._(argument: bookId, from: this);

  @override
  String toString() => r'readChaptersOfBookProvider';
}

/// Alvo do botão "Continuar leitura".

@ProviderFor(continueReading)
final continueReadingProvider = ContinueReadingProvider._();

/// Alvo do botão "Continuar leitura".

final class ContinueReadingProvider
    extends
        $FunctionalProvider<
          AsyncValue<ContinueReading>,
          ContinueReading,
          Stream<ContinueReading>
        >
    with $FutureModifier<ContinueReading>, $StreamProvider<ContinueReading> {
  /// Alvo do botão "Continuar leitura".
  ContinueReadingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'continueReadingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$continueReadingHash();

  @$internal
  @override
  $StreamProviderElement<ContinueReading> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ContinueReading> create(Ref ref) {
    return continueReading(ref);
  }
}

String _$continueReadingHash() => r'dc6433b0aa64f983d957ef6ae96601eb4d591504';

/// Capítulos por dia em um mês (heatmap). [month] é qualquer dia do mês.

@ProviderFor(monthActivity)
final monthActivityProvider = MonthActivityFamily._();

/// Capítulos por dia em um mês (heatmap). [month] é qualquer dia do mês.

final class MonthActivityProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<DateTime, int>>,
          Map<DateTime, int>,
          Stream<Map<DateTime, int>>
        >
    with
        $FutureModifier<Map<DateTime, int>>,
        $StreamProvider<Map<DateTime, int>> {
  /// Capítulos por dia em um mês (heatmap). [month] é qualquer dia do mês.
  MonthActivityProvider._({
    required MonthActivityFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'monthActivityProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$monthActivityHash();

  @override
  String toString() {
    return r'monthActivityProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<DateTime, int>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<DateTime, int>> create(Ref ref) {
    final argument = this.argument as DateTime;
    return monthActivity(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthActivityProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthActivityHash() => r'43332a1b2d535961c7a100a0aaa7b76182914ac9';

/// Capítulos por dia em um mês (heatmap). [month] é qualquer dia do mês.

final class MonthActivityFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Map<DateTime, int>>, DateTime> {
  MonthActivityFamily._()
    : super(
        retry: null,
        name: r'monthActivityProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Capítulos por dia em um mês (heatmap). [month] é qualquer dia do mês.

  MonthActivityProvider call(DateTime month) =>
      MonthActivityProvider._(argument: month, from: this);

  @override
  String toString() => r'monthActivityProvider';
}

/// Semana atual (domingo a sábado) para a faixa de ofensiva do painel.

@ProviderFor(weekActivity)
final weekActivityProvider = WeekActivityProvider._();

/// Semana atual (domingo a sábado) para a faixa de ofensiva do painel.

final class WeekActivityProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<DateTime, int>>,
          Map<DateTime, int>,
          Stream<Map<DateTime, int>>
        >
    with
        $FutureModifier<Map<DateTime, int>>,
        $StreamProvider<Map<DateTime, int>> {
  /// Semana atual (domingo a sábado) para a faixa de ofensiva do painel.
  WeekActivityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weekActivityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weekActivityHash();

  @$internal
  @override
  $StreamProviderElement<Map<DateTime, int>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<DateTime, int>> create(Ref ref) {
    return weekActivity(ref);
  }
}

String _$weekActivityHash() => r'7774c2625f8f65596751422ceda7fc55949c2a69';

@ProviderFor(logsOnDay)
final logsOnDayProvider = LogsOnDayFamily._();

final class LogsOnDayProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ReadingLogWithBook>>,
          List<ReadingLogWithBook>,
          Stream<List<ReadingLogWithBook>>
        >
    with
        $FutureModifier<List<ReadingLogWithBook>>,
        $StreamProvider<List<ReadingLogWithBook>> {
  LogsOnDayProvider._({
    required LogsOnDayFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'logsOnDayProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$logsOnDayHash();

  @override
  String toString() {
    return r'logsOnDayProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ReadingLogWithBook>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ReadingLogWithBook>> create(Ref ref) {
    final argument = this.argument as DateTime;
    return logsOnDay(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LogsOnDayProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$logsOnDayHash() => r'694c104dbe661cff03ff1eb95be2f8726223caf2';

final class LogsOnDayFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<ReadingLogWithBook>>, DateTime> {
  LogsOnDayFamily._()
    : super(
        retry: null,
        name: r'logsOnDayProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LogsOnDayProvider call(DateTime day) =>
      LogsOnDayProvider._(argument: day, from: this);

  @override
  String toString() => r'logsOnDayProvider';
}

/// Todos os dias com leitura (calendário de histórico da ofensiva).

@ProviderFor(readDays)
final readDaysProvider = ReadDaysProvider._();

/// Todos os dias com leitura (calendário de histórico da ofensiva).

final class ReadDaysProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<DateTime>>,
          Set<DateTime>,
          Stream<Set<DateTime>>
        >
    with $FutureModifier<Set<DateTime>>, $StreamProvider<Set<DateTime>> {
  /// Todos os dias com leitura (calendário de histórico da ofensiva).
  ReadDaysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readDaysProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readDaysHash();

  @$internal
  @override
  $StreamProviderElement<Set<DateTime>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Set<DateTime>> create(Ref ref) {
    return readDays(ref);
  }
}

String _$readDaysHash() => r'1d09b4a986bf68a718730ad124d48a203d8ea6fc';

/// Dias em que um devocional (anotação) foi criado.

@ProviderFor(noteDays)
final noteDaysProvider = NoteDaysProvider._();

/// Dias em que um devocional (anotação) foi criado.

final class NoteDaysProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<DateTime>>,
          Set<DateTime>,
          Stream<Set<DateTime>>
        >
    with $FutureModifier<Set<DateTime>>, $StreamProvider<Set<DateTime>> {
  /// Dias em que um devocional (anotação) foi criado.
  NoteDaysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noteDaysProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noteDaysHash();

  @$internal
  @override
  $StreamProviderElement<Set<DateTime>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Set<DateTime>> create(Ref ref) {
    return noteDays(ref);
  }
}

String _$noteDaysHash() => r'42c7f645f6526fc24ccb6340f2b18833839343fe';

@ProviderFor(notesOnDay)
final notesOnDayProvider = NotesOnDayFamily._();

final class NotesOnDayProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VerseNoteWithBook>>,
          List<VerseNoteWithBook>,
          Stream<List<VerseNoteWithBook>>
        >
    with
        $FutureModifier<List<VerseNoteWithBook>>,
        $StreamProvider<List<VerseNoteWithBook>> {
  NotesOnDayProvider._({
    required NotesOnDayFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'notesOnDayProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$notesOnDayHash();

  @override
  String toString() {
    return r'notesOnDayProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<VerseNoteWithBook>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<VerseNoteWithBook>> create(Ref ref) {
    final argument = this.argument as DateTime;
    return notesOnDay(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NotesOnDayProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$notesOnDayHash() => r'e199498779617e9d767ef1d89e1f7275e0bcf498';

final class NotesOnDayFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<VerseNoteWithBook>>, DateTime> {
  NotesOnDayFamily._()
    : super(
        retry: null,
        name: r'notesOnDayProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NotesOnDayProvider call(DateTime day) =>
      NotesOnDayProvider._(argument: day, from: this);

  @override
  String toString() => r'notesOnDayProvider';
}

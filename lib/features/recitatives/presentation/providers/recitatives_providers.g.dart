// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recitatives_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(recitativeMemoryService)
final recitativeMemoryServiceProvider = RecitativeMemoryServiceProvider._();

final class RecitativeMemoryServiceProvider
    extends
        $FunctionalProvider<
          RecitativeMemoryService,
          RecitativeMemoryService,
          RecitativeMemoryService
        >
    with $Provider<RecitativeMemoryService> {
  RecitativeMemoryServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recitativeMemoryServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recitativeMemoryServiceHash();

  @$internal
  @override
  $ProviderElement<RecitativeMemoryService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecitativeMemoryService create(Ref ref) {
    return recitativeMemoryService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecitativeMemoryService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecitativeMemoryService>(value),
    );
  }
}

String _$recitativeMemoryServiceHash() =>
    r'a6778cba91c560bc0e43613975372f832c2057f9';

@ProviderFor(recitativeMemories)
final recitativeMemoriesProvider = RecitativeMemoriesProvider._();

final class RecitativeMemoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<RecitativeMemoryResult>,
          RecitativeMemoryResult,
          Stream<RecitativeMemoryResult>
        >
    with
        $FutureModifier<RecitativeMemoryResult>,
        $StreamProvider<RecitativeMemoryResult> {
  RecitativeMemoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recitativeMemoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recitativeMemoriesHash();

  @$internal
  @override
  $StreamProviderElement<RecitativeMemoryResult> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<RecitativeMemoryResult> create(Ref ref) {
    return recitativeMemories(ref);
  }
}

String _$recitativeMemoriesHash() =>
    r'9d7081e9a8e99c4002499f5ded135c7360bc23be';

@ProviderFor(pendingRecitatives)
final pendingRecitativesProvider = PendingRecitativesProvider._();

final class PendingRecitativesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RecitativeWithBook>>,
          List<RecitativeWithBook>,
          Stream<List<RecitativeWithBook>>
        >
    with
        $FutureModifier<List<RecitativeWithBook>>,
        $StreamProvider<List<RecitativeWithBook>> {
  PendingRecitativesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingRecitativesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingRecitativesHash();

  @$internal
  @override
  $StreamProviderElement<List<RecitativeWithBook>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RecitativeWithBook>> create(Ref ref) {
    return pendingRecitatives(ref);
  }
}

String _$pendingRecitativesHash() =>
    r'989e1b60b0e955751fc39b7aa99a80c73899845a';

@ProviderFor(recitedRecitatives)
final recitedRecitativesProvider = RecitedRecitativesProvider._();

final class RecitedRecitativesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RecitativeWithBook>>,
          List<RecitativeWithBook>,
          Stream<List<RecitativeWithBook>>
        >
    with
        $FutureModifier<List<RecitativeWithBook>>,
        $StreamProvider<List<RecitativeWithBook>> {
  RecitedRecitativesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recitedRecitativesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recitedRecitativesHash();

  @$internal
  @override
  $StreamProviderElement<List<RecitativeWithBook>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RecitativeWithBook>> create(Ref ref) {
    return recitedRecitatives(ref);
  }
}

String _$recitedRecitativesHash() =>
    r'8550936766809068140a40473f46fa2d08bac347';

@ProviderFor(nextPendingRecitative)
final nextPendingRecitativeProvider = NextPendingRecitativeProvider._();

final class NextPendingRecitativeProvider
    extends
        $FunctionalProvider<
          AsyncValue<RecitativeWithBook?>,
          RecitativeWithBook?,
          Stream<RecitativeWithBook?>
        >
    with
        $FutureModifier<RecitativeWithBook?>,
        $StreamProvider<RecitativeWithBook?> {
  NextPendingRecitativeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nextPendingRecitativeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nextPendingRecitativeHash();

  @$internal
  @override
  $StreamProviderElement<RecitativeWithBook?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<RecitativeWithBook?> create(Ref ref) {
    return nextPendingRecitative(ref);
  }
}

String _$nextPendingRecitativeHash() =>
    r'a6dc2331085477523b1caf3e08b7f2c86ee14de7';

@ProviderFor(recitativeById)
final recitativeByIdProvider = RecitativeByIdFamily._();

final class RecitativeByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<RecitativeWithBook?>,
          RecitativeWithBook?,
          Stream<RecitativeWithBook?>
        >
    with
        $FutureModifier<RecitativeWithBook?>,
        $StreamProvider<RecitativeWithBook?> {
  RecitativeByIdProvider._({
    required RecitativeByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'recitativeByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recitativeByIdHash();

  @override
  String toString() {
    return r'recitativeByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<RecitativeWithBook?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<RecitativeWithBook?> create(Ref ref) {
    final argument = this.argument as String;
    return recitativeById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecitativeByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recitativeByIdHash() => r'6a0e709ecd6438b05bbc757fe5f1f606a9f7a57c';

final class RecitativeByIdFamily extends $Family
    with $FunctionalFamilyOverride<Stream<RecitativeWithBook?>, String> {
  RecitativeByIdFamily._()
    : super(
        retry: null,
        name: r'recitativeByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RecitativeByIdProvider call(String id) =>
      RecitativeByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'recitativeByIdProvider';
}

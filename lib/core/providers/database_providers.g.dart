// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'59cce38d45eeaba199eddd097d8e149d66f9f3e1';

@ProviderFor(bibleSeedService)
final bibleSeedServiceProvider = BibleSeedServiceProvider._();

final class BibleSeedServiceProvider
    extends
        $FunctionalProvider<
          BibleSeedService,
          BibleSeedService,
          BibleSeedService
        >
    with $Provider<BibleSeedService> {
  BibleSeedServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bibleSeedServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bibleSeedServiceHash();

  @$internal
  @override
  $ProviderElement<BibleSeedService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BibleSeedService create(Ref ref) {
    return bibleSeedService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BibleSeedService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BibleSeedService>(value),
    );
  }
}

String _$bibleSeedServiceHash() => r'6bacb97571b74c9cc1a8cf31982e4e8f77c5a120';

/// Traduções com texto instalado no aparelho. Sem nenhuma, o app mostra a
/// tela de importação. Invalide após importar ou remover uma tradução.

@ProviderFor(availableTranslations)
final availableTranslationsProvider = AvailableTranslationsProvider._();

/// Traduções com texto instalado no aparelho. Sem nenhuma, o app mostra a
/// tela de importação. Invalide após importar ou remover uma tradução.

final class AvailableTranslationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BibleTranslation>>,
          List<BibleTranslation>,
          FutureOr<List<BibleTranslation>>
        >
    with
        $FutureModifier<List<BibleTranslation>>,
        $FutureProvider<List<BibleTranslation>> {
  /// Traduções com texto instalado no aparelho. Sem nenhuma, o app mostra a
  /// tela de importação. Invalide após importar ou remover uma tradução.
  AvailableTranslationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availableTranslationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availableTranslationsHash();

  @$internal
  @override
  $FutureProviderElement<List<BibleTranslation>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BibleTranslation>> create(Ref ref) {
    return availableTranslations(ref);
  }
}

String _$availableTranslationsHash() =>
    r'fe186379a48a7a027d90c8000d90a220bf770937';

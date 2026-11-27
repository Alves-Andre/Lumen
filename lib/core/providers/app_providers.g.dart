// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(settingsDao)
final settingsDaoProvider = SettingsDaoProvider._();

final class SettingsDaoProvider
    extends $FunctionalProvider<SettingsDao, SettingsDao, SettingsDao>
    with $Provider<SettingsDao> {
  SettingsDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsDaoHash();

  @$internal
  @override
  $ProviderElement<SettingsDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SettingsDao create(Ref ref) {
    return settingsDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsDao>(value),
    );
  }
}

String _$settingsDaoHash() => r'a0a5073bee4b1c7ab22a219c1b79798d6aef8421';

@ProviderFor(appSettings)
final appSettingsProvider = AppSettingsProvider._();

final class AppSettingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppSettings>,
          AppSettings,
          Stream<AppSettings>
        >
    with $FutureModifier<AppSettings>, $StreamProvider<AppSettings> {
  AppSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appSettingsHash();

  @$internal
  @override
  $StreamProviderElement<AppSettings> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AppSettings> create(Ref ref) {
    return appSettings(ref);
  }
}

String _$appSettingsHash() => r'3956d057d426f5b22cc4056ab0260a8a123cff95';

/// Tradução principal, usada nos recitativos: a escolhida nas Configurações,
/// senão a ARC, senão a primeira instalada.

@ProviderFor(primaryTranslation)
final primaryTranslationProvider = PrimaryTranslationProvider._();

/// Tradução principal, usada nos recitativos: a escolhida nas Configurações,
/// senão a ARC, senão a primeira instalada.

final class PrimaryTranslationProvider
    extends
        $FunctionalProvider<
          BibleTranslation,
          BibleTranslation,
          BibleTranslation
        >
    with $Provider<BibleTranslation> {
  /// Tradução principal, usada nos recitativos: a escolhida nas Configurações,
  /// senão a ARC, senão a primeira instalada.
  PrimaryTranslationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'primaryTranslationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$primaryTranslationHash();

  @$internal
  @override
  $ProviderElement<BibleTranslation> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BibleTranslation create(Ref ref) {
    return primaryTranslation(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BibleTranslation value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BibleTranslation>(value),
    );
  }
}

String _$primaryTranslationHash() =>
    r'df9692b0e260903fd846e86b0c46a56bc8af03e0';

/// Tradução de leitura efetiva: a escolhida, se estiver instalada; senão a principal.

@ProviderFor(readingTranslation)
final readingTranslationProvider = ReadingTranslationProvider._();

/// Tradução de leitura efetiva: a escolhida, se estiver instalada; senão a principal.

final class ReadingTranslationProvider
    extends
        $FunctionalProvider<
          BibleTranslation,
          BibleTranslation,
          BibleTranslation
        >
    with $Provider<BibleTranslation> {
  /// Tradução de leitura efetiva: a escolhida, se estiver instalada; senão a principal.
  ReadingTranslationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readingTranslationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingTranslationHash();

  @$internal
  @override
  $ProviderElement<BibleTranslation> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BibleTranslation create(Ref ref) {
    return readingTranslation(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BibleTranslation value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BibleTranslation>(value),
    );
  }
}

String _$readingTranslationHash() =>
    r'ffcf7abb3c6a1df51c5b863482803d6a1c0869f6';

@ProviderFor(notificationService)
final notificationServiceProvider = NotificationServiceProvider._();

final class NotificationServiceProvider
    extends
        $FunctionalProvider<
          NotificationService,
          NotificationService,
          NotificationService
        >
    with $Provider<NotificationService> {
  NotificationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationServiceHash();

  @$internal
  @override
  $ProviderElement<NotificationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationService create(Ref ref) {
    return notificationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationService>(value),
    );
  }
}

String _$notificationServiceHash() =>
    r'585c1e42ea844e71a2b76b80b165adfe2c5c8529';

@ProviderFor(backupService)
final backupServiceProvider = BackupServiceProvider._();

final class BackupServiceProvider
    extends $FunctionalProvider<BackupService, BackupService, BackupService>
    with $Provider<BackupService> {
  BackupServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupServiceHash();

  @$internal
  @override
  $ProviderElement<BackupService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BackupService create(Ref ref) {
    return backupService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupService>(value),
    );
  }
}

String _$backupServiceHash() => r'07bce273ebfd8738845610d8805992b960a79991';

/// Mantém os agendamentos em dia com as preferências e com os recitativos.

@ProviderFor(notificationSync)
final notificationSyncProvider = NotificationSyncProvider._();

/// Mantém os agendamentos em dia com as preferências e com os recitativos.

final class NotificationSyncProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Mantém os agendamentos em dia com as preferências e com os recitativos.
  NotificationSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationSyncHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return notificationSync(ref);
  }
}

String _$notificationSyncHash() => r'cf7b264221d610f8be157868cecab389368f4062';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../backup/backup_service.dart';
import '../database/app_database.dart';
import '../database/daos/settings_dao.dart';
import '../notifications/notification_service.dart';
import '../settings/app_settings.dart';
import 'database_providers.dart';

part 'app_providers.g.dart';

@Riverpod(keepAlive: true)
SettingsDao settingsDao(Ref ref) => ref.watch(appDatabaseProvider).settingsDao;

@Riverpod(keepAlive: true)
Stream<AppSettings> appSettings(Ref ref) => ref.watch(settingsDaoProvider).watchAll().map(AppSettings.fromMap);

/// Tradução principal, usada nos recitativos: a escolhida nas Configurações,
/// senão a ARC, senão a primeira instalada.
@Riverpod(keepAlive: true)
BibleTranslation primaryTranslation(Ref ref) {
  final chosen = ref.watch(appSettingsProvider.select((s) => s.value?.primaryTranslationCode));
  final installed = ref.watch(availableTranslationsProvider).value ?? const <BibleTranslation>[];
  return BibleTranslation.pickPrimary(installed, chosen) ?? BibleTranslation.preferredPrimary;
}

/// Tradução de leitura efetiva: a escolhida, se estiver instalada; senão a principal.
@Riverpod(keepAlive: true)
BibleTranslation readingTranslation(Ref ref) {
  final chosen = ref.watch(appSettingsProvider.select((s) => s.value?.translationCode));
  final installed = ref.watch(availableTranslationsProvider).value ?? const <BibleTranslation>[];
  for (final t in installed) {
    if (t.code == chosen) return t;
  }
  return ref.watch(primaryTranslationProvider);
}

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) => NotificationService();

@Riverpod(keepAlive: true)
BackupService backupService(Ref ref) => BackupService(ref.watch(appDatabaseProvider));

/// Mantém os agendamentos em dia com as preferências e com os recitativos.
@Riverpod(keepAlive: true)
Future<void> notificationSync(Ref ref) async {
  final prefs = await ref.watch(
    appSettingsProvider.selectAsync((s) => (s.reminderEnabled, s.reminderHour, s.reminderMinute, s.memoryNotificationsEnabled)),
  );
  final service = ref.watch(notificationServiceProvider);
  final recitativesDao = ref.watch(appDatabaseProvider).recitativesDao;
  final (reminderEnabled, hour, minute, memoriesEnabled) = prefs;

  await service.init();
  if (reminderEnabled) {
    await service.scheduleDailyReminder(hour: hour, minute: minute);
  } else {
    await service.cancelDailyReminder();
  }

  Future<void> syncMemories() async {
    if (memoriesEnabled) {
      await service.syncRecitativeAnniversaries(await recitativesDao.getAll());
    } else {
      await service.cancelRecitativeAnniversaries();
    }
  }

  await syncMemories();
  final sub = recitativesDao.watchChanges().listen((_) => unawaited(syncMemories()));
  ref.onDispose(sub.cancel);
}

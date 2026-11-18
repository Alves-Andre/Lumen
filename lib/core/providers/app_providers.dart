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

/// Versão de leitura efetiva: a escolhida, se estiver carregada; senão a ARC.
@Riverpod(keepAlive: true)
BibleTranslation readingTranslation(Ref ref) {
  final chosen = ref.watch(appSettingsProvider.select((s) => s.value?.translation)) ?? BibleTranslation.primary;
  final available = ref.watch(availableTranslationsProvider).value ?? const [BibleTranslation.primary];
  return available.contains(chosen) ? chosen : BibleTranslation.primary;
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

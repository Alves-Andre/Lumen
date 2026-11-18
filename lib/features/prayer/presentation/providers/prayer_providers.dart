import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_providers.dart';

// Escritos à mão: PrayerRequest é gerado pelo Drift (ver bible_providers.dart).

final activePrayersProvider = StreamProvider.autoDispose<List<PrayerRequest>>(
  (ref) => ref.watch(appDatabaseProvider).prayerDao.watchActive(),
);

final answeredPrayersProvider = StreamProvider.autoDispose<List<PrayerRequest>>(
  (ref) => ref.watch(appDatabaseProvider).prayerDao.watchAnswered(),
);

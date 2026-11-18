import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/app_database.dart';
import '../database/seed/bible_seed_service.dart';

part 'database_providers.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

@Riverpod(keepAlive: true)
BibleSeedService bibleSeedService(Ref ref) => BibleSeedService(ref.watch(appDatabaseProvider));

/// Versões com texto instalado no banco. A ARC é obrigatória: sem ela o app
/// mostra a tela de importação. Invalide após importar uma versão.
@Riverpod(keepAlive: true)
Future<List<BibleTranslation>> availableTranslations(Ref ref) async {
  final dao = ref.watch(appDatabaseProvider).bibleDao;
  return [
    for (final t in BibleTranslation.values)
      if (await dao.isSeeded(t)) t,
  ];
}

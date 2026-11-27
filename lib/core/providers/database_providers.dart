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

/// Traduções com texto instalado no aparelho. Sem nenhuma, o app mostra a
/// tela de importação. Invalide após importar ou remover uma tradução.
@Riverpod(keepAlive: true)
Future<List<BibleTranslation>> availableTranslations(Ref ref) =>
    ref.watch(appDatabaseProvider).bibleDao.getInstalled();

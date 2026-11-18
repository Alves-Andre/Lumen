import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_providers.dart';
import '../../domain/models/recitative_memory.dart';
import '../../domain/services/recitative_memory_service.dart';

part 'recitatives_providers.g.dart';

@Riverpod(keepAlive: true)
RecitativeMemoryService recitativeMemoryService(Ref ref) =>
    RecitativeMemoryService(ref.watch(appDatabaseProvider).recitativesDao);

@riverpod
Stream<RecitativeMemoryResult> recitativeMemories(Ref ref) =>
    ref.watch(recitativeMemoryServiceProvider).watch();

@riverpod
Stream<List<RecitativeWithBook>> pendingRecitatives(Ref ref) =>
    ref.watch(appDatabaseProvider).recitativesDao.watchPending();

@riverpod
Stream<List<RecitativeWithBook>> recitedRecitatives(Ref ref) =>
    ref.watch(appDatabaseProvider).recitativesDao.watchRecited();

@riverpod
Stream<RecitativeWithBook?> nextPendingRecitative(Ref ref) =>
    ref.watch(appDatabaseProvider).recitativesDao.watchNextPending(DateTime.now());

@riverpod
Stream<RecitativeWithBook?> recitativeById(Ref ref, int id) =>
    ref.watch(appDatabaseProvider).recitativesDao.watchById(id);

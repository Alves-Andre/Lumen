import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_providers.dart';

part 'devotions_providers.g.dart';

@riverpod
Stream<List<VerseNoteWithBook>> allNotes(Ref ref) => ref.watch(appDatabaseProvider).notesDao.watchAll();

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [AppSettingsEntries])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.attachedDatabase);

  Stream<Map<String, String>> watchAll() =>
      select(appSettingsEntries).watch().map((rows) => {for (final r in rows) r.key: r.value});

  Future<Map<String, String>> getAll() async =>
      {for (final r in await select(appSettingsEntries).get()) r.key: r.value};

  Future<void> setValue(String key, String value) => into(appSettingsEntries)
      .insertOnConflictUpdate(AppSettingsEntriesCompanion.insert(key: key, value: value));
}

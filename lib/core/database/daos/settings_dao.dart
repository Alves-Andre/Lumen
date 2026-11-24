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

  Future<String?> getValue(String key) async =>
      (await (select(appSettingsEntries)..where((s) => s.key.equals(key))).getSingleOrNull())?.value;

  Stream<String?> watchValue(String key) =>
      (select(appSettingsEntries)..where((s) => s.key.equals(key))).watchSingleOrNull().map((s) => s?.value);

  Future<void> removeValue(String key) => (delete(appSettingsEntries)..where((s) => s.key.equals(key))).go();

  /// Remove todas as chaves que começam com [prefix].
  Future<void> removeWithPrefix(String prefix) =>
      (delete(appSettingsEntries)..where((s) => s.key.like('${_escapeLike(prefix)}%', escapeChar: r'\'))).go();

  static String _escapeLike(String v) => v.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
}

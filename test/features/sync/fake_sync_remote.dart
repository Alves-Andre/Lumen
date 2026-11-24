import 'package:devocional/features/sync/data/sync_remote.dart';

/// "Supabase" em memória com o mesmo comportamento do `schema.sql`:
/// * `synced_at` carimbado pelo servidor a cada escrita (sempre crescente);
/// * Last-Write-Wins: escrita com `updated_at` mais antigo que o atual é ignorada;
/// * leitura por (synced_at, id) com limite (paginação por chave).
class FakeSyncRemote implements SyncRemote {
  final Map<String, Map<String, RemoteRow>> tables = {};
  int _clock = 0;
  int upsertCalls = 0;
  int fetchCalls = 0;

  /// Simula falta de internet.
  bool offline = false;

  String _nextSyncedAt() {
    _clock++;
    final micros = DateTime.utc(2026).microsecondsSinceEpoch + _clock;
    return DateTime.fromMicrosecondsSinceEpoch(micros, isUtc: true).toIso8601String();
  }

  void _checkOnline() {
    if (offline) throw Exception('ClientException: Connection refused');
  }

  @override
  Future<void> upsert(String table, List<RemoteRow> rows) async {
    _checkOnline();
    upsertCalls++;
    final t = tables.putIfAbsent(table, () => {});
    for (final row in rows) {
      final id = row['id'] as String;
      final existing = t[id];
      if (existing != null &&
          DateTime.parse(row['updated_at'] as String).isBefore(DateTime.parse(existing['updated_at'] as String))) {
        continue; // versão mais antiga: o gatilho do servidor descarta
      }
      t[id] = {...?existing, ...row, 'synced_at': _nextSyncedAt()};
    }
  }

  @override
  Future<List<RemoteRow>> fetchSince(
    String table, {
    required String ownerColumn,
    required String userId,
    SyncCursor? after,
    required int limit,
  }) async {
    _checkOnline();
    fetchCalls++;
    final rows = (tables[table]?.values ?? const <RemoteRow>[])
        .where((r) => r[ownerColumn] == userId)
        .where((r) {
          if (after == null) return true;
          final cmp = (r['synced_at'] as String).compareTo(after.syncedAt);
          return cmp > 0 || (cmp == 0 && (r['id'] as String).compareTo(after.id) > 0);
        })
        .toList()
      ..sort((a, b) {
        final cmp = (a['synced_at'] as String).compareTo(b['synced_at'] as String);
        return cmp != 0 ? cmp : (a['id'] as String).compareTo(b['id'] as String);
      });
    return [for (final r in rows.take(limit)) Map<String, dynamic>.from(r)];
  }
}

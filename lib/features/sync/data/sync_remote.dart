import 'package:supabase_flutter/supabase_flutter.dart';

typedef RemoteRow = Map<String, dynamic>;

/// Posição do último registro recebido de uma tabela: `(synced_at, id)`.
///
/// `synced_at` é carimbado pelo servidor e guardado como texto, exatamente
/// como veio (com microssegundos), para a próxima consulta continuar dali.
class SyncCursor {
  const SyncCursor(this.syncedAt, this.id);

  final String syncedAt;
  final String id;

  factory SyncCursor.ofRow(RemoteRow row) => SyncCursor(row['synced_at'] as String, row['id'] as String);

  static SyncCursor? parse(String? raw) {
    if (raw == null) return null;
    final sep = raw.lastIndexOf('|');
    return sep <= 0 ? null : SyncCursor(raw.substring(0, sep), raw.substring(sep + 1));
  }

  String serialize() => '$syncedAt|$id';
}

/// Lado nuvem da sincronização. Interface para permitir testes sem rede.
abstract interface class SyncRemote {
  /// Insere ou atualiza [rows] em [table] (conflito pelo `id`).
  Future<void> upsert(String table, List<RemoteRow> rows);

  /// Linhas do usuário em [table] gravadas no servidor depois de [after],
  /// em ordem de `(synced_at, id)`, no máximo [limit].
  Future<List<RemoteRow>> fetchSince(
    String table, {
    required String ownerColumn,
    required String userId,
    SyncCursor? after,
    required int limit,
  });
}

class SupabaseSyncRemote implements SyncRemote {
  SupabaseSyncRemote(this._client);

  final SupabaseClient _client;

  @override
  Future<void> upsert(String table, List<RemoteRow> rows) async {
    if (rows.isEmpty) return;
    await _client.from(table).upsert(rows, onConflict: 'id');
  }

  @override
  Future<List<RemoteRow>> fetchSince(
    String table, {
    required String ownerColumn,
    required String userId,
    SyncCursor? after,
    required int limit,
  }) async {
    var query = _client.from(table).select().eq(ownerColumn, userId);
    if (after != null) {
      // Paginação por chave (keyset): estável mesmo com escritas durante o download.
      final ts = after.syncedAt;
      query = query.or('synced_at.gt."$ts",and(synced_at.eq."$ts",id.gt.${after.id})');
    }
    final rows = await query.order('synced_at', ascending: true).order('id', ascending: true).limit(limit);
    return rows;
  }
}

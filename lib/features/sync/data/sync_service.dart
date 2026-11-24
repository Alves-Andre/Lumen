import 'dart:async';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/settings_dao.dart';
import '../../../core/database/daos/sync_dao.dart';
import 'sync_remote.dart';
import 'sync_tables.dart';

/// Resultado de uma rodada de sincronização.
class SyncReport {
  const SyncReport({required this.pulled, required this.pushed, required this.finishedAt});

  /// Linhas recebidas da nuvem e gravadas no aparelho.
  final int pulled;

  /// Linhas enviadas à nuvem.
  final int pushed;
  final DateTime finishedAt;
}

/// Motor de sincronização offline-first (Drift ⇄ Supabase).
///
/// O app sempre lê e grava no banco local; este serviço só reconcilia:
/// 1. **Pull**: baixa o que mudou na nuvem desde o último cursor de cada tabela
///    e mescla por Last-Write-Wins (`updated_at`). Sem cursor (aparelho novo ou
///    conta recém-conectada) o pull baixa tudo — a restauração completa.
/// 2. **Push**: envia em lote (upsert) as linhas com `is_synced = false` e as
///    marca como sincronizadas.
///
/// O pull vem antes do push: assim uma alteração mais nova feita em outro
/// aparelho é aplicada antes de enviarmos a nossa, e o servidor ainda descarta
/// qualquer escrita mais antiga que a que já tem (gatilho `lumen_before_write`).
class SyncService {
  SyncService(this._db, this._remote) : _specs = buildSyncSpecs(_db);

  final AppDatabase _db;
  final SyncRemote _remote;
  final List<SyncTableSpec<Object?>> _specs;

  SyncDao get _dao => _db.syncDao;
  SettingsDao get _settings => _db.settingsDao;

  Future<SyncReport>? _inFlight;
  bool _rerunRequested = false;

  /// Sincroniza a conta [userId]. Chamadas durante uma rodada em andamento não
  /// abrem outra em paralelo: a rodada atual é repetida uma vez ao terminar.
  Future<SyncReport> sync(String userId) {
    final running = _inFlight;
    if (running != null) {
      _rerunRequested = true;
      return running;
    }
    final future = _runUntilSettled(userId).whenComplete(() => _inFlight = null);
    _inFlight = future;
    return future;
  }

  Future<SyncReport> _runUntilSettled(String userId) async {
    SyncReport report;
    do {
      _rerunRequested = false;
      report = await _syncOnce(userId);
    } while (_rerunRequested);
    return report;
  }

  Future<SyncReport> _syncOnce(String userId) async {
    var pulled = 0;
    for (final spec in _specs) {
      pulled += await spec.pull(_dao, _settings, _remote, userId);
    }
    if (pulled > 0) await _dao.consolidateActiveRows();

    var pushed = 0;
    for (final spec in _specs) {
      pushed += await spec.push(_dao, _remote, userId);
    }

    final now = DateTime.now();
    await _settings.setValue(SyncKeys.lastSyncAt, now.toIso8601String());
    return SyncReport(pulled: pulled, pushed: pushed, finishedAt: now);
  }

  /// Vincula os dados do aparelho à conta [userId] (logo após o login):
  /// * primeira conta no aparelho: o que foi feito sem login passa a pertencer
  ///   a ela e é enviado na próxima sincronização;
  /// * outra conta: os dados locais da conta anterior são apagados antes do
  ///   download completo (não se misturam dados de pessoas diferentes).
  Future<void> attachUser(String userId) async {
    final owner = await _settings.getValue(SyncKeys.ownerId);
    if (owner == userId) return;
    if (owner == null) {
      await _dao.markAllUnsynced();
    } else {
      await _dao.wipeUserData();
    }
    await _settings.removeWithPrefix(SyncKeys.cursorPrefix);
    await _settings.removeValue(SyncKeys.lastSyncAt);
    await _settings.removeValue(SyncKeys.guestMode);
    await _settings.setValue(SyncKeys.ownerId, userId);
  }

  /// Ao sair da conta: apaga do aparelho os dados dela e o estado da
  /// sincronização. A Bíblia e as preferências do app permanecem.
  Future<void> detachUser() async {
    await _dao.wipeUserData();
    await _settings.removeWithPrefix(SyncKeys.prefix);
  }

  /// Busca o perfil na nuvem (login num aparelho novo) e o grava localmente.
  Future<UserProfile?> fetchRemoteProfile(String userId) async {
    final spec = _specs.firstWhere((s) => s.remoteTable == 'profiles');
    await spec.pull(_dao, _settings, _remote, userId);
    return _dao.getProfile(userId);
  }

  /// Envia só o perfil (logo após o onboarding).
  Future<void> pushProfile(String userId) async {
    final spec = _specs.firstWhere((s) => s.remoteTable == 'profiles');
    await spec.push(_dao, _remote, userId);
  }

  Future<DateTime?> lastSyncAt() async {
    final raw = await _settings.getValue(SyncKeys.lastSyncAt);
    return raw == null ? null : DateTime.tryParse(raw);
  }
}

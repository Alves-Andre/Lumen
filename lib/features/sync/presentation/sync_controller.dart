import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/database_providers.dart';
import '../../auth/presentation/providers/auth_providers.dart';

enum SyncPhase {
  /// App sem nuvem configurada.
  disabled,

  /// Ninguém conectado (modo sem conta).
  signedOut,
  idle,
  syncing,
  offline,
  error,
}

class SyncState {
  const SyncState({required this.phase, this.lastSyncAt, this.pending = 0, this.message});

  final SyncPhase phase;
  final DateTime? lastSyncAt;

  /// Alterações locais aguardando envio.
  final int pending;
  final String? message;

  bool get isActive => phase != SyncPhase.disabled && phase != SyncPhase.signedOut;

  SyncState copyWith({SyncPhase? phase, DateTime? lastSyncAt, int? pending, String? message}) => SyncState(
        phase: phase ?? this.phase,
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
        pending: pending ?? this.pending,
        message: message,
      );

  /// Texto de status para as Configurações.
  String get label {
    String changes(int n) => n == 1 ? '1 alteração' : '$n alterações';
    switch (phase) {
      case SyncPhase.disabled:
        return 'Sincronização indisponível';
      case SyncPhase.signedOut:
        return 'Sem conta: dados apenas neste aparelho';
      case SyncPhase.syncing:
        return 'Sincronizando…';
      case SyncPhase.offline:
        return pending > 0 ? 'Modo offline · ${changes(pending)} aguardando conexão' : 'Modo offline';
      case SyncPhase.error:
        return 'Não foi possível sincronizar${message == null ? '' : ': $message'}';
      case SyncPhase.idle:
        if (pending > 0) return '${changes(pending)} aguardando envio';
        final last = lastSyncAt;
        if (last == null) return 'Ainda não sincronizado';
        final now = DateTime.now();
        final sameDay = last.year == now.year && last.month == now.month && last.day == now.day;
        return sameDay
            ? 'Sincronizado às ${DateFormat.Hm('pt_BR').format(last)}'
            : 'Sincronizado em ${DateFormat("d 'de' MMM, HH:mm", 'pt_BR').format(last)}';
    }
  }
}

/// Orquestra a sincronização automática enquanto há um usuário conectado:
/// * ao abrir o app (e ao voltar para ele);
/// * quando o aparelho volta a ter internet;
/// * logo após qualquer alteração local (leitura, recitativo, oração, nota),
///   em segundo plano e com um pequeno atraso para agrupar alterações seguidas;
/// * no botão "Sincronizar agora".
final syncControllerProvider = NotifierProvider<SyncController, SyncState>(SyncController.new);

class SyncController extends Notifier<SyncState> {
  static const Duration _debounce = Duration(seconds: 3);

  Timer? _debounceTimer;
  bool _online = true;

  @override
  SyncState build() {
    final service = ref.watch(syncServiceProvider);
    if (service == null) return const SyncState(phase: SyncPhase.disabled);
    final user = ref.watch(authUserProvider).value;
    if (user == null) return const SyncState(phase: SyncPhase.signedOut);
    final userId = user.id;

    final db = ref.watch(appDatabaseProvider);
    var lastPending = 0;
    final pendingSub = db.syncDao.watchPendingCount().listen((count) {
      state = state.copyWith(pending: count, message: state.message);
      // Nova alteração local: agenda o envio.
      if (count > lastPending && count > 0) _schedule(userId);
      lastPending = count;
    });

    final connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final online = _isOnline(results);
      final cameBack = online && !_online;
      _online = online;
      if (!online) {
        state = state.copyWith(phase: SyncPhase.offline);
      } else if (cameBack) {
        unawaited(syncNow());
      }
    }, onError: (Object _) {});

    final lifecycle = AppLifecycleListener(onResume: () => _schedule(userId, delay: Duration.zero));

    ref.onDispose(() {
      _debounceTimer?.cancel();
      pendingSub.cancel();
      connectivitySub.cancel();
      lifecycle.dispose();
    });

    // Ao abrir o app (ou ao conectar a conta): sincroniza logo em seguida.
    Future.microtask(() async {
      final last = await service.lastSyncAt();
      if (last != null && ref.mounted) state = state.copyWith(lastSyncAt: last, message: state.message);
      if (ref.mounted) await syncNow();
    });
    return const SyncState(phase: SyncPhase.idle);
  }

  void _schedule(String userId, {Duration delay = _debounce}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, () => unawaited(syncNow()));
  }

  /// Sincroniza agora (botão manual e gatilhos automáticos). Nunca lança erro:
  /// falhas viram estado ("Modo offline" ou mensagem de erro).
  Future<void> syncNow() async {
    final service = ref.read(syncServiceProvider);
    final user = ref.read(authUserProvider).value;
    if (service == null || user == null) return;

    try {
      _online = _isOnline(await Connectivity().checkConnectivity());
    } on Object {
      _online = true; // Sem o plugin (ex.: testes), tenta mesmo assim.
    }
    if (!ref.mounted) return;
    if (!_online) {
      state = state.copyWith(phase: SyncPhase.offline);
      return;
    }

    state = state.copyWith(phase: SyncPhase.syncing);
    try {
      final report = await service.sync(user.id);
      if (!ref.mounted) return;
      state = state.copyWith(phase: SyncPhase.idle, lastSyncAt: report.finishedAt);
    } on Object catch (e) {
      if (!ref.mounted) return;
      if (_isNetworkError(e)) {
        state = state.copyWith(phase: SyncPhase.offline);
      } else {
        state = state.copyWith(phase: SyncPhase.error, message: _describe(e));
      }
    }
  }

  static bool _isOnline(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  static bool _isNetworkError(Object e) {
    if (e is AuthRetryableFetchException) return true;
    if (e is TimeoutException) return true;
    final text = e.toString();
    return text.contains('SocketException') ||
        text.contains('ClientException') ||
        text.contains('Failed host lookup') ||
        text.contains('Connection') ||
        text.contains('XMLHttpRequest');
  }

  static String _describe(Object e) {
    if (e is PostgrestException) {
      if (e.code == '42P01' || e.code == 'PGRST205') return 'tabelas não encontradas no Supabase (rode supabase/schema.sql)';
      if (e.code == '42501') return 'acesso negado pelo servidor (verifique as políticas RLS)';
      return e.message;
    }
    if (e is AuthException) return 'sessão expirada, entre novamente';
    return 'erro inesperado';
  }
}

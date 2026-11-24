import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/cloud/cloud_bootstrap.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/settings/app_settings.dart';
import '../../../sync/data/sync_remote.dart';
import '../../../sync/data/sync_service.dart';
import '../../../sync/data/sync_tables.dart';
import '../../data/auth_repository.dart';

// Providers escritos à mão: os tipos do Drift e do Supabase não são resolvidos
// pelo riverpod_generator (ver build.yaml).

/// Cliente do Supabase, ou `null` quando o app roda sem nuvem (sem chaves).
final supabaseClientProvider = Provider<SupabaseClient?>(
  (ref) => CloudBootstrap.isReady ? Supabase.instance.client : null,
);

/// `true` quando login e sincronização estão disponíveis.
final cloudEnabledProvider = Provider<bool>((ref) => ref.watch(supabaseClientProvider) != null);

final authRepositoryProvider = Provider<AuthRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : AuthRepository(client);
});

final syncServiceProvider = Provider<SyncService?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;
  return SyncService(ref.watch(appDatabaseProvider), SupabaseSyncRemote(client));
});

/// Usuário conectado (ou `null`). Funciona offline: a sessão salva é usada
/// até o token poder ser renovado.
final authUserProvider = StreamProvider<User?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  if (repo == null) return Stream.value(null);
  final controller = StreamController<User?>();
  controller.add(repo.currentUser);
  final sub = repo.authStateChanges.listen((state) {
    if (state.event == AuthChangeEvent.passwordRecovery) {
      ref.read(passwordRecoveryProvider.notifier).start();
    }
    controller.add(state.session?.user);
  }, onError: (Object _) {
    // Link de login inválido/expirado: mantém o estado atual.
  });
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream.distinct((a, b) => a?.id == b?.id);
});

/// Ativo depois que o usuário abre o link "Esqueci minha senha": o app pede a nova senha.
final passwordRecoveryProvider = NotifierProvider<PasswordRecoveryNotifier, bool>(PasswordRecoveryNotifier.new);

class PasswordRecoveryNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void start() => state = true;

  void finish() => state = false;
}

/// Usuário escolheu "Continuar sem conta" neste aparelho.
final guestModeProvider = StreamProvider<bool>(
  (ref) => ref.watch(settingsDaoProvider).watchValue(SyncKeys.guestMode).map((v) => v == 'true'),
);

/// Perfil local da conta [userId] (`null` = onboarding pendente).
final userProfileProvider = StreamProvider.family<UserProfile?, String>(
  (ref, userId) => ref.watch(appDatabaseProvider).syncDao.watchProfile(userId),
);

/// Preparação da conta logo após o login: vincula os dados do aparelho à
/// conta e, se o perfil ainda não estiver no aparelho, tenta buscá-lo na nuvem
/// (login num aparelho novo). Sem internet, segue em frente: o onboarding
/// salva localmente e envia depois.
final accountSetupProvider = FutureProvider.family<void, String>((ref, userId) async {
  final service = ref.watch(syncServiceProvider);
  if (service == null) return;
  await service.attachUser(userId);
  final local = await ref.read(appDatabaseProvider).syncDao.getProfile(userId);
  if (local != null) return;
  try {
    await service.fetchRemoteProfile(userId).timeout(const Duration(seconds: 10));
  } on Object {
    // Offline ou servidor indisponível: o onboarding cuida disso.
  }
});

/// Ações da conta usadas pelas telas.
final accountActionsProvider = Provider<AccountActions>((ref) => AccountActions(ref));

class AccountActions {
  AccountActions(this._ref);

  final Ref _ref;

  Future<void> continueAsGuest() =>
      _ref.read(settingsDaoProvider).setValue(SyncKeys.guestMode, 'true');

  /// Salva o perfil no aparelho e tenta enviá-lo na hora (se offline, ele
  /// segue pendente e sobe na próxima sincronização).
  Future<void> saveProfile({
    required String userId,
    required String fullName,
    required int age,
    required String churchName,
  }) async {
    final db = _ref.read(appDatabaseProvider);
    await db.syncDao.saveProfile(userId: userId, fullName: fullName, age: age, churchName: churchName);
    // A saudação da tela "Hoje" usa o primeiro nome.
    await db.settingsDao.setValue(AppSettings.kUserName, fullName.trim().split(RegExp(r'\s+')).first);
    final service = _ref.read(syncServiceProvider);
    if (service != null) {
      unawaited(service.pushProfile(userId).catchError((Object _) {}));
    }
  }

  /// Envia o que estiver pendente, apaga do aparelho os dados da conta e sai.
  /// Retorna quantas alterações ficaram sem enviar (perdidas), se houver.
  Future<int> signOut() async {
    final repo = _ref.read(authRepositoryProvider);
    final service = _ref.read(syncServiceProvider);
    final user = repo?.currentUser;
    if (repo == null || service == null || user == null) return 0;
    final db = _ref.read(appDatabaseProvider);
    try {
      await service.sync(user.id).timeout(const Duration(seconds: 20));
    } on Object {
      // Offline: o que não subiu será descartado (o usuário confirmou antes).
    }
    final lost = await db.syncDao.countPending();
    // Encerra a sessão antes de limpar o aparelho, para nenhuma sincronização
    // automática rodar no meio da limpeza.
    try {
      await repo.signOut();
    } on AuthFailure {
      // Sem internet a sessão local é encerrada mesmo assim.
    }
    await service.detachUser();
    return lost;
  }
}

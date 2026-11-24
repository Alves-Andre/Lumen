import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/cloud/cloud_config.dart';

/// Erro de autenticação com mensagem pronta para o usuário.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Resultado do cadastro por e-mail.
enum SignUpResult {
  /// Conta criada e já conectada.
  signedIn,

  /// Conta criada; falta confirmar o e-mail (link enviado).
  confirmationSent,
}

/// Autenticação via Supabase Auth: e-mail/senha e Google.
///
/// O login com Google usa o fluxo OAuth do Supabase (PKCE), que funciona igual
/// no Android (navegador + deep link `lumen://login-callback`) e no Web App do
/// iPhone (redirecionamento de volta ao site). Não depende de SHA-1 nem de
/// client IDs específicos por plataforma, só do provedor Google configurado no
/// painel do Supabase.
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  User? get currentUser => _auth.currentUser;

  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  Future<void> signInWithGoogle() => _guard(() async {
        final launched = await _auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: CloudConfig.authRedirectUrl,
          // Na web, troca a página atual pelo login do Google e volta ao app.
          authScreenLaunchMode: LaunchMode.platformDefault,
          queryParams: const {'prompt': 'select_account'},
        );
        if (!launched) throw const AuthFailure('Não foi possível abrir o login do Google.');
      });

  Future<void> signInWithEmail({required String email, required String password}) =>
      _guard(() => _auth.signInWithPassword(email: email.trim(), password: password));

  Future<SignUpResult> signUpWithEmail({required String email, required String password}) => _guard(() async {
        final response = await _auth.signUp(
          email: email.trim(),
          password: password,
          emailRedirectTo: CloudConfig.authRedirectUrl,
        );
        // Com "Confirm email" ligado no Supabase, a sessão só existe após o clique no link.
        return response.session == null ? SignUpResult.confirmationSent : SignUpResult.signedIn;
      });

  /// Envia o e-mail com o link para criar uma nova senha. Ao abrir o link, o
  /// app recebe [AuthChangeEvent.passwordRecovery] e pede a nova senha.
  Future<void> sendPasswordReset(String email) =>
      _guard(() => _auth.resetPasswordForEmail(email.trim(), redirectTo: CloudConfig.authRedirectUrl));

  Future<void> updatePassword(String newPassword) =>
      _guard(() => _auth.updateUser(UserAttributes(password: newPassword)));

  Future<void> signOut() => _guard(() => _auth.signOut(scope: SignOutScope.local));

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthException catch (e) {
      throw AuthFailure(describeAuthError(e));
    } on AuthFailure {
      rethrow;
    } on Exception {
      throw const AuthFailure('Sem conexão com o servidor. Verifique a internet e tente de novo.');
    }
  }

  /// Traduz os erros do Supabase Auth para mensagens claras em português.
  static String describeAuthError(AuthException e) {
    switch (e.code) {
      case 'invalid_credentials':
        return 'E-mail ou senha incorretos.';
      case 'email_not_confirmed':
        return 'Confirme seu e-mail pelo link que enviamos antes de entrar.';
      case 'user_already_exists':
      case 'email_exists':
        return 'Já existe uma conta com este e-mail. Use "Entrar" ou "Esqueci minha senha".';
      case 'weak_password':
        return 'Senha fraca. Use pelo menos 6 caracteres, misturando letras e números.';
      case 'same_password':
        return 'A nova senha precisa ser diferente da atual.';
      case 'email_address_invalid':
      case 'validation_failed':
        return 'E-mail inválido.';
      case 'over_email_send_rate_limit':
      case 'over_request_rate_limit':
        return 'Muitas tentativas seguidas. Aguarde alguns minutos e tente de novo.';
      case 'signup_disabled':
        return 'Novos cadastros estão desativados no momento.';
      case 'user_banned':
        return 'Esta conta está bloqueada.';
      case 'otp_expired':
      case 'flow_state_expired':
        return 'O link expirou. Peça um novo.';
    }
    if (e is AuthRetryableFetchException) {
      return 'Sem conexão com o servidor. Verifique a internet e tente de novo.';
    }
    return 'Não foi possível concluir: ${e.message}';
  }
}

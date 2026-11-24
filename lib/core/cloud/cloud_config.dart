import 'package:flutter/foundation.dart';

/// Credenciais do Supabase, passadas na compilação (nunca versionadas):
///
///     flutter run --dart-define-from-file=supabase.json
///
/// com `supabase.json` (ignorado pelo git) contendo:
///
///     { "SUPABASE_URL": "https://xxxx.supabase.co", "SUPABASE_ANON_KEY": "eyJ..." }
///
/// A chave anon/publishable é pública por natureza (vai dentro do app); quem
/// protege os dados é o RLS do banco. Sem essas chaves o app funciona como
/// antes: 100% local, sem tela de login.
abstract final class CloudConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Deep link de retorno do login (Google, confirmação de e-mail e
  /// recuperação de senha) no Android/iOS. Cadastrado no AndroidManifest e em
  /// Authentication → URL Configuration → Redirect URLs no Supabase.
  static const String mobileRedirectUrl = 'lumen://login-callback';

  static bool get isConfigured => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Para onde o Supabase devolve o usuário depois do login: no navegador,
  /// o próprio endereço do Web App (sem rota/hash); no celular, o deep link.
  static String get authRedirectUrl {
    if (!kIsWeb) return mobileRedirectUrl;
    final base = Uri.base;
    return Uri(scheme: base.scheme, host: base.host, port: base.hasPort ? base.port : null, path: base.path)
        .toString();
  }
}

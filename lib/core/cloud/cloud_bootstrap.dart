import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'cloud_config.dart';

/// Inicializa o Supabase antes do `runApp`, sem depender de internet: a
/// sessão salva é lida do armazenamento local e renovada em segundo plano.
abstract final class CloudBootstrap {
  static bool _ready = false;

  /// `true` quando há credenciais e o cliente foi inicializado.
  static bool get isReady => _ready;

  static Future<void> init() async {
    if (!CloudConfig.isConfigured) return;
    try {
      await Supabase.initialize(
        url: CloudConfig.supabaseUrl,
        publishableKey: CloudConfig.supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce),
        debug: false,
        // Nunca segura a abertura do app: sem resposta a tempo, segue sem nuvem.
      ).timeout(const Duration(seconds: 8));
      _ready = true;
    } on Object catch (e) {
      // Sem a nuvem o app continua 100% funcional, só não sincroniza.
      debugPrint('Supabase indisponível: $e');
    }
  }
}

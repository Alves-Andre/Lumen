import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

import 'app/app.dart';
import 'core/cloud/cloud_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  // Login e sincronização (opcionais): sem as chaves do Supabase o app roda 100% local.
  await CloudBootstrap.init();
  runApp(const ProviderScope(child: DevocionalApp()));
}

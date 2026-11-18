import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/providers/app_providers.dart';
import '../core/router/app_router.dart';
import '../core/settings/app_settings.dart';
import '../core/theme/app_theme.dart';
import 'startup_gate.dart';

class DevocionalApp extends ConsumerWidget {
  const DevocionalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
        title: 'Lumen',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ref
            .watch(appSettingsProvider.select((s) => s.value?.themePreference ?? AppThemePreference.system))
            .themeMode,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        routerConfig: ref.watch(routerProvider),
        builder: (context, child) => StartupGate(child: child ?? const SizedBox.shrink()),
      );
}

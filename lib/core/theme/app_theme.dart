import 'package:material_ui/material_ui.dart';

import '../settings/app_settings.dart';
import 'duo_colors.dart';

/// Tema inspirado no Duolingo: tipografia pesada, superfícies brancas,
/// bordas de 2px e cantos generosos — sobre a paleta azul-marinho do app.
abstract final class AppTheme {
  static ThemeData light() => _build(DuoColors.light, Brightness.light);

  static ThemeData dark() => _build(DuoColors.dark, Brightness.dark);

  static ThemeData _build(DuoColors c, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: c.primary.fill,
      brightness: brightness,
      primary: c.primary.fill,
      onPrimary: c.primary.onFill,
      surface: c.background,
      onSurface: c.text,
      error: c.danger.fill,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: brightness);
    final text = base.textTheme.apply(bodyColor: c.text, displayColor: c.text);

    return base.copyWith(
      extensions: [c],
      scaffoldBackgroundColor: c.background,
      dividerColor: c.border,
      textTheme: text.copyWith(
        headlineMedium: text.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        headlineSmall: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.8),
        bodyMedium: text.bodyMedium?.copyWith(height: 1.4),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: c.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: c.text),
        shape: Border(bottom: BorderSide(color: c.border, width: 2)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.neutral.soft,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c.border, width: 2)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c.border, width: 2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c.primary.fill, width: 2)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.text,
        contentTextStyle: TextStyle(color: c.background, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.white : null),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.primary.fill : null),
      ),
    );
  }
}

/// Cores da área de leitura bíblica.
@immutable
class ReaderPalette {
  const ReaderPalette(this.background, this.text, this.verseNumber, this.highlight);

  final Color background;
  final Color text;
  final Color verseNumber;
  final Color highlight;

  static const _light = ReaderPalette(Color(0xFFFFFFFF), Color(0xFF1B2740), Color(0xFF2453C7), Color(0xFFE7EEFC));
  static const _sepia = ReaderPalette(Color(0xFFF4ECD8), Color(0xFF4A3B2A), Color(0xFFA0702A), Color(0xFFEADBB5));
  static const _dark = ReaderPalette(Color(0xFF0B1426), Color(0xFFDCE4F2), Color(0xFF6B97F2), Color(0xFF17284A));

  /// [brightness] é o brilho atual do app, usado por [ReaderTheme.auto].
  static ReaderPalette of(ReaderTheme theme, Brightness brightness) => switch (theme) {
        ReaderTheme.auto => brightness == Brightness.dark ? _dark : _light,
        ReaderTheme.light => _light,
        ReaderTheme.sepia => _sepia,
        ReaderTheme.dark => _dark,
      };
}

extension AppThemePreferenceMode on AppThemePreference {
  ThemeMode get themeMode => switch (this) {
        AppThemePreference.system => ThemeMode.system,
        AppThemePreference.light => ThemeMode.light,
        AppThemePreference.dark => ThemeMode.dark,
      };
}

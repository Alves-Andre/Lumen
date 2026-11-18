import '../database/enums.dart';

/// Aparência geral do app.
enum AppThemePreference {
  system('Sistema'),
  light('Claro'),
  dark('Escuro');

  const AppThemePreference(this.label);

  final String label;
}

/// Fundo da área de leitura bíblica. [auto] acompanha o tema do app.
enum ReaderTheme {
  auto('Auto'),
  light('Claro'),
  sepia('Sépia'),
  dark('Escuro');

  const ReaderTheme(this.label);

  final String label;
}

/// Preferências do usuário, persistidas em `app_settings_entries`.
class AppSettings {
  const AppSettings({
    this.userName = '',
    this.themePreference = AppThemePreference.system,
    this.translation = BibleTranslation.primary,
    this.readerFontSize = defaultFontSize,
    this.readerTheme = ReaderTheme.auto,
    this.reminderEnabled = false,
    this.reminderMinutes = 20 * 60,
    this.graceEnabled = true,
    this.memoryNotificationsEnabled = true,
  });

  static const double minFontSize = 14;
  static const double maxFontSize = 32;
  static const double defaultFontSize = 19;

  static const String kUserName = 'user_name';
  static const String kThemePreference = 'theme_preference';
  static const String kTranslation = 'bible_translation';
  static const String kReaderFontSize = 'reader_font_size';
  static const String kReaderTheme = 'reader_theme';
  static const String kReminderEnabled = 'reminder_enabled';
  static const String kReminderMinutes = 'reminder_minutes';
  static const String kGraceEnabled = 'grace_enabled';
  static const String kMemoryNotifications = 'memory_notifications';

  final String userName;
  final AppThemePreference themePreference;

  /// Versão usada na leitura (recitativos usam sempre a ARC).
  final BibleTranslation translation;
  final double readerFontSize;
  final ReaderTheme readerTheme;
  final bool reminderEnabled;

  /// Minutos desde a meia-noite (20:00 = 1200).
  final int reminderMinutes;
  final bool graceEnabled;
  final bool memoryNotificationsEnabled;

  int get reminderHour => reminderMinutes ~/ 60;
  int get reminderMinute => reminderMinutes % 60;

  String get reminderLabel =>
      '${reminderHour.toString().padLeft(2, '0')}:${reminderMinute.toString().padLeft(2, '0')}';

  factory AppSettings.fromMap(Map<String, String> map) {
    bool flag(String key, bool fallback) => map[key] == null ? fallback : map[key] == 'true';
    T byName<T extends Enum>(List<T> values, String key, T fallback) =>
        values.firstWhere((v) => v.name == map[key], orElse: () => fallback);
    return AppSettings(
      userName: map[kUserName] ?? '',
      themePreference: byName(AppThemePreference.values, kThemePreference, AppThemePreference.system),
      translation: BibleTranslation.fromName(map[kTranslation]),
      readerFontSize: (double.tryParse(map[kReaderFontSize] ?? '') ?? defaultFontSize)
          .clamp(minFontSize, maxFontSize)
          .toDouble(),
      readerTheme: byName(ReaderTheme.values, kReaderTheme, ReaderTheme.auto),
      reminderEnabled: flag(kReminderEnabled, false),
      reminderMinutes: (int.tryParse(map[kReminderMinutes] ?? '') ?? 20 * 60).clamp(0, 24 * 60 - 1),
      graceEnabled: flag(kGraceEnabled, true),
      memoryNotificationsEnabled: flag(kMemoryNotifications, true),
    );
  }
}

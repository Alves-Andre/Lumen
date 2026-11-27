import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/backup/backup_service.dart';
import '../../../../core/constants/bible_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/settings/app_settings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/duo_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/duo_button.dart';
import '../../../../core/widgets/duo_widgets.dart';
import '../../../reading_plan/presentation/providers/reading_plan_providers.dart';
import '../../../sync/presentation/account_section.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _name = TextEditingController();
  bool _nameLoaded = false;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _set(String key, String value) => ref.read(settingsDaoProvider).setValue(key, value);

  Future<void> _toggleReminder(bool on) async {
    if (on) {
      final granted = await ref.read(notificationServiceProvider).requestPermission();
      if (!granted) {
        if (mounted) showDuoSnack(context, 'Permita as notificações do app nas configurações do sistema.');
        return;
      }
    }
    await _set(AppSettings.kReminderEnabled, '$on');
  }

  Future<void> _pickTime(AppSettings s) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: s.reminderHour, minute: s.reminderMinute),
      helpText: 'Horário do lembrete',
    );
    if (picked != null) await _set(AppSettings.kReminderMinutes, '${picked.hour * 60 + picked.minute}');
  }

  Future<void> _newCycle() async {
    final ok = await confirmDialog(
      context,
      title: 'Iniciar novo ciclo?',
      message:
          'A contagem de capítulos volta a 0 de ${thousands(BibleConstants.totalChapters)}. '
          'Seu histórico de leituras e a ofensiva continuam guardados.',
      confirmLabel: 'Novo ciclo',
    );
    if (!ok) return;
    await ref.read(appDatabaseProvider).readingDao.startNewCycle();
    if (mounted) showDuoSnack(context, 'Novo ciclo de leitura iniciado. Boa leitura!');
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      await ref.read(backupServiceProvider).shareBackup();
    } on Exception catch (e) {
      if (mounted) showDuoSnack(context, 'Não foi possível exportar: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final ok = await confirmDialog(
      context,
      title: 'Importar backup?',
      message:
          'Leituras, recitativos, orações, anotações e preferências atuais serão SUBSTITUÍDOS '
          'pelos dados do arquivo. Esta ação não pode ser desfeita.',
      confirmLabel: 'Importar',
      destructive: true,
    );
    if (!ok) return;
    setState(() => _busy = true);
    try {
      final summary = await ref.read(backupServiceProvider).pickAndRestore();
      if (mounted && summary != null) showDuoSnack(context, 'Backup restaurado: ${summary.description}.');
    } on BackupException catch (e) {
      if (mounted) showDuoSnack(context, e.message);
    } on Exception catch (e) {
      if (mounted) showDuoSnack(context, 'Não foi possível importar: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    final settings = ref.watch(appSettingsProvider);
    final translations = ref.watch(availableTranslationsProvider).value ?? const <BibleTranslation>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: AsyncView<AppSettings>(
        value: settings,
        builder: (s) {
          if (!_nameLoaded) {
            _name.text = s.userName;
            _nameLoaded = true;
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const AccountSection(),
              const SectionTitle('Perfil'),
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Seu nome (para a saudação)'),
                onChanged: (v) => _set(AppSettings.kUserName, v.trim()),
              ),
              const SizedBox(height: 24),
              const SectionTitle('Aparência'),
              DuoSegmented<AppThemePreference>(
                segments: {for (final t in AppThemePreference.values) t: t.label},
                selected: s.themePreference,
                onChanged: (t) => _set(AppSettings.kThemePreference, t.name),
              ),
              const SizedBox(height: 24),
              const SectionTitle('Bíblia'),
              DuoCard(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                onTap: () => context.push(AppRoutes.translations),
                child: ListTile(
                  leading: DuoIconBadge(icon: Icons.menu_book_rounded, tone: c.primary, size: 40),
                  title: const Text('Traduções da Bíblia', style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(
                    '${translations.length} ${translations.length == 1 ? 'instalada' : 'instaladas'} · '
                    'leitura: ${ref.watch(readingTranslationProvider).abbrev} · '
                    'recitativos: ${ref.watch(primaryTranslationProvider).abbrev}',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ),
              const SizedBox(height: 24),
              // Notificações locais não existem no navegador (Web App).
              if (!kIsWeb) ...[
                const SectionTitle('Lembretes'),
                DuoCard(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: s.reminderEnabled,
                        onChanged: _toggleReminder,
                        secondary: DuoIconBadge(icon: Icons.alarm_rounded, tone: c.streak, size: 40),
                        title: const Text('Lembrete diário de leitura', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                      if (s.reminderEnabled)
                        ListTile(
                          leading: const SizedBox(width: 40),
                          title: const Text('Horário'),
                          trailing: Text(
                            s.reminderLabel,
                            style: TextStyle(fontWeight: FontWeight.w800, color: c.primary.fill, fontSize: 18),
                          ),
                          onTap: () => _pickTime(s),
                        ),
                      SwitchListTile(
                        value: s.memoryNotificationsEnabled,
                        onChanged: (v) => _set(AppSettings.kMemoryNotifications, '$v'),
                        secondary: DuoIconBadge(icon: Icons.auto_awesome_rounded, tone: c.gold, size: 40),
                        title: const Text('Lembranças de recitativos', style: TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: const Text('"Há 1 ano você recitou…" no aniversário do culto'),
                      ),
                    ],
                  ),
                ),
              ],
              const SectionTitle('Ofensiva'),
              DuoCard(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: SwitchListTile(
                  value: s.graceEnabled,
                  onChanged: (v) => _set(AppSettings.kGraceEnabled, '$v'),
                  secondary: DuoIconBadge(icon: Icons.shield_rounded, tone: c.grace, size: 40),
                  title: const Text('Escudos da ofensiva', style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: const Text(
                    'Ganhe 1 escudo a cada ${BibleConstants.shieldEarnEveryDays} dias seguidos de leitura. '
                    'Cada escudo protege a ofensiva em 1 dia sem leitura.',
                  ),
                ),
              ),
              const SectionTitle('Leitura'),
              DuoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Tamanho da letra: ${s.readerFontSize.round()}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Slider(
                      value: s.readerFontSize,
                      min: AppSettings.minFontSize,
                      max: AppSettings.maxFontSize,
                      divisions: (AppSettings.maxFontSize - AppSettings.minFontSize).round(),
                      onChanged: (v) => _set(AppSettings.kReaderFontSize, '${v.roundToDouble()}'),
                    ),
                    DuoSegmented<ReaderTheme>(
                      segments: {for (final t in ReaderTheme.values) t: t.label},
                      selected: s.readerTheme,
                      onChanged: (t) => _set(AppSettings.kReaderTheme, t.name),
                    ),
                    const SizedBox(height: 12),
                    Builder(
                      builder: (_) {
                        final p = ReaderPalette.of(s.readerTheme, Theme.of(context).brightness);
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: p.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: c.border, width: 2),
                          ),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '1 ',
                                  style: TextStyle(
                                    color: p.verseNumber,
                                    fontWeight: FontWeight.w800,
                                    fontSize: s.readerFontSize * 0.7,
                                  ),
                                ),
                                const TextSpan(text: 'No princípio, criou Deus os céus e a terra.'),
                              ],
                            ),
                            style: TextStyle(color: p.text, fontSize: s.readerFontSize, height: 1.6),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SectionTitle('Ciclos de leitura'),
              _CyclesCard(onNewCycle: _newCycle),
              const SectionTitle('Backup'),
              DuoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Guarde seus dados ao trocar de celular: leituras, recitativos, orações, anotações e preferências.',
                      style: TextStyle(color: c.textMuted, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    DuoButton(
                      label: 'Exportar backup (.json)',
                      icon: Icons.upload_rounded,
                      style: DuoButtonStyle.primary,
                      onPressed: _busy ? null : _export,
                    ),
                    const SizedBox(height: 12),
                    DuoButton(
                      label: 'Importar backup',
                      icon: Icons.download_rounded,
                      style: DuoButtonStyle.neutral,
                      onPressed: _busy ? null : _import,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Bíblia Sagrada — ${translations.map((t) => '${t.fullName} (${t.abbrev})').join(' · ')}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c.textFaint, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

class _CyclesCard extends ConsumerWidget {
  const _CyclesCard({required this.onNewCycle});

  final VoidCallback onNewCycle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = DuoColors.of(context);
    final cycles = ref.watch(readingCyclesProvider).value ?? const <ReadingCycle>[];
    final projection = ref.watch(readingProjectionProvider).value;
    final active = cycles.where((cy) => cy.endedAt == null).firstOrNull;
    final past = cycles.where((cy) => cy.endedAt != null).toList();

    return DuoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (active != null) ...[
            Text(
              'Ciclo atual',
              style: TextStyle(color: c.textMuted, fontWeight: FontWeight.w700, fontSize: 12),
            ),
            Text('Desde ${fullDate(active.startedAt)}', style: const TextStyle(fontWeight: FontWeight.w800)),
            if (projection != null) ...[
              const SizedBox(height: 10),
              DuoProgressBar(value: projection.progress),
              const SizedBox(height: 6),
              Text(
                '${thousands(projection.chaptersReadInCycle)} de ${thousands(projection.totalChapters)} capítulos',
                style: TextStyle(color: c.textMuted, fontWeight: FontWeight.w700),
              ),
            ],
            const SizedBox(height: 16),
          ],
          DuoButton(
            label: 'Iniciar novo ciclo',
            icon: Icons.restart_alt_rounded,
            style: DuoButtonStyle.neutral,
            onPressed: onNewCycle,
          ),
          if (past.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Ciclos anteriores',
              style: TextStyle(color: c.textMuted, fontWeight: FontWeight.w700, fontSize: 12),
            ),
            const SizedBox(height: 6),
            for (final cy in past)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.history_rounded, size: 18, color: c.textFaint),
                    const SizedBox(width: 8),
                    Text(
                      '${shortDate(cy.startedAt)} ${cy.startedAt.year} → ${shortDate(cy.endedAt!)} ${cy.endedAt!.year}',
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

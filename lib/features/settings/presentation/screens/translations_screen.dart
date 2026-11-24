import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/seed/bible_seed_service.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/settings/app_settings.dart';
import '../../../../core/theme/duo_colors.dart';
import '../../../../core/widgets/duo_button.dart';
import '../../../../core/widgets/duo_widgets.dart';
import '../../../bible/presentation/providers/bible_providers.dart';
import '../../../bible/presentation/widgets/bible_import.dart';

enum _Action { read, primary, replace, remove }

/// Configurações → Traduções da Bíblia: escolher a tradução de leitura e a
/// principal (recitativos), importar outras e remover as que não usa.
class TranslationsScreen extends ConsumerStatefulWidget {
  const TranslationsScreen({super.key});

  @override
  ConsumerState<TranslationsScreen> createState() => _TranslationsScreenState();
}

class _TranslationsScreenState extends ConsumerState<TranslationsScreen> {
  String? _removing;

  Future<void> _set(String key, String value) => ref.read(settingsDaoProvider).setValue(key, value);

  Future<void> _import(BibleTranslation? translation, {bool replace = false}) async {
    final imported = await showBibleImportSheet(context, translation: translation, replace: replace);
    if (imported != null && mounted) {
      showDuoSnack(context, '${imported.abbrev} ${replace ? 'substituída' : 'instalada'} com sucesso.');
    }
  }

  Future<void> _remove(BibleTranslation t) async {
    final ok = await confirmDialog(
      context,
      title: 'Remover a ${t.abbrev}?',
      message: 'O texto da ${t.fullName} sai deste aparelho (libera cerca de 5 MB). '
          'Suas leituras, anotações e recitativos não são afetados. Você pode importar de novo quando quiser.',
      confirmLabel: 'Remover',
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() => _removing = t.code);
    try {
      await ref.read(bibleSeedServiceProvider).removeTranslation(t);
      ref
        ..invalidate(availableTranslationsProvider)
        ..invalidate(allBooksProvider);
      if (mounted) showDuoSnack(context, '${t.abbrev} removida.');
    } on BibleSeedException catch (e) {
      if (mounted) showDuoSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _removing = null);
    }
  }

  Future<void> _onAction(BibleTranslation t, _Action action) async {
    switch (action) {
      case _Action.read:
        await _set(AppSettings.kTranslation, t.code);
      case _Action.primary:
        await _set(AppSettings.kPrimaryTranslation, t.code);
        if (mounted) showDuoSnack(context, 'Novos recitativos usarão a ${t.abbrev}.');
      case _Action.replace:
        await _import(t, replace: true);
      case _Action.remove:
        await _remove(t);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    final installed = ref.watch(availableTranslationsProvider).value ?? const <BibleTranslation>[];
    final reading = ref.watch(readingTranslationProvider);
    final primary = ref.watch(primaryTranslationProvider);
    final available = [
      for (final t in BibleTranslation.catalog)
        if (!installed.contains(t)) t,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Traduções da Bíblia')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'A tradução de leitura aparece no leitor e na busca (dá para trocar também pelo topo do leitor). '
            'A principal é usada no texto dos novos recitativos.',
            style: TextStyle(color: c.textMuted, height: 1.4),
          ),
          const SizedBox(height: 20),
          SectionTitle('Instaladas (${installed.length})'),
          DuoCard(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Column(
              children: [
                for (final t in installed)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    leading: DuoIconBadge(icon: Icons.menu_book_rounded, tone: c.success, size: 40),
                    title: Text('${t.abbrev} · ${t.fullName}', style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (t == reading) DuoChip(label: 'Leitura', tone: c.primary, icon: Icons.chrome_reader_mode_rounded),
                          if (t == primary) DuoChip(label: 'Recitativos', tone: c.gold, icon: Icons.record_voice_over_rounded),
                          if (t.isCustom) DuoChip(label: 'Personalizada', tone: c.neutral),
                          if (t != reading && t != primary && !t.isCustom)
                            Text('Instalada', style: TextStyle(color: c.textFaint, fontSize: 12)),
                        ],
                      ),
                    ),
                    trailing: _removing == t.code
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5))
                        : PopupMenuButton<_Action>(
                            tooltip: 'Opções da ${t.abbrev}',
                            onSelected: (a) => _onAction(t, a),
                            itemBuilder: (_) => [
                              if (t != reading)
                                const PopupMenuItem(value: _Action.read, child: Text('Usar na leitura')),
                              if (t != primary)
                                const PopupMenuItem(value: _Action.primary, child: Text('Usar nos recitativos')),
                              const PopupMenuItem(value: _Action.replace, child: Text('Substituir arquivo')),
                              if (installed.length > 1)
                                const PopupMenuItem(value: _Action.remove, child: Text('Remover do aparelho')),
                            ],
                          ),
                    onTap: t == reading ? null : () => _onAction(t, _Action.read),
                  ),
              ],
            ),
          ),
          if (available.isNotEmpty) ...[
            const SizedBox(height: 8),
            const SectionTitle('Disponíveis para importar'),
            DuoCard(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Column(
                children: [
                  for (final t in available)
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      leading: DuoIconBadge(icon: Icons.download_rounded, tone: c.primary, size: 40),
                      title: Text('${t.abbrev} · ${t.fullName}', style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text(
                        t.downloadUrl != null ? 'Com link de download' : 'Requer um arquivo próprio',
                        style: TextStyle(color: c.textFaint, fontSize: 12),
                      ),
                      trailing: TextButton(onPressed: () => _import(t), child: const Text('Importar')),
                      onTap: () => _import(t),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          DuoButton(
            label: 'Importar outra tradução',
            icon: Icons.add_rounded,
            style: DuoButtonStyle.neutral,
            onPressed: () => _import(null),
          ),
          const SizedBox(height: 12),
          Text(
            'Os textos bíblicos têm direitos autorais e por isso não vêm com o app: cada tradução é importada '
            'de um arquivo .json, uma única vez, e fica só neste aparelho.',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.textFaint, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/constants/bible_constants.dart';
import '../core/database/app_database.dart';
import '../core/providers/app_providers.dart';
import '../core/providers/database_providers.dart';
import '../core/theme/duo_colors.dart';
import '../core/widgets/duo_button.dart';
import '../core/widgets/duo_widgets.dart';
import '../features/bible/presentation/widgets/bible_import.dart';
import '../features/dashboard/presentation/providers/home_widget_sync.dart';

/// Segura o app até a ARC estar instalada; depois libera o [child] (router).
/// O app não embarca textos bíblicos: na primeira abertura o usuário importa o .json.
class StartupGate extends ConsumerWidget {
  const StartupGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installed = ref.watch(availableTranslationsProvider);
    final c = DuoColors.of(context);

    Widget centered(List<Widget> children) => Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(mainAxisSize: MainAxisSize.min, children: children),
              ),
            ),
          ),
        );

    return installed.when(
      data: (translations) {
        if (!translations.contains(BibleTranslation.primary)) return const _Welcome();
        // Agenda lembretes e atualiza o widget em segundo plano; falhas não bloqueiam o app.
        ref
          ..watch(notificationSyncProvider)
          ..watch(homeWidgetSyncProvider);
        return child;
      },
      loading: () => centered([
        Image.asset('assets/branding/lumen_mark.png', width: 120),
        const SizedBox(height: 16),
        Text('Lumen', style: Theme.of(context).textTheme.headlineMedium),
      ]),
      error: (error, _) => centered([
        DuoIconBadge(icon: Icons.error_outline_rounded, tone: c.danger, size: 88),
        const SizedBox(height: 24),
        Text(
          'Não foi possível abrir o banco de dados',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text('$error', textAlign: TextAlign.center, style: TextStyle(color: c.textMuted)),
        const SizedBox(height: 24),
        DuoButton(label: 'Tentar novamente', onPressed: () => ref.invalidate(availableTranslationsProvider)),
      ]),
    );
  }
}

/// Boas-vindas: importação da ARC (obrigatória) na primeira abertura.
class _Welcome extends StatelessWidget {
  const _Welcome();

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          children: [
            Center(child: Image.asset('assets/branding/lumen_mark.png', width: 110)),
            const SizedBox(height: 12),
            Text('Bem-vindo ao Lumen', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(
              'Por respeito aos direitos autorais das traduções, o Lumen não vem com o texto bíblico. '
              'Importe o arquivo da ${BibleTranslation.primary.fullName} uma única vez para começar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textMuted, height: 1.4),
            ),
            const SizedBox(height: 28),
            const BibleImportPanel(translation: BibleTranslation.primary),
            const SizedBox(height: 20),
            Text(
              'Os arquivos estão em ${BibleConstants.biblesSourcePage}. '
              'A NVI é opcional e pode ser importada depois, em Configurações.',
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textFaint, fontSize: 12, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

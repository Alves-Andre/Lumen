import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/constants/bible_constants.dart';
import '../core/database/app_database.dart';
import '../core/providers/app_providers.dart';
import '../core/providers/database_providers.dart';
import '../core/theme/duo_colors.dart';
import '../core/widgets/duo_button.dart';
import '../core/widgets/duo_widgets.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
import '../features/auth/presentation/screens/auth_screen.dart';
import '../features/auth/presentation/screens/new_password_screen.dart';
import '../features/auth/presentation/screens/onboarding_profile_screen.dart';
import '../features/bible/presentation/widgets/bible_import.dart';
import '../features/dashboard/presentation/providers/home_widget_sync.dart';
import '../features/sync/presentation/sync_controller.dart';

/// Segura o app até tudo estar pronto e então libera o [child] (router):
///
/// 1. com a nuvem configurada: nova senha (link de recuperação), login (ou
///    "continuar sem conta"), preparação da conta e perfil (onboarding);
/// 2. ao menos uma tradução da Bíblia instalada (o app não embarca textos
///    bíblicos: na primeira abertura o usuário escolhe e importa o .json).
///
/// Tudo é decidido com dados locais, então o app abre na hora mesmo offline;
/// só o primeiro login num aparelho novo consulta a nuvem (com limite de tempo).
class StartupGate extends ConsumerWidget {
  const StartupGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(cloudEnabledProvider)) {
      final blocker = _accountStep(ref);
      if (blocker != null) return blocker;
    }

    final installed = ref.watch(availableTranslationsProvider);
    final c = DuoColors.of(context);
    return installed.when(
      data: (translations) {
        if (translations.isEmpty) return const _Standalone(_Welcome());
        // Lembretes, widget e sincronização rodam em segundo plano; falhas não bloqueiam o app.
        ref
          ..watch(notificationSyncProvider)
          ..watch(homeWidgetSyncProvider)
          ..watch(syncControllerProvider);
        return child;
      },
      loading: () => const _Splash(),
      error: (error, _) => _Centered([
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

  /// Tela de conta que precisa aparecer antes do app, ou `null` se está tudo pronto.
  Widget? _accountStep(WidgetRef ref) {
    if (ref.watch(passwordRecoveryProvider)) return const _Standalone(NewPasswordScreen());

    final userAsync = ref.watch(authUserProvider);
    if (!userAsync.hasValue) return const _Splash();
    final user = userAsync.value;

    if (user == null) {
      final guest = ref.watch(guestModeProvider);
      if (!guest.hasValue) return const _Splash();
      return guest.value! ? null : const _Standalone(AuthScreen());
    }

    final setup = ref.watch(accountSetupProvider(user.id));
    if (setup.isLoading) return const _Splash(message: 'Preparando sua conta…');

    final profile = ref.watch(userProfileProvider(user.id));
    if (!profile.hasValue) return const _Splash();
    if (profile.value == null) {
      return _Standalone(OnboardingProfileScreen(userId: user.id, email: user.email));
    }
    return null;
  }
}

/// Tela fora do router com o próprio Navigator (para diálogos e teclado).
class _Standalone extends StatelessWidget {
  const _Standalone(this.screen);

  final Widget screen;

  @override
  Widget build(BuildContext context) => Navigator(
        pages: [MaterialPage<void>(child: screen)],
        onDidRemovePage: (_) {},
      );
}

class _Centered extends StatelessWidget {
  const _Centered(this.children);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisSize: MainAxisSize.min, children: children),
            ),
          ),
        ),
      );
}

class _Splash extends StatelessWidget {
  const _Splash({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) => _Centered([
        Image.asset('assets/branding/lumen_mark.png', width: 120),
        const SizedBox(height: 16),
        Text('Lumen', style: Theme.of(context).textTheme.headlineMedium),
        if (message != null) ...[
          const SizedBox(height: 12),
          Text(message!, style: TextStyle(color: DuoColors.of(context).textMuted)),
        ],
      ]);
}

/// Boas-vindas: escolha e importação da primeira tradução (ARC sugerida).
class _Welcome extends StatefulWidget {
  const _Welcome();

  @override
  State<_Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<_Welcome> {
  /// `null` = "Outra" (tradução personalizada).
  BibleTranslation? _choice = BibleTranslation.preferredPrimary;
  bool _custom = false;

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              children: [
                Center(child: Image.asset('assets/branding/lumen_mark.png', width: 110)),
                const SizedBox(height: 12),
                Text('Bem-vindo ao Lumen', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text(
                  'Por respeito aos direitos autorais das traduções, o Lumen não vem com o texto bíblico. '
                  'Escolha uma tradução e importe o arquivo uma única vez para começar. '
                  'Outras podem ser adicionadas depois, em Configurações.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c.textMuted, height: 1.4),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final t in BibleTranslation.catalog)
                      ChoiceChip(
                        label: Text(t.abbrev),
                        tooltip: t.fullName,
                        showCheckmark: false,
                        selected: !_custom && _choice == t,
                        onSelected: (_) => setState(() {
                          _choice = t;
                          _custom = false;
                        }),
                      ),
                    ChoiceChip(
                      label: const Text('Outra'),
                      showCheckmark: false,
                      selected: _custom,
                      onSelected: (_) => setState(() {
                        _choice = null;
                        _custom = true;
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _custom ? 'Tradução fora da lista' : _choice!.fullName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                if (_choice == BibleTranslation.preferredPrimary)
                  Text(
                    'Usada nos cultos da CCB e no texto dos recitativos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: c.textFaint, fontSize: 12),
                  ),
                const SizedBox(height: 20),
                // Uma chave por escolha: cada tradução começa com o painel limpo.
                BibleImportPanel(key: ValueKey(_custom ? 'custom' : _choice!.code), translation: _choice),
                const SizedBox(height: 20),
                Text(
                  'Os arquivos com link de download estão em ${BibleConstants.biblesSourcePage}.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c.textFaint, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

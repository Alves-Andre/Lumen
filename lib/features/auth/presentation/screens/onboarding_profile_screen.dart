import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/duo_colors.dart';
import '../../../../core/widgets/duo_button.dart';
import '../providers/auth_providers.dart';

/// Perfil básico (nome, idade e igreja), pedido uma única vez após o primeiro
/// login. Também usado para editar o perfil pelas Configurações ([existing]).
class OnboardingProfileScreen extends ConsumerStatefulWidget {
  const OnboardingProfileScreen({super.key, required this.userId, this.email, this.existing});

  final String userId;
  final String? email;

  /// Perfil atual (modo edição). `null` no primeiro acesso.
  final UserProfile? existing;

  @override
  ConsumerState<OnboardingProfileScreen> createState() => _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState extends ConsumerState<OnboardingProfileScreen> {
  static const String _other = 'Outra';

  /// Sugestões rápidas (toque) — "Outra" libera o campo para digitar.
  static const List<String> churchSuggestions = [
    'Congregação Cristã no Brasil (CCB)',
    'Assembleia de Deus',
    'Batista',
    'Presbiteriana',
    _other,
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _age;
  late final TextEditingController _church;
  final _churchFocus = FocusNode();
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _name = TextEditingController(text: p?.fullName ?? '');
    _age = TextEditingController(text: p == null || p.age <= 0 ? '' : '${p.age}');
    _church = TextEditingController(text: p?.churchName ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _church.dispose();
    _churchFocus.dispose();
    super.dispose();
  }

  void _pickChurch(String option) {
    if (option == _other) {
      _church.clear();
      _churchFocus.requestFocus();
    } else {
      _church.text = option;
      FocusScope.of(context).unfocus();
    }
    setState(() {});
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(accountActionsProvider).saveProfile(
            userId: widget.userId,
            fullName: _name.text,
            age: int.parse(_age.text.trim()),
            churchName: _church.text,
          );
      if (!mounted) return;
      if (_isEdit) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil atualizado.')));
        Navigator.of(context).pop();
      } else {
        // Primeiro acesso: a próxima tela é a "Hoje".
        ref.read(routerProvider).go(AppRoutes.today);
      }
    } on Object catch (e) {
      if (mounted) setState(() => _error = 'Não foi possível salvar: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _isEdit ? AppBar(title: const Text('Seu perfil')) : null,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                children: [
                  if (!_isEdit) ...[
                    Center(child: Image.asset('assets/branding/lumen_mark.png', width: 84)),
                    const SizedBox(height: 12),
                    Text('Conte um pouco sobre você', textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'Só três perguntas rápidas. Elas nos ajudam a conhecer quem usa o Lumen.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: c.textMuted, height: 1.4),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (widget.email != null) ...[
                    Text('Conta: ${widget.email}', style: TextStyle(color: c.textFaint, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: _name,
                    enabled: !_saving,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    maxLength: 120,
                    decoration: const InputDecoration(labelText: 'Nome', counterText: ''),
                    validator: (v) => (v?.trim().length ?? 0) < 2 ? 'Informe seu nome.' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _age,
                    enabled: !_saving,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
                    decoration: const InputDecoration(labelText: 'Idade'),
                    validator: (v) {
                      final age = int.tryParse(v?.trim() ?? '');
                      if (age == null) return 'Informe sua idade.';
                      if (age < 1 || age > 119) return 'Idade inválida.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _church,
                    focusNode: _churchFocus,
                    enabled: !_saving,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    maxLength: 120,
                    decoration: const InputDecoration(labelText: 'Igreja que frequenta', counterText: ''),
                    validator: (v) => (v?.trim().isEmpty ?? true) ? 'Informe sua igreja (ou toque numa sugestão).' : null,
                    onChanged: (_) => setState(() {}),
                    onFieldSubmitted: (_) => _save(),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final option in churchSuggestions)
                        ChoiceChip(
                          label: Text(option),
                          selected: option != _other && _church.text.trim() == option,
                          onSelected: _saving ? null : (_) => _pickChurch(option),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_error!, style: TextStyle(color: c.danger.fill, fontWeight: FontWeight.w700)),
                    ),
                  DuoButton(
                    label: _saving ? 'Salvando…' : (_isEdit ? 'Salvar' : 'Começar'),
                    icon: _isEdit ? Icons.check_rounded : Icons.arrow_forward_rounded,
                    onPressed: _saving ? null : _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rota "/perfil": carrega o perfil atual e abre a edição.
class EditProfileRoute extends ConsumerWidget {
  const EditProfileRoute({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider).value;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && context.canPop()) context.pop();
      });
      return const Scaffold();
    }
    final profile = ref.watch(userProfileProvider(user.id));
    return profile.when(
      data: (p) => OnboardingProfileScreen(userId: user.id, email: user.email, existing: p),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(appBar: AppBar(), body: Center(child: Text('$e'))),
    );
  }
}

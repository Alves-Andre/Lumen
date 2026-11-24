import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/duo_colors.dart';
import '../../../../core/widgets/duo_button.dart';
import '../../../../core/widgets/duo_widgets.dart';
import '../../data/auth_repository.dart';
import '../providers/auth_providers.dart';

enum _AuthMode { signIn, signUp, forgot }

/// Login: Google ou e-mail/senha (com cadastro e recuperação de senha).
///
/// [linkMode]: aberta pelas Configurações para vincular a uma conta os dados
/// criados sem login; fecha sozinha quando o login acontece.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key, this.linkMode = false});

  final bool linkMode;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  _AuthMode _mode = _AuthMode.signIn;
  bool _busy = false;
  bool _showPassword = false;
  String? _error;
  String? _info;

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  AuthRepository get _repo => ref.read(authRepositoryProvider)!;

  void _setMode(_AuthMode mode) => setState(() {
        _mode = mode;
        _error = null;
        _info = null;
      });

  Future<void> _run(Future<void> Function() action) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    try {
      await action();
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _google() => _run(() async {
        await _repo.signInWithGoogle();
        if (mounted && !kIsWeb) {
          setState(() => _info = 'Conclua o login no navegador. Você voltará ao Lumen automaticamente.');
        }
      });

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    switch (_mode) {
      case _AuthMode.signIn:
        await _run(() => _repo.signInWithEmail(email: _email.text, password: _password.text));
      case _AuthMode.signUp:
        await _run(() async {
          final result = await _repo.signUpWithEmail(email: _email.text, password: _password.text);
          if (result == SignUpResult.confirmationSent && mounted) {
            setState(() {
              _mode = _AuthMode.signIn;
              _info = 'Conta criada! Enviamos um link de confirmação para ${_email.text.trim()}. '
                  'Abra o e-mail neste aparelho e depois entre com sua senha.';
            });
          }
        });
      case _AuthMode.forgot:
        await _run(() async {
          await _repo.sendPasswordReset(_email.text);
          if (mounted) {
            setState(() {
              _mode = _AuthMode.signIn;
              _info = 'Se houver uma conta com ${_email.text.trim()}, você receberá um link para criar uma nova senha. '
                  'Abra-o neste aparelho.';
            });
          }
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    final theme = Theme.of(context);

    // Vinculação concluída: volta para as Configurações. (A tela pode ser
    // reconstruída já com o usuário conectado, depois do onboarding.)
    if (widget.linkMode && ref.watch(authUserProvider).value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
      });
    }

    final title = switch (_mode) {
      _AuthMode.signIn => 'Entrar',
      _AuthMode.signUp => 'Criar conta',
      _AuthMode.forgot => 'Recuperar senha',
    };

    return Scaffold(
      appBar: widget.linkMode ? AppBar(title: const Text('Entrar ou criar conta')) : null,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              children: [
                if (!widget.linkMode) ...[
                  Center(child: Image.asset('assets/branding/lumen_mark.png', width: 96)),
                  const SizedBox(height: 12),
                  Text('Bem-vindo ao Lumen', textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                ],
                Text(
                  widget.linkMode
                      ? 'O que você já registrou neste aparelho será guardado na sua conta e continuará aqui.'
                      : 'Entre para guardar sua leitura, recitativos e orações na nuvem e recuperá-los em qualquer aparelho.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c.textMuted, height: 1.4),
                ),
                const SizedBox(height: 24),
                if (_mode != _AuthMode.forgot) ...[
                  DuoButton(
                    label: 'Continuar com Google',
                    icon: Icons.g_mobiledata_rounded,
                    style: DuoButtonStyle.neutral,
                    onPressed: _busy ? null : _google,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: Divider(color: c.border, thickness: 2)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('ou com e-mail', style: TextStyle(color: c.textFaint, fontWeight: FontWeight.w700)),
                      ),
                      Expanded(child: Divider(color: c.border, thickness: 2)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DuoSegmented<_AuthMode>(
                    segments: const {_AuthMode.signIn: 'Entrar', _AuthMode.signUp: 'Criar conta'},
                    selected: _mode,
                    onChanged: _busy ? (_) {} : _setMode,
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  Text(title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(
                    'Informe o e-mail da sua conta. Enviaremos um link para você criar uma nova senha.',
                    style: TextStyle(color: c.textMuted),
                  ),
                  const SizedBox(height: 16),
                ],
                Form(
                  key: _formKey,
                  child: AutofillGroup(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _email,
                          enabled: !_busy,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          autocorrect: false,
                          textInputAction: _mode == _AuthMode.forgot ? TextInputAction.done : TextInputAction.next,
                          decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.mail_outline_rounded)),
                          validator: (v) {
                            final value = v?.trim() ?? '';
                            if (value.isEmpty) return 'Informe seu e-mail.';
                            if (!_emailPattern.hasMatch(value)) return 'E-mail inválido. Ex.: nome@gmail.com';
                            return null;
                          },
                          onFieldSubmitted: _mode == _AuthMode.forgot ? (_) => _submit() : null,
                        ),
                        if (_mode != _AuthMode.forgot) ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _password,
                            enabled: !_busy,
                            obscureText: !_showPassword,
                            autofillHints: [
                              _mode == _AuthMode.signUp ? AutofillHints.newPassword : AutofillHints.password,
                            ],
                            textInputAction: _mode == _AuthMode.signUp ? TextInputAction.next : TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                tooltip: _showPassword ? 'Ocultar senha' : 'Mostrar senha',
                                icon: Icon(_showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                                onPressed: () => setState(() => _showPassword = !_showPassword),
                              ),
                            ),
                            validator: (v) {
                              final value = v ?? '';
                              if (value.isEmpty) return 'Informe sua senha.';
                              if (_mode == _AuthMode.signUp && value.length < 6) {
                                return 'A senha precisa ter pelo menos 6 caracteres.';
                              }
                              return null;
                            },
                            onFieldSubmitted: _mode == _AuthMode.signIn ? (_) => _submit() : null,
                          ),
                        ],
                        if (_mode == _AuthMode.signUp) ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _confirm,
                            enabled: !_busy,
                            obscureText: !_showPassword,
                            autofillHints: const [AutofillHints.newPassword],
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              labelText: 'Confirme a senha',
                              prefixIcon: Icon(Icons.lock_outline_rounded),
                            ),
                            validator: (v) => v != _password.text ? 'As senhas não conferem.' : null,
                            onFieldSubmitted: (_) => _submit(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_error != null) _Message(text: _error!, tone: c.danger, icon: Icons.error_outline_rounded),
                if (_info != null) _Message(text: _info!, tone: c.primary, icon: Icons.mark_email_read_outlined),
                DuoButton(
                  label: switch (_mode) {
                    _AuthMode.signIn => _busy ? 'Entrando…' : 'Entrar',
                    _AuthMode.signUp => _busy ? 'Criando conta…' : 'Criar conta',
                    _AuthMode.forgot => _busy ? 'Enviando…' : 'Enviar link',
                  },
                  onPressed: _busy ? null : _submit,
                ),
                const SizedBox(height: 8),
                if (_mode == _AuthMode.signIn)
                  TextButton(
                    onPressed: _busy ? null : () => _setMode(_AuthMode.forgot),
                    child: const Text('Esqueci minha senha'),
                  )
                else if (_mode == _AuthMode.forgot)
                  TextButton(
                    onPressed: _busy ? null : () => _setMode(_AuthMode.signIn),
                    child: const Text('Voltar para o login'),
                  ),
                if (!widget.linkMode) ...[
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: _busy ? null : () => ref.read(accountActionsProvider).continueAsGuest(),
                    style: TextButton.styleFrom(foregroundColor: c.textFaint),
                    child: const Text(
                      'Continuar sem conta (apenas neste aparelho)',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text(
                    'Você pode criar a conta depois, em Configurações, sem perder nada.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: c.textFaint, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, required this.tone, required this.icon});

  final String text;
  final DuoTone tone;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: tone.soft, borderRadius: BorderRadius.circular(12)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: tone.fill, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: TextStyle(color: tone.fill, fontWeight: FontWeight.w700, height: 1.35))),
          ],
        ),
      );
}

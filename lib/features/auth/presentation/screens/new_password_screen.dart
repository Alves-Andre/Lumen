import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/duo_colors.dart';
import '../../../../core/widgets/duo_button.dart';
import '../../data/auth_repository.dart';
import '../providers/auth_providers.dart';

/// Aberta pelo link "Esqueci minha senha": define a nova senha.
class NewPasswordScreen extends ConsumerStatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  ConsumerState<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends ConsumerState<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider)!.updatePassword(_password.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Senha alterada com sucesso.')));
      ref.read(passwordRecoveryProvider.notifier).finish();
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                shrinkWrap: true,
                children: [
                  Text('Crie uma nova senha', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    enabled: !_busy,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: const InputDecoration(labelText: 'Nova senha'),
                    validator: (v) => (v?.length ?? 0) < 6 ? 'A senha precisa ter pelo menos 6 caracteres.' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirm,
                    obscureText: true,
                    enabled: !_busy,
                    decoration: const InputDecoration(labelText: 'Confirme a nova senha'),
                    validator: (v) => v != _password.text ? 'As senhas não conferem.' : null,
                    onFieldSubmitted: (_) => _save(),
                  ),
                  const SizedBox(height: 16),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_error!, style: TextStyle(color: c.danger.fill, fontWeight: FontWeight.w700)),
                    ),
                  DuoButton(label: _busy ? 'Salvando…' : 'Salvar nova senha', onPressed: _busy ? null : _save),
                  TextButton(
                    onPressed: _busy ? null : () => ref.read(passwordRecoveryProvider.notifier).finish(),
                    child: const Text('Agora não'),
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

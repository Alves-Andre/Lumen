import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/providers/database_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/duo_colors.dart';
import '../../../core/widgets/duo_button.dart';
import '../../../core/widgets/duo_widgets.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import 'sync_controller.dart';

/// Seção "Conta e sincronização" das Configurações. Some quando o app roda
/// sem nuvem configurada.
class AccountSection extends ConsumerWidget {
  const AccountSection({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final pending = await ref.read(appDatabaseProvider).syncDao.countPending();
    if (!context.mounted) return;
    final ok = await confirmDialog(
      context,
      title: 'Sair da conta?',
      message: pending > 0
          ? 'Ainda há $pending ${pending == 1 ? 'alteração não enviada' : 'alterações não enviadas'}. '
              'Vamos tentar enviar agora; o que não subir (sem internet) será perdido.\n\n'
              'Seus dados serão removidos deste aparelho e voltam quando você entrar de novo.'
          : 'Seus dados estão salvos na nuvem. Eles serão removidos deste aparelho e voltam quando você entrar de novo.',
      confirmLabel: 'Sair',
      destructive: true,
    );
    if (!ok) return;
    final lost = await ref.read(accountActionsProvider).signOut();
    if (lost > 0 && context.mounted) {
      showDuoSnack(context, '$lost ${lost == 1 ? 'alteração não pôde ser enviada' : 'alterações não puderam ser enviadas'}.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(cloudEnabledProvider)) return const SizedBox.shrink();
    final c = DuoColors.of(context);
    final user = ref.watch(authUserProvider).value;
    final sync = ref.watch(syncControllerProvider);

    if (user == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionTitle('Conta'),
            DuoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      DuoIconBadge(icon: Icons.cloud_off_rounded, tone: c.primary, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Você está usando o Lumen sem conta. Seus dados ficam só neste aparelho.',
                          style: TextStyle(color: c.textMuted, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DuoButton(
                    label: 'Entrar ou criar conta',
                    icon: Icons.cloud_upload_rounded,
                    onPressed: () => context.push(AppRoutes.account),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ao entrar, tudo o que você já registrou é guardado na conta.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: c.textFaint, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final profile = ref.watch(userProfileProvider(user.id)).value;
    final tone = switch (sync.phase) {
      SyncPhase.error => c.danger,
      SyncPhase.offline => c.streak,
      _ => c.success,
    };
    final icon = switch (sync.phase) {
      SyncPhase.syncing => Icons.sync_rounded,
      SyncPhase.offline => Icons.cloud_off_rounded,
      SyncPhase.error => Icons.sync_problem_rounded,
      _ => sync.pending > 0 ? Icons.cloud_upload_rounded : Icons.cloud_done_rounded,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionTitle('Conta e sincronização'),
          DuoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    DuoIconBadge(icon: Icons.person_rounded, tone: c.primary, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(profile?.fullName ?? 'Sua conta', style: const TextStyle(fontWeight: FontWeight.w800)),
                          if (user.email != null) Text(user.email!, style: TextStyle(color: c.textMuted)),
                          if (profile != null)
                            Text(profile.churchName, style: TextStyle(color: c.textFaint, fontSize: 12)),
                        ],
                      ),
                    ),
                    TextButton(onPressed: () => context.push(AppRoutes.profile), child: const Text('Editar')),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: tone.soft, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Icon(icon, color: tone.fill),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(sync.label, style: TextStyle(color: tone.fill, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                DuoButton(
                  label: sync.phase == SyncPhase.syncing ? 'Sincronizando…' : 'Sincronizar agora',
                  icon: Icons.sync_rounded,
                  style: DuoButtonStyle.neutral,
                  onPressed: sync.phase == SyncPhase.syncing
                      ? null
                      : () => ref.read(syncControllerProvider.notifier).syncNow(),
                ),
                const SizedBox(height: 8),
                DuoButtonLite(label: 'Sair da conta', destructive: true, onPressed: () => _signOut(context, ref)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

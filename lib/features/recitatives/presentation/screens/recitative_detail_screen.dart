import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/duo_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/duo_button.dart';
import '../../../../core/widgets/duo_widgets.dart';
import '../../../../core/widgets/text_input_sheet.dart';
import '../providers/recitatives_providers.dart';

class RecitativeDetailScreen extends ConsumerWidget {
  const RecitativeDetailScreen({super.key, required this.id});

  final String id;

  Future<void> _markRecited(BuildContext context, WidgetRef ref, Recitative r) async {
    final notes = await showTextInputSheet(
      context,
      title: 'Como foi o culto?',
      subtitle: 'Registre um resumo da palavra pregada ou sua experiência (opcional).',
      initialText: r.notes ?? '',
      hint: 'Deus falou sobre…',
      confirmLabel: 'Marcar como recitado',
    );
    if (notes == null) return;
    await ref.read(appDatabaseProvider).recitativesDao.markAsRecited(r.id, notes: notes);
    if (context.mounted) showDuoSnack(context, 'Recitativo guardado no histórico. Glória a Deus!');
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await confirmDialog(
      context,
      title: 'Excluir recitativo?',
      message: 'Este recitativo será apagado do seu histórico.',
      confirmLabel: 'Excluir',
      destructive: true,
    );
    if (!ok) return;
    await ref.read(appDatabaseProvider).recitativesDao.deleteRecitative(id);
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = DuoColors.of(context);
    final item = ref.watch(recitativeByIdProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recitativo'),
        actions: [
          IconButton(
            tooltip: 'Editar',
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => context.push(AppRoutes.editRecitative(id)),
          ),
          IconButton(
            tooltip: 'Excluir',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _delete(context, ref),
          ),
        ],
      ),
      body: AsyncView<RecitativeWithBook?>(
        value: item,
        builder: (data) {
          if (data == null) return const Center(child: Text('Recitativo não encontrado.'));
          final r = data.recitative;
          final pending = r.status == RecitativeStatus.pending;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DuoCard(
                color: c.gold.soft,
                borderColor: c.gold.shadow,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(data.reference, style: Theme.of(context).textTheme.headlineSmall),
                        ),
                        DuoChip(label: r.status.label, tone: pending ? c.primary : c.success),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '“${r.verseTextSnapshot}”',
                      style: const TextStyle(fontSize: 20, height: 1.6, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 8),
                    Text('Almeida Revista e Corrigida', style: TextStyle(color: c.textMuted, fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              _InfoRow(icon: Icons.event_rounded, tone: c.primary, label: 'Culto', value: '${fullDate(r.serviceDate)} (${relativeDay(r.serviceDate)})'),
              if (r.congregation != null)
                _InfoRow(icon: Icons.church_rounded, tone: c.primary, label: 'Comum congregação', value: r.congregation!),
              if (r.notes != null)
                _InfoRow(icon: Icons.notes_rounded, tone: c.success, label: 'Observações', value: r.notes!),
              const SizedBox(height: 8),
              DuoButton(
                label: 'Treinar memorização',
                icon: Icons.psychology_rounded,
                style: DuoButtonStyle.gold,
                onPressed: () => context.push(AppRoutes.train(id)),
              ),
              const SizedBox(height: 12),
              if (pending)
                DuoButton(
                  label: 'Marcar como recitado',
                  icon: Icons.check_rounded,
                  style: DuoButtonStyle.success,
                  onPressed: () => _markRecited(context, ref, r),
                )
              else
                DuoButton(
                  label: 'Voltar para "A recitar"',
                  style: DuoButtonStyle.neutral,
                  onPressed: () => ref.read(appDatabaseProvider).recitativesDao.markAsPending(id),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.tone, required this.label, required this.value});

  final IconData icon;
  final DuoTone tone;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    return DuoCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DuoIconBadge(icon: icon, tone: tone, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: c.textMuted, fontWeight: FontWeight.w700, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w700, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

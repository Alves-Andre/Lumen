import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/theme/duo_colors.dart';
import '../../../../core/utils/day_utils.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/duo_button.dart';
import '../../../../core/widgets/duo_widgets.dart';
import '../../../../core/widgets/text_input_sheet.dart';

DuoTone categoryTone(DuoColors c, PrayerCategory category) => switch (category) {
      PrayerCategory.family => c.streak,
      PrayerCategory.church => c.primary,
      PrayerCategory.personal => c.success,
      PrayerCategory.intercession => c.danger,
      PrayerCategory.gratitude => c.gold,
    };

IconData categoryIcon(PrayerCategory category) => switch (category) {
      PrayerCategory.family => Icons.family_restroom_rounded,
      PrayerCategory.church => Icons.church_rounded,
      PrayerCategory.personal => Icons.person_rounded,
      PrayerCategory.intercession => Icons.diversity_1_rounded,
      PrayerCategory.gratitude => Icons.favorite_rounded,
    };

/// Formulário de pedido de oração (novo ou edição).
Future<void> showPrayerForm(BuildContext context, {PrayerRequest? existing}) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PrayerForm(existing: existing),
    );

class _PrayerForm extends ConsumerStatefulWidget {
  const _PrayerForm({this.existing});

  final PrayerRequest? existing;

  @override
  ConsumerState<_PrayerForm> createState() => _PrayerFormState();
}

class _PrayerFormState extends ConsumerState<_PrayerForm> {
  late final _title = TextEditingController(text: widget.existing?.title ?? '');
  late final _description = TextEditingController(text: widget.existing?.description ?? '');
  late PrayerCategory _category = widget.existing?.category ?? PrayerCategory.personal;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final dao = ref.read(appDatabaseProvider).prayerDao;
    if (widget.existing == null) {
      await dao.createRequest(title: _title.text, description: _description.text, category: _category);
    } else {
      await dao.updateRequest(
        id: widget.existing!.id,
        title: _title.text,
        description: _description.text,
        category: _category,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing == null ? 'Novo pedido de oração' : 'Editar pedido',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _title,
              autofocus: widget.existing == null,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Pelo que você vai orar?'),
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              controller: _description,
              minLines: 2,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Detalhes (opcional)'),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final cat in PrayerCategory.values)
                  ChoiceChip(
                    avatar: Icon(categoryIcon(cat), size: 18, color: categoryTone(c, cat).fill),
                    label: Text(cat.label, style: const TextStyle(fontWeight: FontWeight.w800)),
                    selected: _category == cat,
                    showCheckmark: false,
                    selectedColor: categoryTone(c, cat).soft,
                    side: BorderSide(color: _category == cat ? categoryTone(c, cat).fill : c.border, width: 2),
                    onSelected: (_) => setState(() => _category = cat),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            DuoButton(
              label: 'Salvar pedido',
              style: DuoButtonStyle.success,
              onPressed: _title.text.trim().isEmpty ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}

class PrayerCard extends ConsumerWidget {
  const PrayerCard({super.key, required this.request});

  final PrayerRequest request;

  Future<void> _markAnswered(BuildContext context, WidgetRef ref) async {
    final testimony = await showTextInputSheet(
      context,
      title: 'Oração respondida! 🙌',
      subtitle: request.title,
      label: 'Testemunho (opcional)',
      hint: 'Como Deus respondeu?',
      confirmLabel: 'Glória a Deus!',
      confirmStyle: DuoButtonStyle.gold,
    );
    if (testimony == null) return;
    await ref.read(appDatabaseProvider).prayerDao.markAnswered(request.id, testimony: testimony);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = DuoColors.of(context);
    final tone = categoryTone(c, request.category);
    final answered = request.status == PrayerStatus.answered;
    final prayedToday = request.lastPrayedAt != null && isSameDay(request.lastPrayedAt!, DateTime.now());
    final dao = ref.read(appDatabaseProvider).prayerDao;

    return DuoCard(
      color: answered ? c.gold.soft : null,
      borderColor: answered ? c.gold.shadow : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DuoIconBadge(icon: categoryIcon(request.category), tone: tone, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 4),
                    DuoChip(label: request.category.label, tone: tone),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Mais opções',
                onSelected: (action) async {
                  switch (action) {
                    case 'edit':
                      await showPrayerForm(context, existing: request);
                    case 'answered':
                      await _markAnswered(context, ref);
                    case 'reopen':
                      await dao.reopen(request.id);
                    case 'delete':
                      final ok = await confirmDialog(
                        context,
                        title: 'Excluir pedido?',
                        message: '"${request.title}" será apagado.',
                        confirmLabel: 'Excluir',
                        destructive: true,
                      );
                      if (ok) await dao.deleteRequest(request.id);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  if (!answered) const PopupMenuItem(value: 'answered', child: Text('Marcar como respondida')),
                  if (answered) const PopupMenuItem(value: 'reopen', child: Text('Voltar a orar')),
                  const PopupMenuItem(value: 'delete', child: Text('Excluir')),
                ],
              ),
            ],
          ),
          if (request.description != null) ...[
            const SizedBox(height: 10),
            Text(request.description!, style: TextStyle(color: c.textMuted, height: 1.4)),
          ],
          if (answered && request.answerTestimony != null) ...[
            const SizedBox(height: 12),
            Text('Testemunho', style: TextStyle(fontWeight: FontWeight.w800, color: c.gold.shadow, fontSize: 12)),
            const SizedBox(height: 4),
            Text('“${request.answerTestimony}”', style: const TextStyle(fontStyle: FontStyle.italic, height: 1.4)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.favorite_rounded, size: 16, color: c.danger.fill),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  answered && request.answeredAt != null
                      ? 'Orou ${request.prayCount}× · respondida em ${shortDate(request.answeredAt!)}'
                      : request.lastPrayedAt == null
                          ? 'Ainda não orou por este pedido'
                          : 'Orou ${request.prayCount}× · última vez ${relativeDay(request.lastPrayedAt!)}',
                  style: TextStyle(color: c.textMuted, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            ],
          ),
          if (!answered) ...[
            const SizedBox(height: 12),
            DuoButton(
              label: prayedToday ? 'Orou hoje ✓' : 'Orei hoje (+1)',
              style: DuoButtonStyle.success,
              compact: true,
              icon: prayedToday ? null : Icons.volunteer_activism_rounded,
              onPressed: prayedToday
                  ? null
                  : () async {
                      HapticFeedback.lightImpact();
                      await dao.registerPrayer(request.id);
                    },
            ),
          ],
        ],
      ),
    );
  }
}

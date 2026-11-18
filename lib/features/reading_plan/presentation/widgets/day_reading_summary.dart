import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/duo_colors.dart';
import '../../../../core/widgets/duo_widgets.dart';
import '../providers/reading_plan_providers.dart';

/// "Neste dia você leu: Gênesis 1-3, Salmos 23" + devocionais do dia.
class DayReadingSummary extends ConsumerWidget {
  const DayReadingSummary({super.key, required this.day, this.protectedByShield = false});

  final DateTime day;
  final bool protectedByShield;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = DuoColors.of(context);
    final logs = ref.watch(logsOnDayProvider(day));
    final notes = ref.watch(notesOnDayProvider(day)).value ?? const <VerseNoteWithBook>[];

    return AsyncView<List<ReadingLogWithBook>>(
      value: logs,
      builder: (items) {
        final groups = groupLogsByBook(items);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (protectedByShield)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DuoChip(label: 'Ofensiva protegida por escudo', tone: c.grace, icon: Icons.shield_rounded),
              ),
            if (groups.isEmpty)
              Text('Nenhuma leitura registrada neste dia.', style: TextStyle(color: c.textMuted))
            else ...[
              Text('Neste dia você leu:', style: TextStyle(color: c.textMuted, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final g in groups)
                    ActionChip(
                      avatar: Icon(
                        switch (g.source) {
                          ReadingSource.app => Icons.phone_android_rounded,
                          ReadingSource.physicalBible => Icons.menu_book_rounded,
                          null => Icons.devices_rounded,
                        },
                        size: 16,
                        color: c.success.fill,
                      ),
                      label: Text(g.label, style: const TextStyle(fontWeight: FontWeight.w800)),
                      side: BorderSide(color: c.border, width: 2),
                      onPressed: () => _openGroup(context, g),
                    ),
                ],
              ),
            ],
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.edit_note_rounded, color: c.gold.fill, size: 20),
                  const SizedBox(width: 6),
                  Text('Devocional', style: TextStyle(color: c.textMuted, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 8),
              for (final n in notes)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: c.gold.soft, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.reference, style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(n.note.content, maxLines: 4, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _openGroup(BuildContext context, ReadingDayGroup group) => showModalBottomSheet<void>(
        context: context,
        builder: (_) => _GroupSheet(group: group),
      );
}

/// Capítulos de um livro lidos no dia: abrir a leitura ou desmarcar.
class _GroupSheet extends ConsumerWidget {
  const _GroupSheet({required this.group});

  final ReadingDayGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = DuoColors.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(group.label, style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final log in group.logs)
                    ListTile(
                      leading: Icon(
                        log.source == ReadingSource.app ? Icons.phone_android_rounded : Icons.menu_book_rounded,
                        color: c.success.fill,
                      ),
                      title: Text('${group.book.name} ${log.chapter}', style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text(log.source.label),
                      onTap: () {
                        Navigator.pop(context);
                        context.push(AppRoutes.reader(group.book.id, log.chapter));
                      },
                      trailing: IconButton(
                        tooltip: 'Desmarcar leitura',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () async {
                          final ok = await confirmDialog(
                            context,
                            title: 'Desmarcar ${group.book.name} ${log.chapter}?',
                            message: 'O registro de leitura deste dia será removido.',
                            confirmLabel: 'Desmarcar',
                            destructive: true,
                          );
                          if (!ok) return;
                          await ref.read(appDatabaseProvider).readingDao.deleteLog(log.id);
                          if (context.mounted) Navigator.pop(context);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

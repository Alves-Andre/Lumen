import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/duo_colors.dart';
import '../../../../core/widgets/duo_widgets.dart';
import '../../../reading_plan/presentation/providers/reading_plan_providers.dart';
import '../providers/bible_providers.dart';

/// Grid numérico de capítulos de um livro.
class ChapterGridScreen extends ConsumerWidget {
  const ChapterGridScreen({super.key, required this.bookId});

  final int bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = DuoColors.of(context);
    final book = ref.watch(bookProvider(bookId));
    final read = ref.watch(readChaptersOfBookProvider(bookId)).value ?? const <int>{};

    return Scaffold(
      appBar: AppBar(title: Text(book.value?.name ?? '')),
      body: AsyncView(
        value: book,
        builder: (b) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '${read.length} de ${b.chaptersCount} capítulos lidos neste ciclo',
              style: TextStyle(fontWeight: FontWeight.w800, color: c.textMuted),
            ),
            const SizedBox(height: 10),
            DuoProgressBar(value: read.length / b.chaptersCount),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 64,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: b.chaptersCount,
              itemBuilder: (_, i) {
                final chapter = i + 1;
                final done = read.contains(chapter);
                return Semantics(
                  button: true,
                  label: 'Capítulo $chapter${done ? ', lido' : ''}',
                  child: GestureDetector(
                    onTap: () => context.push(AppRoutes.reader(bookId, chapter)),
                    child: DuoTile(
                      alignment: Alignment.center,
                      color: done ? c.success.fill : c.card,
                      borderColor: done ? c.success.fill : c.border,
                      shadowColor: done ? c.success.shadow : c.border,
                      child: Text(
                        '$chapter',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: done ? c.success.onFill : c.text,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

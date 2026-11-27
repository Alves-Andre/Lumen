import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/settings/app_settings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/duo_colors.dart';
import '../../../../core/widgets/duo_button.dart';
import '../../../../core/widgets/duo_widgets.dart';
import '../../../reading_plan/presentation/providers/reading_plan_providers.dart';
import '../providers/bible_providers.dart';

/// Aba 2 — seletor de livros da Bíblia.
class BibleBooksScreen extends ConsumerStatefulWidget {
  const BibleBooksScreen({super.key});

  @override
  ConsumerState<BibleBooksScreen> createState() => _BibleBooksScreenState();
}

class _BibleBooksScreenState extends ConsumerState<BibleBooksScreen> {
  String _testament = 'AT';

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(allBooksProvider);
    final counts = ref.watch(readCountsPerBookProvider).value ?? const {};
    final target = ref.watch(continueReadingProvider).value;
    final translation = ref.watch(readingTranslationProvider);
    final translations = ref.watch(availableTranslationsProvider).value ?? const <BibleTranslation>[];

    return Scaffold(
      appBar: AppBar(
        title: translations.length > 1
            ? PopupMenuButton<BibleTranslation>(
                tooltip: 'Versão da Bíblia',
                initialValue: translation,
                onSelected: (t) => ref.read(settingsDaoProvider).setValue(AppSettings.kTranslation, t.code),
                itemBuilder: (_) => [
                  for (final t in translations)
                    PopupMenuItem(value: t, child: Text('${t.abbrev} · ${t.fullName}')),
                ],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Bíblia ${translation.abbrev}'),
                    const Icon(Icons.arrow_drop_down_rounded),
                  ],
                ),
              )
            : Text('Bíblia ${translation.abbrev}'),
        actions: [
          IconButton(
            tooltip: 'Buscar na Bíblia',
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push(AppRoutes.search),
          ),
          IconButton(
            tooltip: 'Registrar leitura retroativa / Bíblia física',
            icon: const Icon(Icons.edit_calendar_rounded),
            onPressed: () => context.push(AppRoutes.retroactive),
          ),
        ],
      ),
      body: AsyncView<List<Book>>(
        value: books,
        builder: (all) {
          final visible = all.where((b) => b.testament == _testament).toList();
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverList.list(children: [
                  if (target != null)
                    DuoButton(
                      label: 'Continuar: ${target.label}',
                      style: DuoButtonStyle.success,
                      icon: Icons.play_arrow_rounded,
                      onPressed: () => context.push(AppRoutes.reader(target.book.id, target.chapter)),
                    ),
                  const SizedBox(height: 8),
                  DuoButton(
                    label: 'Planos de leitura',
                    style: DuoButtonStyle.neutral,
                    icon: Icons.event_note_rounded,
                    onPressed: () => context.push(AppRoutes.plans),
                  ),
                  const SizedBox(height: 8),
                  DuoButton(
                    label: 'Li na Bíblia física / outra data',
                    style: DuoButtonStyle.neutral,
                    icon: Icons.edit_calendar_rounded,
                    onPressed: () => context.push(AppRoutes.retroactive),
                  ),
                  const SizedBox(height: 16),
                  DuoSegmented<String>(
                    segments: const {'AT': 'Antigo Testamento', 'NT': 'Novo Testamento'},
                    selected: _testament,
                    onChanged: (v) => setState(() => _testament = v),
                  ),
                  const SizedBox(height: 16),
                ]),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 130,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: visible.length,
                  itemBuilder: (_, i) => _BookTile(book: visible[i], readCount: counts[visible[i].id] ?? 0),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BookTile extends StatelessWidget {
  const _BookTile({required this.book, required this.readCount});

  final Book book;
  final int readCount;

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    final done = readCount >= book.chaptersCount;
    return DuoCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(10),
      color: done ? c.success.soft : null,
      borderColor: done ? c.success.fill : null,
      onTap: () => context.go(AppRoutes.book(book.id)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  book.abbrev,
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                    color: done ? c.success.fill : c.primary.fill,
                  ),
                ),
              ),
              if (done) Icon(Icons.check_circle_rounded, color: c.success.fill, size: 18),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            book.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.textMuted),
          ),
          const SizedBox(height: 8),
          DuoProgressBar(value: readCount / book.chaptersCount, height: 8),
          const SizedBox(height: 4),
          Text('$readCount/${book.chaptersCount}', style: TextStyle(fontSize: 11, color: c.textFaint, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

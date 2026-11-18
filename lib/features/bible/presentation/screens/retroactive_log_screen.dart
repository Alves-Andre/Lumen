import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/theme/duo_colors.dart';
import '../../../../core/utils/day_utils.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/duo_button.dart';
import '../../../../core/widgets/duo_widgets.dart';
import '../providers/bible_providers.dart';

/// Registro de leitura em data passada / na Bíblia física: vários capítulos,
/// de um ou mais livros, num mesmo dia.
class RetroactiveLogScreen extends ConsumerStatefulWidget {
  const RetroactiveLogScreen({super.key});

  @override
  ConsumerState<RetroactiveLogScreen> createState() => _RetroactiveLogScreenState();
}

class _RetroactiveLogScreenState extends ConsumerState<RetroactiveLogScreen> {
  DateTime _date = dateOnly(DateTime.now());
  int _bookId = 1;
  ReadingSource _source = ReadingSource.physicalBible;
  final Set<ChapterRef> _selected = {};
  bool _saving = false;

  Future<void> _save(Map<int, Book> books) async {
    setState(() => _saving = true);
    final ordered = _selected.toList()
      ..sort((a, b) => a.bookId != b.bookId ? a.bookId.compareTo(b.bookId) : a.chapter.compareTo(b.chapter));
    // Meio-dia do dia escolhido: evita ambiguidades de fuso na virada do dia.
    final readAt = DateTime(_date.year, _date.month, _date.day, 12);
    final inserted = await ref
        .read(appDatabaseProvider)
        .readingDao
        .logChapters(ordered, readAt: readAt, source: _source);
    if (!mounted) return;
    final skipped = ordered.length - inserted;
    showDuoSnack(
      context,
      '$inserted ${inserted == 1 ? 'capítulo registrado' : 'capítulos registrados'} em ${shortDate(_date)}'
      '${skipped > 0 ? ' ($skipped já estavam registrados)' : ''}.',
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    final books = ref.watch(allBooksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Leitura retroativa')),
      body: AsyncView<List<Book>>(
        value: books,
        builder: (all) {
          final byId = {for (final b in all) b.id: b};
          final book = byId[_bookId]!;
          final selectedLabels = (_selected.toList()
                ..sort((a, b) => a.bookId != b.bookId ? a.bookId.compareTo(b.bookId) : a.chapter.compareTo(b.chapter)))
              .map((r) => '${byId[r.bookId]!.abbrev} ${r.chapter}')
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SectionTitle('Quando você leu?'),
              DuoCard(
                padding: const EdgeInsets.all(4),
                child: CalendarDatePicker(
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: dateOnly(DateTime.now()),
                  onDateChanged: (d) => setState(() => _date = dateOnly(d)),
                ),
              ),
              const SectionTitle('Onde?'),
              DuoSegmented<ReadingSource>(
                segments: {for (final s in ReadingSource.values) s: s.label},
                selected: _source,
                onChanged: (s) => setState(() => _source = s),
              ),
              const SizedBox(height: 20),
              const SectionTitle('O que você leu?'),
              DropdownMenu<int>(
                initialSelection: _bookId,
                expandedInsets: EdgeInsets.zero,
                enableFilter: true,
                requestFocusOnTap: true,
                label: const Text('Livro'),
                menuHeight: 360,
                dropdownMenuEntries: [
                  for (final b in all) DropdownMenuEntry(value: b.id, label: b.name),
                ],
                onSelected: (id) {
                  if (id != null) setState(() => _bookId = id);
                },
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var ch = 1; ch <= book.chaptersCount; ch++)
                    FilterChip(
                      label: Text('$ch', style: const TextStyle(fontWeight: FontWeight.w800)),
                      selected: _selected.contains((bookId: book.id, chapter: ch)),
                      selectedColor: c.success.soft,
                      checkmarkColor: c.success.fill,
                      side: BorderSide(color: c.border, width: 2),
                      onSelected: (on) => setState(() {
                        final chapterRef = (bookId: book.id, chapter: ch);
                        on ? _selected.add(chapterRef) : _selected.remove(chapterRef);
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              if (selectedLabels.isNotEmpty)
                DuoCard(
                  color: c.success.soft,
                  borderColor: c.success.fill,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${selectedLabels.length} selecionados · ${fullDate(_date)}',
                        style: TextStyle(fontWeight: FontWeight.w800, color: c.success.fill),
                      ),
                      const SizedBox(height: 6),
                      Text(selectedLabels.join(', ')),
                    ],
                  ),
                ),
              DuoButton(
                label: _saving ? 'Registrando…' : 'Registrar leitura',
                style: DuoButtonStyle.success,
                icon: Icons.check_rounded,
                onPressed: _selected.isEmpty || _saving ? null : () => _save(byId),
              ),
            ],
          );
        },
      ),
    );
  }
}

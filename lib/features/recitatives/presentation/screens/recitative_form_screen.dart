import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/duo_colors.dart';
import '../../../../core/utils/bible_reference.dart';
import '../../../../core/utils/day_utils.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/duo_button.dart';
import '../../../../core/widgets/duo_widgets.dart';
import '../../../bible/presentation/providers/bible_providers.dart';

/// Cadastro/edição de recitativo. O texto vem automaticamente da ARC.
class RecitativeFormScreen extends ConsumerStatefulWidget {
  const RecitativeFormScreen({
    super.key,
    this.editId,
    this.initialBookId,
    this.initialChapter,
    this.initialVerse,
  });

  final String? editId;
  final int? initialBookId;
  final int? initialChapter;
  final int? initialVerse;

  @override
  ConsumerState<RecitativeFormScreen> createState() => _RecitativeFormScreenState();
}

class _RecitativeFormScreenState extends ConsumerState<RecitativeFormScreen> {
  late int _bookId = widget.initialBookId ?? 45;
  late int _chapter = widget.initialChapter ?? 1;
  late int _verseStart = widget.initialVerse ?? 1;
  int? _verseEnd;
  DateTime _serviceDate = dateOnly(DateTime.now());
  final _congregation = TextEditingController();
  final _notes = TextEditingController();
  bool _loaded = false;
  bool _saving = false;

  bool get _isEdit => widget.editId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _loadExisting();
    } else {
      _loaded = true;
    }
  }

  Future<void> _loadExisting() async {
    final item = await ref.read(appDatabaseProvider).recitativesDao.getById(widget.editId!);
    if (!mounted || item == null) return;
    final r = item.recitative;
    setState(() {
      _bookId = r.bookId;
      _chapter = r.chapter;
      _verseStart = r.verseStart;
      _verseEnd = r.verseEnd;
      _serviceDate = r.serviceDate;
      _congregation.text = r.congregation ?? '';
      _notes.text = r.notes ?? '';
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _congregation.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _serviceDate,
      firstDate: DateTime(1990),
      lastDate: DateTime(DateTime.now().year + 5),
      helpText: 'Data do culto',
    );
    if (picked != null) setState(() => _serviceDate = picked);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final dao = ref.read(appDatabaseProvider).recitativesDao;
    try {
      if (_isEdit) {
        await dao.updateRecitative(
          id: widget.editId!,
          bookId: _bookId,
          chapter: _chapter,
          verseStart: _verseStart,
          verseEnd: _verseEnd,
          serviceDate: _serviceDate,
          congregation: _congregation.text,
          notes: _notes.text,
        );
        if (mounted) context.pop();
      } else {
        final id = await dao.createRecitative(
          bookId: _bookId,
          chapter: _chapter,
          verseStart: _verseStart,
          verseEnd: _verseEnd,
          serviceDate: _serviceDate,
          congregation: _congregation.text,
          notes: _notes.text,
        );
        if (mounted) context.pushReplacement(AppRoutes.recitative(id));
      }
    } on ArgumentError catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showDuoSnack(context, '${e.message}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    final books = ref.watch(allBooksProvider);
    final verseCount = ref.watch(arcVerseCountProvider((bookId: _bookId, chapter: _chapter))).value ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Editar recitativo' : 'Novo recitativo')),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : AsyncView<List<Book>>(
              value: books,
              builder: (all) {
                final book = all.firstWhere((b) => b.id == _bookId);
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SectionTitle('Referência'),
                    DropdownMenu<int>(
                      initialSelection: _bookId,
                      expandedInsets: EdgeInsets.zero,
                      enableFilter: true,
                      requestFocusOnTap: true,
                      label: const Text('Livro'),
                      menuHeight: 360,
                      dropdownMenuEntries: [for (final b in all) DropdownMenuEntry(value: b.id, label: b.name)],
                      onSelected: (id) {
                        if (id == null) return;
                        setState(() {
                          _bookId = id;
                          _chapter = 1;
                          _verseStart = 1;
                          _verseEnd = null;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _NumberDropdown(
                            label: 'Capítulo',
                            value: _chapter,
                            max: book.chaptersCount,
                            onChanged: (v) => setState(() {
                              _chapter = v;
                              _verseStart = 1;
                              _verseEnd = null;
                            }),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _NumberDropdown(
                            label: 'Versículo',
                            value: verseCount == 0 ? null : _verseStart.clamp(1, verseCount),
                            max: verseCount,
                            onChanged: (v) => setState(() {
                              _verseStart = v;
                              if (_verseEnd != null && _verseEnd! <= v) _verseEnd = null;
                            }),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<int?>(
                            initialValue: _verseEnd,
                            key: ValueKey('end-$_bookId-$_chapter-$_verseStart'),
                            decoration: const InputDecoration(labelText: 'Até'),
                            items: [
                              const DropdownMenuItem<int?>(value: null, child: Text('—')),
                              for (var v = _verseStart + 1; v <= verseCount; v++)
                                DropdownMenuItem<int?>(value: v, child: Text('$v')),
                            ],
                            onChanged: (v) => setState(() => _verseEnd = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _PassagePreview(
                      reference: formatReference(book.name, _chapter, _verseStart, _verseEnd),
                      bookId: _bookId,
                      chapter: _chapter,
                      verseStart: _verseStart,
                      verseEnd: _verseEnd,
                    ),
                    const SectionTitle('Culto'),
                    DuoCard(
                      onTap: _pickDate,
                      child: Row(
                        children: [
                          DuoIconBadge(icon: Icons.event_rounded, tone: c.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Data do culto', style: TextStyle(color: c.textMuted, fontWeight: FontWeight.w700, fontSize: 12)),
                                Text(fullDate(_serviceDate), style: const TextStyle(fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: c.textFaint),
                        ],
                      ),
                    ),
                    TextField(
                      controller: _congregation,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Comum congregação (opcional)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notes,
                      minLines: 3,
                      maxLines: 8,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Observações (opcional)',
                        hintText: 'Resumo da palavra pregada ou experiência',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 24),
                    DuoButton(
                      label: _saving ? 'Salvando…' : 'Salvar recitativo',
                      style: DuoButtonStyle.gold,
                      onPressed: _saving || verseCount == 0 ? null : _save,
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _NumberDropdown extends StatelessWidget {
  const _NumberDropdown({required this.label, required this.value, required this.max, required this.onChanged});

  final String label;
  final int? value;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<int>(
        key: ValueKey('$label-$max-$value'),
        initialValue: value,
        menuMaxHeight: 360,
        decoration: InputDecoration(labelText: label),
        items: [for (var i = 1; i <= max; i++) DropdownMenuItem(value: i, child: Text('$i'))],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      );
}

/// Texto exato da ARC para a referência escolhida.
class _PassagePreview extends ConsumerWidget {
  const _PassagePreview({
    required this.reference,
    required this.bookId,
    required this.chapter,
    required this.verseStart,
    required this.verseEnd,
  });

  final String reference;
  final int bookId;
  final int chapter;
  final int verseStart;
  final int? verseEnd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = DuoColors.of(context);
    return FutureBuilder<String>(
      key: ValueKey('$bookId-$chapter-$verseStart-$verseEnd'),
      future: ref
          .read(appDatabaseProvider)
          .bibleDao
          .getPassageText(BibleTranslation.primary, bookId, chapter, verseStart, verseEnd),
      builder: (context, snap) => DuoCard(
        color: c.gold.soft,
        borderColor: c.gold.shadow,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reference, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              snap.data == null ? 'Carregando texto…' : '“${snap.data}”',
              style: const TextStyle(fontStyle: FontStyle.italic, height: 1.5, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Texto da ${BibleTranslation.primary.fullName} — versão usada nos recitativos',
              style: TextStyle(color: c.textMuted, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

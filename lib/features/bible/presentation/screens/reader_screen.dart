import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/bible_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/settings/app_settings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/duo_colors.dart';
import '../../../../core/utils/bible_reference.dart';
import '../../../../core/widgets/duo_button.dart';
import '../../../../core/widgets/duo_widgets.dart';
import '../../../devotions/presentation/widgets/note_editor_sheet.dart';
import '../../../reading_plan/presentation/providers/plan_providers.dart';
import '../../../reading_plan/presentation/providers/reading_plan_providers.dart';
import '../providers/bible_providers.dart';
import '../widgets/chapter_complete_dialog.dart';

/// Leitura de um capítulo na versão escolhida.
class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({
    super.key,
    required this.bookId,
    required this.chapter,
    this.continueSession = false,
    this.highlightVerse,
    this.planMode = false,
  });

  final int bookId;
  final int chapter;

  /// Chegou por "Próximo"/"Anterior": mantém os capítulos já lidos na sessão.
  final bool continueSession;

  /// Versículo a destacar e trazer para a tela (vindo da busca).
  final int? highlightVerse;

  /// Leitura guiada pelo plano ativo: "Concluir e ir para" segue a leitura do dia.
  final bool planMode;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  late int? _selectedVerse = widget.highlightVerse;
  bool _saving = false;
  final _highlightKey = GlobalKey();
  bool _scrolledToHighlight = false;

  ChapterRef get _ref => (bookId: widget.bookId, chapter: widget.chapter);

  @override
  void initState() {
    super.initState();
    if (!widget.continueSession) {
      // Nova sessão de leitura. Fora do build: o Riverpod não permite alterar estado durante o build.
      Future.microtask(() => ref.read(readingSessionProvider.notifier).reset());
    }
  }

  Future<void> _updateSetting(String key, String value) => ref.read(settingsDaoProvider).setValue(key, value);

  ChapterRef? _neighbor(List<Book> books, {required bool next}) {
    final book = books.firstWhere((b) => b.id == widget.bookId);
    if (next) {
      if (widget.chapter < book.chaptersCount) return (bookId: book.id, chapter: widget.chapter + 1);
      if (book.id < BibleConstants.lastBookId) return (bookId: book.id + 1, chapter: 1);
      return null;
    }
    if (widget.chapter > 1) return (bookId: book.id, chapter: widget.chapter - 1);
    if (book.id > BibleConstants.firstBookId) {
      final prev = books.firstWhere((b) => b.id == book.id - 1);
      return (bookId: prev.id, chapter: prev.chaptersCount);
    }
    return null;
  }

  void _goTo(ChapterRef target) => context.pushReplacement(
    AppRoutes.reader(target.bookId, target.chapter, continueSession: true, plan: widget.planMode),
  );

  /// Rola até o versículo destacado uma única vez, depois que o capítulo é desenhado.
  void _scrollToHighlightOnce() {
    if (_scrolledToHighlight || widget.highlightVerse == null) return;
    _scrolledToHighlight = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _highlightKey.currentContext;
      if (target != null) {
        Scrollable.ensureVisible(target, alignment: 0.3, duration: const Duration(milliseconds: 350));
      }
    });
  }

  /// Registra o capítulo atual e o soma à sessão. Retorna `false` se já estava registrado hoje.
  Future<bool> _markRead(Book book) async {
    final inserted = await ref
        .read(appDatabaseProvider)
        .readingDao
        .logChapter(bookId: book.id, chapter: widget.chapter, readAt: DateTime.now());
    ref.read(readingSessionProvider.notifier).add(_ref);
    return inserted;
  }

  /// Registra e segue para o próximo capítulo, sem interromper a leitura.
  Future<void> _completeAndNext(Book book, ChapterRef next) async {
    setState(() => _saving = true);
    final inserted = await _markRead(book);
    if (!mounted) return;
    HapticFeedback.lightImpact();
    showDuoSnack(
      context,
      inserted
          ? '✓ ${book.name} ${widget.chapter} registrado'
          : '${book.name} ${widget.chapter} já estava registrado hoje',
      duration: const Duration(milliseconds: 1500),
    );
    _goTo(next);
  }

  /// Registra o capítulo atual e encerra a sessão com a comemoração.
  Future<void> _completeAndStop(Book book, List<Book> books) async {
    setState(() => _saving = true);
    await _markRead(book);
    final session = ref.read(readingSessionProvider);
    final streak = await ref.read(streakServiceProvider).compute();
    final projection = await ref.read(readingProjectionServiceProvider).compute();
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    await showReadingSummary(
      context,
      summary: describeSession(session, {for (final b in books) b.id: b}),
      chapterCount: session.length,
      streakDays: streak.currentStreak,
      chaptersRead: projection.chaptersReadInCycle,
      totalChapters: projection.totalChapters,
    );
    ref.read(readingSessionProvider.notifier).reset();
    if (mounted) context.pop();
  }

  Future<void> _openVerseActions(Book book, Verse verse) async {
    setState(() => _selectedVerse = verse.verse);
    final reference = formatReference(book.name, verse.chapter, verse.verse);
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => _VerseActionsSheet(
        reference: reference,
        text: verse.verseText,
        onCopy: () async {
          final abbrev = ref.read(readingTranslationProvider).abbrev;
          await Clipboard.setData(ClipboardData(text: '“${verse.verseText}” — $reference ($abbrev)'));
          if (sheetContext.mounted) Navigator.pop(sheetContext);
          if (mounted) showDuoSnack(context, 'Versículo copiado.');
        },
        onNote: () {
          Navigator.pop(sheetContext);
          showNoteEditor(context, reference: reference, bookId: book.id, chapter: verse.chapter, verse: verse.verse);
        },
        onRecitative: () {
          Navigator.pop(sheetContext);
          context.push(AppRoutes.newRecitativeFrom(bookId: book.id, chapter: verse.chapter, verse: verse.verse));
        },
      ),
    );
    if (mounted) setState(() => _selectedVerse = null);
  }

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    final settings = ref.watch(appSettingsProvider).value ?? const AppSettings();
    final palette = ReaderPalette.of(settings.readerTheme, Theme.of(context).brightness);
    final books = ref.watch(allBooksProvider).value;
    final verses = ref.watch(chapterVersesProvider(_ref));
    final notes = ref.watch(chapterNotesProvider(_ref)).value ?? const <VerseNote>[];
    final book = books?.firstWhere((b) => b.id == widget.bookId);
    final planProgress = widget.planMode ? ref.watch(planProgressProvider).value : null;
    final next = widget.planMode
        ? planProgress?.nextAfter(_ref)
        : (books == null ? null : _neighbor(books, next: true));
    final prev = books == null ? null : _neighbor(books, next: false);
    final notedVerses = {for (final n in notes) ?n.verse};
    final fontSize = settings.readerFontSize;
    final translation = ref.watch(readingTranslationProvider);
    final translations = ref.watch(availableTranslationsProvider).value ?? const [BibleTranslation.primary];

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        foregroundColor: palette.text,
        centerTitle: false,
        shape: Border(bottom: BorderSide(color: palette.text.withValues(alpha: 0.12), width: 2)),
        title: GestureDetector(
          onTap: () => context.go(AppRoutes.book(widget.bookId)),
          child: Text(
            book == null ? '' : '${book.name} ${widget.chapter}',
            style: TextStyle(color: palette.text, fontWeight: FontWeight.w800),
          ),
        ),
        actions: [
          if (translations.length > 1)
            PopupMenuButton<BibleTranslation>(
              tooltip: 'Versão da Bíblia',
              initialValue: translation,
              onSelected: (t) => _updateSetting(AppSettings.kTranslation, t.name),
              itemBuilder: (_) => [
                for (final t in translations)
                  PopupMenuItem(
                    value: t,
                    child: Text('${t.abbrev} · ${t.fullName}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
              ],
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: palette.verseNumber, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  translation.abbrev,
                  style: TextStyle(color: palette.verseNumber, fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Diminuir fonte',
            icon: Text(
              'A−',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: palette.text.withValues(alpha: fontSize <= AppSettings.minFontSize ? 0.3 : 1),
              ),
            ),
            onPressed: fontSize <= AppSettings.minFontSize
                ? null
                : () => _updateSetting(AppSettings.kReaderFontSize, '${fontSize - 1}'),
          ),
          IconButton(
            tooltip: 'Aumentar fonte',
            icon: Text(
              'A+',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: palette.text.withValues(alpha: fontSize >= AppSettings.maxFontSize ? 0.3 : 1),
              ),
            ),
            onPressed: fontSize >= AppSettings.maxFontSize
                ? null
                : () => _updateSetting(AppSettings.kReaderFontSize, '${fontSize + 1}'),
          ),
          PopupMenuButton<ReaderTheme>(
            tooltip: 'Tema de leitura',
            icon: Icon(Icons.palette_outlined, color: palette.text),
            initialValue: settings.readerTheme,
            onSelected: (t) => _updateSetting(AppSettings.kReaderTheme, t.name),
            itemBuilder: (_) => [
              for (final t in ReaderTheme.values)
                PopupMenuItem(
                  value: t,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: ReaderPalette.of(t, Theme.of(context).brightness).background,
                      ),
                      const SizedBox(width: 12),
                      Text(t.label),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      // Botões e anotações seguem o fundo da leitura (ex.: sépia claro com o app em modo escuro).
      body: Theme(
        data: palette.background.computeLuminance() > 0.4 ? AppTheme.light() : AppTheme.dark(),
        child: AsyncView<List<Verse>>(
          value: verses,
          builder: (list) {
            if (book == null) return const SizedBox.shrink();
            _scrollToHighlightOnce();
            // Coluna (e não ListView): todos os versículos existem, então dá para rolar até o destacado.
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Capítulo ${widget.chapter}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: palette.text, fontSize: fontSize + 8, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 20),
                  for (final v in list)
                    InkWell(
                      key: v.verse == widget.highlightVerse ? _highlightKey : null,
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _openVerseActions(book, v),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                        decoration: BoxDecoration(
                          color: _selectedVerse == v.verse ? palette.highlight : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${v.verse} ',
                                style: TextStyle(
                                  color: palette.verseNumber,
                                  fontWeight: FontWeight.w800,
                                  fontSize: fontSize * 0.7,
                                ),
                              ),
                              TextSpan(text: v.verseText),
                              if (notedVerses.contains(v.verse))
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: Icon(Icons.sticky_note_2_rounded, size: fontSize * 0.85, color: c.gold.fill),
                                  ),
                                ),
                            ],
                          ),
                          style: TextStyle(color: palette.text, fontSize: fontSize, height: 1.6),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  if (notes.isNotEmpty) ...[
                    Text(
                      'Suas anotações',
                      style: TextStyle(color: palette.text, fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    for (final n in notes) NoteTile(note: n, reference: formatReference(book.name, n.chapter, n.verse)),
                  ],
                  TextButton.icon(
                    onPressed: () => showNoteEditor(
                      context,
                      reference: '${book.name} ${widget.chapter}',
                      bookId: book.id,
                      chapter: widget.chapter,
                    ),
                    icon: Icon(Icons.edit_note_rounded, color: palette.verseNumber),
                    label: Text(
                      'Anotar sobre este capítulo',
                      style: TextStyle(color: palette.verseNumber, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (next != null) ...[
                    DuoButton(
                      label: _saving
                          ? 'Registrando…'
                          : 'Concluir e ir para ${books!.firstWhere((b) => b.id == next.bookId).name} ${next.chapter}',
                      style: DuoButtonStyle.success,
                      icon: Icons.arrow_forward_rounded,
                      onPressed: _saving ? null : () => _completeAndNext(book, next),
                    ),
                    const SizedBox(height: 12),
                  ],
                  DuoButton(
                    label: next != null
                        ? 'Concluir e parar'
                        : widget.planMode
                        ? 'Concluir a leitura de hoje'
                        : 'Concluir a leitura',
                    style: next == null ? DuoButtonStyle.success : DuoButtonStyle.neutral,
                    icon: Icons.check_rounded,
                    onPressed: _saving ? null : () => _completeAndStop(book, books!),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      if (prev != null)
                        TextButton.icon(
                          onPressed: () => _goTo(prev),
                          icon: Icon(Icons.chevron_left_rounded, color: palette.text),
                          label: Text(
                            'Anterior',
                            style: TextStyle(color: palette.text, fontWeight: FontWeight.w700),
                          ),
                        ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => context.push(AppRoutes.retroactive),
                        icon: Icon(Icons.edit_calendar_rounded, color: palette.verseNumber, size: 20),
                        label: Text(
                          'Leitura retroativa',
                          style: TextStyle(color: palette.verseNumber, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _VerseActionsSheet extends StatelessWidget {
  const _VerseActionsSheet({
    required this.reference,
    required this.text,
    required this.onCopy,
    required this.onNote,
    required this.onRecitative,
  });

  final String reference;
  final String text;
  final VoidCallback onCopy;
  final VoidCallback onNote;
  final VoidCallback onRecitative;

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    Widget action(IconData icon, DuoTone tone, String label, VoidCallback onTap) => ListTile(
      leading: DuoIconBadge(icon: icon, tone: tone, size: 40),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      onTap: onTap,
    );
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reference, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(
                    text,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: c.textMuted, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            action(Icons.copy_rounded, c.primary, 'Copiar', onCopy),
            action(Icons.edit_note_rounded, c.success, 'Criar nota devocional', onNote),
            action(Icons.record_voice_over_rounded, c.gold, 'Salvar como recitativo', onRecitative),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/widgets/duo_button.dart';
import '../../../../core/widgets/duo_widgets.dart';

/// Cria ou edita uma anotação devocional. [reference] é exibida no topo.
Future<void> showNoteEditor(
  BuildContext context, {
  required String reference,
  required int bookId,
  required int chapter,
  int? verse,
  VerseNote? existing,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _NoteEditor(
        reference: reference,
        bookId: bookId,
        chapter: chapter,
        verse: verse,
        existing: existing,
      ),
    );

class _NoteEditor extends ConsumerStatefulWidget {
  const _NoteEditor({
    required this.reference,
    required this.bookId,
    required this.chapter,
    required this.verse,
    required this.existing,
  });

  final String reference;
  final int bookId;
  final int chapter;
  final int? verse;
  final VerseNote? existing;

  @override
  ConsumerState<_NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends ConsumerState<_NoteEditor> {
  late final TextEditingController _controller = TextEditingController(text: widget.existing?.content ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final dao = ref.read(appDatabaseProvider).notesDao;
    if (widget.existing == null) {
      await dao.createNote(bookId: widget.bookId, chapter: widget.chapter, verse: widget.verse, content: text);
    } else {
      await dao.updateContent(widget.existing!.id, text);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing == null ? 'Nova anotação' : 'Editar anotação',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(widget.reference, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              minLines: 4,
              maxLines: 10,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'O que Deus falou com você neste texto?'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            DuoButton(
              label: 'Salvar anotação',
              style: DuoButtonStyle.success,
              onPressed: _controller.text.trim().isEmpty ? null : _save,
            ),
          ],
        ),
      );
}

/// Lista de anotações de um capítulo, com edição e exclusão.
class NoteTile extends ConsumerWidget {
  const NoteTile({super.key, required this.note, required this.reference, this.onOpenReference});

  final VerseNote note;
  final String reference;
  final VoidCallback? onOpenReference;

  @override
  Widget build(BuildContext context, WidgetRef ref) => DuoCard(
        margin: const EdgeInsets.only(bottom: 12),
        onTap: () => showNoteEditor(
          context,
          reference: reference,
          bookId: note.bookId,
          chapter: note.chapter,
          verse: note.verse,
          existing: note,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: onOpenReference,
                    child: Text(reference, style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 6),
                  Text(note.content, style: const TextStyle(height: 1.4)),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Excluir anotação',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () async {
                final ok = await confirmDialog(
                  context,
                  title: 'Excluir anotação?',
                  message: 'Esta anotação será apagada.',
                  confirmLabel: 'Excluir',
                  destructive: true,
                );
                if (ok) await ref.read(appDatabaseProvider).notesDao.deleteNote(note.id);
              },
            ),
          ],
        ),
      );
}

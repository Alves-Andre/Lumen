import 'package:material_ui/material_ui.dart';

import 'duo_button.dart';

/// Folha inferior com um campo de texto livre. Retorna o texto digitado ao
/// confirmar, ou `null` se o usuário fechar a folha.
///
/// O controlador pertence ao `State` da folha e só é descartado quando ela sai
/// da árvore — descartá-lo logo após o `await` quebra a animação de fechamento.
Future<String?> showTextInputSheet(
  BuildContext context, {
  required String title,
  String? subtitle,
  String initialText = '',
  String? label,
  String? hint,
  required String confirmLabel,
  DuoButtonStyle confirmStyle = DuoButtonStyle.success,
}) => showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _TextInputSheet(
    title: title,
    subtitle: subtitle,
    initialText: initialText,
    label: label,
    hint: hint,
    confirmLabel: confirmLabel,
    confirmStyle: confirmStyle,
  ),
);

class _TextInputSheet extends StatefulWidget {
  const _TextInputSheet({
    required this.title,
    required this.subtitle,
    required this.initialText,
    required this.label,
    required this.hint,
    required this.confirmLabel,
    required this.confirmStyle,
  });

  final String title;
  final String? subtitle;
  final String initialText;
  final String? label;
  final String? hint;
  final String confirmLabel;
  final DuoButtonStyle confirmStyle;

  @override
  State<_TextInputSheet> createState() => _TextInputSheetState();
}

class _TextInputSheetState extends State<_TextInputSheet> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
        if (widget.subtitle != null) ...[const SizedBox(height: 6), Text(widget.subtitle!)],
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          minLines: 3,
          maxLines: 8,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: widget.label, hintText: widget.hint),
        ),
        const SizedBox(height: 16),
        DuoButton(
          label: widget.confirmLabel,
          style: widget.confirmStyle,
          onPressed: () => Navigator.pop(context, _controller.text),
        ),
      ],
    ),
  );
}

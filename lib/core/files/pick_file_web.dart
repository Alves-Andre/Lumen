import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'pick_file.dart';

/// Navegador: `<input type="file">` próprio.
///
/// Só o evento `cancel` (Safari 16.4+, Chrome, Firefox) conta como desistência.
/// O retorno de foco à página não é usado: no iPhone ele chega antes do
/// `change`, enquanto o arquivo ainda é copiado do app Arquivos.
Future<PickedFile?> pickFile({String? dialogTitle}) async {
  final input = web.HTMLInputElement()
    ..type = 'file'
    // Sem filtro `accept`: no iOS, filtros por extensão às vezes deixam o
    // .json acinzentado. O conteúdo é validado depois da leitura.
    ..style.display = 'none';
  web.document.body!.append(input);

  final completer = Completer<web.File?>();
  void onChange(web.Event _) {
    final files = input.files;
    if (!completer.isCompleted) completer.complete(files != null && files.length > 0 ? files.item(0) : null);
  }

  void onCancel(web.Event _) {
    if (!completer.isCompleted) completer.complete(null);
  }

  final changeListener = onChange.toJS;
  final cancelListener = onCancel.toJS;
  input
    ..addEventListener('change', changeListener)
    ..addEventListener('cancel', cancelListener)
    ..click();

  try {
    final file = await completer.future;
    if (file == null) return null;
    final buffer = await file.arrayBuffer().toDart;
    return PickedFile(name: file.name, bytes: Uint8List.view(buffer.toDart));
  } finally {
    input
      ..removeEventListener('change', changeListener)
      ..removeEventListener('cancel', cancelListener)
      ..remove();
  }
}

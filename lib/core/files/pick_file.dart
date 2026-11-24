import 'dart:typed_data';

import 'pick_file_native.dart' if (dart.library.js_interop) 'pick_file_web.dart' as impl;

/// Arquivo escolhido pelo usuário, já lido em memória.
class PickedFile {
  const PickedFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

/// Abre o seletor de arquivos do sistema e devolve o arquivo escolhido, ou
/// `null` se o usuário cancelar.
///
/// No navegador (inclusive Safari no iPhone) usa um seletor próprio: o do
/// `file_picker` tratava como "cancelado" o retorno de foco que o Safari envia
/// antes de entregar o arquivo, e a importação voltava em silêncio.
Future<PickedFile?> pickFile({String? dialogTitle}) => impl.pickFile(dialogTitle: dialogTitle);

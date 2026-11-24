import 'package:file_picker/file_picker.dart';

import 'pick_file.dart';

/// Android/iOS: seletor nativo do sistema.
Future<PickedFile?> pickFile({String? dialogTitle}) async {
  final file = await FilePicker.pickFile(dialogTitle: dialogTitle);
  if (file == null) return null;
  return PickedFile(name: file.name, bytes: await file.readAsBytes());
}

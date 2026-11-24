// Gera os ícones do Web App (PWA) a partir de assets/branding/lumen_icon.png:
//
//   dart run tool/make_web_icons.dart
//
// O ícone é um quadrado cheio (degradê + emblema em 60% da área), então a
// mesma imagem serve como "maskable" (a área segura exigida é de 80%).
import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  final source = img.decodePng(File('assets/branding/lumen_icon.png').readAsBytesSync());
  if (source == null) {
    stderr.writeln('Não foi possível ler assets/branding/lumen_icon.png');
    exit(1);
  }

  void write(String path, int size) {
    final resized = img.copyResize(source, width: size, height: size, interpolation: img.Interpolation.cubic);
    File(path).writeAsBytesSync(img.encodePng(resized));
    stdout.writeln('$path ($size px)');
  }

  write('web/icons/Icon-192.png', 192);
  write('web/icons/Icon-512.png', 512);
  write('web/icons/Icon-maskable-192.png', 192);
  write('web/icons/Icon-maskable-512.png', 512);
  // Tela de início do iPhone (Safari → Compartilhar → Adicionar à Tela de Início).
  write('web/icons/apple-touch-icon.png', 180);
  write('web/favicon.png', 32);
}

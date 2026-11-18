// Gera os ícones do Lumen a partir de assets/branding/lumen_logo.png.
//
//   dart run tool/make_icons.dart
//   dart run flutter_launcher_icons
//
// Saídas (em assets/branding/):
// * lumen_icon.png            – quadrado completo (iOS e Android antigos);
// * lumen_icon_background.png – fundo em degradê do ícone adaptativo;
// * lumen_icon_foreground.png – emblema (chama + livro) transparente, dentro da área segura;
// * lumen_mark.png            – emblema recortado, usado na tela de abertura do app.
import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;

const _dir = 'assets/branding';
const _launchDir = 'android/app/src/main/res/drawable-xxhdpi';
const _size = 1024;

/// O ícone adaptativo mostra só ~66% central; o emblema ocupa 60% para não ser cortado.
const _safeZone = 0.60;

void main() {
  final source = img.decodeImage(File('$_dir/lumen_logo.png').readAsBytesSync());
  if (source == null) {
    stderr.writeln('Não foi possível ler $_dir/lumen_logo.png');
    exit(1);
  }

  final tile = _cropTile(source);
  final background = _backgroundSampler(tile);
  // Com o brilho da chama: usado sobre o fundo azul (ícones e abertura nativa).
  final emblem = _extractEmblem(tile, background, low: 0.07, high: 0.24);
  // Contorno limpo, sem brilho: usado sobre fundos claros (tela de carregamento no modo claro).
  final crispEmblem = _extractEmblem(tile, background, low: 0.20, high: 0.32);

  final top = background(0.15), bottom = background(0.85);
  final gradient = img.Image(width: _size, height: _size);
  for (var y = 0; y < _size; y++) {
    final t = y / (_size - 1);
    final c = [for (var i = 0; i < 3; i++) (top[i] + (bottom[i] - top[i]) * t).round()];
    for (var x = 0; x < _size; x++) {
      gradient.setPixelRgb(x, y, c[0], c[1], c[2]);
    }
  }
  File('$_dir/lumen_icon_background.png').writeAsBytesSync(img.encodePng(gradient));

  final longest = max(emblem.width, emblem.height);
  final scale = _size * _safeZone / longest;
  final scaled = img.copyResize(
    emblem,
    width: (emblem.width * scale).round(),
    height: (emblem.height * scale).round(),
    interpolation: img.Interpolation.cubic,
  );
  final foreground = img.Image(width: _size, height: _size, numChannels: 4);
  img.compositeImage(
    foreground,
    scaled,
    dstX: (_size - scaled.width) ~/ 2,
    dstY: (_size - scaled.height) ~/ 2,
  );
  File('$_dir/lumen_icon_foreground.png').writeAsBytesSync(img.encodePng(foreground));

  // Quadrado completo (iOS e Android ≤ 7): degradê + emblema, sem cantos da arte original.
  final icon = img.Image.from(gradient);
  final iconEmblem = img.copyResize(
    emblem,
    width: (emblem.width * scale * 1.2).round(),
    height: (emblem.height * scale * 1.2).round(),
    interpolation: img.Interpolation.cubic,
  );
  img.compositeImage(icon, iconEmblem, dstX: (_size - iconEmblem.width) ~/ 2, dstY: (_size - iconEmblem.height) ~/ 2);
  File('$_dir/lumen_icon.png').writeAsBytesSync(img.encodePng(icon));

  final mark = img.copyResize(crispEmblem, width: 512, interpolation: img.Interpolation.cubic);
  File('$_dir/lumen_mark.png').writeAsBytesSync(img.encodePng(mark));

  // Abertura nativa do Android (≤ 11): 96dp de largura na densidade xxhdpi (3x).
  final launch = img.copyResize(emblem, width: 288, interpolation: img.Interpolation.cubic);
  Directory(_launchDir).createSync(recursive: true);
  File('$_launchDir/launch_mark.png').writeAsBytesSync(img.encodePng(launch));

  String hex(List<int> c) => '#${c.map((v) => v.toRadixString(16).padLeft(2, '0')).join()}'.toUpperCase();
  stdout.writeln('Ícones gerados em $_dir (fundo ${hex(top)} → ${hex(bottom)}).');
}

/// Recorta o quadrado arredondado, ignorando a margem escura em volta da arte.
img.Image _cropTile(img.Image src) {
  // Funciona com margem clara ou escura em volta do quadrado arredondado.
  final outer = src.getPixel(4, 4);
  bool differs(int x, int y) {
    final p = src.getPixel(x, y);
    return (p.r - outer.r).abs() + (p.g - outer.g).abs() + (p.b - outer.b).abs() > 30;
  }

  final midY = src.height ~/ 2, midX = src.width ~/ 2;
  var left = 0;
  while (left < midX && !differs(left, midY)) {
    left++;
  }
  var right = src.width - 1;
  while (right > midX && !differs(right, midY)) {
    right--;
  }
  var top = 0;
  while (top < midY && !differs(midX, top)) {
    top++;
  }
  var bottom = src.height - 1;
  while (bottom > midY && !differs(midX, bottom)) {
    bottom--;
  }
  final side = min(right - left, bottom - top);
  return img.copyCrop(src, x: left, y: top, width: side, height: side);
}

/// Cor de fundo do quadrado na altura relativa [t] (0 = topo), medida perto da borda esquerda.
List<int> Function(double t) _backgroundSampler(img.Image tile) => (t) {
      final y = (tile.height * t.clamp(0.15, 0.85)).round();
      var r = 0, g = 0, b = 0, n = 0;
      for (var x = (tile.width * 0.04).round(); x < tile.width * 0.07; x++) {
        final p = tile.getPixel(x, y);
        r += p.r.toInt();
        g += p.g.toInt();
        b += p.b.toInt();
        n++;
      }
      return [r ~/ n, g ~/ n, b ~/ n];
    };

/// Separa o emblema do fundo: a opacidade cresce com a distância da cor ao fundo
/// local, o que preserva o brilho suave em volta da chama.
img.Image _extractEmblem(
  img.Image tile,
  List<int> Function(double t) background, {
  required double low,
  required double high,
}) {
  final out = img.Image(width: tile.width, height: tile.height, numChannels: 4);
  var minX = tile.width, minY = tile.height, maxX = 0, maxY = 0;
  for (var y = 0; y < tile.height; y++) {
    final bg = background(y / tile.height);
    for (var x = 0; x < tile.width; x++) {
      final p = tile.getPixel(x, y);
      final d = sqrt(pow(p.r - bg[0], 2) + pow(p.g - bg[1], 2) + pow(p.b - bg[2], 2)) / 441.7;
      final a = _smoothstep(low, high, d);
      if (a <= 0) continue;
      out.setPixelRgba(x, y, p.r, p.g, p.b, (a * 255).round());
      if (a > 0.5) {
        minX = min(minX, x);
        maxX = max(maxX, x);
        minY = min(minY, y);
        maxY = max(maxY, y);
      }
    }
  }
  // Margem pequena para não cortar o brilho da chama.
  final pad = (tile.width * 0.02).round();
  final x0 = max(0, minX - pad), y0 = max(0, minY - pad);
  return img.copyCrop(
    out,
    x: x0,
    y: y0,
    width: min(tile.width, maxX + pad) - x0,
    height: min(tile.height, maxY + pad) - y0,
  );
}

double _smoothstep(double edge0, double edge1, double x) {
  final t = ((x - edge0) / (edge1 - edge0)).clamp(0.0, 1.0);
  return t * t * (3 - 2 * t);
}

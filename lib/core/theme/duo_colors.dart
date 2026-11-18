import 'package:material_ui/material_ui.dart';

/// Par cor/sombra dos botões e cards "3D" (estilo Duolingo).
@immutable
class DuoTone {
  const DuoTone(this.fill, this.shadow, this.soft, this.onFill);

  final Color fill;
  final Color shadow;

  /// Fundo suave para chips e cards de destaque.
  final Color soft;
  final Color onFill;
}

/// Tokens de cor do app (paletas "Céu & Linho" e "Noite").
@immutable
class DuoColors extends ThemeExtension<DuoColors> {
  const DuoColors({
    required this.background,
    required this.card,
    required this.border,
    required this.text,
    required this.textMuted,
    required this.textFaint,
    required this.primary,
    required this.success,
    required this.streak,
    required this.grace,
    required this.gold,
    required this.danger,
    required this.neutral,
  });

  final Color background;
  final Color card;
  final Color border;
  final Color text;
  final Color textMuted;
  final Color textFaint;

  /// Azul-safira (marca).
  final DuoTone primary;

  /// Azul-celeste: concluir, progresso.
  final DuoTone success;

  /// Dourado de candeia: ofensiva.
  final DuoTone streak;

  /// Lavanda: Escudo de Graça.
  final DuoTone grace;

  /// Dourado: recitativos e lembranças.
  final DuoTone gold;
  final DuoTone danger;

  /// Botão secundário (branco com borda).
  final DuoTone neutral;

  /// Paleta "Céu & Linho" — azul-safira e branco, com dourado de candeia.
  static const light = DuoColors(
    background: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    border: Color(0xFFDCE5F2),
    text: Color(0xFF13233F),
    textMuted: Color(0xFF5A6B87),
    textFaint: Color(0xFF9AA9C2),
    primary: DuoTone(Color(0xFF2453C7), Color(0xFF183C96), Color(0xFFE7EEFC), Colors.white),
    success: DuoTone(Color(0xFF2F8FE0), Color(0xFF1F6FB6), Color(0xFFE3F1FD), Colors.white),
    streak: DuoTone(Color(0xFFF0A537), Color(0xFFC4812A), Color(0xFFFDF2DF), Color(0xFF3D2600)),
    grace: DuoTone(Color(0xFF7C8CF0), Color(0xFF5B6BCB), Color(0xFFEEF0FD), Colors.white),
    gold: DuoTone(Color(0xFFD9AE34), Color(0xFFAD8820), Color(0xFFFBF5DE), Color(0xFF3D2E00)),
    danger: DuoTone(Color(0xFFE0525A), Color(0xFFB83C44), Color(0xFFFDE8EA), Colors.white),
    neutral: DuoTone(Color(0xFFFFFFFF), Color(0xFFDCE5F2), Color(0xFFF4F7FC), Color(0xFF13233F)),
  );

  /// Paleta "Noite" — azul-marinho profundo com os mesmos acentos, mais luminosos.
  static const dark = DuoColors(
    background: Color(0xFF0B1426),
    card: Color(0xFF111D33),
    border: Color(0xFF243552),
    text: Color(0xFFE9EFFA),
    textMuted: Color(0xFFA3B2CC),
    textFaint: Color(0xFF61728F),
    primary: DuoTone(Color(0xFF6B97F2), Color(0xFF4570C9), Color(0xFF17284A), Color(0xFF0B1426)),
    success: DuoTone(Color(0xFF5AAEF2), Color(0xFF3585C9), Color(0xFF122B48), Color(0xFF0B1426)),
    streak: DuoTone(Color(0xFFF4B355), Color(0xFFC88A33), Color(0xFF33270F), Color(0xFF0B1426)),
    grace: DuoTone(Color(0xFF9BA7F6), Color(0xFF717DD2), Color(0xFF1D2249), Color(0xFF0B1426)),
    gold: DuoTone(Color(0xFFE5BE52), Color(0xFFB4902E), Color(0xFF2F2912), Color(0xFF231A00)),
    danger: DuoTone(Color(0xFFF2737A), Color(0xFFC44E56), Color(0xFF3A1820), Color(0xFF0B1426)),
    neutral: DuoTone(Color(0xFF111D33), Color(0xFF243552), Color(0xFF16233D), Color(0xFFE9EFFA)),
  );

  static DuoColors of(BuildContext context) => Theme.of(context).extension<DuoColors>()!;

  @override
  DuoColors copyWith() => this;

  @override
  DuoColors lerp(DuoColors? other, double t) => t < 0.5 ? this : (other ?? this);
}

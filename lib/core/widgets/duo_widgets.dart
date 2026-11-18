import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/duo_colors.dart';

/// Card com borda de 2px e "pé" de 4px, como os cards do Duolingo.
class DuoCard extends StatelessWidget {
  const DuoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderColor,
    this.onTap,
    this.margin = const EdgeInsets.only(bottom: 16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    final border = borderColor ?? c.border;
    final radius = BorderRadius.circular(18);
    return Padding(
      padding: margin,
      child: Material(
        color: color ?? c.card,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border(
                top: BorderSide(color: border, width: 2),
                left: BorderSide(color: border, width: 2),
                right: BorderSide(color: border, width: 2),
                bottom: BorderSide(color: border, width: 4),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Bloco "3D" com cantos arredondados: borda de 2px e um pé de [depth] px em
/// [shadowColor]. O pé é uma camada separada porque o Flutter não pinta bordas
/// arredondadas com cores diferentes por lado.
class DuoTile extends StatelessWidget {
  const DuoTile({
    super.key,
    required this.child,
    required this.color,
    required this.borderColor,
    required this.shadowColor,
    this.radius = 16,
    this.depth = 4,
    this.padding = EdgeInsets.zero,
    this.alignment,
  });

  final Widget child;
  final Color color;
  final Color borderColor;
  final Color shadowColor;
  final double radius;
  final double depth;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.only(bottom: depth),
        decoration: BoxDecoration(color: shadowColor, borderRadius: BorderRadius.circular(radius)),
        child: Container(
          padding: padding,
          alignment: alignment,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: child,
        ),
      );
}

/// Barra de progresso grossa com brilho no topo.
class DuoProgressBar extends StatelessWidget {
  const DuoProgressBar({super.key, required this.value, this.color, this.height = 16});

  final double value;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    final fill = color ?? c.success.fill;
    final v = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: c.border,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: v == 0 ? 0 : v.clamp(0.04, 1.0),
          child: Container(
            decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(height)),
            alignment: Alignment.topCenter,
            padding: EdgeInsets.only(top: height * 0.22, left: height * 0.5, right: height * 0.5),
            child: Container(
              height: height * 0.22,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(height),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Seletor segmentado em pílula (abas internas das telas).
class DuoSegmented<T> extends StatelessWidget {
  const DuoSegmented({super.key, required this.segments, required this.selected, required this.onChanged});

  final Map<T, String> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.neutral.soft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border, width: 2),
      ),
      child: Row(
        children: [
          for (final entry in segments.entries)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(entry.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: entry.key == selected ? c.card : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: entry.key == selected ? Border.all(color: c.primary.fill, width: 2) : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    entry.value.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.6,
                      color: entry.key == selected ? c.primary.fill : c.textMuted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Ícone dentro de um quadrado arredondado colorido.
class DuoIconBadge extends StatelessWidget {
  const DuoIconBadge({super.key, required this.icon, required this.tone, this.size = 44});

  final IconData icon;
  final DuoTone tone;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: tone.soft, borderRadius: BorderRadius.circular(size * 0.3)),
        child: Icon(icon, color: tone.fill, size: size * 0.58),
      );
}

/// Caixa de estatística (como o resumo de fim de lição do Duolingo).
class DuoStatBox extends StatelessWidget {
  const DuoStatBox({super.key, required this.label, required this.value, required this.tone, required this.icon});

  final String label;
  final String value;
  final DuoTone tone;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    return Container(
      decoration: BoxDecoration(color: tone.fill, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 2),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              label.toUpperCase(),
              style: TextStyle(color: tone.onFill, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.6),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(14)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: tone.fill, size: 22),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: tone.fill, fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DuoChip extends StatelessWidget {
  const DuoChip({super.key, required this.label, required this.tone, this.icon});

  final String label;
  final DuoTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: tone.soft, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 14, color: tone.fill), const SizedBox(width: 4)],
            Text(label, style: TextStyle(color: tone.fill, fontWeight: FontWeight.w800, fontSize: 12)),
          ],
        ),
      );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12, top: 4),
        child: Row(
          children: [
            Expanded(child: Text(text, style: Theme.of(context).textTheme.titleLarge)),
            ?trailing,
          ],
        ),
      );
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.message, this.action});

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          DuoIconBadge(icon: icon, tone: c.primary, size: 72),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: c.textMuted)),
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    );
  }
}

/// Renderiza um [AsyncValue] com carregamento e erro padronizados.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({super.key, required this.value, required this.builder, this.loading});

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final Widget? loading;

  @override
  Widget build(BuildContext context) => value.when(
        data: builder,
        loading: () => loading ?? const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Erro: $e', style: TextStyle(color: DuoColors.of(context).danger.fill)),
        ),
      );
}

void showDuoSnack(BuildContext context, String message, {Duration duration = const Duration(seconds: 4)}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), duration: duration));
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      content: Text(message),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: DuoButtonLite(label: 'Cancelar', onPressed: () => Navigator.pop(ctx, false)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DuoButtonLite(
                label: confirmLabel,
                destructive: destructive,
                filled: true,
                onPressed: () => Navigator.pop(ctx, true),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Botão compacto para diálogos (sem a animação 3D).
class DuoButtonLite extends StatelessWidget {
  const DuoButtonLite({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = false,
    this.destructive = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool filled;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    final tone = destructive ? c.danger : c.primary;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: filled ? tone.fill : Colors.transparent,
        foregroundColor: filled ? tone.onFill : c.textMuted,
        minimumSize: const Size.fromHeight(46),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: filled ? BorderSide.none : BorderSide(color: c.border, width: 2),
        ),
      ),
      child: Text(label.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.6)),
    );
  }
}

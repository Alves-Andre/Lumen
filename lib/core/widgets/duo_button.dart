import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/duo_colors.dart';

enum DuoButtonStyle { primary, success, streak, grace, gold, danger, neutral }

/// Botão "3D" do Duolingo: sombra sólida embaixo que some quando pressionado.
class DuoButton extends StatefulWidget {
  const DuoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = DuoButtonStyle.primary,
    this.icon,
    this.expanded = true,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final DuoButtonStyle style;
  final IconData? icon;
  final bool expanded;
  final bool compact;

  @override
  State<DuoButton> createState() => _DuoButtonState();
}

class _DuoButtonState extends State<DuoButton> {
  static const double _depth = 4;
  bool _pressed = false;

  DuoTone _tone(DuoColors c) => switch (widget.style) {
        DuoButtonStyle.primary => c.primary,
        DuoButtonStyle.success => c.success,
        DuoButtonStyle.streak => c.streak,
        DuoButtonStyle.grace => c.grace,
        DuoButtonStyle.gold => c.gold,
        DuoButtonStyle.danger => c.danger,
        DuoButtonStyle.neutral => c.neutral,
      };

  @override
  Widget build(BuildContext context) {
    final c = DuoColors.of(context);
    final enabled = widget.onPressed != null;
    final tone = enabled ? _tone(c) : DuoTone(c.border, c.border, c.border, c.textFaint);
    final isNeutral = widget.style == DuoButtonStyle.neutral && enabled;
    final height = widget.compact ? 40.0 : 50.0;
    final labelColor = isNeutral ? c.primary.fill : tone.onFill;

    final content = Row(
      mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, color: labelColor, size: widget.compact ? 18 : 22),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: labelColor,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              fontSize: widget.compact ? 13 : 15,
            ),
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTapUp: enabled
            ? (_) {
                setState(() => _pressed = false);
                HapticFeedback.lightImpact();
                widget.onPressed!();
              }
            : null,
        child: SizedBox(
          height: height + _depth,
          child: Stack(
            children: [
              Positioned.fill(
                top: _depth,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: tone.shadow, borderRadius: BorderRadius.circular(16)),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 60),
                left: 0,
                right: 0,
                top: _pressed ? _depth : 0,
                height: height,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: widget.compact ? 14 : 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tone.fill,
                    borderRadius: BorderRadius.circular(16),
                    border: isNeutral ? Border.all(color: c.border, width: 2) : null,
                  ),
                  child: content,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

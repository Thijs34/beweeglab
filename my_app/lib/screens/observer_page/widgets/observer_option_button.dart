import 'package:flutter/material.dart';
import 'package:my_app/theme/app_theme.dart';

/// Toggle/choice button that mirrors the small pill buttons from the React UI.
class ObserverOptionButton extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double height;
  final double selectedBorderWidth;
  final double unselectedBorderWidth;
  final double fontSize;
  final FontWeight fontWeight;
  final IconData? icon;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final Color? selectedBackground;
  final Color? selectedForeground;

  const ObserverOptionButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.height = 40,
    this.selectedBorderWidth = 3,
    this.unselectedBorderWidth = 1,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w500,
    this.icon,
    this.iconSize = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
    this.selectedBackground,
    this.selectedForeground,
  });

  @override
  State<ObserverOptionButton> createState() => _ObserverOptionButtonState();
}

class _ObserverOptionButtonState extends State<ObserverOptionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final selectedBg = widget.selectedBackground ?? AppTheme.primaryOrange;
    final selectedFg = widget.selectedForeground ?? AppTheme.white;

    final backgroundColor = widget.selected
        ? selectedBg
        : _isHovered
        ? AppTheme.orange50
        : AppTheme.white;

    final borderColor = widget.selected
        ? AppTheme.primaryOrange
        : AppTheme.gray300;
    final textColor = widget.selected ? selectedFg : AppTheme.gray700;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: widget.selected
                  ? widget.selectedBorderWidth
                  : widget.unselectedBorderWidth,
            ),
            boxShadow: widget.selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: widget.iconSize, color: textColor),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    fontWeight: widget.fontWeight,
                    color: textColor,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

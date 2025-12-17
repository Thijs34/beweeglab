import 'package:flutter/material.dart';
import 'package:my_app/theme/app_theme.dart';

/// Reusable card wrapper that mirrors the subtle bordered cards from the React UI.
class ObserverSectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  const ObserverSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(color: AppTheme.gray200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}

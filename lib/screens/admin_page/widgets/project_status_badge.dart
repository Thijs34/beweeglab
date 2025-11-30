import 'package:flutter/material.dart';
import 'package:my_app/screens/admin_page/admin_models.dart';
import 'package:my_app/theme/app_theme.dart';

class ProjectStatusBadge extends StatelessWidget {
  final ProjectStatus status;
  final EdgeInsets padding;
  final double fontSize;

  const ProjectStatusBadge({
    super.key,
    required this.status,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final style = _badgeStyle(status);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(color: style.border),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: style.foreground,
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
        ),
      ),
    );
  }
}

class _StatusBadgeStyle {
  final Color background;
  final Color border;
  final Color foreground;

  const _StatusBadgeStyle(this.background, this.border, this.foreground);
}

_StatusBadgeStyle _badgeStyle(ProjectStatus status) {
  switch (status) {
    case ProjectStatus.active:
      return const _StatusBadgeStyle(
        AppTheme.green50,
        AppTheme.green200,
        AppTheme.green700,
      );
    case ProjectStatus.finished:
      return const _StatusBadgeStyle(
        AppTheme.orange50,
        AppTheme.orange200,
        AppTheme.primaryOrange,
      );
    case ProjectStatus.archived:
      return const _StatusBadgeStyle(
        AppTheme.gray100,
        AppTheme.gray300,
        AppTheme.gray600,
      );
  }
}

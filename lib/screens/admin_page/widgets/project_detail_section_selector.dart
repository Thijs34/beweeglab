import 'package:flutter/material.dart';
import 'package:my_app/l10n/l10n.dart';
import 'package:my_app/screens/admin_page/admin_models.dart';
import 'package:my_app/theme/app_theme.dart';

class ProjectDetailSectionSelector extends StatelessWidget {
  final ProjectDetailSection activeSection;
  final ValueChanged<ProjectDetailSection> onSectionSelected;

  const ProjectDetailSectionSelector({
    super.key,
    required this.activeSection,
    required this.onSectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: ProjectDetailSection.values.map((section) {
        final isSelected = section == activeSection;
        return ChoiceChip(
          label: Text(section.localizedLabel(l10n)),
          selected: isSelected,
          onSelected: (_) => onSectionSelected(section),
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.primaryOrange : AppTheme.gray700,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: AppTheme.white,
          selectedColor: AppTheme.orange50,
          side: BorderSide(
            color: isSelected ? AppTheme.primaryOrange : AppTheme.gray200,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          ),
        );
      }).toList(),
    );
  }
}

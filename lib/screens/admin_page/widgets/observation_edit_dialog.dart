import 'package:flutter/material.dart';
import 'package:my_app/l10n/l10n.dart';
import 'package:my_app/screens/admin_page/admin_models.dart';
import 'package:my_app/theme/app_theme.dart';

//dialog for editing observation
class ObservationEditDialog extends StatefulWidget {
  final ObservationRecord record;

  const ObservationEditDialog({super.key, required this.record});

  @override
  State<ObservationEditDialog> createState() => _ObservationEditDialogState();
}

class _ObservationEditDialogState extends State<ObservationEditDialog> {
  late String _personId;
  late String _gender;
  late String _ageGroup;
  late String _socialContext;
  late String _activityLevel;
  late String _activityType;
  late TextEditingController _notesController;
  late TextEditingController _personIdController;

  static const _genderOptions = ['male', 'female'];
  static const _ageOptions = ['child', 'teen', 'adult', 'senior'];
  static const _socialOptions = ['alone', 'together'];
  static const _activityLevelOptions = ['sitting', 'moving', 'intense'];
  static const _activityTypeOptions = ['organized', 'unorganized'];

  @override
  void initState() {
    super.initState();

    // Load the initial values from the record
    _personId = widget.record.personId;
    _gender = widget.record.gender;
    _ageGroup = widget.record.ageGroup;
    _socialContext = widget.record.socialContext;
    _activityLevel = widget.record.activityLevel;
    _activityType = widget.record.activityType;
    _notesController = TextEditingController(text: widget.record.notes);
    _personIdController = TextEditingController(text: widget.record.personId);
  }

  @override
  void dispose() {
    _personIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSave() {
    Navigator.of(context).pop(
      ObservationRecord(
        id: widget.record.id,
        personId: _personId,
        gender: _gender,
        ageGroup: _ageGroup,
        socialContext: _socialContext,
        locationTypeId: widget.record.locationTypeId,
        activityLevel: _activityLevel,
        activityType: _activityType,
        notes: _notesController.text.trim(),
        timestamp: widget.record.timestamp,
        projectId: widget.record.projectId,
        mode: widget.record.mode,
        observerEmail: widget.record.observerEmail,
        observerUid: widget.record.observerUid,
        groupSize: widget.record.groupSize,
        genderMix: widget.record.genderMix,
        ageMix: widget.record.ageMix,
        locationLabel: widget.record.locationLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.gray200)),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.adminEditObservationTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontFamily: AppTheme.fontFamilyHeading,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gray900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppTheme.gray500),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LabeledField(
                      label: l10n.adminPersonIdLabel,
                      child: TextField(
                        controller: _personIdController,
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _personId = value,
                        decoration: InputDecoration(
                          hintText: l10n.adminPersonIdHint,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _OptionGroup(
                      label: l10n.adminFieldGender,
                      options: _genderOptions,
                      selectedValue: _gender,
                      columns: 2,
                      optionLabelBuilder: (value) => _optionLabel(value, l10n),
                      onSelected: (value) => setState(() => _gender = value),
                    ),
                    const SizedBox(height: 16),
                    _OptionGroup(
                      label: l10n.adminAgeGroupLabel,
                      options: _ageOptions,
                      selectedValue: _ageGroup,
                      columns: 2,
                      optionLabelBuilder: (value) => _optionLabel(value, l10n),
                      onSelected: (value) => setState(() => _ageGroup = value),
                    ),
                    const SizedBox(height: 16),
                    _OptionGroup(
                      label: l10n.adminSocialContextLabel,
                      options: _socialOptions,
                      selectedValue: _socialContext,
                      columns: 2,
                      optionLabelBuilder: (value) => _optionLabel(value, l10n),
                      onSelected: (value) =>
                          setState(() => _socialContext = value),
                    ),
                    const SizedBox(height: 16),
                    _OptionGroup(
                      label: l10n.adminActivityLevelLabel,
                      options: _activityLevelOptions,
                      selectedValue: _activityLevel,
                      columns: 3,
                      optionLabelBuilder: (value) => _optionLabel(value, l10n),
                      onSelected: (value) =>
                          setState(() => _activityLevel = value),
                    ),
                    const SizedBox(height: 16),
                    _OptionGroup(
                      label: l10n.adminActivityTypeLabel,
                      options: _activityTypeOptions,
                      selectedValue: _activityType,
                      columns: 2,
                      optionLabelBuilder: (value) => _optionLabel(value, l10n),
                      onSelected: (value) =>
                          setState(() => _activityType = value),
                    ),
                    const SizedBox(height: 16),
                    _LabeledField(
                      label: l10n.adminFieldNotes,
                      child: TextField(
                        controller: _notesController,
                        minLines: 3,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: l10n.adminAdditionalNotesHint,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppTheme.gray50,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
                border: Border(top: BorderSide(color: AppTheme.gray200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.gray300),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(l10n.commonCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(l10n.adminSaveChanges),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.gray700,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _OptionGroup extends StatelessWidget {
  final String label;
  final List<String> options;
  final String selectedValue;
  final int columns;
  final String Function(String value)? optionLabelBuilder;
  final ValueChanged<String> onSelected;

  const _OptionGroup({
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.columns,
    this.optionLabelBuilder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacingTotal = (columns - 1) * 12.0;
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width - 80;
        final rawWidth = (maxWidth - spacingTotal) / columns;
        final buttonWidth = rawWidth.clamp(120.0, maxWidth).toDouble();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.gray700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: options.map((option) {
                final isSelected = option == selectedValue;
                final labelBuilder = optionLabelBuilder ?? _formatLabel;
                return SizedBox(
                  width: buttonWidth,
                  child: OutlinedButton(
                    onPressed: () => onSelected(option),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: isSelected
                          ? AppTheme.primaryOrange
                          : AppTheme.white,
                      foregroundColor: isSelected
                          ? AppTheme.white
                          : AppTheme.gray700,
                      side: BorderSide(
                        color: isSelected
                            ? AppTheme.primaryOrange
                            : AppTheme.gray300,
                        width: 2,
                      ),
                    ),
                      child: Text(labelBuilder(option)),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  String _formatLabel(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1);
  }
}

String _optionLabel(String value, AppLocalizations l10n) {
  switch (value) {
    case 'male':
      return l10n.adminGenderMale;
    case 'female':
      return l10n.adminGenderFemale;
    case 'child':
      return l10n.adminAgeChild;
    case 'teen':
      return l10n.adminAgeTeen;
    case 'adult':
      return l10n.adminAgeAdult;
    case 'senior':
      return l10n.adminAgeSenior;
    case 'alone':
      return l10n.adminSocialAlone;
    case 'together':
      return l10n.adminSocialTogether;
    case 'sitting':
      return l10n.adminActivityLevelSitting;
    case 'moving':
      return l10n.adminActivityLevelMoving;
    case 'intense':
      return l10n.adminActivityLevelIntense;
    case 'organized':
      return l10n.adminActivityTypeOrganized;
    case 'unorganized':
      return l10n.adminActivityTypeUnorganized;
    default:
      return value;
  }
}

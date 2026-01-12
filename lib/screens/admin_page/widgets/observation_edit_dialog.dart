import 'package:flutter/material.dart';
import 'package:my_app/l10n/l10n.dart';
import 'package:my_app/models/observation_field.dart';
import 'package:my_app/models/observation_field_registry.dart';
import 'package:my_app/screens/admin_page/admin_models.dart';
import 'package:my_app/theme/app_theme.dart';

//dialog for editing observation
class ObservationEditDialog extends StatefulWidget {
  final ObservationRecord record;
  final List<ObservationField> fields;

  const ObservationEditDialog({
    super.key,
    required this.record,
    required this.fields,
  });

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
  late TextEditingController _activityNotesController;
  late TextEditingController _remarksController;
  late TextEditingController _personIdController;
  late Map<String, dynamic> _fieldValues;
  late List<ObservationField> _customFields;
  final Map<String, TextEditingController> _customTextControllers = {};

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
    _fieldValues = Map<String, dynamic>.from(widget.record.fieldValues ?? {});
    _customFields = widget.fields.where(_isCustomField).toList(growable: false);

    final activityNotes = (widget.record.activityNotes.isNotEmpty
            ? widget.record.activityNotes
            : (_fieldValues[ObservationFieldRegistry.activityNotesFieldId]
                    as String?)) ??
        '';
    final additionalRemarks = (widget.record.additionalRemarks.isNotEmpty
            ? widget.record.additionalRemarks
            : (_fieldValues[ObservationFieldRegistry.remarksFieldId]
                    as String?)) ??
        '';

    _activityNotesController = TextEditingController(text: activityNotes);
    _remarksController = TextEditingController(text: additionalRemarks);
    _personIdController = TextEditingController(text: widget.record.personId);

    for (final field in _customFields) {
      if (_isTextLike(field)) {
        final initial = _fieldValues[field.id];
        _customTextControllers[field.id] = TextEditingController(
          text: initial == null ? '' : initial.toString(),
        );
      }
    }
  }

  @override
  void dispose() {
    _personIdController.dispose();
    _activityNotesController.dispose();
    _remarksController.dispose();
    for (final controller in _customTextControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleSave() {
    for (final entry in _customTextControllers.entries) {
      _fieldValues[entry.key] = entry.value.text.trim();
    }
    final activityNotes = _activityNotesController.text.trim();
    final additionalRemarks = _remarksController.text.trim();
    final combinedNotes = _combineNotes(activityNotes, additionalRemarks);
    final updatedFieldValues = Map<String, dynamic>.from(_fieldValues);
    updatedFieldValues[ObservationFieldRegistry.activityNotesFieldId] =
        activityNotes;
    updatedFieldValues[ObservationFieldRegistry.remarksFieldId] =
        additionalRemarks;

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
        notes: combinedNotes,
        activityNotes: activityNotes,
        additionalRemarks: additionalRemarks,
        timestamp: widget.record.timestamp,
        projectId: widget.record.projectId,
        mode: widget.record.mode,
        observerEmail: widget.record.observerEmail,
        observerUid: widget.record.observerUid,
        groupNumber: widget.record.groupNumber,
        groupSize: widget.record.groupSize,
        genderCounts: widget.record.genderCounts,
        ageCounts: widget.record.ageCounts,
        locationLabel: widget.record.locationLabel,
        demographicPairs: widget.record.demographicPairs,
        fieldValues: updatedFieldValues,
      ),
    );
  }

  Widget _buildCustomField(ObservationField field, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).languageCode;
    final label = field.labelForLocale(locale);
    if (_isTextLike(field)) {
      final controller = _customTextControllers[field.id]!;
      final isMultiline = (field.config is TextObservationFieldConfig)
          ? (field.config as TextObservationFieldConfig).multiline
          : false;
      return _LabeledField(
        label: label,
        child: TextField(
          controller: controller,
          minLines: isMultiline ? 2 : 1,
          maxLines: isMultiline ? 4 : 1,
          onChanged: (value) => _fieldValues[field.id] = value,
        ),
      );
    }

    final config = field.config;
    if (config is OptionObservationFieldConfig) {
      final allowMultiple = config.allowMultiple;
      final selected = _selectedOptions(field.id);
      if (!allowMultiple) {
        return _OptionGroup(
          label: label,
          options: config.options.map((opt) => opt.id).toList(),
          selectedValue: selected.isNotEmpty ? selected.first : '',
          columns: 2,
          optionLabelBuilder: (value) {
            final match = config.options.firstWhere(
              (opt) => opt.id == value,
              orElse: () => ObservationFieldOption(
                id: value,
                label: LocalizedText(nl: value, en: value),
              ),
            );
            return match.labelForLocale(locale);
          },
          onSelected: (value) {
            setState(() {
              _fieldValues[field.id] = value;
            });
          },
        );
      }

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
            children: config.options.map((option) {
              final isSelected = selected.contains(option.id);
              return SizedBox(
                width: 150,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      final updated = _selectedOptions(field.id);
                      if (isSelected) {
                        updated.remove(option.id);
                      } else {
                        updated.add(option.id);
                      }
                      _fieldValues[field.id] = updated.toList();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor:
                        isSelected ? AppTheme.primaryOrange : AppTheme.white,
                    foregroundColor:
                        isSelected ? AppTheme.white : AppTheme.gray700,
                    side: BorderSide(
                      color: isSelected
                          ? AppTheme.primaryOrange
                          : AppTheme.gray300,
                      width: 2,
                    ),
                  ),
                  child: Text(option.labelForLocale(locale)),
                ),
              );
            }).toList(),
          ),
        ],
      );
    }

    return _LabeledField(
      label: label,
      child: Text(
        _fieldValues[field.id]?.toString() ?? '--',
        style: const TextStyle(color: AppTheme.gray600),
      ),
    );
  }

  Set<String> _selectedOptions(String fieldId) {
    final raw = _fieldValues[fieldId];
    if (raw is Iterable) {
      return raw.whereType<String>().toSet();
    }
    if (raw is String && raw.isNotEmpty) {
      return {raw};
    }
    return <String>{};
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
                      label: 'Activity notes',
                      child: TextField(
                        controller: _activityNotesController,
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Describe the activity (optional)',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _LabeledField(
                      label: 'Additional remarks',
                      child: TextField(
                        controller: _remarksController,
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Other notes (optional)',
                        ),
                      ),
                    ),
                    if (_customFields.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Custom fields',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.gray700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._customFields.map((field) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildCustomField(field, l10n),
                          )),
                    ],
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

bool _isCustomField(ObservationField field) {
  const excluded = <String>{
    ObservationFieldRegistry.genderFieldId,
    ObservationFieldRegistry.ageGroupFieldId,
    ObservationFieldRegistry.socialContextFieldId,
    ObservationFieldRegistry.locationTypeFieldId,
    ObservationFieldRegistry.customLocationFieldId,
    ObservationFieldRegistry.activityLevelFieldId,
    ObservationFieldRegistry.activityTypeFieldId,
    ObservationFieldRegistry.activityNotesFieldId,
    ObservationFieldRegistry.remarksFieldId,
    ObservationFieldRegistry.groupSizeFieldId,
    ObservationFieldRegistry.groupGenderMixFieldId,
    ObservationFieldRegistry.groupAgeMixFieldId,
  };
  return !excluded.contains(field.id) && field.isEnabled;
}

bool _isTextLike(ObservationField field) {
  return field.type == ObservationFieldType.text ||
      field.type == ObservationFieldType.number ||
      field.type == ObservationFieldType.rating;
}

String _combineNotes(String activityNotes, String additionalRemarks) {
  final parts = <String>[];
  if (activityNotes.isNotEmpty) parts.add(activityNotes);
  if (additionalRemarks.isNotEmpty) parts.add(additionalRemarks);
  return parts.join('\n');
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

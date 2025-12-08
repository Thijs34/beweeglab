import 'package:flutter/material.dart';
import 'package:my_app/l10n/l10n.dart';
import 'package:my_app/models/observation_field.dart';
import 'package:my_app/theme/app_theme.dart';

class ProjectObservationFieldsCard extends StatelessWidget {
  const ProjectObservationFieldsCard({
    super.key,
    required this.fields,
    required this.activeAudience,
    required this.fieldCounts,
    required this.onAudienceChanged,
    required this.hasChanges,
    required this.isSaving,
    required this.onAddField,
    required this.onEditField,
    required this.onReorderField,
    required this.onToggleField,
    required this.onDeleteField,
    required this.onResetFields,
    required this.onSaveFields,
    required this.onDiscardChanges,
  });

  final List<ObservationField> fields;
  final ObservationFieldAudience activeAudience;
  final Map<ObservationFieldAudience, int> fieldCounts;
  final ValueChanged<ObservationFieldAudience> onAudienceChanged;
  final bool hasChanges;
  final bool isSaving;
  final Future<void> Function(BuildContext context) onAddField;
  final Future<void> Function(BuildContext context, ObservationField field)
      onEditField;
  final void Function(int oldIndex, int newIndex) onReorderField;
  final void Function(String fieldId, bool isEnabled) onToggleField;
  final void Function(String fieldId) onDeleteField;
  final VoidCallback onResetFields;
  final Future<void> Function() onSaveFields;
  final VoidCallback onDiscardChanges;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final visibleCount = fields.length;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.gray200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 480;

              final titleGroup = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      l10n.adminObservationFieldsTitle,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamilyHeading,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.gray100,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      l10n.adminObservationFieldsCount(visibleCount),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.gray600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );

              final addButton = OutlinedButton.icon(
                onPressed: () => onAddField(context),
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.adminAddField),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleGroup,
                    const SizedBox(height: 12),
                    SizedBox(width: double.infinity, child: addButton),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: titleGroup),
                  addButton,
                ],
              );
            },
          ),
          const SizedBox(height: 6),
          Text(
            l10n.adminObservationFieldsSubtitle,
            style: const TextStyle(color: AppTheme.gray600, fontSize: 13),
          ),
          const SizedBox(height: 12),
          _AudienceSegmentedControl(
            activeAudience: activeAudience,
            fieldCounts: fieldCounts,
            onAudienceChanged: onAudienceChanged,
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: hasChanges
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _UnsavedChangesBanner(
                      key: const ValueKey('fields-unsaved-banner'),
                      isSaving: isSaving,
                      onDiscardChanges: onDiscardChanges,
                      onSaveFields: onSaveFields,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          if (fields.isEmpty)
            _EmptyState(
              onAddField: onAddField,
              audienceLabel: _audienceLabel(l10n, activeAudience),
              audienceIcon: _audienceIcon(activeAudience),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: fields.length,
              onReorder: onReorderField,
              itemBuilder: (context, index) {
                final field = fields[index];
                return Container(
                  key: ValueKey(field.id),
                  child: _FieldRow(
                    index: index,
                    field: field,
                    isLast: index == fields.length - 1,
                    onToggleField: (isEnabled) =>
                        onToggleField(field.id, isEnabled),
                    onDeleteField: () => _confirmDelete(context, field),
                    onEditField: () => onEditField(context, field),
                  ),
                );
              },
            ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 420;

              final resetButton = TextButton.icon(
                onPressed: onResetFields,
                icon: const Icon(Icons.settings_backup_restore, size: 18),
                label: Text(l10n.adminRestoreDefaults),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.gray600,
                ),
              );

              final saveButton = ElevatedButton.icon(
                onPressed:
                    !hasChanges || isSaving ? null : () => onSaveFields(),
                icon: isSaving
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      )
                    : const Icon(Icons.save_outlined, size: 18),
                label: Text(
                  isSaving ? l10n.adminSaving : l10n.adminSaveChanges,
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: resetButton,
                    ),
                    const SizedBox(height: 12),
                    saveButton,
                  ],
                );
              }

              return Row(
                children: [
                  resetButton,
                  const Spacer(),
                  saveButton,
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, ObservationField field) async {
    if (field.isStandard) {
      return;
    }
    final l10n = context.l10n;
    final localeCode = Localizations.localeOf(context).languageCode;
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.adminDeleteFieldTitle),
            content: Text(
              l10n.adminDeleteFieldMessage(
                field.labelForLocale(localeCode),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.commonCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.red600,
                ),
                child: Text(l10n.commonDelete),
              ),
            ],
          ),
        ) ??
        false;
    if (confirmed) {
      onDeleteField(field.id);
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.onAddField,
    required this.audienceLabel,
    required this.audienceIcon,
  });

  final Future<void> Function(BuildContext context) onAddField;
  final String audienceLabel;
  final IconData audienceIcon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.gray50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.gray200),
      ),
      child: Column(
        children: [
          const Icon(Icons.ballot_outlined, size: 36, color: AppTheme.gray400),
          const SizedBox(height: 10),
          Chip(
            avatar: Icon(
              audienceIcon,
              size: 16,
              color: AppTheme.primaryOrange,
            ),
            label: Text(
              audienceLabel,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            side: const BorderSide(color: AppTheme.gray200),
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.adminNoFieldsTitle,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.gray700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.adminNoFieldsSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.gray600),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () => onAddField(context),
            child: Text(l10n.adminAddField),
          ),
        ],
      ),
    );
  }
}

class _AudienceSegmentedControl extends StatelessWidget {
  const _AudienceSegmentedControl({
    required this.activeAudience,
    required this.fieldCounts,
    required this.onAudienceChanged,
  });

  final ObservationFieldAudience activeAudience;
  final Map<ObservationFieldAudience, int> fieldCounts;
  final ValueChanged<ObservationFieldAudience> onAudienceChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const options = <ObservationFieldAudience>[
      ObservationFieldAudience.individual,
      ObservationFieldAudience.group,
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((audience) {
        final isActive = audience == activeAudience;
        final count = fieldCounts[audience] ?? 0;
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _audienceIcon(audience),
                size: 16,
                color: isActive ? AppTheme.primaryOrange : AppTheme.gray700,
              ),
              const SizedBox(width: 6),
              Text('${_audienceLabel(l10n, audience)} ($count)'),
            ],
          ),
          selected: isActive,
          onSelected: (_) => onAudienceChanged(audience),
        );
      }).toList(),
    );
  }
}

class _UnsavedChangesBanner extends StatelessWidget {
  const _UnsavedChangesBanner({
    super.key,
    required this.isSaving,
    required this.onSaveFields,
    required this.onDiscardChanges,
  });

  final bool isSaving;
  final Future<void> Function() onSaveFields;
  final VoidCallback onDiscardChanges;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.primaryOrange.withValues(alpha: 0.35),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 520;
          final message = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.primaryOrange,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.adminUnsavedFieldsTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gray900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.adminUnsavedFieldsSubtitle,
                      style: const TextStyle(color: AppTheme.gray700),
                    ),
                  ],
                ),
              ),
            ],
          );

          final discardButton = TextButton.icon(
            onPressed: isSaving ? null : onDiscardChanges,
            icon: const Icon(Icons.undo, size: 18),
            label: Text(l10n.adminDiscardChanges),
          );

          final saveButton = FilledButton.icon(
            onPressed: isSaving ? null : () => onSaveFields(),
            icon: isSaving
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  )
                : const Icon(Icons.save_outlined, size: 18),
            label: Text(
              isSaving ? l10n.adminSaving : l10n.adminSaveChanges,
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
          );

          final actionRow = Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: isCompact ? WrapAlignment.start : WrapAlignment.end,
            children: [
              discardButton,
              saveButton,
            ],
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                message,
                const SizedBox(height: 12),
                actionRow,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: message),
              const SizedBox(width: 16),
              actionRow,
            ],
          );
        },
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.index,
    required this.field,
    required this.isLast,
    required this.onToggleField,
    required this.onDeleteField,
    required this.onEditField,
  });

  final int index;
  final ObservationField field;
  final bool isLast;
  final ValueChanged<bool> onToggleField;
  final VoidCallback onDeleteField;
  final VoidCallback onEditField;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localeCode = Localizations.localeOf(context).languageCode;
    final helper = field.helperForLocale(localeCode);
    final chips = <Widget>[
      _buildChip(
        label: _typeLabel(l10n, field.type),
        color: AppTheme.gray100,
        textColor: AppTheme.gray700,
      ),
      if (field.isStandard)
        _buildChip(
          label: l10n.adminFieldStandard,
          color: const Color(0xFFE4F1FF),
          textColor: const Color(0xFF0E5AA6),
        )
      else
        _buildChip(
          label: l10n.adminFieldCustom,
          color: const Color(0xFFFCECDD),
          textColor: const Color(0xFF9A4E00),
        ),
      if (field.isRequired)
        _buildChip(
          label: l10n.adminRequiredField,
          color: const Color(0xFFFFE5E5),
          textColor: const Color(0xFFB3261E),
        ),
    ];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6, right: 12),
                  child: Icon(
                    Icons.drag_indicator,
                    color: AppTheme.gray400,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      field.labelForLocale(localeCode),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gray900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: chips,
                    ),
                    if (helper != null && helper.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          helper,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.gray600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Switch.adaptive(
                    value: field.isEnabled,
                    onChanged: (value) => onToggleField(value),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: onEditField,
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: l10n.adminEdit,
                      ),
                      if (!field.isStandard)
                        IconButton(
                          onPressed: onDeleteField,
                          icon: const Icon(Icons.delete_outline, size: 20),
                          tooltip: l10n.commonDelete,
                          color: AppTheme.red600,
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            thickness: 1,
            color: AppTheme.gray200,
          ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String _typeLabel(AppLocalizations l10n, ObservationFieldType type) {
    switch (type) {
      case ObservationFieldType.text:
        return l10n.adminFieldTypeTextInput;
      case ObservationFieldType.number:
        return l10n.adminFieldTypeNumber;
      case ObservationFieldType.dropdown:
        return l10n.adminFieldTypeDropdownLegacy;
      case ObservationFieldType.multiSelect:
        return l10n.adminFieldTypeMultiSelect;
      case ObservationFieldType.checkbox:
        return l10n.adminFieldTypeCheckbox;
      case ObservationFieldType.date:
        return l10n.adminFieldTypeDate;
      case ObservationFieldType.time:
        return l10n.adminFieldTypeTime;
      case ObservationFieldType.rating:
        return l10n.adminFieldTypeRating;
    }
  }
}

String _audienceLabel(
  AppLocalizations l10n,
  ObservationFieldAudience value,
) {
  switch (value) {
    case ObservationFieldAudience.individual:
      return l10n.adminAudienceIndividual;
    case ObservationFieldAudience.group:
      return l10n.adminAudienceGroup;
    case ObservationFieldAudience.all:
      return l10n.adminAudienceBoth;
  }
}

IconData _audienceIcon(ObservationFieldAudience value) {
  switch (value) {
    case ObservationFieldAudience.individual:
      return Icons.person_outline;
    case ObservationFieldAudience.group:
      return Icons.groups_outlined;
    case ObservationFieldAudience.all:
      return Icons.all_inclusive;
  }
}

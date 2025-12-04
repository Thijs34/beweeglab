import 'package:flutter/material.dart';
import 'package:my_app/models/observation_field.dart';
import 'package:my_app/theme/app_theme.dart';

class ProjectObservationFieldsCard extends StatelessWidget {
  const ProjectObservationFieldsCard({
    super.key,
    required this.fields,
    required this.hasChanges,
    required this.isSaving,
    required this.onAddField,
    required this.onEditField,
    required this.onReorderField,
    required this.onToggleField,
    required this.onDeleteField,
    required this.onResetFields,
    required this.onSaveFields,
  });

  final List<ObservationField> fields;
  final bool hasChanges;
  final bool isSaving;
  final Future<void> Function(BuildContext context) onAddField;
  final Future<void> Function(
    BuildContext context,
    ObservationField field,
  ) onEditField;
  final void Function(int oldIndex, int newIndex) onReorderField;
  final void Function(String fieldId, bool isEnabled) onToggleField;
  final void Function(String fieldId) onDeleteField;
  final VoidCallback onResetFields;
  final Future<void> Function() onSaveFields;

  @override
  Widget build(BuildContext context) {
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
                  const Flexible(
                    child: Text(
                      'Observation Fields',
                      style: TextStyle(
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
                      '${fields.length} field${fields.length == 1 ? '' : 's'}',
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
                label: const Text('Add Field'),
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
          const Text(
            'Reorder, edit, or toggle standard/custom fields. Remember to save changes.',
            style: TextStyle(color: AppTheme.gray600, fontSize: 13),
          ),
          const SizedBox(height: 16),
          if (fields.isEmpty)
            _EmptyState(onAddField: onAddField)
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
                label: const Text('Restore defaults'),
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
                label: Text(isSaving ? 'Saving…' : 'Save Changes'),
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
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete field'),
            content: Text(
              'Are you sure you want to delete "${field.label}"? This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.red600,
                ),
                child: const Text('Delete'),
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
  const _EmptyState({required this.onAddField});

  final Future<void> Function(BuildContext context) onAddField;

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 12),
          const Text(
            'No fields configured yet.',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.gray700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add your first custom field or restore the default template.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.gray600),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () => onAddField(context),
            child: const Text('Add Field'),
          ),
        ],
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
    final chips = <Widget>[
      _buildChip(
        label: field.type.name,
        color: AppTheme.gray100,
        textColor: AppTheme.gray700,
      ),
      if (field.isStandard)
        _buildChip(
          label: 'Standard',
          color: const Color(0xFFE4F1FF),
          textColor: const Color(0xFF0E5AA6),
        )
      else
        _buildChip(
          label: 'Custom',
          color: const Color(0xFFFCECDD),
          textColor: const Color(0xFF9A4E00),
        ),
      if (field.isRequired)
        _buildChip(
          label: 'Required',
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
                      field.label,
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
                    if (field.helperText != null &&
                        field.helperText!.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          field.helperText!,
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
                      TextButton(
                        onPressed: onEditField,
                        child: const Text('Edit'),
                      ),
                      if (!field.isStandard)
                        IconButton(
                          tooltip: 'Delete field',
                          onPressed: onDeleteField,
                          icon: const Icon(Icons.delete_outline, size: 20),
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
}

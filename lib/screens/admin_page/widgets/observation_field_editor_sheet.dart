import 'package:flutter/material.dart';
import 'package:my_app/l10n/l10n.dart';
import 'package:my_app/models/observation_field.dart';
import 'package:my_app/theme/app_theme.dart';

enum _FieldLanguage { nl, en }

// this lets you edit a custom observation field in a clean and kinda flexible way

Future<ObservationField?> showObservationFieldEditorSheet(
  BuildContext context, {
  required ObservationField field,
  required bool canEditType,
}) {
  return showModalBottomSheet<ObservationField>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return ObservationFieldEditorSheet(
        field: field,
        canEditType: canEditType,
      );
    },
  );
}

class ObservationFieldEditorSheet extends StatefulWidget {
  const ObservationFieldEditorSheet({
    super.key,
    required this.field,
    required this.canEditType,
  });

  final ObservationField field;
  final bool canEditType;

  @override
  State<ObservationFieldEditorSheet> createState() =>
      _ObservationFieldEditorSheetState();
}

class _ObservationFieldEditorSheetState
    extends State<ObservationFieldEditorSheet> {
  static const List<ObservationFieldType> _supportedTypes =
      <ObservationFieldType>[
        ObservationFieldType.text,
        ObservationFieldType.multiSelect,
      ];

  _FieldLanguage _language = _FieldLanguage.nl;
  late ObservationFieldType _type;
  late bool _isRequired;
  late Map<_FieldLanguage, TextEditingController> _labelControllers;
  late Map<_FieldLanguage, TextEditingController> _helperControllers;

  late TextEditingController _textPlaceholderController;
  late TextEditingController _textMaxLengthController;
  bool _textMultiline = false;

  bool _optionAllowMultiple = false;
  List<_OptionDraft> _optionDrafts = [];
  late ObservationFieldAudience _audience;

  String? _errorText;

  late AppLocalizations _l10n;
  bool _didLoadL10n = false;
  ObservationFieldConfig? _initialConfig;

  AppLocalizations get l10n => _l10n;

  @override
  void initState() {
    super.initState();
    final config = widget.field.config;
    _type = widget.field.type;
    if (_type == ObservationFieldType.dropdown) {
      _type = ObservationFieldType.multiSelect;
    }
    if (widget.canEditType && !_supportedTypes.contains(_type)) {
      _type = ObservationFieldType.text;
    }
    _isRequired = widget.field.isRequired;
    _labelControllers = {
      _FieldLanguage.nl:
          TextEditingController(text: widget.field.label.nl.trim()),
      _FieldLanguage.en:
          TextEditingController(text: widget.field.label.en ?? ''),
    };
    _helperControllers = {
      _FieldLanguage.nl:
          TextEditingController(text: widget.field.helperText?.nl ?? ''),
      _FieldLanguage.en:
          TextEditingController(text: widget.field.helperText?.en ?? ''),
    };

    _textPlaceholderController = TextEditingController();
    _textMaxLengthController = TextEditingController();

    _audience = widget.field.audience;
    _initialConfig = config;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadL10n) return;
    _l10n = context.l10n;
    _hydrateConfigState(_initialConfig);
    _didLoadL10n = true;
  }

  @override
  void dispose() {
    for (final controller in _labelControllers.values) {
      controller.dispose();
    }
    for (final controller in _helperControllers.values) {
      controller.dispose();
    }
    _textPlaceholderController.dispose();
    _textMaxLengthController.dispose();
    for (final draft in _optionDrafts) {
      draft.dispose();
    }
    super.dispose();
  }

  void _hydrateConfigState(ObservationFieldConfig? config) {
    switch (_type) {
      case ObservationFieldType.text:
        final cfg = config is TextObservationFieldConfig
            ? config
            : const TextObservationFieldConfig();
        _textPlaceholderController.text = cfg.placeholder ?? '';
        _textMaxLengthController.text = cfg.maxLength?.toString() ?? '';
        _textMultiline = cfg.multiline;
        break;
      case ObservationFieldType.dropdown:
      case ObservationFieldType.multiSelect:
        final cfg = config is OptionObservationFieldConfig
            ? config
            : OptionObservationFieldConfig(
                options: _defaultOptions(),
                allowMultiple: _type == ObservationFieldType.multiSelect,
              );
        _optionAllowMultiple = cfg.allowMultiple;
        _replaceOptionDrafts(
          cfg.options.isEmpty ? _defaultOptions() : cfg.options,
        );
        break;
      default:
        break;
    }
  }

  void _replaceOptionDrafts(List<ObservationFieldOption> options) {
    for (final draft in _optionDrafts) {
      draft.dispose();
    }
    _optionDrafts = options
        .map(
          (option) => _OptionDraft(
            id: option.id,
            label: option.label,
            l10n: _l10n,
          ),
        )
        .toList();
    if (_optionDrafts.isEmpty) {
      _optionDrafts = _defaultOptions()
          .map(
            (option) => _OptionDraft(
              id: option.id,
              label: option.label,
              l10n: _l10n,
            ),
          )
          .toList();
    }
  }

  List<ObservationFieldOption> _defaultOptions() {
    return [
      ObservationFieldOption(
        id: 'option-1',
        label: LocalizedText(
          nl: _l10n.adminOptionNumber(1),
          en: _l10n.adminOptionNumber(1),
        ),
      ),
      ObservationFieldOption(
        id: 'option-2',
        label: LocalizedText(
          nl: _l10n.adminOptionNumber(2),
          en: _l10n.adminOptionNumber(2),
        ),
      ),
    ];
  }

  void _handleTypeChanged(ObservationFieldType? value) {
    if (value == null || (!_typeChangeAllowed && value != _type)) return;
    setState(() {
      final previousType = _type;
      _type = value;
      if (_type == ObservationFieldType.multiSelect &&
          previousType != ObservationFieldType.multiSelect) {
        _optionAllowMultiple = true;
      }
      _errorText = null;
      final switchedBetweenTextAndOptions =
          (previousType == ObservationFieldType.text &&
              _type != ObservationFieldType.text) ||
          (_type == ObservationFieldType.text &&
              previousType != ObservationFieldType.text);
      if (switchedBetweenTextAndOptions) {
        _hydrateConfigState(null);
      }
    });
  }

  bool get _typeChangeAllowed => widget.canEditType;

  @override
  Widget build(BuildContext context) {
    final l10n = _l10n;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.field.isStandard
                        ? l10n.adminEditStandardField
                        : l10n.adminEditCustomField,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamilyHeading,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _FieldLanguage.values
                  .map(
                    (lang) => ChoiceChip(
                      label: Text(
                        lang == _FieldLanguage.nl
                            ? 'Nederlands 🇳🇱'
                            : 'English 🇬🇧',
                      ),
                      selected: _language == lang,
                      onSelected: (_) => setState(() => _language = lang),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _labelControllers[_language],
              decoration: InputDecoration(
                labelText: l10n.adminFieldLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _helperControllers[_language],
              decoration: InputDecoration(
                labelText: l10n.adminHelperTextOptional,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (_typeChangeAllowed)
              DropdownButtonFormField<ObservationFieldType>(
                initialValue: _type,
                decoration: InputDecoration(
                  labelText: l10n.adminFieldTypeLabel,
                  border: const OutlineInputBorder(),
                ),
                onChanged: _handleTypeChanged,
                items: _supportedTypes
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(_humanizeType(type)),
                      ),
                    )
                    .toList(),
              )
            else
              TextFormField(
                initialValue: _humanizeType(_type),
                decoration: InputDecoration(
                  labelText: l10n.adminFieldTypeLabel,
                  border: const OutlineInputBorder(),
                ),
                readOnly: true,
              ),
            const SizedBox(height: 16),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _isRequired,
              onChanged: (value) => setState(() => _isRequired = value),
              title: Text(l10n.adminRequiredField),
              subtitle: Text(
                l10n.adminRequiredFieldSubtitle,
              ),
            ),
            const SizedBox(height: 16),
            _buildAudienceSelector(),
            const Divider(height: 32),
            _buildConfigSection(),
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorText!,
                style: const TextStyle(
                  color: AppTheme.red600,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.commonCancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    child: Text(l10n.adminSaveChanges),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigSection() {
    switch (_type) {
      case ObservationFieldType.text:
        return _buildTextConfig();
      case ObservationFieldType.dropdown:
      case ObservationFieldType.multiSelect:
        return _buildOptionConfig();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAudienceSelector() {
    const options = [
      ObservationFieldAudience.individual,
      ObservationFieldAudience.group,
      ObservationFieldAudience.all,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.adminFormVisibility,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options
              .map(
                (option) => ChoiceChip(
                  label: Text(_audienceLabel(option)),
                  selected: _audience == option,
                  onSelected: (_) => setState(() => _audience = option),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }

  Widget _buildTextConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.adminTextFieldSettings,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _textPlaceholderController,
          decoration: InputDecoration(
            labelText: l10n.adminPlaceholderLabel,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _textMaxLengthController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l10n.adminMaxLengthOptional,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: _textMultiline,
          onChanged: (value) => setState(() => _textMultiline = value),
          title: Text(l10n.adminAllowMultilineInput),
        ),
      ],
    );
  }

  Widget _buildOptionConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.adminOptionsTitle,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ..._optionDrafts.map(_buildOptionRow),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addOption,
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.adminAddOption),
          ),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: _optionAllowMultiple,
          onChanged: (value) => setState(() => _optionAllowMultiple = value),
          title: Text(l10n.adminAllowMultipleValues),
        ),
      ],
    );
  }

  Widget _buildOptionRow(_OptionDraft draft) {
    final isLast = _optionDrafts.last == draft;
    final controller = draft.labelControllers[_language]!;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: l10n.adminFieldLabel,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            tooltip: l10n.adminRemoveOption,
            onPressed: _optionDrafts.length <= 1
                ? null
                : () => _removeOption(draft),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }

  void _addOption() {
    setState(() {
      _optionDrafts = [
        ..._optionDrafts,
        _OptionDraft.empty(_optionDrafts.length, l10n),
      ];
    });
  }

  void _removeOption(_OptionDraft draft) {
    setState(() {
      _optionDrafts = _optionDrafts.where((item) => item != draft).toList();
      draft.dispose();
    });
  }

  String _audienceLabel(ObservationFieldAudience value) {
    switch (value) {
      case ObservationFieldAudience.individual:
        return l10n.adminAudienceIndividual;
      case ObservationFieldAudience.group:
        return l10n.adminAudienceGroup;
      case ObservationFieldAudience.all:
        return l10n.adminAudienceBoth;
    }
  }

  String _humanizeType(ObservationFieldType type) {
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

  void _handleSubmit() {
    final labelNl = _labelControllers[_FieldLanguage.nl]!.text.trim();
    final labelEn = _labelControllers[_FieldLanguage.en]!.text.trim();
    if (labelNl.isEmpty) {
      setState(() => _errorText = l10n.adminFieldLabelRequiredError);
      return;
    }

    final helperNl = _helperControllers[_FieldLanguage.nl]!.text.trim();
    final helperEn = _helperControllers[_FieldLanguage.en]!.text.trim();
    final helper = helperNl.isEmpty && helperEn.isEmpty
        ? null
        : LocalizedText(
            nl: helperNl,
            en: helperEn.isEmpty ? null : helperEn,
          );
    ObservationFieldConfig? config;

    switch (_type) {
      case ObservationFieldType.text:
        final maxLength = int.tryParse(_textMaxLengthController.text.trim());
        config = TextObservationFieldConfig(
          maxLength: maxLength,
          multiline: _textMultiline,
          placeholder: _textPlaceholderController.text.trim().isEmpty
              ? null
              : _textPlaceholderController.text.trim(),
        );
        break;
      case ObservationFieldType.dropdown:
      case ObservationFieldType.multiSelect:
        final options = _optionDrafts
            .map((draft) => draft.toOption())
            .where((option) => option.label.nl.trim().isNotEmpty)
            .toList();
        if (options.length < 2) {
          setState(() => _errorText = l10n.adminOptionMinimumError);
          return;
        }
        final existingOptionConfig = widget.field.config;
        final previousAllowOther =
            existingOptionConfig is OptionObservationFieldConfig
            ? existingOptionConfig.allowOtherOption
            : false;
        config = OptionObservationFieldConfig(
          options: options,
          allowMultiple: _type == ObservationFieldType.multiSelect
              ? _optionAllowMultiple
              : false,
          allowOtherOption: previousAllowOther,
        );
        break;
      default:
        config = widget.field.config;
        break;
    }

    final updated = widget.field.copyWith(
      label: LocalizedText(
        nl: labelNl,
        en: labelEn.isEmpty ? null : labelEn,
      ),
      helperText: helper,
      isRequired: _isRequired,
      audience: _audience,
      type: widget.canEditType ? _type : widget.field.type,
      config: config,
    );
    Navigator.of(context).pop(updated);
  }
}

class _OptionDraft {
  _OptionDraft({required String id, required LocalizedText label, required this.l10n})
    : _id = id,
      labelControllers = {
        _FieldLanguage.nl: TextEditingController(text: label.nl),
        _FieldLanguage.en: TextEditingController(text: label.en ?? ''),
      };

  _OptionDraft.empty(int index, this.l10n)
    : _id = '',
      labelControllers = {
        _FieldLanguage.nl:
            TextEditingController(text: l10n.adminOptionNumber(index + 1)),
        _FieldLanguage.en:
            TextEditingController(text: l10n.adminOptionNumber(index + 1)),
      };

  final String _id;
  final Map<_FieldLanguage, TextEditingController> labelControllers;
  final AppLocalizations l10n;

  ObservationFieldOption toOption() {
    final labelNl = labelControllers[_FieldLanguage.nl]!.text.trim();
    final labelEn = labelControllers[_FieldLanguage.en]!.text.trim();
    final slug = _slugify(labelNl.isNotEmpty ? labelNl : labelEn);
    final id = (_id.isNotEmpty ? _id : slug).trim();
    return ObservationFieldOption(
      id: id.isEmpty ? 'option-${DateTime.now().millisecondsSinceEpoch}' : id,
      label: LocalizedText(
        nl: labelNl.isEmpty ? l10n.adminOptionFallback : labelNl,
        en: labelEn.isEmpty ? null : labelEn,
      ),
      description: null,
    );
  }

  void dispose() {
    for (final controller in labelControllers.values) {
      controller.dispose();
    }
  }
}

String _slugify(String input) {
  final sanitized = input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  final slug = sanitized.replaceAll(RegExp(r'-{2,}'), '-').trim();
  if (slug.isEmpty) return 'option-${DateTime.now().millisecondsSinceEpoch}';
  return slug.startsWith('-') ? slug.substring(1) : slug;
}

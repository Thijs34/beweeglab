/// Enumerates the supported observation field types.
enum ObservationFieldType {
  text,
  number,
  dropdown,
  multiSelect,
  checkbox,
  date,
  time,
  rating,
}

ObservationFieldType _parseObservationFieldType(String? raw) {
  if (raw == null) {
    return ObservationFieldType.text;
  }
  return ObservationFieldType.values.firstWhere(
    (value) => value.name.toLowerCase() == raw.toLowerCase(),
    orElse: () => ObservationFieldType.text,
  );
}

/// A selectable option used by dropdown/multi-select fields.
class ObservationFieldOption {
  final String id;
  final String label;
  final String? description;

  const ObservationFieldOption({
    required this.id,
    required this.label,
    this.description,
  });

  factory ObservationFieldOption.fromJson(Map<String, dynamic> json) {
    return ObservationFieldOption(
      id: (json['id'] as String? ?? json['value'] as String?) ?? '',
      label: json['label'] as String? ?? '',
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      if (description != null) 'description': description,
    };
  }
}

/// Base class for field-type specific configuration payloads.
abstract class ObservationFieldConfig {
  const ObservationFieldConfig();

  Map<String, dynamic> toJson();

  static ObservationFieldConfig? fromJson(
    ObservationFieldType type,
    Map<String, dynamic>? json,
  ) {
    if (json == null) return null;
    switch (type) {
      case ObservationFieldType.text:
        return TextObservationFieldConfig.fromJson(json);
      case ObservationFieldType.number:
        return NumberObservationFieldConfig.fromJson(json);
      case ObservationFieldType.dropdown:
      case ObservationFieldType.multiSelect:
        return OptionObservationFieldConfig.fromJson(json);
      case ObservationFieldType.checkbox:
        return CheckboxObservationFieldConfig.fromJson(json);
      case ObservationFieldType.rating:
        return RatingObservationFieldConfig.fromJson(json);
      case ObservationFieldType.date:
      case ObservationFieldType.time:
        return DateTimeObservationFieldConfig.fromJson(json);
    }
  }
}

class TextObservationFieldConfig extends ObservationFieldConfig {
  final int? maxLength;
  final bool multiline;
  final String? placeholder;

  const TextObservationFieldConfig({
    this.maxLength,
    this.multiline = false,
    this.placeholder,
  });

  factory TextObservationFieldConfig.fromJson(Map<String, dynamic> json) {
    return TextObservationFieldConfig(
      maxLength: (json['maxLength'] as num?)?.toInt(),
      multiline: json['multiline'] as bool? ?? false,
      placeholder: json['placeholder'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      if (maxLength != null) 'maxLength': maxLength,
      'multiline': multiline,
      if (placeholder != null) 'placeholder': placeholder,
    };
  }
}

class NumberObservationFieldConfig extends ObservationFieldConfig {
  final double? minValue;
  final double? maxValue;
  final bool allowDecimal;

  const NumberObservationFieldConfig({
    this.minValue,
    this.maxValue,
    this.allowDecimal = true,
  });

  factory NumberObservationFieldConfig.fromJson(Map<String, dynamic> json) {
    return NumberObservationFieldConfig(
      minValue: (json['minValue'] as num?)?.toDouble(),
      maxValue: (json['maxValue'] as num?)?.toDouble(),
      allowDecimal: json['allowDecimal'] as bool? ?? true,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      if (minValue != null) 'minValue': minValue,
      if (maxValue != null) 'maxValue': maxValue,
      'allowDecimal': allowDecimal,
    };
  }
}

class OptionObservationFieldConfig extends ObservationFieldConfig {
  final List<ObservationFieldOption> options;
  final bool allowMultiple;
  final bool allowOtherOption;

  const OptionObservationFieldConfig({
    required this.options,
    this.allowMultiple = false,
    this.allowOtherOption = false,
  });

  factory OptionObservationFieldConfig.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    final options = rawOptions is Iterable
        ? rawOptions
              .whereType<Map<String, dynamic>>()
              .map(ObservationFieldOption.fromJson)
              .toList(growable: false)
        : const <ObservationFieldOption>[];
    return OptionObservationFieldConfig(
      options: options,
      allowMultiple: json['allowMultiple'] as bool? ?? false,
      allowOtherOption: json['allowOtherOption'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'options': options.map((option) => option.toJson()).toList(),
      'allowMultiple': allowMultiple,
      'allowOtherOption': allowOtherOption,
    };
  }
}

class CheckboxObservationFieldConfig extends ObservationFieldConfig {
  final String? trueLabel;
  final String? falseLabel;

  const CheckboxObservationFieldConfig({this.trueLabel, this.falseLabel});

  factory CheckboxObservationFieldConfig.fromJson(Map<String, dynamic> json) {
    return CheckboxObservationFieldConfig(
      trueLabel: json['trueLabel'] as String?,
      falseLabel: json['falseLabel'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      if (trueLabel != null) 'trueLabel': trueLabel,
      if (falseLabel != null) 'falseLabel': falseLabel,
    };
  }
}

class RatingObservationFieldConfig extends ObservationFieldConfig {
  final int minScore;
  final int maxScore;
  final int step;

  const RatingObservationFieldConfig({
    this.minScore = 1,
    this.maxScore = 5,
    this.step = 1,
  }) : assert(minScore < maxScore, 'minScore must be < maxScore');

  factory RatingObservationFieldConfig.fromJson(Map<String, dynamic> json) {
    return RatingObservationFieldConfig(
      minScore: (json['minScore'] as num?)?.toInt() ?? 1,
      maxScore: (json['maxScore'] as num?)?.toInt() ?? 5,
      step: (json['step'] as num?)?.toInt() ?? 1,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'minScore': minScore, 'maxScore': maxScore, 'step': step};
  }
}

class DateTimeObservationFieldConfig extends ObservationFieldConfig {
  final bool includeTime;
  final bool includeDate;

  const DateTimeObservationFieldConfig({
    this.includeTime = false,
    this.includeDate = true,
  });

  factory DateTimeObservationFieldConfig.fromJson(Map<String, dynamic> json) {
    return DateTimeObservationFieldConfig(
      includeTime: json['includeTime'] as bool? ?? false,
      includeDate: json['includeDate'] as bool? ?? true,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'includeTime': includeTime, 'includeDate': includeDate};
  }
}

/// Field definition that combines the core metadata, type, and configuration.
class ObservationField {
  final String id;
  final String label;
  final ObservationFieldType type;
  final bool isRequired;
  final bool isStandard;
  final bool isEnabled;
  final String? helperText;
  final int displayOrder;
  final ObservationFieldConfig? config;

  const ObservationField({
    required this.id,
    required this.label,
    required this.type,
    this.isRequired = false,
    this.isStandard = false,
    this.isEnabled = true,
    this.helperText,
    this.displayOrder = 0,
    this.config,
  });

  ObservationField copyWith({
    String? id,
    String? label,
    ObservationFieldType? type,
    bool? isRequired,
    bool? isStandard,
    bool? isEnabled,
    String? helperText,
    int? displayOrder,
    ObservationFieldConfig? config,
  }) {
    return ObservationField(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      isRequired: isRequired ?? this.isRequired,
      isStandard: isStandard ?? this.isStandard,
      isEnabled: isEnabled ?? this.isEnabled,
      helperText: helperText ?? this.helperText,
      displayOrder: displayOrder ?? this.displayOrder,
      config: config ?? this.config,
    );
  }

  factory ObservationField.fromJson(Map<String, dynamic> json) {
    final type = _parseObservationFieldType(json['type'] as String?);
    final rawConfig = json['config'] as Map<String, dynamic>?;
    return ObservationField(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      type: type,
      isRequired: json['isRequired'] as bool? ?? false,
      isStandard: json['isStandard'] as bool? ?? false,
      isEnabled: json['isEnabled'] as bool? ?? true,
      helperText: json['helperText'] as String?,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      config: ObservationFieldConfig.fromJson(type, rawConfig),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'type': type.name,
      'isRequired': isRequired,
      'isStandard': isStandard,
      'isEnabled': isEnabled,
      if (helperText != null) 'helperText': helperText,
      'displayOrder': displayOrder,
      if (config != null) 'config': config!.toJson(),
    };
  }

  static List<ObservationField> listFromJson(dynamic raw) {
    if (raw is Iterable) {
      final parsed = raw
          .whereType<Map<String, dynamic>>()
          .map(ObservationField.fromJson)
          .toList(growable: true);
      parsed.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      return List<ObservationField>.unmodifiable(parsed);
    }
    return const [];
  }

  static List<Map<String, dynamic>> listToJson(List<ObservationField> fields) {
    return fields.map((field) => field.toJson()).toList(growable: false);
  }
}

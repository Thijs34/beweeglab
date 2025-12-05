import 'package:flutter/material.dart';

/// Lightweight bilingual text container with Dutch required and English optional.
class LocalizedText {
  final String nl;
  final String? en;

  const LocalizedText({required this.nl, this.en});

  /// Selects best value for locale; falls back to Dutch when English missing.
  String resolve(String locale) {
    final normalized = locale.toLowerCase();
    if (normalized.startsWith('en') && (en != null && en!.trim().isNotEmpty)) {
      return en!.trim();
    }
    return nl.trim();
  }

  LocalizedText copyWith({String? nl, String? en}) {
    return LocalizedText(nl: nl ?? this.nl, en: en ?? this.en);
  }

  Map<String, dynamic> toJson() {
    return {
      'nl': nl,
      if (en != null && en!.trim().isNotEmpty) 'en': en,
    };
  }

  static LocalizedText fromJson(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final nlValue = raw['nl'] as String? ?? '';
      final enValue = raw['en'] as String?;
      return LocalizedText(nl: nlValue, en: enValue);
    }
    if (raw is String) {
      // Legacy single-language payloads become Dutch primary.
      return LocalizedText(nl: raw);
    }
    return const LocalizedText(nl: '');
  }
}

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

enum ObservationFieldAudience { all, individual, group }

ObservationFieldType _parseObservationFieldType(String? raw) {
  if (raw == null) {
    return ObservationFieldType.text;
  }
  return ObservationFieldType.values.firstWhere(
    (value) => value.name.toLowerCase() == raw.toLowerCase(),
    orElse: () => ObservationFieldType.text,
  );
}

ObservationFieldAudience _parseObservationFieldAudience(String? raw) {
  if (raw == null) {
    return ObservationFieldAudience.all;
  }
  return ObservationFieldAudience.values.firstWhere(
    (value) => value.name.toLowerCase() == raw.toLowerCase(),
    orElse: () => ObservationFieldAudience.all,
  );
}

/// A selectable option used by dropdown/multi-select fields.
class ObservationFieldOption {
  final String id;
  final LocalizedText label;
  final String? description;
  final IconData? icon;

  /// Optional icon to visually represent this option in the UI

  const ObservationFieldOption({
    required this.id,
    required this.label,
    this.description,
    this.icon,
  });

  factory ObservationFieldOption.fromJson(Map<String, dynamic> json) {
    return ObservationFieldOption(
      id: (json['id'] as String? ?? json['value'] as String?) ?? '',
      label: LocalizedText.fromJson(json['label'] ?? json['value'] ?? ''),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label.toJson(),
      if (description != null) 'description': description,
    };
  }

  String labelForLocale(String locale) => label.resolve(locale);
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
  final LocalizedText label;
  final ObservationFieldType type;
  final ObservationFieldAudience audience;
  final bool isRequired;
  final bool isStandard;
  final bool isEnabled;
  final LocalizedText? helperText;
  final int displayOrder;
  final ObservationFieldConfig? config;

  const ObservationField({
    required this.id,
    required this.label,
    required this.type,
    this.audience = ObservationFieldAudience.all,
    this.isRequired = false,
    this.isStandard = false,
    this.isEnabled = true,
    this.helperText,
    this.displayOrder = 0,
    this.config,
  });

  ObservationField copyWith({
    String? id,
    LocalizedText? label,
    ObservationFieldType? type,
    ObservationFieldAudience? audience,
    bool? isRequired,
    bool? isStandard,
    bool? isEnabled,
    LocalizedText? helperText,
    int? displayOrder,
    ObservationFieldConfig? config,
  }) {
    return ObservationField(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      audience: audience ?? this.audience,
      isRequired: isRequired ?? this.isRequired,
      isStandard: isStandard ?? this.isStandard,
      isEnabled: isEnabled ?? this.isEnabled,
      helperText: helperText ?? this.helperText,
      displayOrder: displayOrder ?? this.displayOrder,
      config: config ?? this.config,
    );
  }

  factory ObservationField.fromJson(Map<String, dynamic> json) {
    final rawType = _parseObservationFieldType(json['type'] as String?);
    final type = rawType == ObservationFieldType.dropdown
        ? ObservationFieldType.multiSelect
        : rawType;
    final rawConfig = json['config'] as Map<String, dynamic>?;
    return ObservationField(
      id: json['id'] as String? ?? '',
      label: LocalizedText.fromJson(json['label'] ?? ''),
      type: type,
      isRequired: json['isRequired'] as bool? ?? false,
      isStandard: json['isStandard'] as bool? ?? false,
      isEnabled: json['isEnabled'] as bool? ?? true,
      helperText: json['helperText'] != null
          ? LocalizedText.fromJson(json['helperText'])
          : null,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      config: ObservationFieldConfig.fromJson(type, rawConfig),
      audience: _parseObservationFieldAudience(json['audience'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label.toJson(),
      'type': type.name,
      'audience': audience.name,
      'isRequired': isRequired,
      'isStandard': isStandard,
      'isEnabled': isEnabled,
      if (helperText != null) 'helperText': helperText!.toJson(),
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

  String labelForLocale(String locale) => label.resolve(locale);
  String? helperForLocale(String locale) => helperText?.resolve(locale);
}

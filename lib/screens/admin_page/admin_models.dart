import 'package:flutter/widgets.dart';
import 'package:my_app/l10n/gen/app_localizations.dart';
import 'package:my_app/models/observation_field.dart';
import 'package:my_app/models/observation_field_registry.dart';

enum ProjectStatus { active, finished, archived }

enum ProjectDetailSection { general, observers, fields, data }

ProjectStatus projectStatusFromString(String? rawValue) {
  switch (rawValue?.toLowerCase()) {
    case 'finished':
      return ProjectStatus.finished;
    case 'archived':
      return ProjectStatus.archived;
    case 'active':
    default:
      return ProjectStatus.active;
  }
}

extension ProjectStatusX on ProjectStatus {
  String get label {
    switch (this) {
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.finished:
        return 'Finished';
      case ProjectStatus.archived:
        return 'Archived';
    }
  }

  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case ProjectStatus.active:
        return l10n.adminStatusActive;
      case ProjectStatus.finished:
        return l10n.adminStatusFinished;
      case ProjectStatus.archived:
        return l10n.adminStatusArchived;
    }
  }

  String get firestoreValue {
    switch (this) {
      case ProjectStatus.active:
        return 'active';
      case ProjectStatus.finished:
        return 'finished';
      case ProjectStatus.archived:
        return 'archived';
    }
  }
}

extension ProjectDetailSectionX on ProjectDetailSection {
  String get label {
    switch (this) {
      case ProjectDetailSection.general:
        return 'General';
      case ProjectDetailSection.observers:
        return 'Observers';
      case ProjectDetailSection.fields:
        return 'Fields';
      case ProjectDetailSection.data:
        return 'Data';
    }
  }

  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case ProjectDetailSection.general:
        return l10n.adminSectionGeneral;
      case ProjectDetailSection.observers:
        return l10n.adminSectionObservers;
      case ProjectDetailSection.fields:
        return l10n.adminSectionFields;
      case ProjectDetailSection.data:
        return l10n.adminSectionData;
    }
  }
}

/// Helper to generate abbreviations for custom location labels
String generateLocationAbbreviation(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    return '';
  }
  final words = trimmed.split(RegExp(r"\s+"));
  if (words.length == 1) {
    return words.first.substring(0, 1).toUpperCase();
  }
  return words.take(3).map((word) => word[0].toUpperCase()).join();
}

/// Default location option shown in the React Admin UI
class AdminLocationOption {
  final String id;
  final String label;
  final String abbreviation;

  const AdminLocationOption({
    required this.id,
    required this.label,
    required this.abbreviation,
  });
}

/// Observer entry used throughout the admin UI
class AdminObserver {
  final String id;
  final String name;
  final String email;

  const AdminObserver({
    required this.id,
    required this.name,
    required this.email,
  });
}

/// Observation record card displayed inside the detail view
class ObservationRecord {
  final String id;
  final String personId;
  final String gender;
  final String ageGroup;
  final String socialContext;
  final String locationTypeId;
  final String activityLevel;
  final String activityType;
  final String notes;
  final String timestamp;
  final String projectId;
  final String mode;
  final String? observerEmail;
  final String? observerUid;
  final int? groupSize;
  final String? genderMix;
  final String? ageMix;
  final String? locationLabel;

  const ObservationRecord({
    required this.id,
    required this.personId,
    required this.gender,
    required this.ageGroup,
    required this.socialContext,
    required this.locationTypeId,
    required this.activityLevel,
    required this.activityType,
    required this.notes,
    required this.timestamp,
    this.projectId = '',
    this.mode = 'individual',
    this.observerEmail,
    this.observerUid,
    this.groupSize,
    this.genderMix,
    this.ageMix,
    this.locationLabel,
  });

  bool get isGroup => mode == 'group';
}

class AdminProject {
  final String id;
  final String name;
  final String description;
  final String mainLocation;
  final ProjectStatus status;
  final List<String> locationTypeIds;
  final List<String> assignedObserverIds;
  final List<ObservationField> fields;
  final List<ObservationRecord> observations;
  final int totalObservationCount;

  const AdminProject({
    required this.id,
    required this.name,
    required this.description,
    required this.mainLocation,
    this.status = ProjectStatus.active,
    required this.locationTypeIds,
    required this.assignedObserverIds,
    this.fields = const [],
    required this.observations,
    this.totalObservationCount = 0,
  });

  AdminProject copyWith({
    String? name,
    String? description,
    String? mainLocation,
    ProjectStatus? status,
    List<String>? locationTypeIds,
    List<String>? assignedObserverIds,
    List<ObservationField>? fields,
    List<ObservationRecord>? observations,
    int? totalObservationCount,
  }) {
    return AdminProject(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      mainLocation: mainLocation ?? this.mainLocation,
      status: status ?? this.status,
      locationTypeIds: List<String>.from(
        locationTypeIds ?? this.locationTypeIds,
      ),
      assignedObserverIds: List<String>.from(
        assignedObserverIds ?? this.assignedObserverIds,
      ),
      fields: List<ObservationField>.from(fields ?? this.fields),
      observations: List<ObservationRecord>.from(
        observations ?? this.observations,
      ),
      totalObservationCount:
          totalObservationCount ?? this.totalObservationCount,
    );
  }
}

/// Resolved location descriptor used by badges and dropdowns
class LocationDisplayData {
  final String label;
  final String abbreviation;
  final bool isCustom;

  const LocationDisplayData({
    required this.label,
    required this.abbreviation,
    required this.isCustom,
  });
}

LocationDisplayData resolveLocationDisplay(
  String id,
  List<AdminLocationOption> defaults,
) {
  if (id.startsWith('custom:')) {
    final raw = id.replaceFirst('custom:', '').trim();
    return LocationDisplayData(
      label: raw,
      abbreviation: generateLocationAbbreviation(raw),
      isCustom: true,
    );
  }

  final match = defaults.firstWhere(
    (option) => option.id == id,
    orElse: () => AdminLocationOption(
      id: id,
      label: id,
      abbreviation: id.substring(0, id.length >= 2 ? 2 : 1).toUpperCase(),
    ),
  );

  final normalizedLabel = match.label.contains('(')
      ? match.label.split('(').first.trim()
      : match.label;

  return LocationDisplayData(
    label: normalizedLabel,
    abbreviation: match.abbreviation,
    isCustom: false,
  );
}

/// Centralized mock data provider so every widget can stay lean
class AdminDataRepository {
  const AdminDataRepository._();

  static const List<AdminLocationOption> locationOptions = [
    AdminLocationOption(
      id: 'cruyff-court',
      label: 'Cruyff Court (C)',
      abbreviation: 'C',
    ),
    AdminLocationOption(
      id: 'basketball-field',
      label: 'Basketball Field (B)',
      abbreviation: 'B',
    ),
    AdminLocationOption(
      id: 'grass-field',
      label: 'Grass Field (G)',
      abbreviation: 'G',
    ),
    AdminLocationOption(
      id: 'playground',
      label: 'Playground (P)',
      abbreviation: 'P',
    ),
    AdminLocationOption(
      id: 'skate-park',
      label: 'Skate Park (S)',
      abbreviation: 'S',
    ),
  ];
}

ObservationField? _findFieldById(
  List<ObservationField> fields,
  String fieldId,
) {
  for (final field in fields) {
    if (field.id == fieldId) return field;
  }
  return null;
}

String localizeObservationOption({
  required List<ObservationField> fields,
  required String fieldId,
  required String rawValue,
  required Locale locale,
}) {
  if (rawValue.trim().isEmpty || rawValue == '—') return rawValue;
  final field = _findFieldById(fields, fieldId);
  if (field == null) return rawValue;
  final config = field.config;
  if (config is OptionObservationFieldConfig) {
    for (final option in config.options) {
      if (option.id == rawValue) {
        return option.labelForLocale(locale.languageCode);
      }
    }
  }
  return rawValue;
}

String localizeObservationLocation({
  required ObservationRecord record,
  required List<ObservationField> fields,
  required Locale locale,
}) {
  if (record.locationLabel != null && record.locationLabel!.trim().isNotEmpty) {
    return record.locationLabel!;
  }
  if (record.locationTypeId.startsWith('custom:')) {
    return record.locationTypeId.replaceFirst('custom:', '').trim();
  }
  return localizeObservationOption(
    fields: fields,
    fieldId: ObservationFieldRegistry.locationTypeFieldId,
    rawValue: record.locationTypeId,
    locale: locale,
  );
}

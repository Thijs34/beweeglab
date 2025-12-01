import 'package:flutter/material.dart';

enum ProjectStatus { active, finished, archived }

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

/// Project entity matching the React Admin Panel mock
class AdminProject {
  final String id;
  final String name;
  final String description;
  final String mainLocation;
  final ProjectStatus status;
  final List<String> locationTypeIds;
  final List<String> assignedObserverIds;
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

  static const List<AdminObserver> observers = [
    AdminObserver(
      id: '1',
      name: 'Emma van der Berg',
      email: 'emma@innobeweeglab.nl',
    ),
    AdminObserver(
      id: '2',
      name: 'Lucas Jansen',
      email: 'lucas@innobeweeglab.nl',
    ),
    AdminObserver(
      id: '3',
      name: 'Sophie Vermeer',
      email: 'sophie@innobeweeglab.nl',
    ),
    AdminObserver(
      id: '4',
      name: 'Thomas de Vries',
      email: 'thomas@innobeweeglab.nl',
    ),
    AdminObserver(id: '5', name: 'Nina Bakker', email: 'nina@innobeweeglab.nl'),
  ];

  static List<ObservationRecord> _observationsForProject(String id) {
    if (id != '1') {
      return const [];
    }
    return const [
      ObservationRecord(
        id: 'obs-1',
        personId: '1',
        gender: 'male',
        ageGroup: 'teen',
        socialContext: 'together',
        locationTypeId: 'cruyff-court',
        activityLevel: 'intense',
        activityType: 'organized',
        notes: 'Playing soccer with team',
        timestamp: '2025-11-17 14:23',
        projectId: '1',
      ),
      ObservationRecord(
        id: 'obs-2',
        personId: '2',
        gender: 'female',
        ageGroup: 'adult',
        socialContext: 'alone',
        locationTypeId: 'cruyff-court',
        activityLevel: 'moving',
        activityType: 'unorganized',
        notes: 'Jogging around the court',
        timestamp: '2025-11-17 14:35',
        projectId: '1',
      ),
      ObservationRecord(
        id: 'obs-3',
        personId: '3',
        gender: 'male',
        ageGroup: 'child',
        socialContext: 'together',
        locationTypeId: 'grass-field',
        activityLevel: 'intense',
        activityType: 'unorganized',
        notes: 'Playing tag with friends',
        timestamp: '2025-11-17 15:12',
        projectId: '1',
      ),
    ];
  }

  static List<AdminProject> initialProjects() {
    final initialObservations = _observationsForProject('1');
    final List<AdminProject> base = [
      AdminProject(
        id: '1',
        name: 'Parkstraat Observation Site',
        description: 'Main observation location with multiple facilities',
        mainLocation: 'Amsterdam Noord',
        status: ProjectStatus.active,
        locationTypeIds: const ['cruyff-court', 'grass-field'],
        assignedObserverIds: const ['1', '2'],
        observations: initialObservations,
        totalObservationCount: initialObservations.length,
      ),
      const AdminProject(
        id: '2',
        name: 'Eindhoven Sportpark',
        description: 'Community sports area with diverse activities',
        mainLocation: 'Eindhoven',
        status: ProjectStatus.active,
        locationTypeIds: ['grass-field', 'basketball-field'],
        assignedObserverIds: ['3'],
        observations: [],
        totalObservationCount: 0,
      ),
      const AdminProject(
        id: '3',
        name: 'City Center Basketball Court',
        description: 'Urban basketball facility',
        mainLocation: 'Rotterdam Centrum',
        status: ProjectStatus.active,
        locationTypeIds: ['basketball-field'],
        assignedObserverIds: [],
        observations: [],
        totalObservationCount: 0,
      ),
    ];

    return base
        .map(
          (project) => AdminProject(
            id: project.id,
            name: project.name,
            description: project.description,
            mainLocation: project.mainLocation,
            locationTypeIds: List<String>.from(project.locationTypeIds),
            assignedObserverIds: List<String>.from(project.assignedObserverIds),
            observations: project.observations,
            totalObservationCount: project.totalObservationCount,
          ),
        )
        .toList();
  }
}

/// Convenience chip styles for the admin panel; keeps widget code terse
class AdminChipStyle {
  final Color background;
  final Color border;
  final Color foreground;

  const AdminChipStyle({
    required this.background,
    required this.border,
    required this.foreground,
  });
}

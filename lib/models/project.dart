import 'package:cloud_firestore/cloud_firestore.dart';

/// Project model representing a field observation project.
class Project {
  final String id;
  final String name;
  final String mainLocation;
  final String? description;
  final List<String> assignedObserverIds;
  final List<String> locationTypeIds;
  final String status;
  final DateTime? updatedAt;
  final DateTime? createdAt;

  const Project({
    required this.id,
    required this.name,
    required this.mainLocation,
    this.description,
    this.assignedObserverIds = const [],
    this.locationTypeIds = const [],
    this.status = 'active',
    this.updatedAt,
    this.createdAt,
  });

  /// Temporary compatibility getter until the rest of the codebase migrates.
  String get location => mainLocation;

  Project copyWith({
    String? name,
    String? mainLocation,
    String? description,
    List<String>? assignedObserverIds,
    List<String>? locationTypeIds,
    String? status,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      mainLocation: mainLocation ?? this.mainLocation,
      description: description ?? this.description,
      assignedObserverIds: assignedObserverIds ?? this.assignedObserverIds,
      locationTypeIds: locationTypeIds ?? this.locationTypeIds,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Project.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return Project(
      id: snapshot.id,
      name: _normalizeName(data['name'] as String?),
      mainLocation: _normalizeLocation(data['mainLocation'] as String?),
      description: _trimOrNull(data['description'] as String?),
      assignedObserverIds: _toStringList(data['assignedObserverIds']),
      locationTypeIds: _toStringList(data['locationTypeIds']),
      status: (data['status'] as String?)?.toLowerCase() ?? 'active',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mainLocation': mainLocation,
      if (description != null) 'description': description,
      'assignedObserverIds': assignedObserverIds,
      'locationTypeIds': locationTypeIds,
      'status': status,
      'updatedAt': updatedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  static String _normalizeName(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return 'Untitled Project';
    }
    return trimmed;
  }

  static String _normalizeLocation(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return 'Unknown location';
    }
    return trimmed;
  }

  static String? _trimOrNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  static List<String> _toStringList(dynamic value) {
    if (value is Iterable) {
      return value.map((item) => item.toString()).toList(growable: false);
    }
    return const [];
  }
}

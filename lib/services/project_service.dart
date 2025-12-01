import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/models/project.dart';
import 'package:my_app/screens/admin_page/admin_models.dart';

class ProjectService {
  ProjectService._();

  static final ProjectService instance = ProjectService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'projects';

  CollectionReference<Map<String, dynamic>> get _projectsCollection =>
      _firestore.collection(_collection);

  Stream<List<Project>> watchObserverProjects(String observerId) {
    return _projectsCollection
        .where('assignedObserverIds', arrayContains: observerId)
        .snapshots()
        .map(
      (snapshot) => snapshot.docs
          .map((doc) => Project.fromFirestore(doc))
          .where(_isVisibleToObservers)
          .toList(growable: false),
    );
  }

  Future<List<Project>> fetchObserverProjects(String observerId) async {
    final snapshot = await _projectsCollection
        .where('assignedObserverIds', arrayContains: observerId)
        .get();
    return snapshot.docs
        .map((doc) => Project.fromFirestore(doc))
        .where(_isVisibleToObservers)
        .toList(growable: false);
  }

  Stream<List<AdminProject>> watchProjects() {
    return _projectsCollection.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => _mapSnapshotToProject(doc)).toList(),
    );
  }

  Future<List<AdminProject>> fetchProjects({
    ProjectStatus? status,
    int? limit,
  }) async {
    Query<Map<String, dynamic>> query = _projectsCollection;
    if (status != null) {
      query = query.where('status', isEqualTo: status.firestoreValue);
    }
    query = query.orderBy('updatedAt', descending: true);
    if (limit != null) {
      query = query.limit(limit);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => _mapSnapshotToProject(doc))
        .toList(growable: false);
  }

  Future<Map<ProjectStatus, int>> fetchStatusCounts() async {
    final futures = ProjectStatus.values.map((status) async {
      final aggregate = await _projectsCollection
          .where('status', isEqualTo: status.firestoreValue)
          .count()
          .get();
      return MapEntry(status, aggregate.count ?? 0);
    });
    return Map<ProjectStatus, int>.fromEntries(await Future.wait(futures));
  }

  Future<void> saveProject({
    required String projectId,
    required String name,
    required String mainLocation,
    required String description,
    required List<String> locationTypeIds,
    required List<String> assignedObserverIds,
    ProjectStatus status = ProjectStatus.active,
  }) async {
    await _projectsCollection.doc(projectId).set({
      'name': name,
      'mainLocation': mainLocation,
      'description': description,
      'locationTypeIds': locationTypeIds,
      'assignedObserverIds': assignedObserverIds,
      'status': status.firestoreValue,
      'observationCount': FieldValue.increment(0),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateAssignedObservers(
    String projectId,
    List<String> observerIds,
  ) async {
    await _projectsCollection.doc(projectId).set({
      'assignedObserverIds': observerIds,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateMainLocation(String projectId, String mainLocation) async {
    await _projectsCollection.doc(projectId).set({
      'mainLocation': mainLocation,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateProjectStatus(
    String projectId,
    ProjectStatus status,
  ) async {
    await _projectsCollection.doc(projectId).set({
      'status': status.firestoreValue,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> syncObservationCount(String projectId, int count) async {
    await _projectsCollection.doc(projectId).set({
      'observationCount': count,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteProject(String projectId) async {
    await _projectsCollection.doc(projectId).delete();
  }

  AdminProject _mapSnapshotToProject(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final rawLocations = data['locationTypeIds'] as List<dynamic>? ?? const [];
    final rawObservers =
        data['assignedObserverIds'] as List<dynamic>? ?? const [];
    final rawName = (data['name'] as String?)?.trim();
    final rawDescription = (data['description'] as String?)?.trim();
    final rawMainLocation = (data['mainLocation'] as String?)?.trim();
    final totalObservationCount =
        (data['observationCount'] as num?)?.toInt() ?? 0;

    return AdminProject(
      id: doc.id,
      name: (rawName == null || rawName.isEmpty) ? 'Untitled Project' : rawName,
      description: rawDescription ?? '',
      mainLocation: rawMainLocation ?? '',
      status: projectStatusFromString(data['status'] as String?),
      locationTypeIds: rawLocations
          .map((value) => value.toString())
          .toList(growable: false),
      assignedObserverIds: rawObservers
          .map((value) => value.toString())
          .toList(growable: false),
      observations: const [],
      totalObservationCount: totalObservationCount,
    );
  }

  bool _isVisibleToObservers(Project project) {
    final status = project.status.toLowerCase();
    return status != 'finished' && status != 'archived';
  }
}

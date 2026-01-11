import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/models/project.dart';
import 'package:my_app/screens/admin_page/admin_models.dart';
import 'package:my_app/screens/observer_page/models/observation_mode.dart';
import 'package:my_app/screens/observer_page/models/observer_entry.dart';

class ObservationPageResult {
  final List<ObservationRecord> records;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  final bool hasMore;

  const ObservationPageResult({
    required this.records,
    required this.lastDocument,
    required this.hasMore,
  });
}

/// Handles persistence of observer entries per project.
class ObservationService {
  ObservationService._();

  static final ObservationService instance = ObservationService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _projectsCollection = 'projects';
  static const String _observationsSubcollection = 'observations';

  Future<ObservationPageResult> fetchObservationPage({
    required String projectId,
    required int limit,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection(_projectsCollection)
        .doc(projectId)
        .collection(_observationsSubcollection)
        .orderBy('recordedAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final records = snapshot.docs
        .map((doc) => _mapDocToObservation(doc, fallbackProjectId: projectId))
        .toList(growable: false);

    final lastDocument = snapshot.docs.isEmpty ? null : snapshot.docs.last;
    final hasMore = snapshot.docs.length == limit && lastDocument != null;

    return ObservationPageResult(
      records: records,
      lastDocument: lastDocument,
      hasMore: hasMore,
    );
  }

  Future<void> saveObservation({
    required Project project,
    required ObserverEntry entry,
    required String observerUid,
    String? observerEmail,
  }) async {
    final docRef = _firestore
        .collection(_projectsCollection)
        .doc(project.id)
        .collection(_observationsSubcollection)
        .doc();

    final payload = _buildPayload(
      project: project,
      entry: entry,
      observerUid: observerUid,
      observerEmail: observerEmail,
    );

    await docRef.set(payload);
    await _firestore.collection(_projectsCollection).doc(project.id).set({
      'observationCount': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  Future<void> updateObservation({
    required String projectId,
    required ObservationRecord record,
  }) async {
    final docRef = _firestore
        .collection(_projectsCollection)
        .doc(projectId)
        .collection(_observationsSubcollection)
        .doc(record.id);

     await docRef.set({
      'personId': record.personId.trim(),
      'gender': record.gender.trim(),
      'ageGroup': record.ageGroup.trim(),
      'socialContext': record.socialContext.trim(),
      'activityLevel': record.activityLevel.trim(),
      'activityType': record.activityType.trim(),
      'activityNotes': record.notes.trim(),
    }, SetOptions(merge: true));
  }

  Stream<List<ObservationRecord>> watchProjectObservations({
    required String projectId,
    required int limit,
  }) {
    return _firestore
        .collection(_projectsCollection)
        .doc(projectId)
        .collection(_observationsSubcollection)
        .orderBy('recordedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    _mapDocToObservation(doc, fallbackProjectId: projectId),
              )
              .toList(growable: false),
        );
  }

  Future<List<ObservationRecord>> fetchAllObservations({
    required String projectId,
  }) async {
    final snapshot = await _firestore
        .collection(_projectsCollection)
        .doc(projectId)
        .collection(_observationsSubcollection)
        .orderBy('recordedAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => _mapDocToObservation(doc, fallbackProjectId: projectId))
        .toList(growable: false);
  }

  Future<int> countObservations({required String projectId}) async {
    final snapshot = await _firestore
        .collection(_projectsCollection)
        .doc(projectId)
        .collection(_observationsSubcollection)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  Map<String, dynamic> _buildPayload({
    required Project project,
    required ObserverEntry entry,
    required String observerUid,
    String? observerEmail,
  }) {
    final shared = entry.shared;
    final locationId = _normalizeLocationId(
      shared.locationType,
      shared.customLocation,
    );
    final isGroup = entry.mode == ObservationMode.group;
    final individual = entry.individual;
    final group = entry.group;
    final personId = individual?.personId.trim();
    final gender = individual?.gender.trim();
    final ageGroup = individual?.ageGroup.trim();
    final socialContext = individual?.socialContext.trim();
    final payload = <String, dynamic>{
      'projectId': project.id,
      'projectName': project.name,
      'projectMainLocation': project.mainLocation,
      'observerUid': observerUid,
      if (observerEmail != null) 'observerEmail': observerEmail,
      'mode': entry.mode.name,
      'recordedAt': FieldValue.serverTimestamp(),
      'localRecordedAt': entry.timestamp.toIso8601String(),
      'locationTypeId': locationId,
      if (shared.customLocation != null &&
          shared.customLocation!.trim().isNotEmpty)
        'customLocationLabel': shared.customLocation!.trim(),
      'activityLevel': shared.activityLevel,
      'activityType': shared.activityType,
      'activityNotes': shared.activityNotes.trim(),
      if (shared.additionalRemarks.trim().isNotEmpty)
        'additionalRemarks': shared.additionalRemarks.trim(),
      'personId': isGroup
          ? 'group-${group?.groupSize ?? 0}'
          : (personId?.isNotEmpty == true ? personId! : '--'),
      'gender': isGroup
          ? _serializeDemographicCounts(group?.genderCounts ?? {})
          : (gender?.isNotEmpty == true ? gender! : '--'),
      'ageGroup': isGroup
          ? _serializeDemographicCounts(group?.ageCounts ?? {})
          : (ageGroup?.isNotEmpty == true ? ageGroup! : '--'),
      'socialContext': isGroup
          ? 'together'
          : (socialContext?.isNotEmpty == true ? socialContext! : '--'),
      'groupSize': group?.groupSize,
      'genderCounts': group?.genderCounts,
      'ageCounts': group?.ageCounts,
      if (group?.demographicPairs != null && group!.demographicPairs!.isNotEmpty)
        'demographicPairs': group.demographicPairs!.map((p) => p.toJson()).toList(),
    };

    return payload;
  }

  ObservationRecord _mapDocToObservation(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String fallbackProjectId,
  }) {
    final data = doc.data() ?? const <String, dynamic>{};
    final recordedAt =
        (data['recordedAt'] as Timestamp?)?.toDate() ??
        DateTime.tryParse((data['localRecordedAt'] as String?) ?? '');
    final mode = (data['mode'] as String?) ?? 'individual';
    final groupSize = (data['groupSize'] as num?)?.toInt();
    final notes = _composeNotes(
      data['activityNotes'] as String?,
      data['additionalRemarks'] as String?,
    );
    final locationId = _extractLocationId(data);

    final fallbackPersonId = (data['personId'] as String?) ?? '--';
    final displayPersonId = mode == 'group'
        ? 'Group ${groupSize ?? ''}'.trim()
        : fallbackPersonId;

    return ObservationRecord(
      id: doc.id,
      projectId: (data['projectId'] as String?) ?? fallbackProjectId,
      personId: displayPersonId.isEmpty ? '--' : displayPersonId,
      gender: (data['gender'] as String?) ?? '--',
      ageGroup: (data['ageGroup'] as String?) ?? '--',
      socialContext: (data['socialContext'] as String?) ?? '--',
      locationTypeId: locationId,
      activityLevel: (data['activityLevel'] as String?) ?? '--',
      activityType: (data['activityType'] as String?) ?? '--',
      notes: notes,
      timestamp: _formatTimestamp(recordedAt),
      mode: mode,
      observerEmail: data['observerEmail'] as String?,
      observerUid: data['observerUid'] as String?,
      groupSize: groupSize,
      genderMix: _extractDemographicDisplay(data, 'genderCounts', 'genderMix'),
      ageMix: _extractDemographicDisplay(data, 'ageCounts', 'ageMix'),
      genderCounts: _extractDemographicCounts(data, 'genderCounts'),
      ageCounts: _extractDemographicCounts(data, 'ageCounts'),
      locationLabel: data['customLocationLabel'] as String?,
      demographicPairs: _extractDemographicPairs(data),
    );
  }

  String _normalizeLocationId(String locationType, String? customLabel) {
    if (locationType == 'custom') {
      final trimmed = customLabel?.trim();
      if (trimmed == null || trimmed.isEmpty) {
        return 'custom:custom-location';
      }
      return 'custom:$trimmed';
    }
    return locationType;
  }

  String _extractLocationId(Map<String, dynamic> data) {
    final direct = data['locationTypeId'] as String?;
    if (direct != null && direct.isNotEmpty) {
      return direct;
    }
    final shared = data['shared'];
    if (shared is Map<String, dynamic>) {
      final raw = shared['locationType'] as String?;
      final custom = shared['customLocation'] as String?;
      if (raw != null) {
        return _normalizeLocationId(raw, custom);
      }
    }
    return 'unknown';
  }

  String _composeNotes(String? primary, String? additional) {
    final buffer = <String>[];
    final primaryTrimmed = primary?.trim();
    if (primaryTrimmed != null && primaryTrimmed.isNotEmpty) {
      buffer.add(primaryTrimmed);
    }
    final secondaryTrimmed = additional?.trim();
    if (secondaryTrimmed != null && secondaryTrimmed.isNotEmpty) {
      buffer.add(secondaryTrimmed);
    }
    if (buffer.isEmpty) {
      return '';
    }
    return buffer.join('\n');
  }

  String _formatTimestamp(DateTime? value) {
    if (value == null) {
      return '--';
    }
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }

  /// Serializes demographic counts to a readable string for display
  /// Example: {"male": 3, "female": 2} -> "Male: 3, Female: 2"
  String _serializeDemographicCounts(Map<String, int> counts) {
    if (counts.isEmpty) {
      return '--';
    }
    final nonZero = counts.entries.where((e) => e.value > 0);
    if (nonZero.isEmpty) {
      return '--';
    }
    return nonZero.map((e) => '${e.key}: ${e.value}').join(', ');
  }

  /// Extracts demographic display from either counts map (new format) or string (old format)
  String? _extractDemographicDisplay(
    Map<String, dynamic> data,
    String countsKey,
    String fallbackKey,
  ) {
    // Try new format first (counts map)
    final countsData = data[countsKey];
    if (countsData is Map) {
      final counts = Map<String, int>.from(
        countsData.map(
          (key, value) => MapEntry(key.toString(), (value as num).toInt()),
        ),
      );
      return _serializeDemographicCounts(counts);
    }

    // Fall back to old format (string)
    return data[fallbackKey] as String?;
  }

  Map<String, int>? _extractDemographicCounts(
    Map<String, dynamic> data,
    String key,
  ) {
    final raw = data[key];
    if (raw is Map) {
      final counts = <String, int>{};
      raw.forEach((entryKey, value) {
        if (value is num) {
          counts[entryKey.toString()] = value.toInt();
        }
      });
      if (counts.isNotEmpty) {
        return counts;
      }
    }
    return null;
  }

  List<DemographicPairData>? _extractDemographicPairs(
    Map<String, dynamic> data,
  ) {
    final raw = data['demographicPairs'];
    if (raw is List) {
      final pairs = raw
          .whereType<Map<String, dynamic>>()
          .map((e) => DemographicPairData.fromJson(e))
          .toList();
      if (pairs.isNotEmpty) {
        return pairs;
      }
    }
    return null;
  }
}

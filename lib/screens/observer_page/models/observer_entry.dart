import 'package:my_app/screens/observer_page/models/observation_mode.dart';

class ObserverEntry {
  final ObservationMode mode;
  final IndividualSnapshot? individual;
  final GroupSnapshot? group;
  final SharedSnapshot shared;
  final DateTime timestamp;

  ObserverEntry({
    required this.mode,
    required this.shared,
    required this.timestamp,
    this.individual,
    this.group,
  });

  Map<String, dynamic> toJson() {
    return {
      'mode': mode.name,
      'timestamp': timestamp.toIso8601String(),
      'shared': shared.toJson(),
      if (individual != null) 'individual': individual!.toJson(),
      if (group != null) 'group': group!.toJson(),
    };
  }

  factory ObserverEntry.fromJson(Map<String, dynamic> json) {
    final modeValue =
        json['mode'] as String? ?? ObservationMode.individual.name;
    final parsedMode = ObservationMode.values.firstWhere(
      (candidate) => candidate.name == modeValue,
      orElse: () => ObservationMode.individual,
    );
    final sharedRaw = json['shared'];
    final individualRaw = json['individual'];
    final groupRaw = json['group'];
    return ObserverEntry(
      mode: parsedMode,
      shared: SharedSnapshot.fromJson(
        sharedRaw is Map<String, dynamic>
            ? sharedRaw
            : const <String, dynamic>{},
      ),
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      individual: individualRaw is Map<String, dynamic>
          ? IndividualSnapshot.fromJson(individualRaw)
          : null,
      group: groupRaw is Map<String, dynamic>
          ? GroupSnapshot.fromJson(groupRaw)
          : null,
    );
  }
}

class IndividualSnapshot {
  final String personId;
  final String gender;
  final String ageGroup;
  final String socialContext;

  const IndividualSnapshot({
    required this.personId,
    required this.gender,
    required this.ageGroup,
    required this.socialContext,
  });

  Map<String, dynamic> toJson() {
    return {
      'personId': personId,
      'gender': gender,
      'ageGroup': ageGroup,
      'socialContext': socialContext,
    };
  }

  factory IndividualSnapshot.fromJson(Map<String, dynamic> json) {
    return IndividualSnapshot(
      personId: json['personId'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      ageGroup: json['ageGroup'] as String? ?? '',
      socialContext: json['socialContext'] as String? ?? '',
    );
  }
}

class GroupSnapshot {
  final int groupSize;
  final Map<String, int> genderCounts;
  final Map<String, int> ageCounts;

  const GroupSnapshot({
    required this.groupSize,
    required this.genderCounts,
    required this.ageCounts,
  });

  Map<String, dynamic> toJson() {
    return {
      'groupSize': groupSize,
      'genderCounts': genderCounts,
      'ageCounts': ageCounts,
    };
  }

  factory GroupSnapshot.fromJson(Map<String, dynamic> json) {
    final genderCountsRaw = json['genderCounts'];
    final ageCountsRaw = json['ageCounts'];

    return GroupSnapshot(
      groupSize: (json['groupSize'] as num?)?.toInt() ?? 0,
      genderCounts: genderCountsRaw is Map
          ? Map<String, int>.from(
              genderCountsRaw.map(
                (key, value) =>
                    MapEntry(key.toString(), (value as num).toInt()),
              ),
            )
          : {},
      ageCounts: ageCountsRaw is Map
          ? Map<String, int>.from(
              ageCountsRaw.map(
                (key, value) =>
                    MapEntry(key.toString(), (value as num).toInt()),
              ),
            )
          : {},
    );
  }
}

class SharedSnapshot {
  final String locationType;
  final String? customLocation;
  final String activityLevel;
  final String activityType;
  final String activityNotes;
  final String additionalRemarks;

  const SharedSnapshot({
    required this.locationType,
    this.customLocation,
    required this.activityLevel,
    required this.activityType,
    required this.activityNotes,
    required this.additionalRemarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'locationType': locationType,
      'customLocation': customLocation,
      'activityLevel': activityLevel,
      'activityType': activityType,
      'activityNotes': activityNotes,
      'additionalRemarks': additionalRemarks,
    };
  }

  factory SharedSnapshot.fromJson(Map<String, dynamic> json) {
    return SharedSnapshot(
      locationType: json['locationType'] as String? ?? '',
      customLocation: json['customLocation'] as String?,
      activityLevel: json['activityLevel'] as String? ?? '',
      activityType: json['activityType'] as String? ?? '',
      activityNotes: json['activityNotes'] as String? ?? '',
      additionalRemarks: json['additionalRemarks'] as String? ?? '',
    );
  }
}

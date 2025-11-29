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
}

class GroupSnapshot {
  final int groupSize;
  final String genderMix;
  final String ageMix;

  const GroupSnapshot({
    required this.groupSize,
    required this.genderMix,
    required this.ageMix,
  });
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
}

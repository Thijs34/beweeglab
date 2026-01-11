import 'package:my_app/screens/observer_page/models/observation_mode.dart';
import 'package:my_app/screens/observer_page/models/weather_condition.dart';

class ObserverEntry {
  final ObservationMode mode;
  final IndividualSnapshot? individual;
  final GroupSnapshot? group;
  final SharedSnapshot shared;
  final Map<String, dynamic> fieldValues;
  final WeatherCondition weatherCondition;
  final String temperatureLabel;
  final DateTime timestamp;

  ObserverEntry({
    required this.mode,
    required this.shared,
    required this.timestamp,
    required this.weatherCondition,
    required this.temperatureLabel,
    this.fieldValues = const {},
    this.individual,
    this.group,
  });

  Map<String, dynamic> toJson() {
    return {
      'mode': mode.name,
      'timestamp': timestamp.toIso8601String(),
      'shared': shared.toJson(),
      'fieldValues': fieldValues,
      'weatherCondition': weatherCondition.name,
      'temperatureLabel': temperatureLabel,
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
    final fieldValuesRaw = json['fieldValues'];
    final weatherRaw = json['weatherCondition'] as String?;
    final temperatureLabel = json['temperatureLabel'] as String? ?? '--°C';
    final parsedWeather = WeatherCondition.values.firstWhere(
      (item) => item.name == weatherRaw,
      orElse: () => WeatherCondition.sunny,
    );
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
      fieldValues: fieldValuesRaw is Map<String, dynamic>
          ? Map<String, dynamic>.from(fieldValuesRaw)
          : const <String, dynamic>{},
      weatherCondition: parsedWeather,
      temperatureLabel: temperatureLabel,
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
  final int groupNumber;
  final Map<String, int> genderCounts;
  final Map<String, int> ageCounts;
  final List<DemographicPair>? demographicPairs;

  const GroupSnapshot({
    required this.groupSize,
    required this.groupNumber,
    required this.genderCounts,
    required this.ageCounts,
    this.demographicPairs,
  });

  Map<String, dynamic> toJson() {
    return {
      'groupSize': groupSize,
      'groupNumber': groupNumber,
      'genderCounts': genderCounts,
      'ageCounts': ageCounts,
      if (demographicPairs != null)
        'demographicPairs': demographicPairs!.map((p) => p.toJson()).toList(),
    };
  }

  factory GroupSnapshot.fromJson(Map<String, dynamic> json) {
    final genderCountsRaw = json['genderCounts'];
    final ageCountsRaw = json['ageCounts'];
    final demographicPairsRaw = json['demographicPairs'];

    return GroupSnapshot(
      groupSize: (json['groupSize'] as num?)?.toInt() ?? 0,
      groupNumber: (json['groupNumber'] as num?)?.toInt() ?? 1,
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
      demographicPairs: demographicPairsRaw is List
          ? demographicPairsRaw
                .whereType<Map<String, dynamic>>()
                .map((e) => DemographicPair.fromJson(e))
                .toList()
          : null,
    );
  }
}

class DemographicPair {
  final String genderId;
  final String ageId;

  const DemographicPair({required this.genderId, required this.ageId});

  Map<String, dynamic> toJson() {
    return {'genderId': genderId, 'ageId': ageId};
  }

  factory DemographicPair.fromJson(Map<String, dynamic> json) {
    return DemographicPair(
      genderId: json['genderId'] as String? ?? '',
      ageId: json['ageId'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DemographicPair &&
          runtimeType == other.runtimeType &&
          genderId == other.genderId &&
          ageId == other.ageId;

  @override
  int get hashCode => genderId.hashCode ^ ageId.hashCode;
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

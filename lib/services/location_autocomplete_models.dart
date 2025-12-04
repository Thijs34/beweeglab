class LocationPrediction {
  final String description;
  final String primaryText;
  final String? secondaryText;
  final String placeId;

  const LocationPrediction({
    required this.description,
    required this.primaryText,
    required this.placeId,
    this.secondaryText,
  });

  factory LocationPrediction.fromJson(Map<String, dynamic> json) {
    final structured = json['structured_formatting'] as Map<String, dynamic>?;
    return LocationPrediction(
      description: json['description'] as String? ?? '',
      primaryText:
          structured?['main_text'] as String? ??
          json['description'] as String? ??
          '',
      secondaryText: structured?['secondary_text'] as String?,
      placeId: json['place_id'] as String? ?? '',
    );
  }
}

/// Lightweight latitude/longitude holder shared by location services.
class LocationCoordinates {
  final double latitude;
  final double longitude;

  const LocationCoordinates({required this.latitude, required this.longitude});

  bool get isValid =>
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;
}

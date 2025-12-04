import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/config/app_config.dart';

import 'location_autocomplete_models.dart';
import 'location_autocomplete_web_delegate_base.dart';
import 'location_autocomplete_web_delegate_stub.dart'
    if (dart.library.html) 'location_autocomplete_web_delegate_web.dart';

export 'location_autocomplete_models.dart';

class LocationAutocompleteService {
  LocationAutocompleteService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client(),
      _webDelegate = kIsWeb ? createLocationAutocompleteWebDelegate() : null;

  final http.Client _httpClient;
  final LocationAutocompleteWebDelegate? _webDelegate;

  static const _endpoint =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static const _geocodeEndpoint =
      'https://maps.googleapis.com/maps/api/geocode/json';

  final Map<String, LocationCoordinates> _geocodeCache = {};

  Future<List<LocationPrediction>> fetchSuggestions(String input) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return const <LocationPrediction>[];
    }

    final delegate = _webDelegate;
    if (delegate != null) {
      return delegate.fetchSuggestions(trimmed);
    }

    final apiKey = AppConfig.googlePlacesApiKey;
    if (apiKey == null) {
      throw StateError('Missing Google Places API key.');
    }

    final uri = Uri.parse(_endpoint).replace(
      queryParameters: {'input': trimmed, 'key': apiKey, 'language': 'en'},
    );

    final response = await _httpClient.get(uri);
    if (response.statusCode != 200) {
      throw Exception(
        'Autocomplete request failed with ${response.statusCode}.',
      );
    }

    final Map<String, dynamic> body =
        json.decode(response.body) as Map<String, dynamic>;
    final status = body['status'] as String?;

    if (status == 'ZERO_RESULTS') {
      return const <LocationPrediction>[];
    }

    if (status != 'OK') {
      throw Exception('Places API returned status $status');
    }

    final predictions = body['predictions'] as List<dynamic>?;
    if (predictions == null) {
      return const <LocationPrediction>[];
    }

    return predictions
        .map((raw) => LocationPrediction.fromJson(raw as Map<String, dynamic>))
        .where(
          (prediction) =>
              prediction.description.isNotEmpty &&
              prediction.placeId.isNotEmpty,
        )
        .toList(growable: false);
  }

  Future<LocationCoordinates?> resolveCoordinates(String input) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final cacheKey = trimmed.toLowerCase();
    final cached = _geocodeCache[cacheKey];
    if (cached != null) {
      return cached;
    }

    final apiKey = AppConfig.googlePlacesApiKey;
    if (apiKey == null) {
      throw StateError('Missing Google Places API key.');
    }

    final uri = Uri.parse(_geocodeEndpoint).replace(
      queryParameters: {'address': trimmed, 'region': 'nl', 'key': apiKey},
    );

    final response = await _httpClient.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Geocoding request failed with ${response.statusCode}.');
    }

    final Map<String, dynamic> body =
        json.decode(response.body) as Map<String, dynamic>;
    final status = body['status'] as String?;

    if (status == 'ZERO_RESULTS') {
      return null;
    }

    if (status != 'OK') {
      throw Exception('Geocoding API returned status $status');
    }

    final results = body['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) {
      return null;
    }

    final geometry = (results.first as Map<String, dynamic>)['geometry'];
    final location = geometry is Map<String, dynamic>
        ? geometry['location'] as Map<String, dynamic>?
        : null;
    final latitude = (location?['lat'] as num?)?.toDouble();
    final longitude = (location?['lng'] as num?)?.toDouble();

    if (latitude == null || longitude == null) {
      return null;
    }

    final coordinates = LocationCoordinates(
      latitude: latitude,
      longitude: longitude,
    );
    if (!coordinates.isValid) {
      return null;
    }

    _geocodeCache[cacheKey] = coordinates;
    return coordinates;
  }

  void dispose() {
    _httpClient.close();
    _webDelegate?.dispose();
  }
}

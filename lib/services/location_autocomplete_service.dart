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
        _webDelegate =
            kIsWeb ? createLocationAutocompleteWebDelegate() : null;

  final http.Client _httpClient;
  final LocationAutocompleteWebDelegate? _webDelegate;

  static const _endpoint =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';

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

    final uri = Uri.parse(_endpoint).replace(queryParameters: {
      'input': trimmed,
      'key': apiKey,
      'language': 'en',
    });

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
      .map((raw) => LocationPrediction.fromJson(
        raw as Map<String, dynamic>))
        .where((prediction) =>
            prediction.description.isNotEmpty && prediction.placeId.isNotEmpty)
        .toList(growable: false);
  }

  void dispose() {
    _httpClient.close();
    _webDelegate?.dispose();
  }
}

// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

import 'package:my_app/config/app_config.dart';

import 'location_autocomplete_models.dart';
import 'location_autocomplete_web_delegate_base.dart';

LocationAutocompleteWebDelegate? createLocationAutocompleteWebDelegate() =>
    _WebLocationAutocompleteDelegate();

class _WebLocationAutocompleteDelegate
    extends LocationAutocompleteWebDelegate {
  static const _language = 'en';
  static const _scriptId = 'google-places-sdk';
  static bool _scriptInjected = false;

  Completer<void>? _initCompleter;
  Object? _autocompleteSuggestionClass;
  Object? _sessionTokenConstructor;

  @override
  Future<List<LocationPrediction>> fetchSuggestions(String input) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return const <LocationPrediction>[];
    }

    await _ensureInitialized();

    final request = js_util.newObject();
    js_util.setProperty(request, 'input', trimmed);
    js_util.setProperty(request, 'language', _language);
    js_util.setProperty(
      request,
      'sessionToken',
      js_util.callConstructor(_sessionTokenConstructor!, const []),
    );

    final result = await js_util.promiseToFuture<Object?>(
      js_util.callMethod(
        _autocompleteSuggestionClass!,
        'fetchAutocompleteSuggestions',
        [request],
      ),
    );

    return _mapResult(result);
  }

  List<LocationPrediction> _mapResult(Object? result) {
    if (result == null) {
      return const <LocationPrediction>[];
    }
    final suggestions = js_util.getProperty(result, 'suggestions');
    if (suggestions == null) {
      return const <LocationPrediction>[];
    }

    final length = js_util.getProperty(suggestions, 'length') as int? ?? 0;
    final predictions = <LocationPrediction>[];
    for (var index = 0; index < length; index++) {
      final suggestion = js_util.getProperty(suggestions, index);
      final prediction = _mapPrediction(suggestion);
      if (prediction != null) {
        predictions.add(prediction);
      }
    }
    return predictions;
  }

  LocationPrediction? _mapPrediction(Object? suggestion) {
    if (suggestion == null) {
      return null;
    }
    final placePrediction =
        js_util.getProperty(suggestion, 'placePrediction');
    if (placePrediction == null) {
      return null;
    }

    final description =
        _readLocalizedText(js_util.getProperty(placePrediction, 'text'));
    if (description.isEmpty) {
      return null;
    }

    var primary = description;
    String? secondary;
    final structuredFormat = js_util.getProperty(
          placePrediction,
          'structuredFormat',
        ) ??
        js_util.getProperty(placePrediction, 'structuredFormatting');
    if (structuredFormat != null) {
      final mainText =
          _readLocalizedText(js_util.getProperty(structuredFormat, 'mainText'));
      if (mainText.isNotEmpty) {
        primary = mainText;
      }
      final secondaryText = _readLocalizedText(
        js_util.getProperty(structuredFormat, 'secondaryText'),
      );
      if (secondaryText.isNotEmpty) {
        secondary = secondaryText;
      }
    }

    final placeId =
        js_util.getProperty(placePrediction, 'placeId') as String? ?? '';
    if (placeId.isEmpty) {
      return null;
    }

    return LocationPrediction(
      description: description,
      primaryText: primary,
      secondaryText: secondary,
      placeId: placeId,
    );
  }

  String _readLocalizedText(Object? value) {
    if (value == null) {
      return '';
    }
    final converted = js_util.callMethod(value, 'toString', const []);
    if (converted is String) {
      return converted;
    }
    if (value is String) {
      return value;
    }
    return value.toString();
  }

  Future<void> _ensureInitialized() {
    if (_initCompleter != null) {
      return _initCompleter!.future;
    }

    _initCompleter = Completer<void>();
    final apiKey = AppConfig.googlePlacesApiKey;
    if (apiKey == null) {
      _initCompleter!.completeError(
        StateError('Missing Google Places API key.'),
      );
      return _initCompleter!.future;
    }

    () async {
      try {
        if (!_isGoogleReady()) {
          _injectScript(apiKey);
          await _waitForGoogleReady();
        }

        final Object placesLibrary = await _loadPlacesLibrary();
        _autocompleteSuggestionClass =
            js_util.getProperty(placesLibrary, 'AutocompleteSuggestion');
        _sessionTokenConstructor =
            js_util.getProperty(placesLibrary, 'AutocompleteSessionToken');

        if (_autocompleteSuggestionClass == null ||
            _sessionTokenConstructor == null) {
          throw StateError(
            'Google Places AutocompleteSuggestion API is unavailable.',
          );
        }

        _initCompleter!.complete();
      } catch (error, stackTrace) {
        if (!(_initCompleter?.isCompleted ?? true)) {
          _initCompleter!.completeError(error, stackTrace);
        }
      }
    }();

    return _initCompleter!.future;
  }

  void _injectScript(String apiKey) {
    if (_scriptInjected || html.document.getElementById(_scriptId) != null) {
      _scriptInjected = true;
      return;
    }

    final script = html.ScriptElement()
      ..id = _scriptId
      ..type = 'text/javascript'
      ..async = true
      ..defer = true
        ..src =
          'https://maps.googleapis.com/maps/api/js?key=$apiKey&libraries=places&loading=async';

    script.onError.listen((_) {
      if (!(_initCompleter?.isCompleted ?? true)) {
        _initCompleter!.completeError(
          StateError('Failed to load Google Maps Places script.'),
        );
      }
    });

    html.document.head?.append(script);
    _scriptInjected = true;
  }

  Future<void> _waitForGoogleReady() async {
    const timeout = Duration(seconds: 15);
    final start = DateTime.now();
    while (!_isGoogleReady()) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (DateTime.now().difference(start) > timeout) {
        throw StateError('Timed out loading Google Maps Places SDK.');
      }
    }
  }

  bool _isGoogleReady() {
    final google = js_util.getProperty(js_util.globalThis, 'google');
    if (google == null) return false;
    final Object googleObject = google;
    final maps = js_util.getProperty(googleObject, 'maps');
    if (maps == null) return false;
    final Object mapsObject = maps;
    return js_util.hasProperty(mapsObject, 'importLibrary');
  }

  Future<Object> _loadPlacesLibrary() async {
    final google = js_util.getProperty(js_util.globalThis, 'google');
    if (google == null) {
      throw StateError('Google Maps SDK is unavailable.');
    }
    final Object googleObject = google;
    final maps = js_util.getProperty(googleObject, 'maps');
    if (maps == null) {
      throw StateError('google.maps is unavailable.');
    }
    final Object mapsObject = maps;
    final promise =
        js_util.callMethod<Object?>(mapsObject, 'importLibrary', ['places']);
    if (promise == null) {
      throw StateError('google.maps.importLibrary returned null.');
    }
    final result = await js_util.promiseToFuture<Object?>(promise);
    if (result == null) {
      throw StateError('google.maps.importLibrary resolved with null.');
    }
    return result;
  }

  @override
  void dispose() {
    _autocompleteSuggestionClass = null;
    _sessionTokenConstructor = null;
    _initCompleter = null;
  }
}

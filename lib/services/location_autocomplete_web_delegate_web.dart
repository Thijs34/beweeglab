import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

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
  JSObject? _autocompleteSuggestionClass;
  JSFunction? _sessionTokenConstructor;

  @override
  Future<List<LocationPrediction>> fetchSuggestions(String input) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return const <LocationPrediction>[];
    }

    await _ensureInitialized();

    final request = JSObject();
    _setProperty(request, 'input', trimmed.toJS);
    _setProperty(request, 'language', _language.toJS);
    final JSAny? sessionToken =
      _construct(_sessionTokenConstructor!);
    _setProperty(request, 'sessionToken', sessionToken);

    final JSFunction fetchFunction = _getFunction(
      _autocompleteSuggestionClass,
      'fetchAutocompleteSuggestions',
    );

    final JSAny? promiseAny =
        fetchFunction.callAsFunction(_autocompleteSuggestionClass, request);
    final JSAny? result = await (promiseAny as JSPromise<JSAny?>).toDart;

    return _mapResult(result);
  }

  List<LocationPrediction> _mapResult(JSAny? result) {
    if (result == null || result.isUndefinedOrNull) {
      return const <LocationPrediction>[];
    }
    final JSAny? suggestions = _getProperty(result, 'suggestions');
    if (suggestions == null || suggestions.isUndefinedOrNull) {
      return const <LocationPrediction>[];
    }

    final lengthValue = _getProperty(suggestions, 'length');
    final length = (lengthValue as JSNumber?)?.toDartInt ?? 0;
    final predictions = <LocationPrediction>[];
    for (var index = 0; index < length; index++) {
      final JSAny? suggestion = _getIndexedProperty(suggestions, index);
      final prediction = _mapPrediction(suggestion);
      if (prediction != null) {
        predictions.add(prediction);
      }
    }
    return predictions;
  }

  LocationPrediction? _mapPrediction(JSAny? suggestion) {
    if (suggestion == null || suggestion.isUndefinedOrNull) {
      return null;
    }
    final JSAny? placePrediction =
        _getProperty(suggestion, 'placePrediction');
    if (placePrediction == null || placePrediction.isUndefinedOrNull) {
      return null;
    }

    final description =
        _readLocalizedText(_getProperty(placePrediction, 'text'));
    if (description.isEmpty) {
      return null;
    }

    var primary = description;
    String? secondary;
    JSAny? structuredFormat =
        _getProperty(placePrediction, 'structuredFormat');
    structuredFormat ??=
        _getProperty(placePrediction, 'structuredFormatting');
    if (structuredFormat != null && !structuredFormat.isUndefinedOrNull) {
      final mainText =
          _readLocalizedText(_getProperty(structuredFormat, 'mainText'));
      if (mainText.isNotEmpty) {
        primary = mainText;
      }
      final secondaryText = _readLocalizedText(
        _getProperty(structuredFormat, 'secondaryText'),
      );
      if (secondaryText.isNotEmpty) {
        secondary = secondaryText;
      }
    }

    final placeId = _readLocalizedText(_getProperty(placePrediction, 'placeId'));
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

  String _readLocalizedText(JSAny? value) {
    if (value == null || value.isUndefinedOrNull) {
      return '';
    }
    if (value is JSString) {
      return value.toDart;
    }
    final JSAny? toStringFn = _getProperty(value, 'toString');
    if (toStringFn is JSFunction) {
      final JSAny? converted = toStringFn.callAsFunction(value);
      if (converted is JSString) {
        return converted.toDart;
      }
      final Object? dartValue = converted?.dartify();
      if (dartValue is String) {
        return dartValue;
      }
      if (dartValue != null) {
        return dartValue.toString();
      }
    }
    final Object? dartFallback = value.dartify();
    if (dartFallback is String) {
      return dartFallback;
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

        final JSObject placesLibrary = await _loadPlacesLibrary();
        _autocompleteSuggestionClass = _getProperty(
          placesLibrary,
          'AutocompleteSuggestion',
        ) as JSObject?;
        _sessionTokenConstructor = _getProperty(
          placesLibrary,
          'AutocompleteSessionToken',
        ) as JSFunction?;

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
    if (_scriptInjected || web.document.getElementById(_scriptId) != null) {
      _scriptInjected = true;
      return;
    }

    final script = web.HTMLScriptElement()
      ..id = _scriptId
      ..type = 'text/javascript'
      ..async = true
      ..defer = true
      ..src =
          'https://maps.googleapis.com/maps/api/js?key=$apiKey&libraries=places&loading=async';

    script.addEventListener(
      'error',
      ((web.Event _) {
        if (!(_initCompleter?.isCompleted ?? true)) {
          _initCompleter!.completeError(
            StateError('Failed to load Google Maps Places script.'),
          );
        }
      }).toJS,
    );

    web.document.head?.append(script);
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
    final JSAny? google = _getProperty(globalContext, 'google');
    if (google == null || google.isUndefinedOrNull) return false;
    final JSAny? maps = _getProperty(google, 'maps');
    if (maps == null || maps.isUndefinedOrNull) return false;
    return _hasProperty(maps, 'importLibrary');
  }

  Future<JSObject> _loadPlacesLibrary() async {
    final JSAny? google = _getProperty(globalContext, 'google');
    if (google == null || google.isUndefinedOrNull) {
      throw StateError('Google Maps SDK is unavailable.');
    }
    final JSAny? maps = _getProperty(google, 'maps');
    if (maps == null || maps.isUndefinedOrNull) {
      throw StateError('google.maps is unavailable.');
    }
    final JSFunction importLibrary = _getFunction(maps, 'importLibrary');
    final JSAny? promise =
        importLibrary.callAsFunction(maps, 'places'.toJS);
    if (promise == null || promise.isUndefinedOrNull) {
      throw StateError('google.maps.importLibrary returned null.');
    }
    final JSAny? result = await (promise as JSPromise<JSAny?>).toDart;
    if (result == null || result.isUndefinedOrNull) {
      throw StateError('google.maps.importLibrary resolved with null.');
    }
    if (result is! JSObject) {
      throw StateError('google.maps.importLibrary returned unexpected type.');
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

JSAny? _getProperty(JSAny? target, String property) =>
    _reflectGet(target, property.toJS);

JSAny? _getIndexedProperty(JSAny? target, int index) =>
    _reflectGet(target, index.toJS);

void _setProperty(JSAny? target, String property, JSAny? value) {
  _reflectSet(target, property.toJS, value);
}

JSAny? _construct(JSFunction constructor,
    [List<JSAny?> args = const <JSAny?>[]]) {
  final JSAny? argumentsList = args.isEmpty ? JSArray<JSAny?>() : args.toJS;
  return _reflectConstruct(constructor, argumentsList);
}

JSFunction _getFunction(JSAny? target, String property) {
  final JSAny? fn = _getProperty(target, property);
  if (fn is! JSFunction) {
    throw StateError('Expected $property to be a JavaScript function.');
  }
  return fn;
}

bool _hasProperty(JSAny? target, String property) =>
    _reflectHas(target, property.toJS);

@JS('Reflect.has')
external bool _reflectHas(JSAny? target, JSAny? propertyKey);

@JS('Reflect.get')
external JSAny? _reflectGet(JSAny? target, JSAny? propertyKey);

@JS('Reflect.set')
external bool _reflectSet(JSAny? target, JSAny? propertyKey, JSAny? value);

@JS('Reflect.construct')
external JSAny? _reflectConstruct(
  JSFunction target,
  JSAny? argumentsList,
);

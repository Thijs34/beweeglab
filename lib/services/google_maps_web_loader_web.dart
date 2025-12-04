import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'package:my_app/config/app_config.dart';

const String _scriptId = 'google-maps-sdk';
final _GoogleMapsSdkLoader _loader = _GoogleMapsSdkLoader();

Future<void> ensureGoogleMapsSdkInitialized() => _loader.ensureInitialized();

class _GoogleMapsSdkLoader {
  Completer<void>? _initCompleter;

  Future<void> ensureInitialized() {
    if (_isGoogleReady()) {
      return Future.value();
    }
    if (_initCompleter != null) {
      return _initCompleter!.future;
    }
    _initCompleter = Completer<void>();

    final apiKey = AppConfig.googlePlacesApiKey;
    if (apiKey == null) {
      _initCompleter!.completeError(StateError('Missing Google Maps API key.'));
      return _initCompleter!.future;
    }

    try {
      _injectScript(apiKey);
      _waitForGoogleReady()
          .then((_) {
            _initCompleter?.complete();
          })
          .catchError((Object error, StackTrace stackTrace) {
            if (!(_initCompleter?.isCompleted ?? true)) {
              _initCompleter!.completeError(error, stackTrace);
            }
          });
    } catch (error, stackTrace) {
      if (!(_initCompleter?.isCompleted ?? true)) {
        _initCompleter!.completeError(error, stackTrace);
      }
    }

    return _initCompleter!.future;
  }

  void _injectScript(String apiKey) {
    final existing = web.document.getElementById(_scriptId);
    if (existing != null) {
      return;
    }

    final script = web.HTMLScriptElement()
      ..id = _scriptId
      ..type = 'text/javascript'
      ..async = true
      ..defer = true
      ..src =
          'https://maps.googleapis.com/maps/api/js?key=$apiKey&libraries=places&v=weekly';

    script.addEventListener(
      'error',
      ((web.Event _) {
        if (!(_initCompleter?.isCompleted ?? true)) {
          _initCompleter!.completeError(
            StateError('Failed to load Google Maps JavaScript SDK.'),
          );
        }
      }).toJS,
    );

    web.document.head?.append(script);
  }

  Future<void> _waitForGoogleReady() async {
    const timeout = Duration(seconds: 15);
    const pollInterval = Duration(milliseconds: 100);
    final start = DateTime.now();
    while (!_isGoogleReady()) {
      await Future.delayed(pollInterval);
      if (DateTime.now().difference(start) > timeout) {
        throw StateError('Timed out waiting for Google Maps SDK.');
      }
    }
  }

  bool _isGoogleReady() {
    if (!_reflectHas(globalContext, 'google'.toJS)) {
      return false;
    }

    final JSAny? googleAny = _reflectGet(globalContext, 'google'.toJS);
    final JSObject? google = googleAny as JSObject?;
    if (google == null || google.isUndefinedOrNull) {
      return false;
    }

    if (!_reflectHas(google, 'maps'.toJS)) {
      return false;
    }

    final JSAny? maps = _reflectGet(google, 'maps'.toJS);
    if (maps == null || maps.isUndefinedOrNull) {
      return false;
    }

    return true;
  }
}

@JS('Reflect.has')
external bool _reflectHas(JSAny? target, JSAny? propertyKey);

@JS('Reflect.get')
external JSAny? _reflectGet(JSAny? target, JSAny? propertyKey);

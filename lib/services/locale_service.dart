import 'package:flutter/material.dart';
import 'package:my_app/l10n/gen/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app locale and persists the user's choice.
class LocaleService extends ChangeNotifier {
  LocaleService._();

  static const _preferenceKey = 'preferred_locale';
  static final LocaleService instance = LocaleService._();

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('nl'),
  ];

  Locale? _selectedLocale;

  /// The locale currently used by the app. Falls back to device or English.
  Locale get locale => _selectedLocale ?? _deviceLocale;

  /// Returns the explicitly selected locale, if any.
  Locale? get selectedLocale => _selectedLocale;

  Locale get _fallbackLocale => supportedLocales.first;

  Locale get _deviceLocale {
    final device = WidgetsBinding.instance.platformDispatcher.locale;
    return _isSupported(device) ? device : _fallbackLocale;
  }

  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_preferenceKey);
    if (savedCode == null || savedCode.isEmpty) return;
    final savedLocale = _localeFromCode(savedCode);
    if (savedLocale != null) {
      _selectedLocale = savedLocale;
    }
  }

  Future<void> setLocale(Locale locale) async {
    final normalized = _normalize(locale);
    if (_selectedLocale == normalized) return;
    _selectedLocale = normalized;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferenceKey, normalized.languageCode);
  }

  Future<void> clearSavedLocale() async {
    _selectedLocale = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_preferenceKey);
  }

  Locale? _localeFromCode(String code) {
    try {
      return supportedLocales.firstWhere(
        (locale) => locale.languageCode == code,
      );
    } catch (_) {
      return null;
    }
  }

  bool _isSupported(Locale locale) {
    return supportedLocales.any(
      (item) => item.languageCode.toLowerCase() ==
          locale.languageCode.toLowerCase(),
    );
  }

  Locale _normalize(Locale locale) {
    return _isSupported(locale)
        ? Locale(locale.languageCode)
        : _fallbackLocale;
  }

  /// Provides localized strings outside of a widget tree.
  AppLocalizations get strings => lookupAppLocalizations(locale);
}

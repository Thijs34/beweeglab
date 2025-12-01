import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/screens/observer_page/models/observer_entry.dart';

/// Persists in-progress observer session entries per observer/project pair.
class SessionDraftService {
  SessionDraftService._();

  static final SessionDraftService instance = SessionDraftService._();

  static const String _keyPrefix = 'session_drafts';

  Future<void> saveEntries({
    required String observerUid,
    required String projectId,
    required List<ObserverEntry> entries,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _buildKey(observerUid, projectId);
    final encoded = entries
        .map((entry) => jsonEncode(entry.toJson()))
        .toList(growable: false);
    await prefs.setStringList(key, encoded);
  }

  Future<List<ObserverEntry>> restoreEntries({
    required String observerUid,
    required String projectId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_buildKey(observerUid, projectId));
    if (raw == null) {
      return const [];
    }
    final restored = <ObserverEntry>[];
    for (final item in raw) {
      try {
        final decoded = jsonDecode(item) as Map<String, dynamic>;
        restored.add(ObserverEntry.fromJson(decoded));
      } catch (_) {
        continue;
      }
    }
    return restored;
  }

  Future<void> clearEntries({
    required String observerUid,
    required String projectId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_buildKey(observerUid, projectId));
  }

  String _buildKey(String observerUid, String projectId) {
    return '$_keyPrefix::$observerUid::$projectId';
  }
}

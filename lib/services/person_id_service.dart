import 'package:shared_preferences/shared_preferences.dart';

/// Simple key-value helper to persist the next person ID per observer & project.
class PersonIdService {
  PersonIdService._();

  static final PersonIdService instance = PersonIdService._();

  static const String _keyPrefix = 'person_counter';

  String _buildKey({required String observerUid, required String projectId}) {
    return '$_keyPrefix::$observerUid::$projectId';
  }

  Future<int?> getNextPersonId({
    required String observerUid,
    required String projectId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(
      _buildKey(observerUid: observerUid, projectId: projectId),
    );
    return value;
  }

  Future<void> saveNextPersonId({
    required String observerUid,
    required String projectId,
    required int nextPersonId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _buildKey(observerUid: observerUid, projectId: projectId),
      nextPersonId,
    );
  }

  Future<void> clearCounter({
    required String observerUid,
    required String projectId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(
      _buildKey(observerUid: observerUid, projectId: projectId),
    );
  }
}

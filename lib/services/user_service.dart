import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:my_app/services/admin_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUserRecord {
  final String uid;
  final String role;
  final String? email;
  final String? displayName;

  const AppUserRecord({
    required this.uid,
    required this.role,
    this.email,
    this.displayName,
  });

  factory AppUserRecord.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    return AppUserRecord(
      uid: snapshot.id,
      role: (data['role'] as String?) ?? 'observer',
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
    );
  }
}

class UserService {
  UserService._();

  static final UserService instance = UserService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AdminNotificationService _notificationService =
      AdminNotificationService.instance;
  static const String _collection = 'users';
  static const String _cachePrefix = 'user_profile_';
  final Map<String, AppUserRecord> _userCache = {};

  AppUserRecord? getCachedUser(String uid) => _userCache[uid];

  Future<AppUserRecord?> getUserProfile(
    String uid, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = _userCache[uid];
      if (cached != null) {
        return cached;
      }
      final persisted = await _loadPersistedUser(uid);
      if (persisted != null) {
        return persisted;
      }
    } else {
      _userCache.remove(uid);
    }

    final snapshot = await _firestore.collection(_collection).doc(uid).get();
    if (!snapshot.exists) {
      return null;
    }

    final record = AppUserRecord.fromSnapshot(snapshot);
    _userCache[uid] = record;
    await _persistUserRecord(record);
    return record;
  }

  Future<void> ensureUserDocument({
    required String uid,
    String role = 'observer',
    String? email,
    String? displayName,
  }) async {
    final docRef = _firestore.collection(_collection).doc(uid);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      await docRef.set({
        'role': role,
        if (email != null) 'email': email,
        if (displayName != null && displayName.trim().isNotEmpty)
          'displayName': displayName.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      final record = AppUserRecord(
        uid: uid,
        role: role,
        email: email,
        displayName: displayName,
      );
      _userCache[uid] = record;
      await _persistUserRecord(record);
      if (email != null && email.trim().isNotEmpty) {
        try {
          await _notificationService.recordNewUserSignup(
            uid: uid,
            email: email.trim(),
            displayName: displayName,
          );
        } catch (error) {
          debugPrint('Failed to create admin notification: $error');
        }
      }
      return;
    }

    final updates = <String, dynamic>{};
    if (email != null) {
      updates['email'] = email;
    }
    if (displayName != null && displayName.trim().isNotEmpty) {
      updates['displayName'] = displayName.trim();
    }
    if (updates.isNotEmpty) {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await docRef.set(updates, SetOptions(merge: true));
      final existing = _userCache[uid];
      final merged = AppUserRecord(
        uid: uid,
        role: updates['role'] as String? ?? existing?.role ?? role,
        email: updates.containsKey('email')
            ? updates['email'] as String?
            : existing?.email ?? email,
        displayName: updates.containsKey('displayName')
            ? updates['displayName'] as String?
            : existing?.displayName ?? displayName,
      );
      _userCache[uid] = merged;
      await _persistUserRecord(merged);
    }
  }

  Future<String> fetchUserRole(String uid) async {
    final record = await getUserProfile(uid, forceRefresh: true);
    if (record == null) {
      await ensureUserDocument(uid: uid);
      return 'observer';
    }
    if (record.role.isNotEmpty) {
      return record.role;
    }
    return 'observer';
  }

  Stream<List<AppUserRecord>> watchObservers() {
    return _firestore
        .collection(_collection)
        .where('role', whereIn: ['observer', 'admin'])
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppUserRecord.fromSnapshot(doc))
              .toList(),
        );
  }

  Future<List<AppUserRecord>> fetchObservers() async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('role', whereIn: ['observer', 'admin'])
        .get();
    return snapshot.docs
        .map((doc) => AppUserRecord.fromSnapshot(doc))
        .toList(growable: false);
  }

  String _cacheKey(String uid) => '$_cachePrefix$uid';

  Future<AppUserRecord?> _loadPersistedUser(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey(uid));
      if (raw == null) {
        return null;
      }
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final record = AppUserRecord(
        uid: uid,
        role: (data['role'] as String?) ?? 'observer',
        email: data['email'] as String?,
        displayName: data['displayName'] as String?,
      );
      _userCache[uid] = record;
      return record;
    } catch (error) {
      debugPrint('Failed to load cached user: $error');
      return null;
    }
  }

  Future<void> _persistUserRecord(AppUserRecord record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _cacheKey(record.uid),
        jsonEncode({
          'role': record.role,
          'email': record.email,
          'displayName': record.displayName,
        }),
      );
    } catch (error) {
      debugPrint('Failed to persist user cache: $error');
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:my_app/services/admin_notification_service.dart';

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
    }
  }

  Future<String> fetchUserRole(String uid) async {
    final doc = await _firestore.collection(_collection).doc(uid).get();
    final data = doc.data();
    if (data == null) {
      await ensureUserDocument(uid: uid);
      return 'observer';
    }
    final role = data['role'];
    if (role is String && role.isNotEmpty) {
      return role;
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
}

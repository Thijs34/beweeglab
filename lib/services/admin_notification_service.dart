import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/models/admin_notification.dart';

/// Centralized gateway for all admin notifications.
class AdminNotificationService {
  AdminNotificationService._();

  static final AdminNotificationService instance = AdminNotificationService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'adminNotifications';

  CollectionReference<Map<String, dynamic>> get _collectionRef =>
      _firestore.collection(_collection);

  Stream<List<AdminNotification>> watchNotifications({int limit = 25}) {
    return _collectionRef
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AdminNotification.fromSnapshot(doc))
              .toList(),
        );
  }

  Stream<int> watchUnreadCount() {
    return _collectionRef
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<int> fetchUnreadCount() async {
    final aggregate = await _collectionRef
        .where('isRead', isEqualTo: false)
        .count()
        .get();
    return aggregate.count ?? 0;
  }

  Future<void> recordNewUserSignup({
    required String uid,
    required String email,
    String? displayName,
  }) async {
    await _collectionRef.add({
      'type': 'new_user',
      'userUid': uid,
      'userEmail': email,
      if (displayName != null && displayName.trim().isNotEmpty)
        'userDisplayName': displayName.trim(),
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markAsRead(String notificationId) async {
    await _collectionRef.doc(notificationId).set({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> markAllAsRead(List<String> notificationIds) async {
    if (notificationIds.isEmpty) return;
    final batch = _firestore.batch();
    for (final id in notificationIds) {
      batch.set(_collectionRef.doc(id), {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }
}

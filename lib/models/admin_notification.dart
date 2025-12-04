import 'package:cloud_firestore/cloud_firestore.dart';

/// Notification emitted whenever admins need to review a new event.
class AdminNotification {
  final String id;
  final String userUid;
  final String userEmail;
  final String userDisplayName;
  final bool isRead;
  final DateTime createdAt;

  const AdminNotification({
    required this.id,
    required this.userUid,
    required this.userEmail,
    required this.userDisplayName,
    required this.isRead,
    required this.createdAt,
  });

  factory AdminNotification.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};

    // get timestamp safely because Firestore might send Timestamp or DateTime
    final timestamp = data['createdAt'];
    DateTime createdAt;
    if (timestamp is Timestamp) {
      createdAt = timestamp.toDate();
    } else if (timestamp is DateTime) {
      createdAt = timestamp;
    } else {
      createdAt = DateTime.fromMillisecondsSinceEpoch(0);
    }
    final providedName = data['userDisplayName'] as String?;
    final email = (data['userEmail'] as String?) ?? 'unknown@user.nl';
    final normalizedName = _deriveDisplayName(providedName, email);

    return AdminNotification(
      id: snapshot.id,
      userUid: (data['userUid'] as String?) ?? '',
      userEmail: email,
      userDisplayName: normalizedName,
      isRead: (data['isRead'] as bool?) ?? false,
      createdAt: createdAt,
    );
  }

  static String _deriveDisplayName(String? displayName, String email) {
    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName.trim();
    }
    final base = email.split('@').first;
    if (base.isEmpty) return 'New user';
    return base
        .split(RegExp(r'[._-]+'))
        .where((segment) => segment.isNotEmpty)
        .map(
          (segment) =>
              segment[0].toUpperCase() + segment.substring(1).toLowerCase(),
        )
        .join(' ')
        .trim();
  }
}

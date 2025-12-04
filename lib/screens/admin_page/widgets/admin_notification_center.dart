import 'package:flutter/material.dart';
import 'package:my_app/models/admin_notification.dart';
import 'package:my_app/theme/app_theme.dart';

class AdminNotificationCenter extends StatelessWidget {
  final GlobalKey anchorKey;
  final VoidCallback onClose;
  final List<AdminNotification> notifications;
  final bool isLoading;
  final bool hasUnread;
  final VoidCallback onMarkAllAsRead;

  const AdminNotificationCenter({
    super.key,
    required this.anchorKey,
    required this.onClose,
    required this.notifications,
    required this.isLoading,
    required this.hasUnread,
    required this.onMarkAllAsRead,
  });

  @override
  Widget build(BuildContext context) {
    final RenderBox? renderBox =
        anchorKey.currentContext?.findRenderObject() as RenderBox?;
    final Offset? buttonPosition = renderBox?.localToGlobal(Offset.zero);
    final Size? buttonSize = renderBox?.size;

    //Calculate where the popup should appear
    final double top =
        (buttonPosition?.dy ?? 64) + (buttonSize?.height ?? 44) + 8;
    final double right =
        MediaQuery.of(context).size.width -
        ((buttonPosition?.dx ?? 0) + (buttonSize?.width ?? 44));

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            child: Container(color: Colors.transparent),
          ),
        ),
        Positioned(
          top: top,
          right: right,
          child: Material(
            elevation: 10,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            child: Container(
              width: 320,
              constraints: const BoxConstraints(maxHeight: 360),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                border: Border.all(color: AppTheme.gray200),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Admin notifications',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.gray900,
                          fontFamily: AppTheme.fontFamilyHeading,
                        ),
                      ),
                      const Spacer(),
                      if (hasUnread)
                        TextButton(
                          onPressed: onMarkAllAsRead,
                          child: const Text('Mark all read'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(height: 240, child: _buildBody()),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryOrange),
      );
    }

    if (notifications.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.notifications_none, size: 36, color: AppTheme.gray300),
          SizedBox(height: 12),
          Text(
            'No notifications yet',
            style: TextStyle(color: AppTheme.gray500, fontSize: 14),
          ),
        ],
      );
    }

    // Actual list of notifsications
    return ListView.separated(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _NotificationTile(notification: notification);
      },
      separatorBuilder: (context, _) =>
          const Divider(height: 16, color: AppTheme.gray100),
      itemCount: notifications.length,
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AdminNotification notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final subtitle =
        '${notification.userEmail} • '
        '${_formatRelativeTime(notification.createdAt)}';

    return Container(
      decoration: BoxDecoration(
        color: notification.isRead ? AppTheme.white : AppTheme.orange50,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppTheme.primaryOrange,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.person_add_alt_1,
              size: 18,
              color: AppTheme.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.userDisplayName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: notification.isRead
                        ? FontWeight.w500
                        : FontWeight.w700,
                    color: AppTheme.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: AppTheme.gray600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Turning timestapms into normal hours
  String _formatRelativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inMinutes < 1) {
      return 'Just now';
    }
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }
    return '${timestamp.year}-${_pad(timestamp.month)}-${_pad(timestamp.day)}';
  }

  String _pad(int value) => value.toString().padLeft(2, '0');
}

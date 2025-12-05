import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/l10n/l10n.dart';
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

    final l10n = context.l10n;

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
                      Text(
                        l10n.adminNotificationsTitle,
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
                          child: Text(l10n.notificationsMarkAllRead),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(height: 240, child: _buildBody(context)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    final l10n = context.l10n;
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryOrange),
      );
    }

    if (notifications.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_none, size: 36, color: AppTheme.gray300),
          const SizedBox(height: 12),
          Text(
            l10n.notificationsEmptyTitle,
            style: const TextStyle(color: AppTheme.gray500, fontSize: 14),
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
        '${_formatRelativeTime(context, notification.createdAt)}';

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
  String _formatRelativeTime(BuildContext context, DateTime timestamp) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inMinutes < 1) {
      return l10n.relativeJustNow;
    }
    if (difference.inMinutes < 60) {
      return l10n.relativeMinutesAgo(difference.inMinutes);
    }
    if (difference.inHours < 24) {
      return l10n.relativeHoursAgo(difference.inHours);
    }
    return DateFormat.yMd(l10n.localeName).format(timestamp);
  }
}

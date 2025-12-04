import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_app/models/admin_notification.dart';
import 'package:my_app/models/navigation_arguments.dart';
import 'package:my_app/screens/admin_page/widgets/admin_header.dart';
import 'package:my_app/screens/observer_page/observer_page.dart';
import 'package:my_app/services/admin_notification_service.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/widgets/profile_menu.dart';

class AdminNotificationsPage extends StatefulWidget {
  final AdminNotificationsArguments? arguments;

  const AdminNotificationsPage({super.key, this.arguments});

  @override
  State<AdminNotificationsPage> createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage> {
  final AdminNotificationService _notificationService =
      AdminNotificationService.instance;
  final GlobalKey _profileButtonKey = GlobalKey();
  StreamSubscription<List<AdminNotification>>? _subscription;
  List<AdminNotification> _notifications = const [];
  bool _isLoading = true;
  bool _isMarkingAllRead = false;
  bool _showProfileMenu = false;

  // Listen to the notification stream and update UI whenever records change.
  // Errors are caught to avoid stream failures crashing the widget

  @override
  void initState() {
    super.initState();
    _subscription = _notificationService
        .watchNotifications(limit: 50)
        .listen(
          (records) {
            setState(() {
              _notifications = records;
              _isLoading = false;
            });
          },
          onError: (error) {
            debugPrint('Failed to load notifications: $error');
            setState(() => _isLoading = false);
            _showSnack(
              'Unable to load notifications right now.',
              isError: true,
            );
          },
        );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // Determines whether there are any unread notifications.
  // Used to conditionally show the "Mark all read" button.

  bool get _hasUnread =>
      _notifications.any((notification) => !notification.isRead);

  Future<void> _markAllAsRead() async {
    if (_isMarkingAllRead) return;
    final unreadIds = _notifications
        .where((notification) => !notification.isRead)
        .map((notification) => notification.id)
        .toList();
    if (unreadIds.isEmpty) return;
    setState(() => _isMarkingAllRead = true);
    try {
      await _notificationService.markAllAsRead(unreadIds);
      _showSnack('All notifications marked as read.');
    } catch (error) {
      debugPrint('Failed to mark notifications read: $error');
      _showSnack('Could not mark notifications as read.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isMarkingAllRead = false);
      }
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppTheme.primaryOrange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppTheme.maxContentWidth,
                ),
                child: Column(
                  children: [
                    AdminHeader(
                      profileButtonKey: _profileButtonKey,
                      onProfileTap: _toggleProfileMenu,
                      title: 'Notifications',
                      unreadNotificationCount: _unreadNotificationCount,
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppTheme.pageGutter,
                          24,
                          AppTheme.pageGutter,
                          24,
                        ),
                        child: _buildNotificationSection(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_showProfileMenu)
              ProfileMenu(
                profileButtonKey: _profileButtonKey,
                userEmail: widget.arguments?.userEmail,
                onClose: () => setState(() => _showProfileMenu = false),
                onLogout: _handleLogout,
                onObserverTap: _openObserverPage,
                onAdminTap: _isAdmin ? _openAdminPage : null,
                onProjectsTap: _openProjectsPage,
                onNotificationsTap: () {},
                activeDestination: ProfileMenuDestination.notifications,
                showAdminOption: _isAdmin,
                showNotificationsOption: _isAdmin,
                unreadNotificationCount: _unreadNotificationCount,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusXL),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.gray900,
                        fontFamily: AppTheme.fontFamilyHeading,
                      ),
                    ),
                    if (widget.arguments?.userEmail != null)
                      Text(
                        widget.arguments!.userEmail!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.gray500,
                        ),
                      ),
                  ],
                ),
              ),
              if (_hasUnread)
                TextButton(
                  onPressed: _isMarkingAllRead ? null : _markAllAsRead,
                  child: _isMarkingAllRead
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Mark all read'),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(child: _buildNotificationBody()),
        ],
      ),
    );
  }

  Widget _buildNotificationBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryOrange),
      );
    }

    if (_notifications.isEmpty) {
      return _EmptyNotificationsState(onRefresh: _manualRefresh);
    }

    return RefreshIndicator(
      onRefresh: _manualRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _NotificationTile(notification: notification);
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: _notifications.length,
      ),
    );
  }

  Future<void> _manualRefresh() async {
    setState(() => _isLoading = true);
    final records = await _notificationService
        .watchNotifications(limit: 50)
        .first;
    if (!mounted) return;
    setState(() {
      _notifications = records;
      _isLoading = false;
    });
  }

  void _toggleProfileMenu() {
    setState(() => _showProfileMenu = !_showProfileMenu);
  }

  void _handleLogout() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _openProjectsPage() {
    Navigator.pushNamed(
      context,
      '/projects',
      arguments: ProjectListArguments(
        userEmail: widget.arguments?.userEmail,
        userRole: widget.arguments?.userRole ?? 'admin',
      ),
    );
  }

  void _openObserverPage() {
    Navigator.pushNamed(
      context,
      '/observer',
      arguments: ObserverPageArguments(
        project: null,
        userEmail: widget.arguments?.userEmail,
        userRole: widget.arguments?.userRole ?? 'admin',
      ),
    );
  }

  void _openAdminPage() {
    Navigator.pushNamed(
      context,
      '/admin',
      arguments: AdminPageArguments(
        userEmail: widget.arguments?.userEmail,
        userRole: widget.arguments?.userRole ?? 'admin',
      ),
    );
  }

  int get _unreadNotificationCount =>
      _notifications.where((notification) => !notification.isRead).length;

  bool get _isAdmin =>
      (widget.arguments?.userRole ?? 'admin').toLowerCase() == 'admin';
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
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(color: AppTheme.gray100),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppTheme.primaryOrange,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.person_add_alt_1,
              size: 20,
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
                    fontSize: 16,
                    fontWeight: notification.isRead
                        ? FontWeight.w600
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

  // Converts timestamps into normal hours
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

/// Shown when there are no notifications to display.
/// Includes a manual refresh button for convenience.
class _EmptyNotificationsState extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _EmptyNotificationsState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications_none,
              size: 56,
              color: AppTheme.gray300,
            ),
            const SizedBox(height: 16),
            const Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.gray700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You will see new user sign-ups here once they happen.',
              style: const TextStyle(fontSize: 13, color: AppTheme.gray500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => onRefresh(),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/l10n/l10n.dart';
import 'package:my_app/models/admin_notification.dart';
import 'package:my_app/models/navigation_arguments.dart';
import 'package:my_app/screens/observer_page/observer_page.dart';
import 'package:my_app/services/admin_notification_service.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/widgets/app_page_header.dart';
import 'package:my_app/widgets/profile_menu_shell.dart';

class AdminNotificationsPage extends StatefulWidget {
  final AdminNotificationsArguments? arguments;

  const AdminNotificationsPage({super.key, this.arguments});

  @override
  State<AdminNotificationsPage> createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage> {
  final AdminNotificationService _notificationService =
      AdminNotificationService.instance;
  StreamSubscription<List<AdminNotification>>? _subscription;
  List<AdminNotification> _notifications = const [];
  bool _isLoading = true;
  bool _isMarkingAllRead = false;
  bool _initialized = false;

  // Listen to the notification stream and update UI whenever records change.
  // Errors are caught to avoid stream failures crashing the widget

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final l10n = context.l10n;
    _subscription = _notificationService
        .watchNotifications(limit: 50)
        .listen(
          (records) {
            if (!mounted) return;
            setState(() {
              _notifications = records;
              _isLoading = false;
            });
          },
          onError: (error) {
            debugPrint('Failed to load notifications: $error');
            if (!mounted) return;
            setState(() => _isLoading = false);
            _showSnack(
              l10n.notificationsLoadError,
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
    final l10n = context.l10n;
    if (_isMarkingAllRead) return;
    final unreadIds = _notifications
        .where((notification) => !notification.isRead)
        .map((notification) => notification.id)
        .toList();
    if (unreadIds.isEmpty) return;
    setState(() => _isMarkingAllRead = true);
    try {
      await _notificationService.markAllAsRead(unreadIds);
      _showSnack(l10n.notificationsMarkAllReadSuccess);
    } catch (error) {
      debugPrint('Failed to mark notifications read: $error');
      _showSnack(l10n.notificationsMarkAllReadFailure, isError: true);
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
    return ProfileMenuShell(
      userEmail: widget.arguments?.userEmail,
      activeDestination: ProfileMenuDestination.notifications,
      onLogout: _handleLogout,
      onProfileSettingsTap: _openProfileSettings,
      onObserverTap: _openObserverPage,
      onAdminTap: _isAdmin ? _openAdminPage : null,
      onProjectsTap: _openProjectsPage,
      onNotificationsTap: () {},
      onProjectMapTap: _isAdmin ? _openProjectMap : null,
      showAdminOption: _isAdmin,
      showNotificationsOption: _isAdmin,
      showProjectMapOption: _isAdmin,
      unreadNotificationCount: _unreadNotificationCount,
      builder: (context, controller) {
        final l10n = context.l10n;
        return Scaffold(
          backgroundColor: AppTheme.background,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppTheme.maxContentWidth,
                ),
                child: Column(
                  children: [
                    AppPageHeader(
                      profileButtonKey: controller.profileButtonKey,
                      onProfileTap: controller.toggleMenu,
                      subtitle: l10n.notificationsNavTitle,
                      subtitleIcon: Icons.notifications_none,
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
          ),
        );
      },
    );
  }

  Widget _buildNotificationSection() {
    final l10n = context.l10n;
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
                    Text(
                      l10n.notificationsRecentActivity,
                      style: const TextStyle(
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
                      : Text(l10n.notificationsMarkAllRead),
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
        separatorBuilder: (_, unused) => const SizedBox(height: 12),
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

  void _handleLogout() async {
    final l10n = context.l10n;
    try {
      await AuthService.instance.signOut();
    } on AuthException catch (error) {
      _showSnack(error.message, isError: true);
      return;
    } catch (error) {
      debugPrint('Failed to sign out: $error');
      _showSnack(
        l10n.profileLogoutError,
        isError: true,
      );
      return;
    }

    if (!mounted) return;
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

  void _openProjectMap() {
    Navigator.pushNamed(
      context,
      '/admin-project-map',
      arguments: AdminProjectMapArguments(
        userEmail: widget.arguments?.userEmail,
        userRole: widget.arguments?.userRole ?? 'admin',
      ),
    );
  }

  void _openProfileSettings() {
    Navigator.pushNamed(
      context,
      '/profile-settings',
      arguments: ProfileSettingsArguments(
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
        '${_formatRelativeTime(context, notification.createdAt)}';

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

/// Shown when there are no notifications to display.
/// Includes a manual refresh button for convenience.
class _EmptyNotificationsState extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _EmptyNotificationsState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
            Text(
              l10n.notificationsEmptyTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.gray700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.notificationsEmptySubtitle,
              style: const TextStyle(fontSize: 13, color: AppTheme.gray500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => onRefresh(),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(l10n.commonRefresh),
            ),
          ],
        ),
      ),
    );
  }
}

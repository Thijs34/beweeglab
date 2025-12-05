import 'package:flutter/material.dart';
import 'package:my_app/theme/app_theme.dart';

enum ProfileMenuDestination {
  profile,
  notifications,
  admin,
  projectMap,
  projects,
  observer,
}

/// Profile menu dropdown widget
class ProfileMenu extends StatelessWidget {
  final GlobalKey profileButtonKey;
  final VoidCallback onClose;
  final VoidCallback onLogout;
  final String? userEmail;
  final VoidCallback? onProfileSettingsTap;
  final VoidCallback? onObserverTap;
  final VoidCallback? onAdminTap;
  final VoidCallback? onProjectsTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onProjectMapTap;
  final ProfileMenuDestination activeDestination;
  final bool showProfileSettingsOption;
  final bool showAdminOption;
  final bool showNotificationsOption;
  final bool showProjectMapOption;
  final int unreadNotificationCount;

  const ProfileMenu({
    super.key,
    required this.profileButtonKey,
    required this.onClose,
    required this.onLogout,
    this.userEmail,
    this.onProfileSettingsTap,
    this.onObserverTap,
    this.onAdminTap,
    this.onProjectsTap,
    this.onNotificationsTap,
    this.onProjectMapTap,
    this.activeDestination = ProfileMenuDestination.projects,
    this.showProfileSettingsOption = true,
    this.showAdminOption = true,
    this.showNotificationsOption = false,
    this.showProjectMapOption = false,
    this.unreadNotificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Get the position of the profile button
    final RenderBox? renderBox =
        profileButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final Offset? buttonPosition = renderBox?.localToGlobal(Offset.zero);
    final Size? buttonSize = renderBox?.size;

    // Calculate menu position (below the button, aligned to right edge)
    final double top =
        (buttonPosition?.dy ?? 64) + (buttonSize?.height ?? 44) + 8;
    final double right =
        MediaQuery.of(context).size.width -
        ((buttonPosition?.dx ?? 0) + (buttonSize?.width ?? 44));

    return Stack(
      children: [
        // Transparent overlay to close menu
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            child: Container(color: Colors.transparent),
          ),
        ),

        // Menu dropdown
        Positioned(
          top: top,
          right: right,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            child: Container(
              width: 180,
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                border: Border.all(color: AppTheme.gray200, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ..._buildMenuButtons(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Divider(height: 1, color: AppTheme.gray200),
                  ),
                  _MenuButton(
                    icon: Icons.logout,
                    label: 'Logout',
                    onTap: () {
                      onClose();
                      onLogout();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildMenuButtons() {
    final children = <Widget>[];

    void addButton({
      required IconData icon,
      required String label,
      required ProfileMenuDestination destination,
      VoidCallback? onTap,
      String? badgeLabel,
    }) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(height: 4));
      }
      children.add(
        _MenuButton(
          icon: icon,
          label: label,
          isActive: activeDestination == destination,
          onTap: () {
            onClose();
            onTap?.call();
          },
          badgeLabel: badgeLabel,
        ),
      );
    }

    final showNotifications =
        showNotificationsOption && onNotificationsTap != null;
    final showAdmin = showAdminOption && onAdminTap != null;
    final showProjectMap = showProjectMapOption && onProjectMapTap != null;
    final showProfileSettings =
        showProfileSettingsOption && onProfileSettingsTap != null;

    if (showProfileSettings) {
      addButton(
        icon: Icons.person_outline,
        label: 'Profile & Settings',
        destination: ProfileMenuDestination.profile,
        onTap: onProfileSettingsTap,
      );
    }

    if (showNotifications) {
      final badgeLabel = unreadNotificationCount > 0
          ? (unreadNotificationCount > 9
                ? '9+'
                : unreadNotificationCount.toString())
          : null;
      addButton(
        icon: Icons.notifications_none,
        label: 'Notifications',
        destination: ProfileMenuDestination.notifications,
        onTap: onNotificationsTap,
        badgeLabel: badgeLabel,
      );
    }

    if (showAdmin) {
      addButton(
        icon: Icons.shield_outlined,
        label: 'Admin Page',
        destination: ProfileMenuDestination.admin,
        onTap: onAdminTap,
      );
    }

    if (showProjectMap) {
      addButton(
        icon: Icons.map_outlined,
        label: 'Project Map',
        destination: ProfileMenuDestination.projectMap,
        onTap: onProjectMapTap,
      );
    }

    addButton(
      icon: Icons.folder_outlined,
      label: 'Project List',
      destination: ProfileMenuDestination.projects,
      onTap: onProjectsTap,
    );

    addButton(
      icon: Icons.assignment_outlined,
      label: 'Observer Page',
      destination: ProfileMenuDestination.observer,
      onTap: onObserverTap,
    );

    return children;
  }
}

class _MenuButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final String? badgeLabel;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.badgeLabel,
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isActive
        ? AppTheme.primaryOrange
        : _isHovered
        ? AppTheme.gray100
        : AppTheme.gray50;

    final textColor = widget.isActive ? AppTheme.white : AppTheme.gray700;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 16, color: textColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(fontSize: 14, color: textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.badgeLabel != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    widget.badgeLabel!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

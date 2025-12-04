import 'package:flutter/material.dart';
import 'package:my_app/widgets/profile_menu.dart';

export 'package:my_app/widgets/profile_menu.dart' show ProfileMenuDestination;

/// Small helper that owns the profile avatar key and menu state so pages
/// no longer have to duplicate that boilerplate.
class ProfileMenuShell extends StatefulWidget {
  const ProfileMenuShell({
    super.key,
    required this.builder,
    required this.activeDestination,
    required this.onLogout,
    this.userEmail,
    this.onObserverTap,
    this.onAdminTap,
    this.onProjectsTap,
    this.onNotificationsTap,
    this.onProjectMapTap,
    this.showAdminOption = false,
    this.showNotificationsOption = false,
    this.showProjectMapOption = false,
    this.unreadNotificationCount = 0,
  });

  final Widget Function(BuildContext context, ProfileMenuController controller)
  builder;
  final ProfileMenuDestination activeDestination;
  final VoidCallback onLogout;
  final String? userEmail;
  final VoidCallback? onObserverTap;
  final VoidCallback? onAdminTap;
  final VoidCallback? onProjectsTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onProjectMapTap;
  final bool showAdminOption;
  final bool showNotificationsOption;
  final bool showProjectMapOption;
  final int unreadNotificationCount;

  @override
  State<ProfileMenuShell> createState() => _ProfileMenuShellState();
}

class _ProfileMenuShellState extends State<ProfileMenuShell> {
  final GlobalKey _profileButtonKey = GlobalKey();
  bool _showProfileMenu = false;

  @override
  Widget build(BuildContext context) {
    final controller = ProfileMenuController(
      profileButtonKey: _profileButtonKey,
      toggleMenu: _toggleProfileMenu,
      hideMenu: _hideProfileMenu,
    );

    return Stack(
      children: [
        widget.builder(context, controller),
        if (_showProfileMenu)
          ProfileMenu(
            profileButtonKey: _profileButtonKey,
            userEmail: widget.userEmail,
            onClose: _hideProfileMenu,
            onLogout: _wrapRequiredAction(widget.onLogout),
            onObserverTap: _wrapAction(widget.onObserverTap),
            onAdminTap: _wrapAction(widget.onAdminTap),
            onProjectsTap: _wrapAction(widget.onProjectsTap),
            onNotificationsTap: _wrapAction(widget.onNotificationsTap),
            onProjectMapTap: _wrapAction(widget.onProjectMapTap),
            activeDestination: widget.activeDestination,
            showAdminOption: widget.showAdminOption,
            showNotificationsOption: widget.showNotificationsOption,
            showProjectMapOption: widget.showProjectMapOption,
            unreadNotificationCount: widget.unreadNotificationCount,
          ),
      ],
    );
  }

  VoidCallback? _wrapAction(VoidCallback? callback) {
    if (callback == null) return null;
    return () {
      _hideProfileMenu();
      callback();
    };
  }

  VoidCallback _wrapRequiredAction(VoidCallback callback) {
    return () {
      _hideProfileMenu();
      callback();
    };
  }

  void _toggleProfileMenu() {
    setState(() => _showProfileMenu = !_showProfileMenu);
  }

  void _hideProfileMenu() {
    if (!_showProfileMenu) return;
    setState(() => _showProfileMenu = false);
  }
}

/// Gives pages access to the profile avatar key and toggle callbacks.
class ProfileMenuController {
  ProfileMenuController({
    required this.profileButtonKey,
    required this.toggleMenu,
    required this.hideMenu,
  });

  final GlobalKey profileButtonKey;
  final VoidCallback toggleMenu;
  final VoidCallback hideMenu;
}

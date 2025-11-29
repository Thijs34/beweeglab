import 'package:flutter/material.dart';
import 'package:my_app/theme/app_theme.dart';

enum ProfileMenuDestination { observer, admin, projects }

/// Profile menu dropdown widget
class ProfileMenu extends StatelessWidget {
  final GlobalKey profileButtonKey;
  final VoidCallback onClose;
  final VoidCallback onLogout;
  final String? userEmail;
  final VoidCallback? onObserverTap;
  final VoidCallback? onAdminTap;
  final VoidCallback? onProjectsTap;
  final ProfileMenuDestination activeDestination;

  const ProfileMenu({
    super.key,
    required this.profileButtonKey,
    required this.onClose,
    required this.onLogout,
    this.userEmail,
    this.onObserverTap,
    this.onAdminTap,
    this.onProjectsTap,
    this.activeDestination = ProfileMenuDestination.projects,
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
                  _MenuButton(
                    icon: Icons.assignment_outlined,
                    label: 'Observer Page',
                    isActive:
                        activeDestination == ProfileMenuDestination.observer,
                    onTap: () {
                      onClose();
                      onObserverTap?.call();
                    },
                  ),
                  const SizedBox(height: 4),
                  _MenuButton(
                    icon: Icons.shield_outlined,
                    label: 'Admin Page',
                    isActive: activeDestination == ProfileMenuDestination.admin,
                    onTap: () {
                      onClose();
                      onAdminTap?.call();
                    },
                  ),
                  const SizedBox(height: 4),
                  _MenuButton(
                    icon: Icons.folder_outlined,
                    label: 'Project List',
                    onTap: () {
                      onClose();
                      onProjectsTap?.call();
                    },
                    isActive:
                        activeDestination == ProfileMenuDestination.projects,
                  ),
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
}

class _MenuButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

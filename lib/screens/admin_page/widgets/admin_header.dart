import 'package:flutter/material.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/widgets/profile_avatar_button.dart';

/// Reusable header for the admin page
class AdminHeader extends StatelessWidget {
  final GlobalKey profileButtonKey;
  final VoidCallback onProfileTap;
  final String title;
  final List<Widget> trailingActions;
  final int unreadNotificationCount;

  const AdminHeader({
    super.key,
    required this.profileButtonKey,
    required this.onProfileTap,
    required this.title,
    this.trailingActions = const [],
    this.unreadNotificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.white,
        border: Border(
          bottom: BorderSide(color: AppTheme.primaryOrange, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: AppTheme.headerPadding,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'InnoBeweegLab',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamilyHeading,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      color: AppTheme.primaryOrange,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gray900,
                        fontFamily: AppTheme.fontFamilyHeading,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ...trailingActions,
          ProfileAvatarButton(
            buttonKey: profileButtonKey,
            onTap: onProfileTap,
            unreadCount: unreadNotificationCount,
          ),
        ],
      ),
    );
  }
}

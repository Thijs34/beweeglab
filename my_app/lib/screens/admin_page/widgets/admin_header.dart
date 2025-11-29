import 'package:flutter/material.dart';
import 'package:my_app/theme/app_theme.dart';

/// Reusable header for the admin page
class AdminHeader extends StatelessWidget {
  final GlobalKey profileButtonKey;
  final VoidCallback onProfileTap;
  final String title;

  const AdminHeader({
    super.key,
    required this.profileButtonKey,
    required this.onProfileTap,
    required this.title,
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          GestureDetector(
            key: profileButtonKey,
            onTap: onProfileTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppTheme.primaryOrange,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: AppTheme.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}

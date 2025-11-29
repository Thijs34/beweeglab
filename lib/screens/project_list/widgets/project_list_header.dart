import 'package:flutter/material.dart';
import 'package:my_app/theme/app_theme.dart';

class ProjectListHeader extends StatelessWidget {
  final GlobalKey profileButtonKey;
  final VoidCallback onProfileTap;

  const ProjectListHeader({
    super.key,
    required this.profileButtonKey,
    required this.onProfileTap,
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
            color: Color(0x0D000000),
            blurRadius: 3,
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
              children: const [
                Text(
                  'InnoBeweegLab',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamilyHeading,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Field Observation System',
                  style: TextStyle(fontSize: 14, color: AppTheme.gray600),
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

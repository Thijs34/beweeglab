import 'package:flutter/material.dart';
import 'package:my_app/theme/app_theme.dart';

class ProfileAvatarButton extends StatelessWidget {
  final GlobalKey buttonKey;
  final VoidCallback onTap;
  final int unreadCount;

  const ProfileAvatarButton({
    super.key,
    required this.buttonKey,
    required this.onTap,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final showBadge = unreadCount > 0;
    final badgeLabel = unreadCount > 9 ? '9+' : unreadCount.toString();

    return GestureDetector(
      key: buttonKey,
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppTheme.primaryOrange,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.person, color: AppTheme.white, size: 24),
          ),
          if (showBadge)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.red600,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppTheme.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  badgeLabel,
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/widgets/profile_avatar_button.dart';

/// Shared header with the project branding, subtitle line and profile button.
/// Consumers can optionally override the subtitle row with a custom widget and
/// inject trailing widgets before the avatar button.
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.profileButtonKey,
    required this.onProfileTap,
    this.title = 'InnoBeweegLab',
    this.subtitle,
    this.subtitleIcon,
    this.subtitleWidget,
    this.trailingActions = const [],
    this.unreadNotificationCount = 0,
  });

  final GlobalKey profileButtonKey;
  final VoidCallback onProfileTap;
  final String title;
  final String? subtitle;
  final IconData? subtitleIcon;
  final Widget? subtitleWidget;
  final List<Widget> trailingActions;
  final int unreadNotificationCount;

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _buildTitleBlock()),
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

  Widget _buildTitleBlock() {
    final subtitleContent = subtitleWidget ?? _buildDefaultSubtitle();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: AppTheme.fontFamilyHeading,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.gray900,
          ),
        ),
        if (subtitleContent != null) ...[
          const SizedBox(height: 4),
          subtitleContent,
        ],
      ],
    );
  }

  Widget? _buildDefaultSubtitle() {
    if (subtitle == null || subtitle!.isEmpty) return null;
    final subtitleRowChildren = <Widget>[];
    if (subtitleIcon != null) {
      subtitleRowChildren.add(Icon(
        subtitleIcon,
        size: 16,
        color: AppTheme.primaryOrange,
      ));
      subtitleRowChildren.add(const SizedBox(width: 6));
    }
    subtitleRowChildren.add(
      Text(
        subtitle!,
        style: const TextStyle(
          fontSize: 14,
          color: AppTheme.gray600,
          fontWeight: FontWeight.w600,
          fontFamily: AppTheme.fontFamilyHeading,
        ),
      ),
    );
    return Row(children: subtitleRowChildren);
  }
}

import 'package:flutter/material.dart';
import 'package:my_app/l10n/l10n.dart';
import 'package:my_app/theme/app_theme.dart';

class UserInfoBar extends StatelessWidget {
  final String? userEmail;
  final VoidCallback onLogout;

  const UserInfoBar({
    super.key,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.white,
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.pageGutter,
        vertical: 14,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.profileLoggedInAs,
                style:
                    const TextStyle(fontSize: 14, color: AppTheme.gray500),
              ),
              const SizedBox(height: 2),
              Text(
                userEmail ?? 'observer@innobeweeglab.nl',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gray900,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: onLogout,
            child: Text(
              context.l10n.profileLogout,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

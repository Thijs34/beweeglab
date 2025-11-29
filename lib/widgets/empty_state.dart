import 'package:flutter/material.dart';
import 'package:my_app/theme/app_theme.dart';

/// Generic empty state widget for screens that need simple messaging.
class EmptyStateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyStateMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppTheme.gray100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: AppTheme.gray400),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamilyHeading,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: AppTheme.gray500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

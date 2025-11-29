import 'package:flutter/material.dart';
import 'package:my_app/theme/app_theme.dart';

class WelcomeSection extends StatelessWidget {
  final String firstName;

  const WelcomeSection({super.key, required this.firstName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, $firstName!',
            style: const TextStyle(
              fontFamily: AppTheme.fontFamilyHeading,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Select a project to begin your observation',
            style: TextStyle(fontSize: 14, color: AppTheme.gray600),
          ),
        ],
      ),
    );
  }
}

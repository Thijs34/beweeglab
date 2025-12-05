import 'package:flutter/material.dart';
import 'package:my_app/l10n/l10n.dart';
import 'package:my_app/theme/app_theme.dart';

class WelcomeSection extends StatelessWidget {
  final String firstName;

  const WelcomeSection({super.key, required this.firstName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppTheme.pageGutter,
        20,
        AppTheme.pageGutter,
        16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.observerWelcomeBack(firstName),
            style: const TextStyle(
              fontFamily: AppTheme.fontFamilyHeading,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.observerSelectProjectPrompt,
            style: const TextStyle(fontSize: 14, color: AppTheme.gray600),
          ),
        ],
      ),
    );
  }
}

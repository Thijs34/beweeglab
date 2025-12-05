import 'package:flutter/material.dart';
import 'package:my_app/l10n/l10n.dart';
import 'package:my_app/theme/app_theme.dart';

/// Displays the InnoBeweegLab logo and product title for auth screens.
class AuthBrandHeader extends StatelessWidget {
  final double logoWidth;

  const AuthBrandHeader({super.key, this.logoWidth = 192});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.network(
          'https://i.postimg.cc/ncxV26bt/afbeelding-(2).jpg',
          width: logoWidth,
          height: logoWidth * 0.5,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: logoWidth,
              height: logoWidth * 0.5,
              color: AppTheme.gray100,
              child: const Center(
                child: Icon(Icons.business, size: 48, color: AppTheme.gray400),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.appTagline,
          style: const TextStyle(fontSize: 14, color: AppTheme.gray600),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:my_app/theme/app_theme.dart';

/// Shared layout wrapper for all auth-related forms.
class AuthFormLayout extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AuthFormLayout({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: padding,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 384),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

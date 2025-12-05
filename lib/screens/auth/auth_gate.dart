import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/l10n/l10n.dart';
import 'package:my_app/screens/auth/login_screen.dart';
import 'package:my_app/screens/project_list/project_list_screen.dart';
import 'package:my_app/services/auth_service.dart';

/// Routes users to the right screen based on their authentication state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        final l10n = context.l10n;
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return _AuthLoading(message: l10n.authCheckingSession);
        }

        final user = authSnapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        return FutureBuilder<String>(
          future: AuthService.instance.getUserRole(user.uid),
          builder: (context, roleSnapshot) {
            final l10n = context.l10n;
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return _AuthLoading(message: l10n.authRestoringWorkspace);
            }

            if (roleSnapshot.hasError) {
              return _AuthError(
                message: l10n.authRestoreError,
                onSignOut: () => FirebaseAuth.instance.signOut(),
              );
            }

            final role = roleSnapshot.data ?? 'observer';
            return ProjectListScreen(userEmail: user.email, userRole: role);
          },
        );
      },
    );
  }
}

class _AuthLoading extends StatelessWidget {
  final String message;

  const _AuthLoading({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _AuthError extends StatelessWidget {
  final String message;
  final VoidCallback onSignOut;

  const _AuthError({required this.message, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onSignOut,
                child: const _ReturnToLoginText(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReturnToLoginText extends StatelessWidget {
  const _ReturnToLoginText();

  @override
  Widget build(BuildContext context) {
    return Text(context.l10n.authReturnToLogin);
  }
}

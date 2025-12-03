import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _AuthLoading(message: 'Checking your session...');
        }

        final user = authSnapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        return FutureBuilder<String>(
          future: AuthService.instance.getUserRole(user.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const _AuthLoading(message: 'Restoring your workspace...');
            }

            if (roleSnapshot.hasError) {
              return _AuthError(
                message:
                    'Unable to restore your profile. Please sign in again.',
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
                child: const Text('Return to login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:my_app/screens/admin_page/admin_page.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/screens/auth/login_screen.dart';
import 'package:my_app/screens/auth/signup_screen.dart';
import 'package:my_app/screens/project_list/project_list_screen.dart';
import 'package:my_app/screens/observer_page/observer_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InnoBeweegLab - Field Observation System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/signup':
            return MaterialPageRoute(builder: (_) => const SignUpScreen());
          case '/projects':
            final email = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (_) => ProjectListScreen(userEmail: email),
            );
          case '/observer':
            final args = settings.arguments as ObserverPageArguments?;
            return MaterialPageRoute(
              builder: (_) => ObserverPage(arguments: args),
            );
          case '/admin':
            final email = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (_) => AdminPage(userEmail: email),
            );
          default:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      },
    );
  }
}

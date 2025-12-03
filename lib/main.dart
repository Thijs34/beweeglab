import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_app/firebase_options.dart';
import 'package:my_app/models/navigation_arguments.dart';
import 'package:my_app/screens/admin_page/admin_page.dart';
import 'package:my_app/screens/admin_notifications/admin_notifications_page.dart';
import 'package:my_app/screens/auth/auth_gate.dart';
import 'package:my_app/screens/auth/signup_screen.dart';
import 'package:my_app/screens/observer_page/observer_page.dart';
import 'package:my_app/screens/project_list/project_list_screen.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AuthService.instance.ensurePersistence();
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
            return MaterialPageRoute(builder: (_) => const AuthGate());
          case '/signup':
            return MaterialPageRoute(builder: (_) => const SignUpScreen());
          case '/projects':
            {
              final args = settings.arguments;
              if (args is ProjectListArguments) {
                return MaterialPageRoute(
                  builder: (_) => ProjectListScreen(
                    userEmail: args.userEmail,
                    userRole: args.userRole,
                  ),
                );
              }
              final email = args as String?;
              return MaterialPageRoute(
                builder: (_) => ProjectListScreen(userEmail: email),
              );
            }
          case '/observer':
            {
              final args = settings.arguments as ObserverPageArguments?;
              return MaterialPageRoute(
                builder: (_) => ObserverPage(arguments: args),
              );
            }
          case '/admin':
            {
              final args = settings.arguments;
              if (args is AdminPageArguments) {
                return MaterialPageRoute(
                  builder: (_) => AdminPage(
                    userEmail: args.userEmail,
                    userRole: args.userRole,
                  ),
                );
              }
              final email = args as String?;
              return MaterialPageRoute(
                builder: (_) => AdminPage(userEmail: email),
              );
            }
          case '/admin-notifications':
            {
              final args = settings.arguments as AdminNotificationsArguments?;
              return MaterialPageRoute(
                builder: (_) => AdminNotificationsPage(arguments: args),
              );
            }
          default:
            return MaterialPageRoute(builder: (_) => const AuthGate());
        }
      },
    );
  }
}

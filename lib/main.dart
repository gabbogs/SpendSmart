import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';

import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SpendSmartApp());
}

class SpendSmartApp extends StatelessWidget {
  const SpendSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpendSmart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        if (child == null) {
          return const SizedBox.shrink();
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: child,
          ),
        );
      },
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _finishedOnboardingThisSession = false;
  bool _wasLoggedIn = false;

  void _finishOnboarding() {
    setState(() {
      _finishedOnboardingThisSession = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snapshot.data;

        if (user != null) {
          _wasLoggedIn = true;
          return const MainNavigationScreen();
        }

        if (_wasLoggedIn) {
          _wasLoggedIn = false;
          _finishedOnboardingThisSession = false;
        }

        if (!_finishedOnboardingThisSession) {
          return OnboardingScreen(
            onFinish: _finishOnboarding,
          );
        }

        return const LoginScreen();
      },
    );
  }
}
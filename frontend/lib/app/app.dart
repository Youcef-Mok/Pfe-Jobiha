import 'package:flutter/material.dart';
import 'package:frontend/features/auth/screens/welcome_screen.dart';
import 'package:frontend/features/auth/screens/login_screen.dart';
import 'package:frontend/features/auth/screens/signup_role_screen.dart';
import 'package:frontend/features/auth/screens/signup_form_screen.dart';
import 'package:frontend/features/auth/screens/signup_profile_screen.dart';
import 'package:frontend/features/auth/screens/recruiter_profile_screen.dart';


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(),
      routes: {
        '/welcome':              (context) => const WelcomeScreen(),
        '/login':                (context) => const LoginScreen(),
        '/signup':               (context) => const SignupRoleScreen(),
        '/signup-form':          (context) => const SignupFormScreen(),
        '/signup-profile':       (context) => const SignupProfileScreen(),
        '/recruiter-profile':    (context) => const RecruiterProfileScreen(),

      },
    );
  }
}

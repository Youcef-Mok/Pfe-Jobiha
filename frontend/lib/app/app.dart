import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/jobs/screens/candidate_home_screen.dart';
import 'package:job_app/features/jobs/screens/jobs_list_screen.dart';
import 'package:job_app/features/auth/screens/welcome_screen.dart';
import 'package:job_app/features/auth/screens/login_screen.dart';
import 'package:job_app/features/auth/screens/verify_email_screen.dart';
import 'package:job_app/features/auth/screens/signup_role_screen.dart';
import 'package:job_app/features/auth/screens/signup_form_screen.dart';
import 'package:job_app/features/auth/screens/signup_profile_screen.dart';
import 'package:job_app/features/auth/screens/forgot_password_screen.dart';
import 'package:job_app/features/auth/screens/preferences_screen.dart';
import 'package:job_app/features/auth/screens/recruiter_profile_screen.dart';
import 'package:job_app/features/profile/screens/recruiter_public_profile_screen.dart';
import 'package:job_app/features/profile/screens/candidate_public_profile_screen.dart';
import 'package:job_app/features/profile/screens/edit_profile_screen.dart';
import 'package:job_app/features/profile/screens/report_comment_screen.dart';

// ── AuthGate imports ──────────────────────────────────────────────────────────
import 'package:job_app/features/auth/providers/auth_providers.dart';
import 'package:job_app/features/auth/data/models/auth_state.dart';


// ── Mouse drag scrolling on web ───────────────────────────────────────────────
class _WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}


// ── AuthGate ──────────────────────────────────────────────────────────────────
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    switch (auth.status) {
      case AuthStatus.initial:
      case AuthStatus.loading:
        return const Scaffold(
          backgroundColor: Colors.white,
          body: SizedBox.shrink(),
        );

      case AuthStatus.authenticated:
        return auth.role == 'candidat'
            ? const CandidateHomeScreen()
            : const JobsListScreen();

      default:
        return const WelcomeScreen();
    }
  }
}


// ── App ───────────────────────────────────────────────────────────────────────
class App extends StatelessWidget {
  const App({super.key});

  static final Map<String, WidgetBuilder> _routes = {
    '/welcome':                  (_) => const WelcomeScreen(),
    '/login':                    (_) => const LoginScreen(),
    '/verify-email':             (_) => const VerifyEmailScreen(),
    '/signup':                   (_) => const SignupRoleScreen(),
    '/signup-form':              (_) => const SignupFormScreen(),
    '/signup-profile':           (_) => const SignupProfileScreen(),
    '/forgot-password':          (_) => const ForgotPasswordScreen(),   
    '/preferences':              (_) => const PreferencesScreen(),
    '/recruiter-profile':        (_) => const RecruiterProfileScreen(),
    '/recruiter-public-profile': (_) => const RecruiterPublicProfileScreen(),
    '/candidate-public-profile': (_) => const CandidatePublicProfileScreen(),
    '/edit-profile':             (_) => const EditProfileScreen(),
    '/candidate-home':           (_) => const CandidateHomeScreen(),
    '/recruiter-home':           (_) => const JobsListScreen(),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTextStyles.lightTheme,
      scrollBehavior: _WebScrollBehavior(),
      home: const _AuthGate(),
      routes: _routes,
      onGenerateRoute: (settings) {
        if (settings.name == '/report-comment') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (_) => ReportCommentScreen(
              authorName: args?['authorName'] ?? '',
              commentText: args?['commentText'] ?? '',
            ),
          );
        }
        return null;
      },
    );
  }
}
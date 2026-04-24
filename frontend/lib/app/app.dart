// C:\projects\Pfe-Jobiha\frontend\lib\app\app.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/features/auth/screens/welcome_screen.dart';
import 'package:job_app/features/auth/screens/login_screen.dart';
import 'package:job_app/features/auth/screens/signup_role_screen.dart';
import 'package:job_app/features/auth/screens/signup_form_screen.dart';
import 'package:job_app/features/auth/screens/signup_profile_screen.dart';
import 'package:job_app/features/auth/screens/verify_email_screen.dart';
import 'package:job_app/features/auth/screens/recruiter_profile_screen.dart';
//import 'package:job_app/features/auth/screens/google_profile_screen.dart'; <- still not used
import 'package:job_app/features/jobs/screens/jobs_list_screen.dart';

import 'package:job_app/features/settings/screens/settings_screen.dart';
import 'package:job_app/features/settings/screens/saved_screen.dart';
import 'package:job_app/features/settings/screens/applications_sent_screen.dart';
//import 'package:job_app/features/settings/screens/applications_received_screen.dart'; <= for the Recruiter role
import 'package:job_app/features/settings/screens/personal_info_screen.dart';
import 'package:job_app/features/settings/screens/security_screen.dart';
import 'package:job_app/features/settings/screens/deactivate_account_screen.dart';
import 'package:job_app/features/settings/screens/accessibility_screen.dart';
import 'package:job_app/features/settings/screens/language_screen.dart';
import 'package:job_app/features/settings/screens/blocked_users_screen.dart';
import 'package:job_app/features/settings/screens/help_center_screen.dart';
import 'package:job_app/features/settings/screens/privacy_policy_screen.dart';
import 'package:job_app/features/settings/screens/terms_conditions_screen.dart';
import 'package:job_app/features/settings/screens/notifications_screen.dart' as settings_notif;
import 'package:job_app/features/auth/screens/preferences_screen.dart';
import 'package:job_app/features/messaging/screens/chat_list_screen.dart';
import 'package:job_app/features/notifications/screens/candidate_notifications_screen.dart';
import 'package:job_app/features/notifications/screens/notifications_screen.dart' as recruiter_notif;

// ── ADDED these two imports for the AuthGate ───────────────────────────────────
import 'package:job_app/features/auth/providers/auth_providers.dart';
import 'package:job_app/features/auth/data/models/auth_state.dart';

// ── Placeholder home screens (TO DO : replace with real screens when ready) ───
class _CandidatHomeScreen extends StatelessWidget {
  const _CandidatHomeScreen();
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Candidat Dashboard')),
        body: const Center(child: Text('Bienvenue, candidat! 🎉')),
      );
}

// ── AuthGate ───────────────────────────────────────────────────────────────────
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
            ? const _CandidatHomeScreen()
            : const JobsListApp();

      default:
        return const WelcomeScreen();
    }
  }
}

// ── App ────────────────────────────────────────────────────────────────────────
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      //home: const _AuthGate(),
      //home: const WelcomeScreen(),
      home: const SettingsScreen(),

      routes: {
        '/home-candidat':           (context) => const _CandidatHomeScreen(),
        '/home-recruteur':          (context) => const JobsListApp(),
        '/welcome':                 (context) => const WelcomeScreen(),
        '/login':                   (context) => const LoginScreen(),
        '/signup':                  (context) => const SignupRoleScreen(),
        '/signup-form':             (context) => const SignupFormScreen(),
        '/verify-email':            (context) => const VerifyEmailScreen(),
        '/signup-profile':          (context) => const SignupProfileScreen(),
        '/recruiter-profile':       (context) => const RecruiterProfileScreen(),
        '/settings':                (context) => const SettingsScreen(),
        '/saved':                   (context) => const SavedScreen(),
        '/notifications':           (context) => const settings_notif.NotificationsScreen(),
        '/applications-sent':       (context) => const ApplicationsSentScreen(),
        '/personal-info':           (context) => const PersonalInfoScreen(),
        '/security':                (context) => const SecurityScreen(),
        '/deactivate-account':      (context) => const DeactivateAccountScreen(),
        '/accessibility':           (context) => const AccessibilityScreen(),
        '/language':                (context) => const LanguageScreen(),
        '/blocked-users':           (context) => const BlockedUsersScreen(),
        '/help-center':             (context) => const HelpCenterScreen(),
        '/privacy-policy':          (context) => const PrivacyPolicyScreen(),
        '/terms-conditions':        (context) => const TermsConditionsScreen(),
        '/preferences':             (context) => const PreferencesScreen(),
        '/messages':                (context) => const ChatListScreen(),
        '/candidate-notifications': (context) => const CandidateNotificationsScreen(),
        '/recruiter-notifications': (context) => const recruiter_notif.NotificationsScreen(),
      },
    );
  }
}
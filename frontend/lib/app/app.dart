import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
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
import 'package:job_app/features/profile/screens/recruiter_edit_profile_screen.dart';
import 'package:job_app/features/profile/screens/report_comment_screen.dart';

// Enables mouse drag scrolling on web
class _WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class App extends StatelessWidget {
  final Widget initialScreen;

  const App({super.key, required this.initialScreen});

  static final Map<String, WidgetBuilder> _routes = {
    '/welcome':           (_) => const WelcomeScreen(),
    '/login':             (_) => const LoginScreen(),
    '/verify-email':      (_) => const VerifyEmailScreen(),
    '/signup':            (_) => const SignupRoleScreen(),
    '/signup-form':       (_) => const SignupFormScreen(),
    '/signup-profile':    (_) => const SignupProfileScreen(),
    '/forgot-password':   (_) => const ForgotPasswordScreen(),
    '/preferences':       (_) => const PreferencesScreen(),
    '/home-recruteur':    (_) => const JobsListScreen(),
    '/recruiter-profile': (_) => const RecruiterProfileScreen(),
    '/recruiter-public-profile': (_) => const RecruiterPublicProfileScreen(),
    '/candidate-public-profile': (_) => const CandidatePublicProfileScreen(),
    '/edit-profile':      (_) => const EditProfileScreen(),
    '/edit-profile-recruiter': (_) => const RecruiterEditProfileScreen(),
    '/candidate-home':    (_) => const CandidateHomeScreen(),
    '/recruiter-home':    (_) => const JobsListScreen(),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTextStyles.lightTheme,
      scrollBehavior: _WebScrollBehavior(),
      home: initialScreen,
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

// ─────────────────────────────────────────────
// Écran de sélection du rôle (Candidat/Recruteur)
// ─────────────────────────────────────────────
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.work_outline,
                size: 80,
                color: AppColors.violet,
              ),
              const SizedBox(height: 32),
              Text(
                'Choisissez votre mode',
                style: AppTextStyles.heading1.copyWith(
                  fontSize: 28,
                  color: AppColors.violet,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Sélectionnez le mode dans lequel vous souhaitez utiliser l\'application',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.slate600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Bouton Candidat
              _RoleCard(
                icon: Icons.person_outline,
                title: 'Mode Candidat',
                description: 'Rechercher des emplois et postuler',
                color: const Color(0xFF401E66),
                onTap: () => Navigator.pushReplacementNamed(context, '/candidate-home'),
              ),
              
              const SizedBox(height: 20),
              
              // Bouton Recruteur
              _RoleCard(
                icon: Icons.business_center_outlined,
                title: 'Mode Recruteur',
                description: 'Publier des offres et gérer les candidatures',
                color: const Color(0xFF7F13EC),
                onTap: () => Navigator.pushReplacementNamed(context, '/recruiter-home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.heading3.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.captionLight.copyWith(
                      color: AppColors.slate600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

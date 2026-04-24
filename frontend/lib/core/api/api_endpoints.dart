// lib/core/api/api_endpoints.dart

class ApiEndpoints {
  // Use 10.0.2.2 for Android emulator (maps to host machine's localhost).
  // Switch to your real IP / production URL for physical devices / release.
 // static const String _base = 'http://10.0.2.2:8000/api/v1'; // virtual device
   static const String _base = 'http://192.168.100.9:8000/api/v1'; // physical device - PC IPV4
  // static const String _base = 'https://api.petitsjobs.dz/v1';   // production

  // ── Auth ────────────────────────────────────────────────────────────────────
  static const String registerCandidat  = '$_base/auth/register/candidat';
  static const String registerRecruteur = '$_base/auth/register/recruteur';
  static const String login             = '$_base/auth/login';
  static const String logout            = '$_base/auth/logout';
  static const String tokenRefresh      = '$_base/auth/token/refresh';
  static const String changePassword    = '$_base/auth/password/change';
  static const String verifyEmail       = '$_base/auth/verify-email';
  static const String resendOtp         = '$_base/auth/resend-otp';
  static const String googleLogin       = '$_base/auth/google';
  static const String googleComplete    = '$_base/auth/google/complete';

  // ── Users ───────────────────────────────────────────────────────────────────
  static const String me                = '$_base/users/me';

  // ── Candidat ────────────────────────────────────────────────────────────────
  static const String candidatMe        = '$_base/candidats/me';
  static const String candidatDispos    = '$_base/candidats/me/disponibilites';
  static const String candidatPortfolio = '$_base/candidats/me/portfolio';

  // ── Recruteur ───────────────────────────────────────────────────────────────
  static const String recruteurMe       = '$_base/recruteurs/me';
  // ── Settings ─────────────────────────────────────────────────────────────
  static const String savedJobs         = '$_base/candidats/me/saved';
  static const String appliedJobs       = '$_base/applications/me';
  static const String notifications     = '$_base/notifications/me';
  static const String blockedUsers      = '$_base/users/me/blocked';
  static const String deactivateAccount = '$_base/users/me/deactivate';
  static const String pushNotifPref     = '$_base/users/me/preferences';
}
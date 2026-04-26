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

  // __ forgot password _________________________________________________________

  static const String forgotPassword = '$_base/auth/password/forgot';
  static const String resetPassword  = '$_base/auth/password/reset';

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
  static const String notifications     = '$_base/notifications';
  static const String blockedUsers      = '$_base/users/me/blocked';
  static const String deactivateAccount = '$_base/users/me/deactivate';
  static const String pushNotifPref     = '$_base/users/me/preferences';
  static const String receivedApplications = '$_base/recruteurs/me/candidatures';
  static const String appliedJobs       = '$_base/candidatures/me';


  // ── Offres ───────────────────────────────────────────────
  static String offreDetail(int id)        => '$_base/offres/$id'; 
  static String fermerOffre(int id)        => '$_base/offres/$id/fermer';
  static const String offres               = '$_base/offres';
  static const String myOffres             = '$_base/recruteurs/me/offres';
  static String offreCandidatures(int id) => '$_base/offres/$id/candidatures';

  // ── Candidatures ─────────────────────────────────────────
  static String candidatureDetail(int id)  => '$_base/candidatures/$id';
  static String accepterCandidature(int id)=> '$_base/candidatures/$id/accepter';
  static String refuserCandidature(int id) => '$_base/candidatures/$id/refuser';

  // ── Missions ─────────────────────────────────────────────
  static const String missions             = '$_base/missions';
  static String missionDetail(int id)      => '$_base/missions/$id';
  static String validerDebut(int id)       => '$_base/missions/$id/valider-debut';
  static String validerFin(int id)         => '$_base/missions/$id/valider-fin';
  static String attestation(int id)        => '$_base/missions/$id/attestation';
  static const String historiqueCandidat   = '$_base/candidats/me/historique';

  // ── Messagerie ───────────────────────────────────────────
  static const String conversations        = '$_base/messages/conversations';
  static String conversation(int userId)   => '$_base/messages/conversations/$userId';
  static const String sendMessage          = '$_base/messages';
  static String marquerMessageLu(int id)   => '$_base/messages/$id/lire';
  static String marquerConvLue(int userId) => '$_base/messages/conversations/$userId/lire-tout';
  static const String notifCount           = '$_base/notifications/non-lues/count';
  static String marquerNotifLue(int id)    => '$_base/notifications/$id/lire';
  static const String marquerToutesLues    = '$_base/notifications/lire-tout';

  // ── Evaluations ──────────────────────────────────────────
  static const String evaluations          = '$_base/evaluations';
  static String evaluationDetail(int id)   => '$_base/evaluations/$id';
  static String missionEvaluations(int id) => '$_base/missions/$id/evaluations';
  static String userEvaluations(int id)    => '$_base/utilisateurs/$id/evaluations';
  static String userReputation(int id)     => '$_base/utilisateurs/$id/reputation';

  // ── Signalements ─────────────────────────────────────────
  static const String signalements         = '$_base/signalements';
  static const String mySignalements       = '$_base/signalements/me';

  // ── Candidat public ──────────────────────────────────────
  static String candidatPublic(int id)     => '$_base/candidats/$id';
  static String recruteurPublic(int id)    => '$_base/recruteurs/$id';

  // __ Job alerts ______________________________________________

  static const String alertes = '$_base/candidats/me/alertes';
  static String alerteDetail(int id) => '$_base/candidats/me/alertes/$id';


}
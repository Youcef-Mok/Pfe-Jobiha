// lib/core/api/api_endpoints.dart

class ApiEndpoints {
  // Use 10.0.2.2 for Android emulator (maps to host machine's localhost).
  // Switch to your real IP / production URL for physical devices / release.
 // static const String _base = 'http://10.0.2.2:8000/api/v1'; // virtual device
   static const String _base = 'http://192.168.100.9:8000/api/v1'; //phisical phone
  // static const String _base = 'https://api.petitsjobs.dz/v1';   // production

  // ── WebSocket base ─────────────────────────────────────────────────────────
  // Mirrors _base but uses ws:// scheme and no /api/v1 prefix.
  // static const String _wsBase = 'ws://10.0.2.2:8000';          // virtual device
  static const String _wsBase = 'ws://192.168.100.9:8000';        // physical device
  // static const String _wsBase = 'wss://api.petitsjobs.dz';     // production

  /// Public getter for WebSocket base URL
  static String get wsBase => _wsBase;

  /// WebSocket URL for a chat session with [conversationId].
  /// Token is passed as a query parameter for the JWT middleware.
  static String chatWebSocket(int conversationId, String token) =>
      '$_wsBase/ws/chat/$conversationId/?token=$token';

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
  static const String users             = '$_base/users';
  static const String me                = '$_base/users/me';
  static const String meAvatar          = '$_base/users/me/avatar';
  static String userById(int userId)    => '$_base/users/$userId';
  static String userReviews(int userId) => '$_base/users/$userId/reviews';
  static String userCv(int userId)      => '$_base/users/$userId/cv';
  static const String userSavedJobs     = '$_base/users/me/saved-jobs';
  static String deleteSavedJob(String jobId) => '$_base/users/me/saved-jobs/$jobId';
  static const String userBlocked       = '$_base/users/me/blocked';
  static String unblockUser(String contactId) => '$_base/users/me/blocked/$contactId';
  static const String userRestricted    = '$_base/users/me/restricted';
  static String unrestrictUser(String contactId) => '$_base/users/me/restricted/$contactId';
  static const String userRecentSearches = '$_base/users/me/recent-searches';

  // ── Candidat ────────────────────────────────────────────────────────────────
  static const String candidatMe        = '$_base/candidats/me'; 
  static const String candidatDispos    = '$_base/candidats/me/disponibilites'; 
  static const String candidatPortfolio = '$_base/candidats/me/portfolio';
  static String candidatById(int id)    => '$_base/candidats/$id';

  // ── Recruteur ───────────────────────────────────────────────────────────────
  static const String recruteurMe       = '$_base/recruteurs/me';
  static String recruteurById(int id)   => '$_base/recruteurs/$id';

  // ── Settings ─────────────────────────────────────────────────────────────
  static const String settings          = '$_base/settings';
  static const String settingsNotifs    = '$_base/settings/notifications';
  static const String settingsNotifications = '$_base/settings/notifications';
  static const String settingsTheme     = '$_base/settings/theme';
  static const String settingsLanguage  = '$_base/settings/language';
  static const String deleteAccount     = '$_base/account';
  static const String savedJobs         = '$_base/candidats/me/saved';
  static String savedJobIds             = '$_base/candidats/me/saved/ids';
  static const String notifications     = '$_base/notifications';
  static String notificationRead(int id) => '$_base/notifications/$id/read';
  static String notificationDelete(int id) => '$_base/notifications/$id';
  static const String blockedUsers      = '$_base/users/me/blocked';
  static const String deactivateAccount = '$_base/users/me/deactivate';
  static const String pushNotifPref     = '$_base/users/me/preferences';
  // Received applications (recruiter view) — backend: GET /applications
  static const String receivedApplications = '$_base/applications';
  // Applied jobs (candidate view) — backend: GET /applications
  static const String appliedJobs       = '$_base/applications';
  static const String applications      = '$_base/applications';
  static String applicationDetail(int id) => '$_base/applications/$id';
  static String acceptApplication(int id) => '$_base/applications/$id/accept';
  static String rejectApplication(int id) => '$_base/applications/$id/reject';

  // ── Offres (Jobs) ────────────────────────────────────────────────────────
  static const String jobs              = '$_base/jobs';
  static const String jobsMine          = '$_base/jobs/mine';
  static const String jobsMap           = '$_base/jobs/map';
  static String jobDetail(int id)       => '$_base/jobs/$id';
  static String closeJob(int id)        => '$_base/jobs/$id/close';
  static String jobCandidates(int id)   => '$_base/jobs/$id/candidates';
  
  // Legacy aliases (keep for backward compatibility)
  static String offreDetail(int id)        => '$_base/jobs/$id';
  static String fermerOffre(int id)        => '$_base/jobs/$id/close';
  static const String offres               = '$_base/jobs';
  static const String myOffres             = '$_base/jobs/mine';
  static String offreCandidatures(int id) => '$_base/jobs/$id/candidates';

  // ── Candidates ───────────────────────────────────────────────────────────
  static String candidateProfile(int candidateId) => '$_base/candidates/$candidateId/profile';
  static String candidateStatus(int candidateId) => '$_base/candidates/$candidateId/status';

  // ── Candidatures (Applications) ──────────────────────────────────────────
  static String candidatureDetail(int id)  => '$_base/applications/$id';
  static String accepterCandidature(int id)=> '$_base/applications/$id/accept';
  static String refuserCandidature(int id) => '$_base/applications/$id/reject';

  // ── Missions ─────────────────────────────────────────────────────────────
  static const String missions             = '$_base/missions';
  static String missionDetail(int id)      => '$_base/missions/$id';
  static String missionConfirm(int id)     => '$_base/missions/$id/confirm';
  static String missionReview(int id)      => '$_base/missions/$id/review';
  static String validerDebut(int id)       => '$_base/missions/$id/valider-debut';
  static String validerFin(int id)         => '$_base/missions/$id/valider-fin';
  static String attestation(int id)        => '$_base/missions/$id/attestation';
  static const String historiqueCandidat   = '$_base/candidats/me/historique';

  // ── Interviews ───────────────────────────────────────────────────────────
  static const String interviews           = '$_base/interviews';
  static String interviewDetail(int id)    => '$_base/interviews/$id';
  static String interviewComplete(int id)  => '$_base/interviews/$id/complete';

  // ── Messagerie (Conversations) ───────────────────────────────────────────
  // Backend messaging URLs are mounted at /api/v1/ (no /messages/ prefix).
  // All paths match apps/messaging/urls.py exactly.
  static const String conversations              = '$_base/conversations';
  static const String conversationsInvitations   = '$_base/conversations/invitations';
  static String conversation(int convId)         => '$_base/conversations/$convId';
  // sendMessage: POST /conversations/<convId>/messages
  static String sendMessage(int convId)          => '$_base/conversations/$convId/messages';
  static String sendImageMessage(int convId)     => '$_base/conversations/$convId/messages/image';
  static String sendFileMessage(int convId)      => '$_base/conversations/$convId/messages/file';
  // Backend uses 'read-all', not 'lire-tout'
  static String marquerConvLue(int convId)       => '$_base/conversations/$convId/read-all';
  static String getOrCreateDm(int userId)        => '$_base/conversations/dm/$userId';
  // Backend: POST /conversations/group
  static const String createGroup                = '$_base/conversations/group';
  static String groupMembers(int groupId)        => '$_base/conversations/$groupId/members';
  // No separate add-member endpoint — use members list URL (POST)
  static String addGroupMember(int groupId)      => '$_base/conversations/$groupId/members';
  // No separate remove-member endpoint — DELETE on members list
  static String removeGroupMember(int gId, int uId) => '$_base/conversations/$gId/members';
  static String acceptConversation(int convId)   => '$_base/conversations/$convId/accept';
  static String declineConversation(int convId)  => '$_base/conversations/$convId/decline';
  static const String deleteConversations        = '$_base/conversations';

  // ── Reports ──────────────────────────────────────────────────────────────
  static const String reports              = '$_base/reports';

  // ── Notifications ────────────────────────────────────────────────────────
  static const String notifCount              = '$_base/notifications/non-lues/count';
  static const String notificationsReadAll    = '$_base/notifications/read-all';
  // Legacy aliases (kept for any existing call sites)
  static String marquerNotifLue(int id)       => '$_base/notifications/$id/read';
  static const String marquerToutesLues       = '$_base/notifications/read-all';

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

  // __ Candidate CV (write) ______________________________________
  static const String cvExperiences  = '$_base/candidates/me/cv/experiences';
  static const String cvFormations   = '$_base/candidates/me/cv/formations';
  static const String cvSkills       = '$_base/candidates/me/cv/skills';
  static const String cvLanguages    = '$_base/candidates/me/languages';

  // __ Job alerts ______________________________________________
  static const String alertes = '$_base/candidats/me/alertes';
  static String alerteDetail(int id) => '$_base/candidats/me/alertes/$id';

  // __ Map ________________________________________________________
  static const String mapJobs             = '$_base/jobs/map';
  static const String recentSearches      = '$_base/users/me/recent-searches';
  static const String recentSearchCreate  = '$_base/searches';
  static const String recentSearchClear   = '$_base/users/me/recent-searches/clear';
}
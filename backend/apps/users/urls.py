"""
URL routing for the Auth + Profiles module.
All paths match the OpenAPI spec exactly (no trailing slashes).
Mounted at api/v1/ in config/urls.py.
"""
from django.urls import path
from apps.users import views

urlpatterns = [
    # --- Auth ---
    path('auth/register/candidat', views.RegisterCandidatView.as_view(), name='register-candidat'),
    path('auth/register/recruteur', views.RegisterRecruteurView.as_view(), name='register-recruteur'),
    path('auth/register', views.UnifiedRegisterView.as_view(), name='register-unified'),
    path('auth/login', views.LoginView.as_view(), name='login'),
    path('auth/logout', views.LogoutView.as_view(), name='logout'),
    path('auth/token/refresh', views.CustomTokenRefreshView.as_view(), name='token-refresh'),
    path('auth/refresh', views.CustomTokenRefreshView.as_view(), name='token-refresh-alias'),
    path('auth/password/change', views.ChangePasswordView.as_view(), name='change-password'),
    path('auth/verify-email', views.VerifyEmailView.as_view(), name='verify-email'),
    path('auth/resend-otp', views.ResendOtpView.as_view(), name='resend-otp'),
    path('auth/google', views.GoogleLoginView.as_view(), name='google-login'),
    path('auth/google/complete', views.GoogleCompleteView.as_view(), name='google-complete'),

    # --- Forget password ---
    path('auth/password/forgot', views.ForgotPasswordView.as_view(), name='forgot-password'),
    path('auth/password/reset',  views.ResetPasswordView.as_view(),  name='reset-password'),

    # --- Users ---
    path('users/me', views.UserMeView.as_view(), name='user-me'),
    path('users/<int:id>/reviews', views.UserReviewsView.as_view(), name='user-reviews'),
    path('users/<int:id>/cv', views.UserCvView.as_view(), name='user-cv'),
    path('users/<int:id>', views.UserByIdView.as_view(), name='user-by-id'),

    # --- Candidats ---
    path('candidats/me', views.CandidatMeView.as_view(), name='candidat-me'),
    path('candidats/me/disponibilites', views.DisponibiliteListCreateView.as_view(), name='disponibilites-list'),
    path('candidats/me/disponibilites/<int:id>', views.DisponibiliteDetailView.as_view(), name='disponibilite-detail'),
    path('candidats/me/portfolio', views.PortfolioListCreateView.as_view(), name='portfolio-list'),
    path('candidats/me/portfolio/<int:id>', views.PortfolioDeleteView.as_view(), name='portfolio-detail'),
    path('candidats/<int:id>', views.CandidatByIdView.as_view(), name='candidat-detail'),

    # --- Recruteurs ---
    path('recruteurs/me', views.RecruteurMeView.as_view(), name='recruteur-me'),
    path('recruteurs/<int:id>', views.RecruteurByIdView.as_view(), name='recruteur-detail'),

    # --- Account ---
    path('account', views.AccountDeleteView.as_view(), name='account-delete'),

    # --- Settings ---
    path('settings', views.UserSettingsView.as_view(), name='settings'),
    path('settings/notifications', views.SettingsNotificationsView.as_view(), name='settings-notifications'),
    path('settings/theme', views.SettingsThemeView.as_view(), name='settings-theme'),
    path('settings/language', views.SettingsLanguageView.as_view(), name='settings-language'),

    # --- Recent searches (both legacy /searches and spec /users/me/recent-searches) ---
    path('searches/recent', views.RecentSearchListView.as_view(), name='recent-searches'),
    path('searches', views.RecentSearchCreateView.as_view(), name='searches-create'),
    path('users/me/recent-searches', views.RecentSearchListView.as_view(), name='recent-searches-v2'),
    path('users/me/recent-searches/clear', views.RecentSearchCreateView.as_view(), name='recent-searches-clear'),

    # --- Blocked users ---
    path('users/me/blocked', views.BlockedUsersView.as_view(), name='blocked-users'),
    path('users/me/blocked/<int:id>', views.BlockedUsersView.as_view(), name='blocked-users-delete'),
    path('users/me/deactivate', views.DeactivateAccountView.as_view(), name='deactivate-account'),
    path('users/me/preferences', views.PushNotifPrefView.as_view(), name='push-notif-pref'),

    # --- Restricted users ---
    path('users/me/restricted', views.RestrictedUsersView.as_view(), name='restricted-users'),
    path('users/me/restricted/<int:id>', views.RestrictedUsersView.as_view(), name='restricted-user-detail'),

    # --- Saved job IDs (read-only — writes via /candidats/me/saved) ---
    path('users/me/saved-jobs', views.SavedJobIdsView.as_view(), name='saved-job-ids'),

    # --- Candidate public profile ---
    path('candidates/<int:id>/profile', views.CandidatePublicProfileView.as_view(), name='candidate-public-profile'),

    # --- Reports ---
    path('reports', views.ReportsView.as_view(), name='reports'),

    # --- Admin ---
    path('admin/utilisateurs', views.AdminUserListView.as_view(), name='admin-users'),
    path('admin/utilisateurs/<int:id>/sanctionner', views.AdminSanctionView.as_view(), name='admin-sanction'),

    # --- Candidate skill groups ---
    path('candidates/me/skill-groups', views.CandidateSkillGroupsView.as_view(), name='skill-groups'),
    path('candidates/me/skill-groups/<int:id>', views.CandidateSkillGroupDetailView.as_view(), name='skill-group-detail'),
    path('candidates/me/skill-groups/<int:group_id>/skills', views.CandidateSkillsView.as_view(), name='skills-create'),
    path('candidates/me/skill-groups/<int:group_id>/skills/<int:skill_id>', views.CandidateSkillDetailView.as_view(), name='skill-detail'),

    # --- Candidate languages ---
    path('candidates/me/languages', views.CandidateLanguagesView.as_view(), name='languages'),
    path('candidates/me/languages/<int:id>', views.CandidateLanguageDetailView.as_view(), name='language-detail'),

    # --- Candidate tools ---
    path('candidates/me/tools', views.CandidateToolsView.as_view(), name='tools'),
    path('candidates/me/tools/<int:id>', views.CandidateToolDetailView.as_view(), name='tool-detail'),

    # --- Candidate CV ---
    path('candidates/me/cv/formations', views.CandidateCvFormationsView.as_view(), name='cv-formations'),
    path('candidates/me/cv/formations/', views.CandidateCvFormationsView.as_view(), name='cv-formations-slash'),
    path('candidates/me/cv/formations/<int:id>', views.CandidateCvFormationDetailView.as_view(), name='cv-formation-detail'),
    path('candidates/me/cv/formations/<int:id>/', views.CandidateCvFormationDetailView.as_view(), name='cv-formation-detail-slash'),
    path('candidates/me/cv/experiences', views.CandidateCvExperiencesView.as_view(), name='cv-experiences'),
    path('candidates/me/cv/experiences/', views.CandidateCvExperiencesView.as_view(), name='cv-experiences-slash'),
    path('candidates/me/cv/experiences/<int:id>', views.CandidateCvExperienceDetailView.as_view(), name='cv-experience-detail'),
    path('candidates/me/cv/experiences/<int:id>/', views.CandidateCvExperienceDetailView.as_view(), name='cv-experience-detail-slash'),
    path('candidates/me/cv/skills', views.CandidateCvSkillsView.as_view(), name='cv-skills'),
    path('candidates/me/cv/skills/', views.CandidateCvSkillsView.as_view(), name='cv-skills-slash'),

    # --- Candidate CV (FR aliases for frontend compatibility) ---
    path('candidats/me/cv/formations', views.CandidateCvFormationsView.as_view(), name='cv-formations-fr'),
    path('candidats/me/cv/formations/', views.CandidateCvFormationsView.as_view(), name='cv-formations-fr-slash'),
    path('candidats/me/cv/formations/<int:id>', views.CandidateCvFormationDetailView.as_view(), name='cv-formation-detail-fr'),
    path('candidats/me/cv/formations/<int:id>/', views.CandidateCvFormationDetailView.as_view(), name='cv-formation-detail-fr-slash'),
    path('candidats/me/cv/experiences', views.CandidateCvExperiencesView.as_view(), name='cv-experiences-fr'),
    path('candidats/me/cv/experiences/', views.CandidateCvExperiencesView.as_view(), name='cv-experiences-fr-slash'),
    path('candidats/me/cv/experiences/<int:id>', views.CandidateCvExperienceDetailView.as_view(), name='cv-experience-detail-fr'),
    path('candidats/me/cv/experiences/<int:id>/', views.CandidateCvExperienceDetailView.as_view(), name='cv-experience-detail-fr-slash'),
    path('candidats/me/cv/skills', views.CandidateCvSkillsView.as_view(), name='cv-skills-fr'),
    path('candidats/me/cv/skills/', views.CandidateCvSkillsView.as_view(), name='cv-skills-fr-slash'),

    # --- Review reply ---
    path('users/<int:user_id>/reviews/<int:review_id>/reply', views.ReviewReplyView.as_view(), name='review-reply'),
]

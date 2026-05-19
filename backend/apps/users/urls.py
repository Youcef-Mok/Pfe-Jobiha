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

    # --- Recent searches ---
    path('searches/recent', views.RecentSearchListView.as_view(), name='recent-searches'),
    path('searches', views.RecentSearchCreateView.as_view(), name='searches-create'),

    # --- Blocked users ---
    path('users/me/blocked', views.BlockedUsersView.as_view(), name='blocked-users'),
    path('users/me/blocked/<int:id>', views.BlockedUsersView.as_view(), name='blocked-users-delete'),
    path('users/me/deactivate', views.DeactivateAccountView.as_view(), name='deactivate-account'),
    path('users/me/preferences', views.PushNotifPrefView.as_view(), name='push-notif-pref'),

    # --- Admin ---
    path('admin/utilisateurs', views.AdminUserListView.as_view(), name='admin-users'),
    path('admin/utilisateurs/<int:id>/sanctionner', views.AdminSanctionView.as_view(), name='admin-sanction'),
]

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
    path('auth/login', views.LoginView.as_view(), name='login'),
    path('auth/logout', views.LogoutView.as_view(), name='logout'),
    path('auth/token/refresh', views.CustomTokenRefreshView.as_view(), name='token-refresh'),
    path('auth/password/change', views.ChangePasswordView.as_view(), name='change-password'),

    # --- Users ---
    path('users/me', views.UserMeView.as_view(), name='user-me'),

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

    # --- Admin ---
    path('admin/utilisateurs', views.AdminUserListView.as_view(), name='admin-users'),
    path('admin/utilisateurs/<int:id>/sanctionner', views.AdminSanctionView.as_view(), name='admin-sanction'),
]

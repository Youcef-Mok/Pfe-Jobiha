"""
apps/reviews/urls.py

URL patterns for the Évaluations & Signalements module.

IMPORTANT — order matters:
  'signalements/me' must come BEFORE any future dynamic <int:id> signalement routes
  so Django does not interpret 'me' as an integer.

Admin endpoints (/admin/signalements*) are intentionally excluded per spec.
"""
from django.urls import path
from apps.reviews import views

urlpatterns = [

    # ── Evaluations ────────────────────────────────────────────────────────
    # POST /evaluations
    path('evaluations', views.EvaluationListCreateView.as_view(), name='evaluations-list'),

    # GET /evaluations/{id}
    path('evaluations/<int:id>', views.EvaluationDetailView.as_view(), name='evaluation-detail'),

    # GET /missions/{id}/evaluations
    path('missions/<int:id>/evaluations', views.MissionEvaluationsView.as_view(), name='mission-evaluations'),

    # GET /utilisateurs/{id}/evaluations
    path('utilisateurs/<int:id>/evaluations', views.UserEvaluationsView.as_view(), name='user-evaluations'),

    # GET /utilisateurs/{id}/reputation
    path('utilisateurs/<int:id>/reputation', views.UserReputationView.as_view(), name='user-reputation'),

    # ── Signalements ───────────────────────────────────────────────────────
    # GET /signalements/me  — static path BEFORE any future <int:id> route
    path('signalements/me', views.MySignalementsView.as_view(), name='my-signalements'),

    # POST /signalements
    path('signalements', views.SignalementListCreateView.as_view(), name='signalements-list'),
]
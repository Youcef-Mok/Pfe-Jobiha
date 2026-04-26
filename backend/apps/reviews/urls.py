from django.urls import path
from apps.reviews import views

urlpatterns = [
    #path('evaluations', views.EvaluationListCreateView.as_view(), name='evaluations-list'),
    #path('evaluations/<int:id>', views.EvaluationDetailView.as_view(), name='evaluation-detail'),
    #path('missions/<int:id>/evaluations', views.MissionEvaluationsView.as_view(), name='mission-evaluations'),
    #path('utilisateurs/<int:id>/evaluations', views.UserEvaluationsView.as_view(), name='user-evaluations'),
    #path('utilisateurs/<int:id>/reputation', views.UserReputationView.as_view(), name='user-reputation'),

    # Signalements
    #path('signalements', views.SignalementListCreateView.as_view(), name='signalements-list'),
    #path('signalements/me', views.MySignalementsView.as_view(), name='my-signalements'),
    #path('admin/signalements', views.AdminSignalementListView.as_view(), name='admin-signalements'),
    #path('admin/signalements/<int:id>/traiter', views.AdminTraiterSignalementView.as_view(), name='traiter-signalement'),
]
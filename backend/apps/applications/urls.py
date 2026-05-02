from django.urls import path
from apps.applications import views

urlpatterns = [
    # Recruiter side
    path('recruteurs/me/candidatures', views.ReceivedApplicationsView.as_view(), name='received-applications'),

    # Candidate side
    path('candidatures/me', views.AppliedJobsView.as_view(), name='applied-jobs'),
    path('candidatures/<int:id>', views.CandidatureDetailView.as_view(), name='candidature-detail'),
    path('candidatures/<int:id>/accepter', views.AccepterCandidatureView.as_view(), name='accepter-candidature'),
    path('candidatures/<int:id>/refuser', views.RefuserCandidatureView.as_view(), name='refuser-candidature'),
]
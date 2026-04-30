from django.urls import path
from apps.jobs import views

urlpatterns = [
    # Offres
    path('offres', views.OffreListCreateView.as_view(), name='offres-list'),
    path('offres/<int:id>', views.OffreDetailView.as_view(), name='offre-detail'),
    path('offres/<int:id>/fermer', views.FermerOffreView.as_view(), name='fermer-offre'),
    path('recruteurs/me/offres', views.MyOffresView.as_view(), name='my-offres'),
    path('offres/<int:id>/candidatures', views.OffreCandidaturesView.as_view(), name='offre-candidatures'),

    # Missions
    path('missions/<int:id>', views.MissionDetailView.as_view(), name='mission-detail'),
    path('missions/<int:id>/valider-debut', views.ValiderDebutView.as_view(), name='valider-debut'),
    path('missions/<int:id>/valider-fin', views.ValiderFinView.as_view(), name='valider-fin'),
    path('missions/<int:id>/attestation', views.AttestationView.as_view(), name='attestation'),

    # Still commented — views not written yet
    #path('missions', views.MissionListCreateView.as_view(), name='missions-list'),
    #path('candidats/me/historique', views.HistoriqueCandidatView.as_view(), name='historique-candidat'),
    #path('candidats/me/saved', views.SavedJobsView.as_view(), name='saved-jobs'),
    #path('candidats/me/alertes', views.AlerteListCreateView.as_view(), name='alertes-list'),
    #path('candidats/me/alertes/<int:id>', views.AlerteDetailView.as_view(), name='alerte-detail'),
]
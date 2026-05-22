from django.urls import path
from apps.jobs import views

urlpatterns = [
    # ── Jobs (formerly Offres) ─────────────────────────────────────────────
    path('jobs', views.OffreListCreateView.as_view(), name='jobs-list'),
    path('jobs/mine', views.MyOffresView.as_view(), name='my-jobs'),
    path('jobs/map', views.MapJobsView.as_view(), name='jobs-map'),
    path('jobs/<int:id>', views.OffreDetailView.as_view(), name='job-detail'),
    path('jobs/<int:id>/close', views.FermerOffreView.as_view(), name='close-job'),
    path('jobs/<int:id>/candidates', views.JobCandidatesView.as_view(), name='job-candidates'),

    # ── Missions ────────────────────────────────────────────────────────────
    path('missions', views.MissionListCreateView.as_view(), name='missions-list'),
    path('missions/<int:id>', views.MissionDetailView.as_view(), name='mission-detail'),
    path('missions/<int:id>/confirm', views.MissionConfirmView.as_view(), name='mission-confirm'),
    path('missions/<int:id>/valider-debut', views.ValiderDebutView.as_view(), name='valider-debut'),
    path('missions/<int:id>/valider-fin', views.ValiderFinView.as_view(), name='valider-fin'),
    path('missions/<int:id>/attestation', views.AttestationView.as_view(), name='attestation'),
    path('missions/<int:id>/review', views.MissionReviewView.as_view(), name='mission-review'),

    # ── Interviews ──────────────────────────────────────────────────────────
    path('interviews', views.InterviewListCreateView.as_view(), name='interviews-list'),
    path('interviews/<int:id>', views.InterviewDetailView.as_view(), name='interview-detail'),
    path('interviews/<int:id>/complete', views.InterviewCompleteView.as_view(), name='interview-complete'),

    # ── Candidat — historique & saved jobs ─────────────────────────────────
    path('candidats/me/historique', views.HistoriqueCandidatView.as_view(), name='historique-candidat'),
    path('candidats/me/saved', views.SavedJobsView.as_view(), name='saved-jobs'),

    # ── Candidat — alertes ─────────────────────────────────────────────────
    path('candidats/me/alertes', views.AlerteListCreateView.as_view(), name='alertes-list'),
    path('candidats/me/alertes/<int:id>', views.AlerteDetailView.as_view(), name='alerte-detail'),

    # Job comments
    path('jobs/<int:id>/comments', views.JobCommentListCreateView.as_view(), name='job-comments'),
    path('jobs/<int:job_id>/comments/<int:comment_id>/reply', views.JobCommentReplyView.as_view(), name='job-comment-reply'),

    # Mission team members
    path('missions/<int:id>/team', views.MissionTeamView.as_view(), name='mission-team'),
    path('missions/<int:id>/team/<int:member_id>', views.MissionTeamMemberDetailView.as_view(), name='mission-team-member'),

    # Job statistics
    path('jobs/<int:id>/statistics', views.JobStatisticsView.as_view(), name='job-statistics'),
]
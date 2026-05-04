"""
apps/notifications/urls.py

URL patterns for the Notifications module.

IMPORTANT — order matters:
  'non-lues/count' and 'lire-tout' are registered BEFORE '<int:id>/lire'
  so Django does not try to match the literal string 'non-lues' as an integer.
"""
from django.urls import path
from apps.notifications import views

urlpatterns = [
    # GET  /notifications/non-lues/count  — unread badge count
    path('notifications/non-lues/count', views.NotifCountView.as_view(), name='notif-count'),

    # POST /notifications/lire-tout       — mark ALL as read
    path('notifications/lire-tout', views.MarquerToutesLuesView.as_view(), name='marquer-toutes-lues'),

    # POST /notifications/<id>/lire       — mark ONE as read
    path('notifications/<int:id>/lire', views.MarquerNotifLueView.as_view(), name='marquer-notif-lue'),

    # GET  /notifications                 — paginated list (with optional filters)
    path('notifications', views.NotificationListView.as_view(), name='notifications-list'),
]
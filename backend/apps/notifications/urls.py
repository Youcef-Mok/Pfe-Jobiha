"""
apps/notifications/urls.py

URL patterns for the Notifications module.

IMPORTANT — order matters:
  'non-lues/count' and 'read-all' are registered BEFORE '<int:id>/read'
  so Django does not try to match the literal string 'non-lues' as an integer.
"""
from django.urls import path
from apps.notifications import views

urlpatterns = [
    # GET  /notifications/non-lues/count  — unread badge count
    path('notifications/non-lues/count', views.NotifCountView.as_view(), name='notif-count'),

    # PUT  /notifications/read-all        — mark ALL as read
    path('notifications/read-all', views.NotificationReadAllView.as_view(), name='mark-all-read'),

    # PUT  /notifications/<id>/read       — mark ONE as read
    path('notifications/<int:id>/read', views.NotificationReadView.as_view(), name='mark-notif-read'),

    # DELETE /notifications/<id>          — delete a notification
    path('notifications/<int:id>', views.NotificationDeleteView.as_view(), name='notification-delete'),

    # GET  /notifications                 — paginated list (with optional filters)
    path('notifications', views.NotificationListView.as_view(), name='notifications-list'),

    # POST /notifications/push/token      — register FCM/APNs push token
    path('notifications/push/token', views.PushTokenView.as_view(), name='push-token'),
]
from django.urls import path
from apps.notifications import views

urlpatterns = [

    #path('notifications/non-lues/count', views.NotifCountView.as_view(), name='notif-count'),
    #path('notifications/lire-tout', views.MarquerToutesLuesView.as_view(), name='marquer-toutes-lues'),
    #path('notifications/<int:id>/lire', views.MarquerNotifLueView.as_view(), name='marquer-notif-lue'),
    #path('notifications', views.NotificationListView.as_view(), name='notifications-list'),
  
  # important :  Order matters here. non-lues/count and lire-tout must come before <int:id>/lire, otherwise Django will try to match non-lues as an integer and fail.
]
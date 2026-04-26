from django.urls import path
from apps.messaging import views

urlpatterns = [
    #path('messages/conversations', views.ConversationListView.as_view(), name='conversations-list'),
    #path('messages/conversations/<int:user_id>', views.ConversationDetailView.as_view(), name='conversation-detail'),
    #path('messages/conversations/<int:user_id>/lire-tout', views.MarquerConvLueView.as_view(), name='marquer-conv-lue'),
    #path('messages', views.SendMessageView.as_view(), name='send-message'),
    #path('messages/<int:id>/lire', views.MarquerMessageLuView.as_view(), name='marquer-message-lu'),
]
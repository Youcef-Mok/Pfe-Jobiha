from django.urls import path
from apps.messaging import views

urlpatterns = [
    # Inbox
    path('messages/conversations', views.ConversationListView.as_view(), name='conversations-list'),
    path('messages/conversations/<int:conv_id>', views.ConversationDetailView.as_view(), name='conversation-detail'),
    path('messages/conversations/<int:conv_id>/lire-tout', views.MarquerConvLueView.as_view(), name='marquer-conv-lue'),

    # Send message
    path('messages', views.SendMessageView.as_view(), name='send-message'),

    # DM shortcut
    path('messages/dm/<int:user_id>', views.GetOrCreateDMView.as_view(), name='get-or-create-dm'),

    # Group management
    path('messages/groups', views.CreateGroupView.as_view(), name='create-group'),
    path('messages/groups/<int:id>/members', views.GroupMembersView.as_view(), name='group-members'),
    path('messages/groups/<int:id>/members/add', views.AddMemberView.as_view(), name='add-member'),
    path('messages/groups/<int:id>/members/<int:user_id>', views.RemoveMemberView.as_view(), name='remove-member'),
]
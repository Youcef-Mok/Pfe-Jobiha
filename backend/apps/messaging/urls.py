from django.urls import path
from apps.messaging import views

urlpatterns = [
    # ── Inbox ──────────────────────────────────────────────────────────────
    path('conversations', views.ConversationListView.as_view(), name='conversations-list'),
    path('conversations/invitations', views.ConversationInvitationsView.as_view(), name='conversation-invitations'),
    path('conversations/group', views.CreateGroupConversationView.as_view(), name='create-group'),

    # ── Conversation detail ────────────────────────────────────────────────
    path('conversations/<int:conv_id>', views.ConversationDetailView.as_view(), name='conversation-detail'),
    path('conversations/<int:conv_id>/read-all', views.MarquerConvLueView.as_view(), name='conversation-read-all'),

    # ── Messages in a conversation ─────────────────────────────────────────
    path('conversations/<int:id>/messages', views.ConvSendMessageView.as_view(), name='send-message'),
    path('conversations/<int:id>/messages/image', views.SendImageMessageView.as_view(), name='send-image-message'),

    # ── Invitation accept/decline ──────────────────────────────────────────
    path('conversations/<int:id>/accept', views.AcceptInvitationView.as_view(), name='conversation-accept'),
    path('conversations/<int:id>/decline', views.DeclineInvitationView.as_view(), name='conversation-decline'),

    # ── Block/Unblock ──────────────────────────────────────────────────────
    path('conversations/<int:id>/block', views.BlockContactView.as_view(), name='conversation-block'),

    # ── DM shortcut ────────────────────────────────────────────────────────
    path('conversations/dm/<int:user_id>', views.GetOrCreateDMView.as_view(), name='get-or-create-dm'),

    # ── Group management ───────────────────────────────────────────────────
    path('conversations/<int:id>/members', views.GroupMembersView.as_view(), name='group-members'),
]
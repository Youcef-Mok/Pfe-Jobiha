"""
apps/messaging/serializers.py
Serializers for the Messagerie module (unified conversations).
"""
from rest_framework import serializers
from apps.messaging.models.message import Message
from apps.messaging.models.conversation import (
    Conversation, ConversationMember, ReadCursor,
)


# ---------------------------------------------------------------------------
# Message
# ---------------------------------------------------------------------------

class MessageRequestSerializer(serializers.Serializer):
    """Write serializer for sending a message. POST /messages"""
    conversation_id = serializers.IntegerField(help_text="ID of the target conversation")
    contenu = serializers.CharField()


class UserBriefSerializer(serializers.Serializer):
    """Lightweight user sub-object."""
    id = serializers.IntegerField()
    nom = serializers.CharField()
    prenom = serializers.CharField()


class MessageSerializer(serializers.ModelSerializer):
    """
    Read serializer — Flutter MessageModel.fromJson expects:
      id (String), sender_id (String), content (String),
      timestamp (DateTime), is_read (bool), is_mine (bool), type (String)

    Pass request via context for is_mine / is_read.
    Pass cursor_id (int|None) via context for efficient read-status checks.
    """
    id = serializers.SerializerMethodField()
    sender_id = serializers.SerializerMethodField()
    content = serializers.CharField(source='contenu', read_only=True)
    timestamp = serializers.DateTimeField(source='date_envoi', read_only=True)
    is_read = serializers.SerializerMethodField()
    is_mine = serializers.SerializerMethodField()
    type = serializers.SerializerMethodField()

    class Meta:
        model = Message
        fields = ['id', 'sender_id', 'content', 'timestamp', 'is_read', 'is_mine', 'type']

    def get_id(self, obj):
        return str(obj.id)

    def get_sender_id(self, obj):
        return str(obj.expediteur_id)

    def get_is_mine(self, obj):
        request = self.context.get('request')
        if not request:
            return False
        return obj.expediteur_id == request.user.pk

    def get_is_read(self, obj):
        request = self.context.get('request')
        if not request:
            return True
        # Own messages are always "sent"
        if obj.expediteur_id == request.user.pk:
            return True
        # For incoming messages, check ReadCursor
        cursor_id = self.context.get('cursor_id')
        if cursor_id is None:
            return False
        return obj.id <= cursor_id

    def get_type(self, obj):
        # No type field on model yet — default to 'text'
        return getattr(obj, 'type', None) or 'text'


class PaginatedMessagesSerializer(serializers.Serializer):
    """Maps to PaginatedMessages schema."""
    count    = serializers.IntegerField()
    next     = serializers.URLField(allow_null=True)
    previous = serializers.URLField(allow_null=True)
    results  = MessageSerializer(many=True)


# ---------------------------------------------------------------------------
# Conversation list item — built from the services.get_conversation_list() dict
# ---------------------------------------------------------------------------

class ConversationListItemSerializer(serializers.Serializer):
    """
    Serializes dicts returned by services.get_conversation_list() into the
    Flutter ConversationModel shape.

    Expected dict keys:
      conversation  (Conversation)
      interlocuteur (Utilisateur|None)
      members       (QuerySet[ConversationMember]|None)
      dernier_message (Message)
      nb_non_lus    (int)
      is_invitation (bool)   — injected by the view
    """
    id = serializers.SerializerMethodField()
    contact_name = serializers.SerializerMethodField()
    contact_role = serializers.SerializerMethodField()
    contact_avatar = serializers.SerializerMethodField()
    is_online = serializers.SerializerMethodField()
    last_message = serializers.SerializerMethodField()
    last_message_time = serializers.SerializerMethodField()
    is_unread = serializers.SerializerMethodField()
    is_invitation = serializers.SerializerMethodField()
    messages = serializers.SerializerMethodField()
    is_group = serializers.SerializerMethodField()
    group_name = serializers.SerializerMethodField()
    member_avatars = serializers.SerializerMethodField()
    member_names = serializers.SerializerMethodField()

    def get_id(self, obj):
        return str(obj['conversation'].id)

    def get_contact_name(self, obj):
        conv = obj['conversation']
        if conv.type == Conversation.TYPE_GROUP:
            return conv.nom or f'Group #{conv.pk}'
        partner = obj.get('interlocuteur')
        if partner:
            return f"{partner.prenom} {partner.nom}"
        return f"Conversation #{conv.pk}"

    def get_contact_role(self, obj):
        conv = obj['conversation']
        if conv.type == Conversation.TYPE_GROUP:
            return 'group'
        partner = obj.get('interlocuteur')
        return getattr(partner, 'role', None) if partner else None

    def get_contact_avatar(self, obj):
        return None

    def get_is_online(self, obj):
        return False

    def get_last_message(self, obj):
        msg = obj.get('dernier_message')
        return msg.contenu if msg else ''

    def get_last_message_time(self, obj):
        msg = obj.get('dernier_message')
        if msg:
            return msg.date_envoi.isoformat()
        return None

    def get_is_unread(self, obj):
        return obj.get('nb_non_lus', 0) > 0

    def get_is_invitation(self, obj):
        return obj.get('is_invitation', False)

    def get_messages(self, obj):
        return []

    def get_is_group(self, obj):
        return obj['conversation'].type == Conversation.TYPE_GROUP

    def get_group_name(self, obj):
        conv = obj['conversation']
        if conv.type == Conversation.TYPE_GROUP:
            return conv.nom
        return None

    def get_member_avatars(self, obj):
        members = obj.get('members')
        if not members:
            return []
        return [None for _ in members]

    def get_member_names(self, obj):
        members = obj.get('members')
        if not members:
            return []
        return [f"{m.user.prenom} {m.user.nom}" for m in members]


# Keep as alias used by ConversationListView / ConversationInvitationsView
ConversationSummarySerializer = ConversationListItemSerializer


# ---------------------------------------------------------------------------
# Conversation detail — single Conversation model instance
# ---------------------------------------------------------------------------

class ConversationSerializer(serializers.ModelSerializer):
    """
    Read serializer for a single Conversation.
    Returns Flutter ConversationModel shape.
    Requires context["request"] to identify the requesting user.
    """
    id = serializers.SerializerMethodField()
    contact_name = serializers.SerializerMethodField()
    contact_role = serializers.SerializerMethodField()
    contact_avatar = serializers.SerializerMethodField()
    is_online = serializers.SerializerMethodField()
    last_message = serializers.SerializerMethodField()
    last_message_time = serializers.SerializerMethodField()
    is_unread = serializers.SerializerMethodField()
    is_invitation = serializers.SerializerMethodField()
    messages = serializers.SerializerMethodField()
    is_group = serializers.SerializerMethodField()
    group_name = serializers.SerializerMethodField()
    member_avatars = serializers.SerializerMethodField()
    member_names = serializers.SerializerMethodField()

    class Meta:
        model = Conversation
        fields = [
            'id', 'contact_name', 'contact_role', 'contact_avatar',
            'is_online', 'last_message', 'last_message_time',
            'is_unread', 'is_invitation', 'messages',
            'is_group', 'group_name', 'member_avatars', 'member_names',
        ]

    def _other_member(self, obj):
        request = self.context.get('request')
        if not request:
            return None
        return (
            obj.memberships
            .select_related('user')
            .filter(left_at__isnull=True)
            .exclude(user_id=request.user.id)
            .first()
        )

    def _latest_message(self, obj):
        return obj.messages.order_by('-date_envoi').first()

    def get_id(self, obj):
        return str(obj.id)

    def get_contact_name(self, obj):
        if obj.type == Conversation.TYPE_GROUP:
            return obj.nom or f'Group #{obj.pk}'
        m = self._other_member(obj)
        return f"{m.user.prenom} {m.user.nom}" if m else f"Conversation #{obj.pk}"

    def get_contact_role(self, obj):
        if obj.type == Conversation.TYPE_GROUP:
            return 'group'
        m = self._other_member(obj)
        return getattr(m.user, 'role', None) if m else None

    def get_contact_avatar(self, obj):
        return None

    def get_is_online(self, obj):
        return False

    def get_last_message(self, obj):
        msg = self._latest_message(obj)
        return msg.contenu if msg else ''

    def get_last_message_time(self, obj):
        msg = self._latest_message(obj)
        return msg.date_envoi.isoformat() if msg else None

    def get_is_unread(self, obj):
        request = self.context.get('request')
        if not request:
            return False
        latest = self._latest_message(obj)
        if not latest:
            return False
        cursor = ReadCursor.objects.filter(conversation=obj, user=request.user).first()
        if not cursor or not cursor.last_read_message_id:
            return True
        return cursor.last_read_message_id < latest.id

    def get_is_invitation(self, obj):
        request = self.context.get('request')
        if not request:
            return False
        membership = obj.memberships.filter(user=request.user).first()
        return membership.is_invitation if membership else False

    def get_messages(self, obj):
        return []

    def get_is_group(self, obj):
        return obj.type == Conversation.TYPE_GROUP

    def get_group_name(self, obj):
        return obj.nom if obj.type == Conversation.TYPE_GROUP else None

    def get_member_avatars(self, obj):
        if obj.type != Conversation.TYPE_GROUP:
            return []
        return [None for _ in obj.memberships.filter(left_at__isnull=True)]

    def get_member_names(self, obj):
        if obj.type != Conversation.TYPE_GROUP:
            return []
        return [
            f"{m.user.prenom} {m.user.nom}"
            for m in obj.memberships.filter(left_at__isnull=True).select_related('user')
        ]


# ---------------------------------------------------------------------------
# Group management
# ---------------------------------------------------------------------------

class CreateGroupSerializer(serializers.Serializer):
    nom        = serializers.CharField(max_length=100)
    member_ids = serializers.ListField(child=serializers.IntegerField(), min_length=1)


class ConversationDetailSerializer(serializers.ModelSerializer):
    """Used by group create/DM create responses (admin-level detail)."""
    members = serializers.SerializerMethodField()

    class Meta:
        model = Conversation
        fields = ['id', 'type', 'nom', 'created_at', 'members']

    def get_members(self, obj):
        active = obj.memberships.filter(left_at__isnull=True).select_related('user')
        return [
            {'id': m.user.id, 'nom': m.user.nom, 'prenom': m.user.prenom, 'role': m.role}
            for m in active
        ]

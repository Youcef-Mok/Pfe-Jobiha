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
    """Read serializer — used everywhere messages are returned."""
    expediteur = serializers.SerializerMethodField()
    conversation_id = serializers.IntegerField(source='conversation.id', read_only=True)

    class Meta:
        model = Message
        fields = ['id', 'contenu', 'date_envoi', 'conversation_id', 'expediteur']

    @staticmethod
    def _user_brief(user):
        return {'id': user.id, 'nom': user.nom, 'prenom': user.prenom}

    def get_expediteur(self, obj):
        return self._user_brief(obj.expediteur)


class PaginatedMessagesSerializer(serializers.Serializer):
    """Maps to PaginatedMessages schema."""
    count    = serializers.IntegerField()
    next     = serializers.URLField(allow_null=True)
    previous = serializers.URLField(allow_null=True)
    results  = MessageSerializer(many=True)


# ---------------------------------------------------------------------------
# Conversation — API-spec shape
# ---------------------------------------------------------------------------

class ConversationSerializer(serializers.ModelSerializer):
    """
    Read serializer for the conversation list.
    Returns the API-spec shape with contact_* derived from the OTHER member.
    Requires context["request"] to identify the requesting user.
    """
    contact_name = serializers.SerializerMethodField()
    contact_role = serializers.SerializerMethodField()
    contact_avatar = serializers.SerializerMethodField()
    is_online = serializers.SerializerMethodField()
    last_message = serializers.SerializerMethodField()
    last_message_time = serializers.SerializerMethodField()
    is_unread = serializers.SerializerMethodField()
    is_invitation = serializers.SerializerMethodField()
    messages = MessageSerializer(many=True, read_only=True, source='messages.none')

    class Meta:
        model = Conversation
        fields = [
            'id', 'contact_name', 'contact_role', 'contact_avatar',
            'is_online', 'last_message', 'last_message_time',
            'is_unread', 'is_invitation', 'messages',
        ]

    def _get_other_member(self, obj):
        request = self.context.get('request')
        if not request:
            return None
        memberships = obj.memberships.select_related('user').filter(left_at__isnull=True)
        for m in memberships:
            if m.user_id != request.user.id:
                return m
        return None

    def _get_latest_message(self, obj):
        return obj.messages.order_by('-date_envoi').first()

    def get_contact_name(self, obj):
        m = self._get_other_member(obj)
        if m:
            return f"{m.user.prenom} {m.user.nom}"
        return obj.nom or f"Conversation #{obj.pk}"

    def get_contact_role(self, obj):
        m = self._get_other_member(obj)
        return getattr(m.user, 'role', None) if m else None

    def get_contact_avatar(self, obj):
        return None

    def get_is_online(self, obj):
        return False

    def get_last_message(self, obj):
        msg = self._get_latest_message(obj)
        return msg.contenu if msg else None

    def get_last_message_time(self, obj):
        msg = self._get_latest_message(obj)
        return msg.date_envoi if msg else None

    def get_is_unread(self, obj):
        request = self.context.get('request')
        if not request:
            return False
        latest_msg = self._get_latest_message(obj)
        if not latest_msg:
            return False
        cursor = ReadCursor.objects.filter(conversation=obj, user=request.user).first()
        if not cursor or not cursor.last_read_message:
            return True
        return cursor.last_read_message_id < latest_msg.id

    def get_is_invitation(self, obj):
        request = self.context.get('request')
        if not request:
            return False
        membership = obj.memberships.filter(user=request.user).first()
        return membership.is_invitation if membership else False


# ---------------------------------------------------------------------------
# Legacy conversation summary (kept for backward-compat)
# ---------------------------------------------------------------------------

class MemberBriefSerializer(serializers.Serializer):
    id     = serializers.IntegerField(source='user.id')
    nom    = serializers.CharField(source='user.nom')
    prenom = serializers.CharField(source='user.prenom')
    role   = serializers.CharField()


class ConversationSummarySerializer(serializers.Serializer):
    conversation_id = serializers.IntegerField(source='conversation.id')
    type            = serializers.CharField(source='conversation.type')
    nom             = serializers.CharField(source='conversation.nom', allow_null=True)
    interlocuteur   = serializers.SerializerMethodField()
    members         = serializers.SerializerMethodField()
    dernier_message = MessageSerializer()
    nb_non_lus      = serializers.IntegerField()

    def get_interlocuteur(self, obj):
        partner = obj.get('interlocuteur')
        if partner is None:
            return None
        return {
            'id': partner.id, 'nom': partner.nom,
            'prenom': partner.prenom, 'role': getattr(partner, 'role', None),
        }

    def get_members(self, obj):
        members = obj.get('members')
        if members is None:
            return None
        return [
            {'id': m.user.id, 'nom': m.user.nom, 'prenom': m.user.prenom, 'role': m.role}
            for m in members
        ]


# ---------------------------------------------------------------------------
# Group management
# ---------------------------------------------------------------------------

class CreateGroupSerializer(serializers.Serializer):
    nom        = serializers.CharField(max_length=100)
    member_ids = serializers.ListField(child=serializers.IntegerField(), min_length=1)


class ConversationDetailSerializer(serializers.ModelSerializer):
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
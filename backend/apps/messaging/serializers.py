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
    is_mine = serializers.SerializerMethodField()
    is_read = serializers.SerializerMethodField()

    class Meta:
        model = Message
        fields = ['id', 'contenu', 'date_envoi', 'conversation_id', 'expediteur', 'is_mine', 'is_read']

    @staticmethod
    def _user_brief(user):
        return {'id': user.id, 'nom': user.nom, 'prenom': user.prenom}

    def get_expediteur(self, obj):
        return self._user_brief(obj.expediteur)

    def get_is_mine(self, obj):
        request = self.context.get('request')
        if not request or not hasattr(request, 'user'):
            return False
        return obj.expediteur_id == request.user.id

    def get_is_read(self, obj):
        """
        Compute read status using ReadCursor.
        A message is read if the requesting user's ReadCursor.last_read_message_id >= message.id
        Only compute for messages NOT sent by requesting user (sender always sees their own as sent).
        """
        request = self.context.get('request')
        if not request or not hasattr(request, 'user'):
            return False
        
        # Sender's own messages are always considered "sent" (not read by receiver)
        if obj.expediteur_id == request.user.id:
            # Check if the OTHER user has read this message
            cursor = ReadCursor.objects.filter(
                conversation=obj.conversation
            ).exclude(user=request.user).first()
            
            if not cursor or not cursor.last_read_message:
                return False
            return cursor.last_read_message_id >= obj.id
        
        # For received messages, check if current user has read it
        cursor = ReadCursor.objects.filter(
            conversation=obj.conversation,
            user=request.user
        ).first()
        
        if not cursor or not cursor.last_read_message:
            return False
        return cursor.last_read_message_id >= obj.id


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
    is_group = serializers.SerializerMethodField()
    group_name = serializers.SerializerMethodField()
    member_avatars = serializers.SerializerMethodField()
    member_names = serializers.SerializerMethodField()
    messages = MessageSerializer(many=True, read_only=True, source='messages.none')

    class Meta:
        model = Conversation
        fields = [
            'id', 'contact_name', 'contact_role', 'contact_avatar',
            'is_online', 'last_message', 'last_message_time',
            'is_unread', 'is_invitation', 'is_group', 'group_name',
            'member_avatars', 'member_names', 'messages',
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

    def get_is_group(self, obj):
        return obj.type == Conversation.TYPE_GROUP

    def get_group_name(self, obj):
        if obj.type == Conversation.TYPE_GROUP:
            return obj.nom
        return None

    def get_member_avatars(self, obj):
        if obj.type == Conversation.TYPE_GROUP:
            members = obj.memberships.select_related('user').filter(left_at__isnull=True)
            # Return avatar URLs for all members (placeholder for now)
            return [getattr(m.user, 'avatar_url', None) or '' for m in members]
        return []

    def get_member_names(self, obj):
        if obj.type == Conversation.TYPE_GROUP:
            members = obj.memberships.select_related('user').filter(left_at__isnull=True)
            return [f"{m.user.prenom} {m.user.nom}" for m in members]
        return []


# ---------------------------------------------------------------------------
# Legacy conversation summary (kept for backward-compat)
# ---------------------------------------------------------------------------

class MemberBriefSerializer(serializers.Serializer):
    id     = serializers.IntegerField(source='user.id')
    nom    = serializers.CharField(source='user.nom')
    prenom = serializers.CharField(source='user.prenom')
    role   = serializers.CharField()


class ConversationSummarySerializer(serializers.Serializer):
    id                = serializers.IntegerField(source='conversation.id')
    contact_name      = serializers.SerializerMethodField()
    contact_role      = serializers.SerializerMethodField()
    contact_avatar    = serializers.SerializerMethodField()
    is_online         = serializers.SerializerMethodField()
    last_message      = serializers.SerializerMethodField()
    last_message_time = serializers.SerializerMethodField()
    is_unread         = serializers.SerializerMethodField()
    is_invitation     = serializers.SerializerMethodField()
    is_group          = serializers.SerializerMethodField()
    group_name        = serializers.SerializerMethodField()
    member_avatars    = serializers.SerializerMethodField()
    member_names      = serializers.SerializerMethodField()

    def get_contact_name(self, obj):
        partner = obj.get('interlocuteur')
        if partner is None:
            return None
        return f"{partner.prenom} {partner.nom}"

    def get_contact_role(self, obj):
        partner = obj.get('interlocuteur')
        if partner is None:
            return None
        return getattr(partner, 'role', None)

    def get_contact_avatar(self, obj):
        partner = obj.get('interlocuteur')
        if partner is None:
            return None
        return getattr(partner, 'avatar_url', None)

    def get_is_online(self, obj):
        return False

    def get_last_message(self, obj):
        msg = obj.get('dernier_message')
        if msg is None:
            return None
        return msg.contenu

    def get_last_message_time(self, obj):
        msg = obj.get('dernier_message')
        if msg is None:
            return None
        return msg.date_envoi.isoformat() if hasattr(msg.date_envoi, 'isoformat') else str(msg.date_envoi)

    def get_is_unread(self, obj):
        return obj.get('nb_non_lus', 0) > 0

    def get_is_invitation(self, obj):
        return False

    def get_is_group(self, obj):
        return False

    def get_group_name(self, obj):
        return None

    def get_member_avatars(self, obj):
        return []

    def get_member_names(self, obj):
        return []


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
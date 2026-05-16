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
    """
    Write serializer for sending a message.
    POST /messages
    """
    conversation_id = serializers.IntegerField(
        help_text="ID of the target conversation"
    )
    contenu = serializers.CharField()


class UserBriefSerializer(serializers.Serializer):
    """Lightweight user sub-object."""
    id = serializers.IntegerField()
    nom = serializers.CharField()
    prenom = serializers.CharField()


class MessageSerializer(serializers.ModelSerializer):
    """
    Read serializer — used everywhere messages are returned.
    """
    expediteur = serializers.SerializerMethodField()
    conversation_id = serializers.IntegerField(source='conversation.id', read_only=True)

    class Meta:
        model = Message
        fields = [
            'id', 'contenu', 'date_envoi',
            'conversation_id', 'expediteur',
        ]

    @staticmethod
    def _user_brief(user):
        return {
            'id':     user.id,
            'nom':    user.nom,
            'prenom': user.prenom,
        }

    def get_expediteur(self, obj):
        return self._user_brief(obj.expediteur)


class PaginatedMessagesSerializer(serializers.Serializer):
    """
    Maps to PaginatedMessages schema.
    GET /messages/conversations/{conversationId}
    """
    count    = serializers.IntegerField()
    next     = serializers.URLField(allow_null=True)
    previous = serializers.URLField(allow_null=True)
    results  = MessageSerializer(many=True)


# ---------------------------------------------------------------------------
# Conversation
# ---------------------------------------------------------------------------

class MemberBriefSerializer(serializers.Serializer):
    """Member info in conversation summaries."""
    id     = serializers.IntegerField(source='user.id')
    nom    = serializers.CharField(source='user.nom')
    prenom = serializers.CharField(source='user.prenom')
    role   = serializers.CharField()


class ConversationSummarySerializer(serializers.Serializer):
    """
    Read serializer for inbox list.
    Each entry contains the conversation, last message, and unread count.
    For DMs, an 'interlocuteur' field is populated.
    For groups, 'nom' and 'members' are populated.
    """
    conversation_id = serializers.IntegerField(source='conversation.id')
    type            = serializers.CharField(source='conversation.type')
    nom             = serializers.CharField(source='conversation.nom', allow_null=True)
    interlocuteur   = serializers.SerializerMethodField()
    members         = serializers.SerializerMethodField()
    dernier_message = MessageSerializer()
    nb_non_lus      = serializers.IntegerField()

    def get_interlocuteur(self, obj):
        """For DMs, return the partner's info."""
        partner = obj.get('interlocuteur')
        if partner is None:
            return None
        return {
            'id':     partner.id,
            'nom':    partner.nom,
            'prenom': partner.prenom,
            'role':   getattr(partner, 'role', None),
        }

    def get_members(self, obj):
        """For groups, return a list of active members."""
        members = obj.get('members')
        if members is None:
            return None
        return [
            {
                'id':     m.user.id,
                'nom':    m.user.nom,
                'prenom': m.user.prenom,
                'role':   m.role,
            }
            for m in members
        ]


# ---------------------------------------------------------------------------
# Group management
# ---------------------------------------------------------------------------

class CreateGroupSerializer(serializers.Serializer):
    """POST /messages/groups"""
    nom        = serializers.CharField(max_length=100)
    member_ids = serializers.ListField(
        child=serializers.IntegerField(), min_length=1,
    )


class ConversationDetailSerializer(serializers.ModelSerializer):
    """Full conversation detail with members."""
    members = serializers.SerializerMethodField()

    class Meta:
        model = Conversation
        fields = ['id', 'type', 'nom', 'created_at', 'members']

    def get_members(self, obj):
        active = obj.memberships.filter(left_at__isnull=True).select_related('user')
        return [
            {
                'id':     m.user.id,
                'nom':    m.user.nom,
                'prenom': m.user.prenom,
                'role':   m.role,
            }
            for m in active
        ]
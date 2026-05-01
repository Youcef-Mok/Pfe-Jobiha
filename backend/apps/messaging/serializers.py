"""
apps/messaging/serializers.py
Serializers for the Messagerie module.
All field names and structures match openapi_messagerie.json exactly.
"""
from rest_framework import serializers
from apps.messaging.models.message import Message


# ---------------------------------------------------------------------------
# Message
# ---------------------------------------------------------------------------

class MessageRequestSerializer(serializers.Serializer):
    """
    Write serializer — maps to MessageRequest schema.
    POST /messages
    """
    destinataire_id = serializers.IntegerField(
        help_text="ID of the recipient user"
    )
    contenu = serializers.CharField()


class MessageSerializer(serializers.ModelSerializer):
    """
    Read serializer — maps to MessageResponse schema.
    Used by POST /messages, GET /messages/conversations/{userId},
    POST /messages/{id}/lire, and nested inside ConversationSummarySerializer.
    """
    expediteur   = serializers.SerializerMethodField()
    destinataire = serializers.SerializerMethodField()

    class Meta:
        model  = Message
        fields = [
            'id', 'contenu', 'date_envoi', 'est_lu',
            'expediteur', 'destinataire',
        ]

    def get_expediteur(self, obj):
        return {
            'id':     obj.expediteur.id,
            'nom':    obj.expediteur.nom,
            'prenom': obj.expediteur.prenom,
        }

    def get_destinataire(self, obj):
        return {
            'id':     obj.destinataire.id,
            'nom':    obj.destinataire.nom,
            'prenom': obj.destinataire.prenom,
        }


class PaginatedMessagesSerializer(serializers.Serializer):
    """
    Maps to PaginatedMessages schema (newest messages first).
    GET /messages/conversations/{userId}
    """
    count    = serializers.IntegerField()
    next     = serializers.URLField(allow_null=True)
    previous = serializers.URLField(allow_null=True)
    results  = MessageSerializer(many=True)


# ---------------------------------------------------------------------------
# Conversation
# ---------------------------------------------------------------------------

class ConversationSummarySerializer(serializers.Serializer):
    """
    Read serializer — maps to ConversationSummary schema.
    One entry per unique conversation partner with latest message preview.
    GET /messages/conversations

    The view is expected to pass a list of dicts, each with:
      - 'interlocuteur': a Utilisateur instance
      - 'dernier_message': a Message instance
      - 'nb_non_lus': int
    """
    interlocuteur   = serializers.SerializerMethodField()
    dernier_message = MessageSerializer()
    nb_non_lus      = serializers.IntegerField()

    def get_interlocuteur(self, obj):
        u = obj['interlocuteur']
        return {
            'id':     u.id,
            'nom':    u.nom,
            'prenom': u.prenom,
            'role':   u.role,  # 'candidat' | 'recruteur' via Utilisateur.role property
        }


class PaginatedConversationsSerializer(serializers.Serializer):
    """
    Maps to PaginatedConversations schema.
    GET /messages/conversations
    """
    count    = serializers.IntegerField()
    next     = serializers.URLField(allow_null=True)
    previous = serializers.URLField(allow_null=True)
    results  = ConversationSummarySerializer(many=True)
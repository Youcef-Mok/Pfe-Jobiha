"""
apps/messaging/views.py
REST views for the Messagerie module.

Views are intentionally thin — heavy queryset logic lives in services.py.

Endpoints
---------
GET  /messages/conversations                     → ConversationListView
GET  /messages/conversations/<user_id>           → ConversationDetailView
POST /messages/conversations/<user_id>/lire-tout → MarquerConvLueView
POST /messages                                   → SendMessageView
POST /messages/<id>/lire                         → MarquerMessageLuView
"""

from rest_framework import status
from rest_framework.generics import ListAPIView
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.messaging.models.message import Message
from apps.messaging.serializers import (
    ConversationSummarySerializer,
    MessageSerializer,
    MessageRequestSerializer,
)
from apps.messaging import services
from apps.users.models import Utilisateur
from core.pagination import StandardPagination
from core.permissions import IsMessageParticipant


# ---------------------------------------------------------------------------
# 1.  GET /messages/conversations — inbox (all virtual conversations)
# ---------------------------------------------------------------------------

class ConversationListView(APIView):
    """
    Return every unique conversation for the authenticated user.

    Each entry includes:
      - interlocuteur  (id, nom, prenom, role)
      - dernier_message (full MessageSerializer)
      - nb_non_lus     (unread count from that partner)

    Sorted by most-recent message first.
    """

    def get(self, request):
        conversations = services.get_conversation_list(request.user)
        serializer = ConversationSummarySerializer(conversations, many=True)
        return Response(serializer.data)


# ---------------------------------------------------------------------------
# 2.  GET /messages/conversations/<user_id> — conversation detail
# ---------------------------------------------------------------------------

class ConversationDetailView(ListAPIView):
    """
    Return all messages between the authenticated user and the partner
    identified by ``user_id``.

    Ordered chronologically (oldest → newest).  Paginated via
    ``StandardPagination`` (page_size=20 by default).
    """
    serializer_class = MessageSerializer
    pagination_class = StandardPagination

    def get_queryset(self):
        partner_id = self.kwargs["user_id"]
        return services.get_conversation_messages(self.request.user, partner_id)


# ---------------------------------------------------------------------------
# 3.  POST /messages — send a new message
# ---------------------------------------------------------------------------

class SendMessageView(APIView):
    """
    Send a message to another user.

    Request body (JSON):
      - destinataire_id  (int) — recipient user ID
      - contenu          (str) — message text

    The sender is set automatically from the JWT-authenticated user.
    Returns the created message (MessageSerializer).
    """

    def post(self, request):
        ser = MessageRequestSerializer(data=request.data)
        ser.is_valid(raise_exception=True)

        dest_id = ser.validated_data["destinataire_id"]
        contenu = ser.validated_data["contenu"]

        # Prevent sending to yourself
        if dest_id == request.user.pk:
            return Response(
                {"detail": "Vous ne pouvez pas vous envoyer un message."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Validate recipient exists
        try:
            destinataire = Utilisateur.objects.get(pk=dest_id)
        except Utilisateur.DoesNotExist:
            return Response(
                {"detail": "Destinataire introuvable."},
                status=status.HTTP_404_NOT_FOUND,
            )

        message = Message.objects.create(
            expediteur=request.user,
            destinataire=destinataire,
            contenu=contenu,
        )

        out = MessageSerializer(message)
        return Response(out.data, status=status.HTTP_201_CREATED)


# ---------------------------------------------------------------------------
# 4.  POST /messages/<id>/lire — mark one message as read
# ---------------------------------------------------------------------------

class MarquerMessageLuView(APIView):
    """
    Mark a single message as read.

    Only the **destinataire** of the message can mark it as read.
    Returns the updated message.
    """

    def post(self, request, id):
        try:
            message = (
                Message.objects
                .select_related("expediteur", "destinataire")
                .get(pk=id)
            )
        except Message.DoesNotExist:
            return Response(
                {"detail": "Message introuvable."},
                status=status.HTTP_404_NOT_FOUND,
            )

        # Only the recipient can mark as read
        if message.destinataire.pk != request.user.pk:
            return Response(
                {"detail": "Seul le destinataire peut marquer ce message comme lu."},
                status=status.HTTP_403_FORBIDDEN,
            )

        message.marquer_lu()
        out = MessageSerializer(message)
        return Response(out.data)


# ---------------------------------------------------------------------------
# 5.  POST /messages/conversations/<user_id>/lire-tout — mark conv as read
# ---------------------------------------------------------------------------

class MarquerConvLueView(APIView):
    """
    Mark **all** unread messages in a conversation as read.

    Only messages FROM the partner TO the authenticated user are affected
    (you can't mark your own sent messages as "read").

    Returns the number of messages updated.
    """

    def post(self, request, user_id):
        # Validate partner exists
        if not Utilisateur.objects.filter(pk=user_id).exists():
            return Response(
                {"detail": "Utilisateur introuvable."},
                status=status.HTTP_404_NOT_FOUND,
            )

        updated = services.mark_conversation_read(request.user, user_id)
        return Response({"updated": updated})

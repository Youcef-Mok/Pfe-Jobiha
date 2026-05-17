"""
apps/messaging/views.py
REST views for the Messagerie module (unified conversations).

Endpoints
---------
GET  /messages/conversations                          → ConversationListView
GET  /messages/conversations/<conv_id>                → ConversationDetailView
POST /messages/conversations/<conv_id>/lire-tout      → MarquerConvLueView
POST /messages                                        → SendMessageView
POST /messages/groups                                 → CreateGroupView
GET  /messages/groups/<id>/members                    → GroupMembersView
POST /messages/groups/<id>/members                    → AddMemberView
DELETE /messages/groups/<id>/members/<user_id>         → RemoveMemberView
POST /messages/dm/<user_id>                           → GetOrCreateDMView
"""

from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync
from django.utils import timezone
from rest_framework import status
from rest_framework.generics import ListAPIView
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.messaging.models.message import Message
from apps.messaging.models.conversation import (
    Conversation, ConversationMember, ReadCursor,
)
from apps.messaging.serializers import (
    ConversationSummarySerializer,
    ConversationDetailSerializer,
    MessageSerializer,
    MessageRequestSerializer,
    CreateGroupSerializer,
)
from apps.messaging import services
from apps.users.models import Utilisateur
from core.pagination import StandardPagination


# ---------------------------------------------------------------------------
# 1.  GET /messages/conversations — inbox
# ---------------------------------------------------------------------------

class ConversationListView(APIView):
    """
    Return every conversation the authenticated user belongs to.
    Sorted by most-recent message first.
    """

    def get(self, request):
        conversations = services.get_conversation_list(request.user)
        serializer = ConversationSummarySerializer(conversations, many=True)
        return Response(serializer.data)


# ---------------------------------------------------------------------------
# 2.  GET /messages/conversations/<conv_id> — messages in a conversation
# ---------------------------------------------------------------------------

class ConversationDetailView(ListAPIView):
    """
    Return paginated messages in a conversation.
    Newest-first; the frontend reverses each page.

    The first page includes a ``read_cursors`` dict mapping each
    other member's user-id to the id of the last message they read.
    """
    serializer_class = MessageSerializer
    pagination_class = StandardPagination

    def get_queryset(self):
        conv_id = self.kwargs['conv_id']
        try:
            return services.get_conversation_messages(self.request.user, conv_id)
        except ConversationMember.DoesNotExist:
            return Message.objects.none()

    def list(self, request, *args, **kwargs):
        response = super().list(request, *args, **kwargs)

        # Inject read cursors on the first page only (no ?page= or page=1).
        page = request.query_params.get('page')
        if page is None or page == '1':
            conv_id = self.kwargs['conv_id']
            cursors = (
                ReadCursor.objects
                .filter(conversation_id=conv_id)
                .exclude(user=request.user)
            )
            response.data['read_cursors'] = {
                str(c.user_id): c.last_read_message_id
                for c in cursors
                if c.last_read_message_id is not None
            }

        return response


# ---------------------------------------------------------------------------
# 3.  POST /messages — send a message
# ---------------------------------------------------------------------------

class SendMessageView(APIView):
    """
    Send a message to a conversation.

    Request body:
      - conversation_id (int)
      - contenu         (str)
    """

    def post(self, request):
        ser = MessageRequestSerializer(data=request.data)
        ser.is_valid(raise_exception=True)

        conv_id = ser.validated_data['conversation_id']
        contenu = ser.validated_data['contenu']

        # Verify membership
        if not ConversationMember.objects.filter(
            conversation_id=conv_id,
            user=request.user,
            left_at__isnull=True,
        ).exists():
            return Response(
                {'detail': 'Vous ne faites pas partie de cette conversation.'},
                status=status.HTTP_403_FORBIDDEN,
            )

        message = Message.objects.create(
            conversation_id=conv_id,
            expediteur=request.user,
            contenu=contenu,
        )
        message = Message.objects.select_related(
            'expediteur', 'conversation',
        ).get(pk=message.pk)

        out = MessageSerializer(message)

        # Broadcast via WebSocket
        channel_layer = get_channel_layer()
        if channel_layer:
            async_to_sync(channel_layer.group_send)(
                f'conv_{conv_id}',
                {
                    'type': 'chat.message',
                    'message': out.data,
                    'sender_id': request.user.pk,
                },
            )

        return Response(out.data, status=status.HTTP_201_CREATED)


# ---------------------------------------------------------------------------
# 4.  POST /messages/conversations/<conv_id>/lire-tout — mark as read
# ---------------------------------------------------------------------------

class MarquerConvLueView(APIView):
    """
    Move the user's ReadCursor to the latest message.
    Broadcasts a read_receipt via WebSocket.
    """

    def post(self, request, conv_id):
        if not ConversationMember.objects.filter(
            conversation_id=conv_id,
            user=request.user,
            left_at__isnull=True,
        ).exists():
            return Response(
                {'detail': 'Non membre.'},
                status=status.HTTP_403_FORBIDDEN,
            )

        last_read_id = services.mark_conversation_read(request.user, conv_id)

        if last_read_id:
            channel_layer = get_channel_layer()
            if channel_layer:
                async_to_sync(channel_layer.group_send)(
                    f'conv_{conv_id}',
                    {
                        'type': 'chat.read_receipt',
                        'reader_id': request.user.pk,
                        'last_read_id': last_read_id,
                    },
                )

        return Response({'last_read_id': last_read_id})


# ---------------------------------------------------------------------------
# 5.  POST /messages/dm/<user_id> — get or create a DM conversation
# ---------------------------------------------------------------------------

class GetOrCreateDMView(APIView):
    """
    Return (or create) the direct conversation with the given user.
    """

    def post(self, request, user_id):
        if user_id == request.user.pk:
            return Response(
                {'detail': 'Impossible de créer un DM avec vous-même.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        try:
            partner = Utilisateur.objects.get(pk=user_id)
        except Utilisateur.DoesNotExist:
            return Response(
                {'detail': 'Utilisateur introuvable.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        conv = services.get_or_create_direct_conversation(request.user, partner)
        return Response(ConversationDetailSerializer(conv).data, status=status.HTTP_200_OK)


# ---------------------------------------------------------------------------
# 6.  POST /messages/groups — create group
# ---------------------------------------------------------------------------

class CreateGroupView(APIView):
    """
    Create a new group conversation.

    Request body:
      - nom        (str)
      - member_ids (list[int])

    The creator is automatically added as admin.
    """

    def post(self, request):
        ser = CreateGroupSerializer(data=request.data)
        ser.is_valid(raise_exception=True)

        conv = services.create_group_conversation(
            creator=request.user,
            nom=ser.validated_data['nom'],
            member_ids=ser.validated_data['member_ids'],
        )
        return Response(
            ConversationDetailSerializer(conv).data,
            status=status.HTTP_201_CREATED,
        )


# ---------------------------------------------------------------------------
# 7.  GET /messages/groups/<id>/members — list members
# ---------------------------------------------------------------------------

class GroupMembersView(APIView):
    """List active members of a group."""

    def get(self, request, id):
        if not ConversationMember.objects.filter(
            conversation_id=id, user=request.user, left_at__isnull=True,
        ).exists():
            return Response({'detail': 'Non membre.'}, status=status.HTTP_403_FORBIDDEN)

        members = (
            ConversationMember.objects
            .filter(conversation_id=id, left_at__isnull=True)
            .select_related('user')
        )
        data = [
            {
                'id': m.user.id,
                'nom': m.user.nom,
                'prenom': m.user.prenom,
                'role': m.role,
            }
            for m in members
        ]
        return Response(data)


# ---------------------------------------------------------------------------
# 8.  POST /messages/groups/<id>/members — add member
# ---------------------------------------------------------------------------

class AddMemberView(APIView):
    """Add a user to a group. Only admins can add."""

    def post(self, request, id):
        # Check caller is admin
        try:
            caller = ConversationMember.objects.get(
                conversation_id=id, user=request.user, left_at__isnull=True,
            )
        except ConversationMember.DoesNotExist:
            return Response({'detail': 'Non membre.'}, status=status.HTTP_403_FORBIDDEN)

        if caller.role != ConversationMember.ROLE_ADMIN:
            return Response(
                {'detail': 'Seuls les admins peuvent ajouter des membres.'},
                status=status.HTTP_403_FORBIDDEN,
            )

        user_id = request.data.get('user_id')
        try:
            new_user = Utilisateur.objects.get(pk=user_id)
        except Utilisateur.DoesNotExist:
            return Response({'detail': 'Utilisateur introuvable.'}, status=status.HTTP_404_NOT_FOUND)

        member, created = ConversationMember.objects.get_or_create(
            conversation_id=id, user=new_user,
            defaults={'role': ConversationMember.ROLE_MEMBER},
        )
        if not created and member.left_at:
            member.left_at = None
            member.save(update_fields=['left_at'])

        # Broadcast member update
        channel_layer = get_channel_layer()
        if channel_layer:
            async_to_sync(channel_layer.group_send)(
                f'conv_{id}',
                {
                    'type': 'chat.member_update',
                    'action': 'added',
                    'user_id': new_user.pk,
                    'user_name': f'{new_user.prenom} {new_user.nom}',
                },
            )

        return Response({'detail': 'Membre ajouté.'}, status=status.HTTP_201_CREATED)


# ---------------------------------------------------------------------------
# 9.  DELETE /messages/groups/<id>/members/<user_id> — remove / leave
# ---------------------------------------------------------------------------

class RemoveMemberView(APIView):
    """Remove a member or leave the group."""

    def delete(self, request, id, user_id):
        try:
            caller = ConversationMember.objects.get(
                conversation_id=id, user=request.user, left_at__isnull=True,
            )
        except ConversationMember.DoesNotExist:
            return Response({'detail': 'Non membre.'}, status=status.HTTP_403_FORBIDDEN)

        is_self = (user_id == request.user.pk)
        if not is_self and caller.role != ConversationMember.ROLE_ADMIN:
            return Response(
                {'detail': 'Seuls les admins peuvent retirer des membres.'},
                status=status.HTTP_403_FORBIDDEN,
            )

        try:
            target = ConversationMember.objects.get(
                conversation_id=id, user_id=user_id, left_at__isnull=True,
            )
        except ConversationMember.DoesNotExist:
            return Response({'detail': 'Membre introuvable.'}, status=status.HTTP_404_NOT_FOUND)

        target.left_at = timezone.now()
        target.save(update_fields=['left_at'])

        # Broadcast
        channel_layer = get_channel_layer()
        if channel_layer:
            async_to_sync(channel_layer.group_send)(
                f'conv_{id}',
                {
                    'type': 'chat.member_update',
                    'action': 'removed',
                    'user_id': user_id,
                    'user_name': '',
                },
            )

        return Response({'detail': 'Membre retiré.'}, status=status.HTTP_200_OK)
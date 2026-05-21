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
    ConversationSerializer,
    ConversationSummarySerializer,
    ConversationDetailSerializer,
    MessageSerializer,
    MessageRequestSerializer,
    CreateGroupSerializer,
)
from apps.messaging import services
from apps.users.models import Utilisateur, BlockedUser
from rest_framework.permissions import IsAuthenticated
from rest_framework.parsers import MultiPartParser, FormParser
from core.pagination import StandardPagination


# ---------------------------------------------------------------------------
# 1.  GET /messages/conversations — inbox
# ---------------------------------------------------------------------------

class ConversationListView(APIView):
    """
    GET /conversations — active conversations (not invitations).
    POST /conversations — get or create DM conversation with contact_id.
    Returns the shape the Flutter frontend expects via ConversationSummarySerializer:
      conversation_id, type, nom, interlocuteur, members, dernier_message, nb_non_lus
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        # get_conversation_list already filters by membership, computes nb_non_lus,
        # resolves the interlocuteur/members, and sorts by last message date.
        data = services.get_conversation_list(request.user)
        # Exclude invitation conversations so the inbox only shows accepted ones.
        data = [
            d for d in data
            if not ConversationMember.objects.filter(
                conversation=d['conversation'],
                user=request.user,
                is_invitation=True,
                left_at__isnull=True,
            ).exists()
        ]
        print(f'[ConversationListView] returning {len(data)} conversations')
        serializer = ConversationSummarySerializer(data, many=True, context={'request': request})
        print(f'[ConversationListView] FULL serializer.data:')
        print(serializer.data)
        return Response(serializer.data)

    def post(self, request):
        """Get or create a DM conversation with the given contact_id."""
        contact_id = request.data.get('contact_id')
        if not contact_id:
            return Response({'detail': 'contact_id is required.'}, status=status.HTTP_400_BAD_REQUEST)
        if int(contact_id) == request.user.pk:
            return Response({'detail': 'Cannot create conversation with yourself.'}, status=status.HTTP_400_BAD_REQUEST)
        try:
            partner = Utilisateur.objects.get(pk=contact_id)
        except Utilisateur.DoesNotExist:
            return Response({'detail': 'User not found.'}, status=status.HTTP_404_NOT_FOUND)

        # Find existing DM
        my_convs = set(ConversationMember.objects.filter(
            user=request.user, left_at__isnull=True,
        ).values_list('conversation_id', flat=True))
        partner_convs = set(ConversationMember.objects.filter(
            user=partner, left_at__isnull=True,
        ).values_list('conversation_id', flat=True))
        shared = my_convs & partner_convs
        existing = Conversation.objects.filter(
            id__in=shared, type=Conversation.TYPE_DIRECT
        ).first()

        if existing:
            serializer = ConversationSerializer(existing, context={'request': request})
            return Response(serializer.data, status=status.HTTP_200_OK)

        # Create new DM
        conv = Conversation.objects.create(type=Conversation.TYPE_DIRECT, created_by=request.user)
        ConversationMember.objects.create(
            conversation=conv, user=request.user, role=ConversationMember.ROLE_MEMBER,
        )
        ConversationMember.objects.create(
            conversation=conv, user=partner, role=ConversationMember.ROLE_MEMBER,
            is_invitation=True,
        )
        serializer = ConversationSerializer(conv, context={'request': request})
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    def delete(self, request):
        """Bulk delete conversations - marks user as left."""
        ids = request.data.get('ids', [])
        if not ids:
            return Response({'detail': 'ids is required.'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Convert string IDs to integers
        try:
            int_ids = [int(id_str) for id_str in ids]
        except (ValueError, TypeError):
            return Response({'detail': 'Invalid ID format.'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Mark user as left from these conversations
        ConversationMember.objects.filter(
            conversation_id__in=int_ids, 
            user=request.user, 
            left_at__isnull=True,
        ).update(left_at=timezone.now())
        
        print(f'[ConversationListView] Deleted {len(int_ids)} conversations for user {request.user.id}')
        return Response(status=status.HTTP_204_NO_CONTENT)


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

    def get_serializer_context(self):
        """Pass request to serializer context for is_mine calculation."""
        context = super().get_serializer_context()
        context['request'] = self.request
        return context

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

        print(f'[ConversationDetailView] conv_id={self.kwargs["conv_id"]} response.data:')
        print(response.data)
        print(f"messages retournés: {response.data.get('results', [])}")
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


# ---------------------------------------------------------------------------
# New conversation endpoints
# ---------------------------------------------------------------------------

class ConversationInvitationsView(APIView):
    """GET /conversations/invitations"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        # Use the same service + summary serializer so the Flutter frontend
        # can parse invitations the same way as regular conversations.
        data = services.get_conversation_list(request.user)
        # Keep only invitation memberships.
        data = [
            d for d in data
            if ConversationMember.objects.filter(
                conversation=d['conversation'],
                user=request.user,
                is_invitation=True,
                left_at__isnull=True,
            ).exists()
        ]
        serializer = ConversationSummarySerializer(data, many=True, context={'request': request})
        return Response(serializer.data)


class ConvSendMessageView(APIView):
    """POST /conversations/<id>/messages"""
    permission_classes = [IsAuthenticated]

    def post(self, request, id):
        print(f'[ConvSendMessageView] POST /conversations/{id}/messages')
        print(f'[ConvSendMessageView] request.data: {request.data}')
        print(f'[ConvSendMessageView] request.user: {request.user}')
        
        # Accept 'contenu' (current frontend implementation)
        content = request.data.get('contenu', '')
        if not content:
            print('[ConvSendMessageView] ERROR: contenu is empty')
            return Response({'detail': 'contenu is required.'}, status=status.HTTP_400_BAD_REQUEST)

        if not ConversationMember.objects.filter(
            conversation_id=id, user=request.user, left_at__isnull=True,
        ).exists():
            print('[ConvSendMessageView] ERROR: User is not a member of this conversation')
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        try:
            message = Message.objects.create(
                conversation_id=id, expediteur=request.user, contenu=content,
            )
            message = Message.objects.select_related('expediteur', 'conversation').get(pk=message.pk)
            print(f'[ConvSendMessageView] Message created: id={message.id}, expediteur={message.expediteur_id}')

            out = MessageSerializer(message, context={'request': request})
            print(f'[ConvSendMessageView] Serialized message: {out.data}')
            
            channel_layer = get_channel_layer()
            if channel_layer:
                async_to_sync(channel_layer.group_send)(
                    f'conv_{id}',
                    {'type': 'chat.message', 'message': out.data, 'sender_id': request.user.pk},
                )
            
            print(f'[ConvSendMessageView] SUCCESS: Returning 201')
            return Response(out.data, status=status.HTTP_201_CREATED)
        except Exception as e:
            print(f'[ConvSendMessageView] EXCEPTION: {e}')
            import traceback
            traceback.print_exc()
            return Response({'detail': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class SendImageMessageView(APIView):
    """POST /conversations/<id>/messages/image"""
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def post(self, request, id):
        if not ConversationMember.objects.filter(
            conversation_id=id, user=request.user, left_at__isnull=True,
        ).exists():
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        file = request.FILES.get('file')
        if not file:
            return Response({'detail': 'file is required.'}, status=status.HTTP_400_BAD_REQUEST)

        from django.core.files.storage import default_storage
        from django.conf import settings as django_settings
        path = default_storage.save(f'chat_images/{file.name}', file)
        url = request.build_absolute_uri(django_settings.MEDIA_URL + path)

        message = Message.objects.create(
            conversation_id=id, 
            expediteur=request.user, 
            contenu=url,
            type='image',  # Set the message type
        )
        message = Message.objects.select_related('expediteur', 'conversation').get(pk=message.pk)
        out = MessageSerializer(message, context={'request': request})
        channel_layer = get_channel_layer()
        if channel_layer:
            async_to_sync(channel_layer.group_send)(
                f'conv_{id}',
                {'type': 'chat.message', 'message': out.data, 'sender_id': request.user.pk},
            )
        return Response(out.data, status=status.HTTP_201_CREATED)


class SendFileMessageView(APIView):
    """POST /conversations/<id>/messages/file"""
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def post(self, request, id):
        if not ConversationMember.objects.filter(
            conversation_id=id, user=request.user, left_at__isnull=True,
        ).exists():
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        file = request.FILES.get('file')
        if not file:
            return Response({'detail': 'file is required.'}, status=status.HTTP_400_BAD_REQUEST)

        from django.core.files.storage import default_storage
        from django.conf import settings as django_settings
        path = default_storage.save(f'chat_files/{file.name}', file)
        url = request.build_absolute_uri(django_settings.MEDIA_URL + path)

        message = Message.objects.create(
            conversation_id=id, 
            expediteur=request.user, 
            contenu=url,
            type='file',  # Set the message type
        )
        message = Message.objects.select_related('expediteur', 'conversation').get(pk=message.pk)
        out = MessageSerializer(message, context={'request': request})
        channel_layer = get_channel_layer()
        if channel_layer:
            async_to_sync(channel_layer.group_send)(
                f'conv_{id}',
                {'type': 'chat.message', 'message': out.data, 'sender_id': request.user.pk},
            )
        return Response(out.data, status=status.HTTP_201_CREATED)


class AcceptInvitationView(APIView):
    """PUT /conversations/<id>/accept"""
    permission_classes = [IsAuthenticated]

    def put(self, request, id):
        try:
            membership = ConversationMember.objects.get(
                conversation_id=id, user=request.user, left_at__isnull=True,
            )
        except ConversationMember.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        membership.is_invitation = False
        membership.save(update_fields=['is_invitation'])
        return Response({'detail': 'Invitation accepted.'})


class DeclineInvitationView(APIView):
    """DELETE /conversations/<id>/decline"""
    permission_classes = [IsAuthenticated]

    def delete(self, request, id):
        try:
            membership = ConversationMember.objects.get(
                conversation_id=id, user=request.user, left_at__isnull=True,
            )
        except ConversationMember.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        membership.left_at = timezone.now()
        membership.save(update_fields=['left_at'])
        return Response(status=status.HTTP_204_NO_CONTENT)


class BulkDeleteConversationsView(APIView):
    """DELETE /conversations — body: { ids: [int] }"""
    permission_classes = [IsAuthenticated]

    def delete(self, request):
        ids = request.data.get('ids', [])
        if not ids:
            return Response({'detail': 'ids is required.'}, status=status.HTTP_400_BAD_REQUEST)
        ConversationMember.objects.filter(
            conversation_id__in=ids, user=request.user, left_at__isnull=True,
        ).update(left_at=timezone.now())
        return Response(status=status.HTTP_204_NO_CONTENT)


class BlockContactView(APIView):
    """POST /conversations/<id>/block"""
    permission_classes = [IsAuthenticated]

    def post(self, request, id):
        other = ConversationMember.objects.filter(
            conversation_id=id, left_at__isnull=True,
        ).exclude(user=request.user).first()
        if not other:
            return Response({'detail': 'No other member found.'}, status=status.HTTP_404_NOT_FOUND)
        BlockedUser.objects.get_or_create(bloqueur=request.user, bloque=other.user)
        return Response({'detail': 'Contact blocked.'})


class UnblockContactView(APIView):
    """DELETE /conversations/<id>/block"""
    permission_classes = [IsAuthenticated]

    def delete(self, request, id):
        other = ConversationMember.objects.filter(
            conversation_id=id, left_at__isnull=True,
        ).exclude(user=request.user).first()
        if not other:
            return Response({'detail': 'No other member found.'}, status=status.HTTP_404_NOT_FOUND)
        BlockedUser.objects.filter(bloqueur=request.user, bloque=other.user).delete()
        return Response({'detail': 'Contact unblocked.'})


class GetOrCreateConversationView(APIView):
    """POST /conversations — body: { contact_id }"""
    permission_classes = [IsAuthenticated]

    def post(self, request):
        contact_id = request.data.get('contact_id')
        if not contact_id:
            return Response({'detail': 'contact_id is required.'}, status=status.HTTP_400_BAD_REQUEST)
        if int(contact_id) == request.user.pk:
            return Response({'detail': 'Cannot create conversation with yourself.'}, status=status.HTTP_400_BAD_REQUEST)
        try:
            partner = Utilisateur.objects.get(pk=contact_id)
        except Utilisateur.DoesNotExist:
            return Response({'detail': 'User not found.'}, status=status.HTTP_404_NOT_FOUND)

        # Find existing DM
        my_convs = set(ConversationMember.objects.filter(
            user=request.user, left_at__isnull=True,
        ).values_list('conversation_id', flat=True))
        partner_convs = set(ConversationMember.objects.filter(
            user=partner, left_at__isnull=True,
        ).values_list('conversation_id', flat=True))
        shared = my_convs & partner_convs
        existing = Conversation.objects.filter(
            id__in=shared, type=Conversation.TYPE_DIRECT
        ).first()

        if existing:
            serializer = ConversationSerializer(existing, context={'request': request})
            return Response(serializer.data, status=status.HTTP_200_OK)

        # Create new DM
        conv = Conversation.objects.create(type=Conversation.TYPE_DIRECT, created_by=request.user)
        ConversationMember.objects.create(
            conversation=conv, user=request.user, role=ConversationMember.ROLE_MEMBER,
        )
        ConversationMember.objects.create(
            conversation=conv, user=partner, role=ConversationMember.ROLE_MEMBER,
            is_invitation=True,
        )
        serializer = ConversationSerializer(conv, context={'request': request})
        return Response(serializer.data, status=status.HTTP_201_CREATED)


class CreateGroupConversationView(APIView):
    """POST /conversations/group"""
    permission_classes = [IsAuthenticated]

    def post(self, request):
        group_name = request.data.get('group_name', '')
        member_ids = request.data.get('member_ids', [])
        print(f"[CreateGroup] Received request.data: {request.data}")
        print(f"[CreateGroup] group_name='{group_name}' member_ids={member_ids}")
        if not member_ids:
            return Response({'detail': 'member_ids is required.'}, status=status.HTTP_400_BAD_REQUEST)

        # Create group conversation with TYPE_GROUP
        conv = Conversation.objects.create(
            type=Conversation.TYPE_GROUP, 
            nom=group_name, 
            created_by=request.user,
        )
        
        # Creator is admin
        ConversationMember.objects.create(
            conversation=conv, user=request.user, role=ConversationMember.ROLE_ADMIN,
        )
        
        # Add all selected members (not invitations for group chats)
        for uid in member_ids:
            # Skip if the user is the creator (already added above)
            if uid == request.user.pk:
                continue
            try:
                user = Utilisateur.objects.get(pk=uid)
                ConversationMember.objects.get_or_create(
                    conversation=conv, user=user,
                    defaults={'role': ConversationMember.ROLE_MEMBER, 'is_invitation': False},
                )
            except Utilisateur.DoesNotExist:
                continue

        # Use ConversationSerializer to return the full shape expected by Flutter
        serializer = ConversationSerializer(conv, context={'request': request})
        print(f"[CreateGroup] returning: id={conv.id} type={conv.type} nom={conv.nom}")
        print(f"[CreateGroup] serialized data: {serializer.data}")
        return Response(serializer.data, status=status.HTTP_201_CREATED)


# ---------------------------------------------------------------------------
# Stub for not-yet-implemented endpoints
# ---------------------------------------------------------------------------

class StubView(APIView):
    """Temporary stub — returns 501 for every HTTP method."""

    def handle(self, request, *args, **kwargs):
        return Response({'detail': 'not implemented'}, status=501)

    get = post = put = patch = delete = handle

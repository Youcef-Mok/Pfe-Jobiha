"""
apps/messaging/services.py
Service / helper functions for the messaging module (unified conversations).
"""
from django.db.models import Q

from apps.messaging.models.message import Message
from apps.messaging.models.conversation import (
    Conversation, ConversationMember, ReadCursor,
)
from apps.users.models import Utilisateur


# ---------------------------------------------------------------------------
# 1.  Conversation list — unified inbox (DMs + groups)
# ---------------------------------------------------------------------------

def get_conversation_list(user):
    """
    Return a list of dicts suitable for ``ConversationSummarySerializer``.

    Each dict contains:
      - conversation   : Conversation instance
      - interlocuteur  : Utilisateur instance (DMs only, None for groups)
      - members        : QuerySet of active ConversationMember (groups only)
      - dernier_message: Message instance
      - nb_non_lus     : int
    """
    memberships = (
        ConversationMember.objects
        .filter(user=user, left_at__isnull=True)
        .select_related('conversation')
    )

    results = []
    for membership in memberships:
        conv = membership.conversation

        # Latest message
        dernier = (
            Message.objects
            .filter(conversation=conv)
            .select_related('expediteur')
            .order_by('-date_envoi')
            .first()
        )
        if dernier is None:
            continue

        # Unread count via ReadCursor
        cursor = ReadCursor.objects.filter(
            conversation=conv, user=user,
        ).first()
        if cursor and cursor.last_read_message_id:
            nb_non_lus = (
                Message.objects
                .filter(conversation=conv, id__gt=cursor.last_read_message_id)
                .exclude(expediteur=user)
                .count()
            )
        else:
            nb_non_lus = (
                Message.objects
                .filter(conversation=conv)
                .exclude(expediteur=user)
                .count()
            )

        entry = {
            'conversation': conv,
            'dernier_message': dernier,
            'nb_non_lus': nb_non_lus,
            'interlocuteur': None,
            'members': None,
        }

        if conv.type == Conversation.TYPE_DIRECT:
            # Find the partner
            partner_membership = (
                ConversationMember.objects
                .filter(conversation=conv, left_at__isnull=True)
                .exclude(user=user)
                .select_related('user')
                .first()
            )
            if partner_membership:
                entry['interlocuteur'] = partner_membership.user
        else:
            # Group: include active members
            entry['members'] = (
                ConversationMember.objects
                .filter(conversation=conv, left_at__isnull=True)
                .select_related('user')
            )

        results.append(entry)

    results.sort(key=lambda c: c['dernier_message'].date_envoi, reverse=True)
    return results


# ---------------------------------------------------------------------------
# 2.  Conversation messages
# ---------------------------------------------------------------------------

def get_conversation_messages(user, conversation_id):
    """
    Return a queryset of messages in the conversation, newest-first.
    Raises ConversationMember.DoesNotExist if user is not a member.
    """
    ConversationMember.objects.get(
        conversation_id=conversation_id,
        user=user,
        left_at__isnull=True,
    )
    return (
        Message.objects
        .filter(conversation_id=conversation_id)
        .select_related('expediteur')
        .order_by('-date_envoi')
    )


# ---------------------------------------------------------------------------
# 3.  Mark conversation as read (update ReadCursor)
# ---------------------------------------------------------------------------

def mark_conversation_read(user, conversation_id):
    """
    Move the user's ReadCursor to the latest message.
    Returns the last_read_message_id or None.
    """
    last_msg = (
        Message.objects
        .filter(conversation_id=conversation_id)
        .order_by('-date_envoi')
        .values_list('id', flat=True)
        .first()
    )
    if not last_msg:
        return None

    ReadCursor.objects.update_or_create(
        conversation_id=conversation_id,
        user=user,
        defaults={'last_read_message_id': last_msg},
    )
    return last_msg


# ---------------------------------------------------------------------------
# 4.  Get or create direct conversation
# ---------------------------------------------------------------------------

def get_or_create_direct_conversation(user_a, user_b):
    """
    Find or create the DM conversation between two users.
    Returns the Conversation instance.
    """
    # Find existing direct conversation shared by both users
    common = (
        ConversationMember.objects
        .filter(
            user=user_a,
            left_at__isnull=True,
            conversation__type=Conversation.TYPE_DIRECT,
        )
        .values_list('conversation_id', flat=True)
    )
    partner_match = (
        ConversationMember.objects
        .filter(
            user=user_b,
            left_at__isnull=True,
            conversation_id__in=common,
        )
        .select_related('conversation')
        .first()
    )
    if partner_match:
        return partner_match.conversation

    # Create new DM
    conv = Conversation.objects.create(type=Conversation.TYPE_DIRECT)
    ConversationMember.objects.create(conversation=conv, user=user_a)
    ConversationMember.objects.create(conversation=conv, user=user_b)
    return conv


# ---------------------------------------------------------------------------
# 5.  Create group conversation
# ---------------------------------------------------------------------------

def create_group_conversation(creator, nom, member_ids):
    """
    Create a group conversation. The creator is auto-added as admin.
    Returns the Conversation instance.
    """
    conv = Conversation.objects.create(
        type=Conversation.TYPE_GROUP,
        nom=nom,
        created_by=creator,
    )
    ConversationMember.objects.create(
        conversation=conv, user=creator, role=ConversationMember.ROLE_ADMIN,
    )
    members = Utilisateur.objects.filter(pk__in=member_ids).exclude(pk=creator.pk)
    for member in members:
        ConversationMember.objects.create(conversation=conv, user=member)

    return conv

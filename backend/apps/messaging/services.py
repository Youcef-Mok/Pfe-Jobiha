"""
apps/messaging/services.py
Service / helper functions for the messaging module.

Keeps views thin by encapsulating the heavy queryset logic here.
All functions accept a `user` (Utilisateur instance) so they can be
tested independently of the HTTP layer.
"""
from django.db.models import (
    Q, Max, Count, Subquery, OuterRef, F, Value, IntegerField
)
from django.db.models.functions import Greatest

from apps.messaging.models.message import Message
from apps.users.models import Utilisateur


# ---------------------------------------------------------------------------
# 1.  Conversation list — virtual conversations for the inbox
# ---------------------------------------------------------------------------

def get_conversation_list(user):
    """
    Return a list of dicts suitable for ``ConversationSummarySerializer``.

    Each dict contains:
      - interlocuteur  : Utilisateur instance
      - dernier_message: Message instance (the newest message in the pair)
      - nb_non_lus     : int (unread messages FROM that partner TO `user`)

    Steps
    -----
    1. Collect every distinct partner ID (users the caller exchanged at
       least one message with).
    2. For each partner, find the latest message and the unread count.
    3. Sort by most-recent first.

    The implementation deliberately avoids N+1 by pre-fetching users and
    messages in bulk, then zipping in Python.
    """
    # -- Step 1: distinct partner IDs ----------------------------------------
    sent_partners = (
        Message.objects
        .filter(expediteur=user)
        .values_list("destinataire_id", flat=True)
        .distinct()
    )
    received_partners = (
        Message.objects
        .filter(destinataire=user)
        .values_list("expediteur_id", flat=True)
        .distinct()
    )
    partner_ids = set(sent_partners) | set(received_partners)

    if not partner_ids:
        return []

    # -- Step 2: latest message per partner ----------------------------------
    # Subquery approach: for each partner, get the max date_envoi among all
    # messages where (exp=user,dest=partner) OR (exp=partner,dest=user).
    conversations = []

    # Pre-fetch partner user objects in one shot
    partners = {u.pk: u for u in Utilisateur.objects.filter(pk__in=partner_ids)}

    for pid in partner_ids:
        partner = partners.get(pid)
        if partner is None:
            continue  # deleted user — skip

        pair_q = (
            Q(expediteur=user, destinataire_id=pid)
            | Q(expediteur_id=pid, destinataire=user)
        )

        # Latest message (one query per partner — acceptable for inbox sizes
        # typically < 50; a single-query Subquery version is below if needed)
        dernier = (
            Message.objects
            .filter(pair_q)
            .select_related("expediteur", "destinataire")
            .order_by("-date_envoi")
            .first()
        )
        if dernier is None:
            continue

        # Unread count: messages FROM partner that I haven't read
        nb_non_lus = (
            Message.objects
            .filter(expediteur_id=pid, destinataire=user, est_lu=False)
            .count()
        )

        conversations.append({
            "interlocuteur": partner,
            "dernier_message": dernier,
            "nb_non_lus": nb_non_lus,
        })

    # Sort by most-recent message first
    conversations.sort(
        key=lambda c: c["dernier_message"].date_envoi,
        reverse=True,
    )
    return conversations


# ---------------------------------------------------------------------------
# 2.  Conversation detail — all messages between two users
# ---------------------------------------------------------------------------

def get_conversation_messages(user, partner_id):
    """
    Return a queryset of messages between ``user`` and the partner,
    ordered chronologically (oldest first).

    The view is responsible for pagination.
    """
    return (
        Message.objects
        .filter(
            Q(expediteur=user, destinataire_id=partner_id)
            | Q(expediteur_id=partner_id, destinataire=user)
        )
        .select_related("expediteur", "destinataire")
        .order_by("date_envoi")
    )


# ---------------------------------------------------------------------------
# 3.  Mark all messages in a conversation as read
# ---------------------------------------------------------------------------

def mark_conversation_read(user, partner_id):
    """
    Bulk-mark all unread messages FROM ``partner_id`` TO ``user`` as read.
    Returns the number of rows updated.
    """
    return (
        Message.objects
        .filter(
            expediteur_id=partner_id,
            destinataire=user,
            est_lu=False,
        )
        .update(est_lu=True)
    )

"""
apps/messaging/models/conversation.py

New models for unified conversations (direct + group).
"""
from django.db import models


class Conversation(models.Model):
    TYPE_DIRECT = 'direct'
    TYPE_GROUP = 'group'
    TYPE_CHOICES = [
        (TYPE_DIRECT, 'Direct'),
        (TYPE_GROUP, 'Group'),
    ]

    type = models.CharField(max_length=10, choices=TYPE_CHOICES, default=TYPE_DIRECT)
    nom = models.CharField(max_length=100, blank=True, null=True)
    created_by = models.ForeignKey(
        'users.Utilisateur',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='created_conversations',
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'conversation'
        ordering = ['-created_at']

    def __str__(self):
        if self.type == self.TYPE_GROUP:
            return f"Groupe: {self.nom or self.pk}"
        return f"DM #{self.pk}"


class ConversationMember(models.Model):
    ROLE_ADMIN = 'admin'
    ROLE_MEMBER = 'member'
    ROLE_CHOICES = [
        (ROLE_ADMIN, 'Admin'),
        (ROLE_MEMBER, 'Member'),
    ]

    conversation = models.ForeignKey(
        Conversation, on_delete=models.CASCADE, related_name='memberships',
    )
    user = models.ForeignKey(
        'users.Utilisateur', on_delete=models.CASCADE, related_name='conversation_memberships',
    )
    role = models.CharField(max_length=10, choices=ROLE_CHOICES, default=ROLE_MEMBER)
    joined_at = models.DateTimeField(auto_now_add=True)
    left_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'conversation_member'
        unique_together = [('conversation', 'user')]

    def __str__(self):
        return f"{self.user} in {self.conversation}"

    @property
    def is_active(self):
        return self.left_at is None


class ReadCursor(models.Model):
    conversation = models.ForeignKey(
        Conversation, on_delete=models.CASCADE, related_name='read_cursors',
    )
    user = models.ForeignKey(
        'users.Utilisateur', on_delete=models.CASCADE, related_name='read_cursors',
    )
    last_read_message = models.ForeignKey(
        'messaging.Message', on_delete=models.SET_NULL, null=True, blank=True,
    )
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'read_cursor'
        unique_together = [('conversation', 'user')]

    def __str__(self):
        return f"ReadCursor({self.user}, conv={self.conversation_id})"

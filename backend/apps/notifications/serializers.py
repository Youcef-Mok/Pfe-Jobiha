"""
apps/notifications/serializers.py
Serializers for the Notifications module.
All field names and structures match openapi_messagerie.json exactly.
"""
from rest_framework import serializers
from apps.notifications.models.notification import Notification


# ---------------------------------------------------------------------------
# Notification
# ---------------------------------------------------------------------------

class NotificationSerializer(serializers.ModelSerializer):
    """
    Read serializer — maps to NotificationResponse schema.
    Used by GET /notifications and POST /notifications/{id}/lire.

    'type' values: candidature | mission | message | evaluation | signalement
    """

    class Meta:
        model  = Notification
        fields = ['id', 'contenu', 'type', 'date_envoi', 'est_lue']


class PaginatedNotificationsSerializer(serializers.Serializer):
    """
    Maps to PaginatedNotifications schema.
    GET /notifications
    """
    count    = serializers.IntegerField()
    next     = serializers.URLField(allow_null=True)
    previous = serializers.URLField(allow_null=True)
    results  = NotificationSerializer(many=True)


class UnreadCountSerializer(serializers.Serializer):
    """
    Maps to the inline response schema for
    GET /notifications/non-lues/count
    """
    count = serializers.IntegerField()
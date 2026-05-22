"""
apps/notifications/serializers.py
Serializers for the Notifications module.
All field names and structures match the API spec exactly.
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

    Flutter NotificationsRepositoryApi._fromJson reads:
      id, titre/title, message, type, date_creation (NOT timestamp),
      est_lue/is_read, job_title, sender_name, avatar_url,
      context_image_url, count
    """
    message = serializers.CharField(source='contenu', read_only=True)
    # Flutter reads 'date_creation' — NOT 'timestamp'
    date_creation = serializers.DateTimeField(source='date_envoi', read_only=True)
    is_read = serializers.BooleanField(source='est_lue', read_only=True)
    # Flutter reads 'context_image_url' (nullable)
    context_image_url = serializers.SerializerMethodField()

    class Meta:
        model  = Notification
        fields = [
            'id', 'title', 'message', 'type', 'date_creation', 'is_read',
            'job_title', 'sender_name', 'avatar_url', 'context_image_url', 'count',
        ]

    def get_context_image_url(self, obj):
        return obj.context_image_url


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
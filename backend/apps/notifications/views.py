"""
apps/notifications/views.py
Views for the Notifications module.

Endpoints implemented (notifications only — messaging is in apps.messaging):
    GET  /notifications                    → NotificationListView
    GET  /notifications/non-lues/count    → NotifCountView
    POST /notifications/lire-tout         → MarquerToutesLuesView
    POST /notifications/{id}/lire         → MarquerNotifLueView
"""
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated

from apps.notifications.models import Notification
from apps.notifications.serializers import NotificationSerializer
from core.pagination import StandardPagination


class NotificationListView(APIView):
    """
    GET /notifications
    Returns a paginated list of the authenticated user's notifications.
    Supports optional query filters:
      - est_lue (bool)  : filter by read status
      - type    (str)   : filter by notification type
                          (candidature | mission | message | evaluation | signalement)
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        qs = Notification.objects.filter(
            utilisateur=request.user
        ).order_by('-date_envoi')

        # Optional filter: est_lue
        est_lue = request.query_params.get('est_lue')
        if est_lue is not None:
            # Accept "true"/"false" (case-insensitive) as per OpenAPI boolean
            if est_lue.lower() == 'true':
                qs = qs.filter(est_lue=True)
            elif est_lue.lower() == 'false':
                qs = qs.filter(est_lue=False)

        # Optional filter: type
        notif_type = request.query_params.get('type')
        if notif_type:
            qs = qs.filter(type=notif_type)

        paginator = StandardPagination()
        page = paginator.paginate_queryset(qs, request)
        serializer = NotificationSerializer(page, many=True)
        return paginator.get_paginated_response(serializer.data)


class NotifCountView(APIView):
    """
    GET /notifications/non-lues/count
    Returns the count of unread notifications for the authenticated user.
    Used for badge display in the frontend.
    Response: { "count": <int> }
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        count = Notification.objects.filter(
            utilisateur=request.user,
            est_lue=False
        ).count()
        return Response({'count': count}, status=status.HTTP_200_OK)


class MarquerToutesLuesView(APIView):
    """
    POST /notifications/lire-tout
    Marks all of the authenticated user's notifications as read.
    Returns 204 No Content on success.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request):
        Notification.objects.filter(
            utilisateur=request.user,
            est_lue=False
        ).update(est_lue=True)
        return Response(status=status.HTTP_204_NO_CONTENT)


class MarquerNotifLueView(APIView):
    """
    POST /notifications/{id}/lire
    Marks a single notification as read.
    - 404 if the notification does not exist.
    - 403 if the notification belongs to a different user.
    - 200 with the updated NotificationResponse on success.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request, id):
        try:
            notification = Notification.objects.get(pk=id)
        except Notification.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

        # Enforce ownership — never expose another user's notification
        if notification.utilisateur != request.user:
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        notification.est_lue = True
        notification.save(update_fields=['est_lue'])

        serializer = NotificationSerializer(notification)
        return Response(serializer.data, status=status.HTTP_200_OK)

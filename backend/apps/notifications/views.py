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
      - filter  (str): jobs|messaging|applications — maps to type field
      - est_lue (bool): filter by read status
      - type    (str):  filter by notification type directly
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        qs = Notification.objects.filter(
            utilisateur=request.user
        ).order_by('-date_envoi')

        # New: ?filter= maps friendly names to notification types
        filter_param = request.query_params.get('filter')
        if filter_param:
            filter_map = {
                'jobs': 'mission',
                'messaging': 'message',
                'applications': 'candidature',
            }
            mapped_type = filter_map.get(filter_param, filter_param)
            qs = qs.filter(type=mapped_type)

        # Optional filter: est_lue
        est_lue = request.query_params.get('est_lue')
        if est_lue is not None:
            if est_lue.lower() == 'true':
                qs = qs.filter(est_lue=True)
            elif est_lue.lower() == 'false':
                qs = qs.filter(est_lue=False)

        # Optional filter: type (direct)
        notif_type = request.query_params.get('type')
        if notif_type:
            qs = qs.filter(type=notif_type)

        paginator = StandardPagination()
        page = paginator.paginate_queryset(qs, request)
        serializer = NotificationSerializer(page, many=True)
        return paginator.get_paginated_response(serializer.data)


class NotifCountView(APIView):
    """GET /notifications/non-lues/count"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        count = Notification.objects.filter(
            utilisateur=request.user,
            est_lue=False
        ).count()
        return Response({'count': count}, status=status.HTTP_200_OK)


class NotificationReadView(APIView):
    """PUT /notifications/<id>/read — mark a single notification as read."""
    permission_classes = [IsAuthenticated]

    def put(self, request, id):
        try:
            notification = Notification.objects.get(pk=id)
        except Notification.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

        if notification.utilisateur != request.user:
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        notification.est_lue = True
        notification.save(update_fields=['est_lue'])
        return Response(NotificationSerializer(notification).data)


class NotificationReadAllView(APIView):
    """PUT /notifications/read-all — mark ALL as read."""
    permission_classes = [IsAuthenticated]

    def put(self, request):
        Notification.objects.filter(
            utilisateur=request.user,
            est_lue=False
        ).update(est_lue=True)
        return Response({'detail': 'All notifications marked as read.'})


class NotificationDeleteView(APIView):
    """DELETE /notifications/<id>"""
    permission_classes = [IsAuthenticated]

    def delete(self, request, id):
        try:
            notification = Notification.objects.get(pk=id)
        except Notification.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

        if notification.utilisateur != request.user:
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        notification.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


# Legacy aliases for backward compatibility
class MarquerToutesLuesView(NotificationReadAllView):
    def post(self, request):
        return self.put(request)


class MarquerNotifLueView(NotificationReadView):
    def post(self, request, id):
        return self.put(request, id)


class PushTokenView(APIView):
    """POST /notifications/push/token — register FCM/APNs token"""
    permission_classes = [IsAuthenticated]

    def post(self, request):
        token = request.data.get('token', '').strip()
        if not token:
            return Response({'detail': 'token is required.'}, status=status.HTTP_400_BAD_REQUEST)
        request.user.push_token = token
        request.user.save(update_fields=['push_token'])
        return Response({'detail': 'Token registered.'})


# ===========================================================================
# Stub for not-yet-implemented endpoints
# ===========================================================================

class StubView(APIView):
    """Temporary stub — returns 501 for every HTTP method."""
    permission_classes = [IsAuthenticated]

    def handle(self, request, *args, **kwargs):
        return Response({'detail': 'not implemented'}, status=501)

    get = post = put = patch = delete = handle

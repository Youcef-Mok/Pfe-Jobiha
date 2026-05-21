"""
Views for the Applications module.
"""
from django.utils import timezone
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated

from apps.applications.models import Candidature
from apps.applications.serializers import ApplicationSerializer, CreateCandidatureSerializer
from apps.jobs.models.offre import Offre
from core.pagination import StandardPagination


# ===========================================================================
# /applications  (GET, POST)
# ===========================================================================

class ApplicationsView(APIView):
    """
    GET  /applications → list applications scoped to user role
    Query params: status, applied_within, department
    POST /applications → candidate applies to a job
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if hasattr(request.user, 'recruteur'):
            queryset = Candidature.objects.filter(
                offre__recruteur=request.user.recruteur
            ).select_related(
                'candidat', 'offre__recruteur'
            ).order_by('-date_postulation')
        elif hasattr(request.user, 'candidat'):
            queryset = Candidature.objects.filter(
                candidat=request.user.candidat
            ).select_related(
                'candidat', 'offre__recruteur'
            ).order_by('-date_postulation')
        else:
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        # Filter by status (API values: pending, accepted, rejected)
        status_param = request.query_params.get('status')
        if status_param:
            # Map API status names back to DB values
            api_to_db = {
                'pending': 'en_attente',
                'accepted': 'acceptee',
                'rejected': 'refusee',
                # Also support French UI labels
                'En attente': 'en_attente',
                'Acceptée': 'acceptee',
                'Refusée': 'refusee',
            }
            db_val = api_to_db.get(status_param, status_param)
            queryset = queryset.filter(statut=db_val)

        # Filter by applied_within (today, 3d, 7d, 30d)
        applied_within = request.query_params.get('applied_within')
        if applied_within:
            from datetime import timedelta
            now = timezone.now()
            
            if applied_within == 'today':
                start = now.replace(hour=0, minute=0, second=0, microsecond=0)
                queryset = queryset.filter(date_postulation__gte=start)
            else:
                days_map = {'3d': 3, '7d': 7, '30d': 30}
                days = days_map.get(applied_within)
                if days:
                    cutoff = now - timedelta(days=days)
                    queryset = queryset.filter(date_postulation__gte=cutoff)

        # Filter by department
        department = request.query_params.get('department')
        if department:
            queryset = queryset.filter(offre__categorie=department)

        paginator = StandardPagination()
        page = paginator.paginate_queryset(queryset, request)
        serializer = ApplicationSerializer(page, many=True)
        return paginator.get_paginated_response(serializer.data)

    def post(self, request):
        if not hasattr(request.user, 'candidat'):
            return Response(
                {'detail': 'Only candidates can apply.'},
                status=status.HTTP_403_FORBIDDEN
            )

        job_id = request.data.get('job_id')
        if not job_id:
            return Response(
                {'detail': 'job_id is required.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            offre = Offre.objects.get(pk=job_id)
        except Offre.DoesNotExist:
            return Response({'detail': 'Job not found.'}, status=status.HTTP_404_NOT_FOUND)

        if not offre.is_published:
            return Response(
                {'detail': 'This job is not published.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Prevent duplicate applications
        if Candidature.objects.filter(candidat=request.user.candidat, offre=offre).exists():
            return Response(
                {'detail': 'You have already applied to this offer.'},
                status=status.HTTP_409_CONFLICT
            )

        motivation = request.data.get('motivation_letter', '')
        candidature = Candidature.objects.create(
            candidat=request.user.candidat,
            offre=offre,
            message_personnalise=motivation,
        )
        return Response(
            ApplicationSerializer(candidature).data,
            status=status.HTTP_201_CREATED
        )


# ===========================================================================
# /applications/<id>  (DELETE)
# ===========================================================================

class ApplicationDetailView(APIView):
    """DELETE /applications/<id> → candidate withdraws their application."""
    permission_classes = [IsAuthenticated]

    def delete(self, request, id):
        try:
            candidature = Candidature.objects.select_related('candidat').get(pk=id)
        except Candidature.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

        if not hasattr(request.user, 'candidat') or candidature.candidat != request.user.candidat:
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        candidature.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


# ===========================================================================
# /applications/<id>/accept  (PUT)
# ===========================================================================

class AcceptApplicationView(APIView):
    """PUT /applications/<id>/accept → recruiter accepts an application."""
    permission_classes = [IsAuthenticated]

    def put(self, request, id):
        if not hasattr(request.user, 'recruteur'):
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        try:
            candidature = Candidature.objects.select_related('offre__recruteur', 'candidat').get(pk=id)
        except Candidature.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

        if candidature.offre.recruteur != request.user.recruteur:
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        candidature.statut = 'acceptee'  # Fixed: was 'accepte'
        candidature.save(update_fields=['statut'])
        return Response(ApplicationSerializer(candidature).data)


# ===========================================================================
# /applications/<id>/reject  (PUT)
# ===========================================================================

class RejectApplicationView(APIView):
    """PUT /applications/<id>/reject → recruiter rejects an application."""
    permission_classes = [IsAuthenticated]

    def put(self, request, id):
        if not hasattr(request.user, 'recruteur'):
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        try:
            candidature = Candidature.objects.select_related('offre__recruteur', 'candidat').get(pk=id)
        except Candidature.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

        if candidature.offre.recruteur != request.user.recruteur:
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        candidature.statut = 'refusee'  # Fixed: was 'refuse'
        candidature.save(update_fields=['statut'])
        return Response(ApplicationSerializer(candidature).data)


# ===========================================================================
# /candidates/<id>/status  (PUT)
# ===========================================================================

class UpdateCandidateStatusView(APIView):
    """PUT /candidates/<id>/status → update candidature status."""
    permission_classes = [IsAuthenticated]

    def put(self, request, id):
        new_status = request.data.get('status')
        if new_status not in ('examine', 'archive'):
            return Response(
                {'detail': 'status must be "examine" or "archive".'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            candidature = Candidature.objects.select_related('offre__recruteur').get(pk=id)
        except Candidature.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

        candidature.statut = new_status
        candidature.save(update_fields=['statut'])
        return Response(ApplicationSerializer(candidature).data)


# ===========================================================================
# Legacy views kept for backward-compat URL routing
# ===========================================================================

class AppliedJobsView(ApplicationsView):
    """Legacy alias — GET /candidatures/me."""
    pass


class ReceivedApplicationsView(ApplicationsView):
    """Legacy alias — GET /recruteurs/me/candidatures."""
    pass


class CandidatureDetailView(ApplicationDetailView):
    """Legacy alias — GET /candidatures/{id}."""

    def get(self, request, id):
        try:
            candidature = Candidature.objects.select_related(
                'candidat', 'offre__recruteur'
            ).get(pk=id)
        except Candidature.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

        is_candidat = hasattr(request.user, 'candidat') and candidature.candidat == request.user.candidat
        is_recruteur = hasattr(request.user, 'recruteur') and candidature.offre.recruteur == request.user.recruteur

        if not is_candidat and not is_recruteur:
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        return Response(ApplicationSerializer(candidature).data)


class AccepterCandidatureView(AcceptApplicationView):
    """Legacy alias — POST /candidatures/{id}/accepter."""

    def post(self, request, id):
        return self.put(request, id)


class RefuserCandidatureView(RejectApplicationView):
    """Legacy alias — POST /candidatures/{id}/refuser."""

    def post(self, request, id):
        return self.put(request, id)


# ===========================================================================
# Stub for not-yet-implemented endpoints
# ===========================================================================

class StubView(APIView):
    """Temporary stub — returns 501 for every HTTP method."""
    permission_classes = [IsAuthenticated]

    def handle(self, request, *args, **kwargs):
        return Response({'detail': 'not implemented'}, status=501)

    get = post = put = patch = delete = handle
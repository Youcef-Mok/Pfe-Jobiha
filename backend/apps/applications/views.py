"""
Views for the Applications module.
"""
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated

from apps.applications.models import Candidature
from apps.applications.serializers import CandidatureSerializer
from core.pagination import StandardPagination


class AppliedJobsView(APIView):
    """
    GET /candidatures/me → candidate sees their own applications
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if not hasattr(request.user, 'candidat'):
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        candidatures = Candidature.objects.filter(
            candidat=request.user.candidat
        ).order_by('-date_postulation')

        # Optional filter by statut
        statut = request.query_params.get('statut')
        if statut:
            candidatures = candidatures.filter(statut=statut)

        paginator = StandardPagination()
        page = paginator.paginate_queryset(candidatures, request)
        serializer = CandidatureSerializer(page, many=True)
        return paginator.get_paginated_response(serializer.data)


class ReceivedApplicationsView(APIView):
    """
    GET /recruteurs/me/candidatures → recruiter sees all applications to their jobs
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if not hasattr(request.user, 'recruteur'):
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        candidatures = Candidature.objects.filter(
            offre__recruteur=request.user.recruteur
        ).order_by('-date_postulation')

        # Optional filter by statut
        statut = request.query_params.get('statut')
        if statut:
            candidatures = candidatures.filter(statut=statut)

        paginator = StandardPagination()
        page = paginator.paginate_queryset(candidatures, request)
        serializer = CandidatureSerializer(page, many=True)
        return paginator.get_paginated_response(serializer.data)


class CandidatureDetailView(APIView):
    """
    GET /candidatures/{id} → view one application (owner candidat or recruiter)
    """
    permission_classes = [IsAuthenticated]

    def get(self, request, id):
        try:
            candidature = Candidature.objects.get(pk=id)
        except Candidature.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

        # Only the candidat who applied OR the recruiter who owns the job can see it
        is_candidat = hasattr(request.user, 'candidat') and candidature.candidat == request.user.candidat
        is_recruteur = hasattr(request.user, 'recruteur') and candidature.offre.recruteur == request.user.recruteur

        if not is_candidat and not is_recruteur:
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        return Response(CandidatureSerializer(candidature).data)


class AccepterCandidatureView(APIView):
    """
    POST /candidatures/{id}/accepter → recruiter accepts an application
    """
    permission_classes = [IsAuthenticated]

    def post(self, request, id):
        if not hasattr(request.user, 'recruteur'):
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        try:
            candidature = Candidature.objects.get(pk=id)
        except Candidature.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

        # Only the recruiter who owns the job can accept
        if candidature.offre.recruteur != request.user.recruteur:
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        candidature.statut = 'acceptee'
        candidature.save(update_fields=['statut'])

        return Response(CandidatureSerializer(candidature).data)


class RefuserCandidatureView(APIView):
    """
    POST /candidatures/{id}/refuser → recruiter refuses an application
    """
    permission_classes = [IsAuthenticated]

    def post(self, request, id):
        if not hasattr(request.user, 'recruteur'):
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        try:
            candidature = Candidature.objects.get(pk=id)
        except Candidature.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

        # Only the recruiter who owns the job can refuse
        if candidature.offre.recruteur != request.user.recruteur:
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        candidature.statut = 'refusee'
        candidature.save(update_fields=['statut'])

        return Response(CandidatureSerializer(candidature).data)
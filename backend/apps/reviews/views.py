"""
apps/reviews/views.py
Views for the Évaluations & Signalements module.

Endpoints implemented (admin endpoints excluded per spec):
    POST /evaluations                          → EvaluationListCreateView
    GET  /evaluations/{id}                     → EvaluationDetailView
    GET  /missions/{id}/evaluations            → MissionEvaluationsView
    GET  /utilisateurs/{id}/evaluations        → UserEvaluationsView
    GET  /utilisateurs/{id}/reputation         → UserReputationView
    POST /signalements                         → SignalementListCreateView
    GET  /signalements/me                      → MySignalementsView
"""
from django.db.models import Avg, Count
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated

from apps.reviews.models import Evaluation, Signalement
from apps.reviews.serializers import (
    EvaluationRequestSerializer,
    EvaluationSerializer,
    SignalementRequestSerializer,
    SignalementSerializer,
    ReputationSerializer,
)
from apps.jobs.models import Mission
from apps.users.models import Utilisateur
from core.pagination import StandardPagination


# ---------------------------------------------------------------------------
# Evaluations
# ---------------------------------------------------------------------------

class EvaluationListCreateView(APIView):
    """
    POST /evaluations
    Submit a rating after a completed mission.

    Business rules enforced:
      - The mission must exist and be terminee.
      - The evalue user must exist.
      - The authenticated user (evaluateur) must be a party to the mission
        (either the candidat or the recruteur of the related candidature).
      - One evaluation per (evaluateur, mission) pair — returns 409 on duplicate.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = EvaluationRequestSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        data = serializer.validated_data

        # --- Resolve mission ---
        try:
            mission = Mission.objects.select_related(
                'candidature__candidat__utilisateur_ptr',
                'candidature__offre__recruteur__utilisateur_ptr',
            ).get(pk=data['mission_id'])
        except Mission.DoesNotExist:
            return Response({'detail': 'Mission not found.'}, status=status.HTTP_404_NOT_FOUND)

        if mission.statut != 'terminee':
            return Response(
                {'detail': 'Evaluations can only be submitted for completed missions.'},
                status=status.HTTP_403_FORBIDDEN,
            )

        # --- Resolve evalue ---
        try:
            evalue = Utilisateur.objects.get(pk=data['evalue_id'])
        except Utilisateur.DoesNotExist:
            return Response({'detail': 'Evaluated user not found.'}, status=status.HTTP_404_NOT_FOUND)

        # --- Verify the authenticated user is a party to this mission ---
        candidature = mission.candidature
        candidat_user = candidature.candidat  # Candidat (Utilisateur subtype)
        recruteur_user = candidature.offre.recruteur  # Recruteur (Utilisateur subtype)

        is_candidat = (request.user.pk == candidat_user.pk)
        is_recruteur = (request.user.pk == recruteur_user.pk)

        if not (is_candidat or is_recruteur):
            return Response(
                {'detail': 'You are not a party to this mission.'},
                status=status.HTTP_403_FORBIDDEN,
            )

        # --- Duplicate guard (unique_together: evaluateur + mission) ---
        if Evaluation.objects.filter(evaluateur=request.user, mission=mission).exists():
            return Response(
                {'detail': 'You have already submitted an evaluation for this mission.'},
                status=status.HTTP_409_CONFLICT,
            )

        # --- Create ---
        evaluation = Evaluation.objects.create(
            mission=mission,
            evaluateur=request.user,
            evalue=evalue,
            note=data['note'],
            commentaire=data.get('commentaire'),
        )

        return Response(
            EvaluationSerializer(evaluation).data,
            status=status.HTTP_201_CREATED,
        )


class EvaluationDetailView(APIView):
    """
    GET /evaluations/{id}
    Return a single evaluation. Any authenticated user may view it.
    """
    permission_classes = [IsAuthenticated]

    def get(self, request, id):
        try:
            evaluation = Evaluation.objects.get(pk=id)
        except Evaluation.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

        return Response(EvaluationSerializer(evaluation).data)


class MissionEvaluationsView(APIView):
    """
    GET /missions/{id}/evaluations
    List all evaluations for a specific mission (max 2: one per party).
    Returns a plain array, not paginated, per the spec.
    """
    permission_classes = [IsAuthenticated]

    def get(self, request, id):
        try:
            Mission.objects.get(pk=id)
        except Mission.DoesNotExist:
            return Response({'detail': 'Mission not found.'}, status=status.HTTP_404_NOT_FOUND)

        evaluations = Evaluation.objects.filter(mission_id=id)
        return Response(EvaluationSerializer(evaluations, many=True).data)


class UserEvaluationsView(APIView):
    """
    GET /utilisateurs/{id}/evaluations
    Paginated list of evaluations *received* by the specified user.
    Public reputation page — any authenticated user may call it.
    """
    permission_classes = [IsAuthenticated]

    def get(self, request, id):
        if not Utilisateur.objects.filter(pk=id).exists():
            return Response({'detail': 'User not found.'}, status=status.HTTP_404_NOT_FOUND)

        evaluations = Evaluation.objects.filter(
            evalue_id=id
        ).order_by('-date_evaluation')

        paginator = StandardPagination()
        page = paginator.paginate_queryset(evaluations, request)
        serializer = EvaluationSerializer(page, many=True)
        return paginator.get_paginated_response(serializer.data)


class UserReputationView(APIView):
    """
    GET /utilisateurs/{id}/reputation
    Reputation dashboard for the specified user:
      - note_globale  : average of all received ratings
      - total_missions: count of received evaluations
      - distribution  : count per star value (1–5)
      - derniers_commentaires: last 5 evaluations with a non-empty comment
    """
    permission_classes = [IsAuthenticated]

    def get(self, request, id):
        if not Utilisateur.objects.filter(pk=id).exists():
            return Response({'detail': 'User not found.'}, status=status.HTTP_404_NOT_FOUND)

        received = Evaluation.objects.filter(evalue_id=id)

        # Aggregate average
        agg = received.aggregate(moyenne=Avg('note'))
        note_globale = round(agg['moyenne'], 2) if agg['moyenne'] is not None else 0.0
        total_missions = received.count()

        # Star distribution (keys as strings to match OpenAPI schema)
        dist_qs = received.values('note').annotate(count=Count('note'))
        distribution = {str(i): 0 for i in range(1, 6)}
        for row in dist_qs:
            distribution[str(row['note'])] = row['count']

        # Last 5 evaluations that have a comment
        derniers = list(
            received.exclude(commentaire__isnull=True)
                    .exclude(commentaire='')
                    .order_by('-date_evaluation')[:5]
        )

        data = {
            'utilisateur_id':       id,
            'note_globale':         note_globale,
            'total_missions':       total_missions,
            'distribution':         distribution,
            'derniers_commentaires': derniers,
        }

        return Response(ReputationSerializer(data).data)


# ---------------------------------------------------------------------------
# Signalements
# ---------------------------------------------------------------------------

class SignalementListCreateView(APIView):
    """
    POST /signalements
    Report a user for inappropriate behaviour.

    Business rules:
      - cible must exist and must not be the authenticated user themselves.
      - One report per (auteur, cible) pair — returns 409 on duplicate.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = SignalementRequestSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        data = serializer.validated_data

        # --- Resolve cible ---
        try:
            cible = Utilisateur.objects.get(pk=data['cible_id'])
        except Utilisateur.DoesNotExist:
            return Response({'detail': 'Reported user not found.'}, status=status.HTTP_404_NOT_FOUND)

        # Cannot report yourself
        if cible.pk == request.user.pk:
            return Response(
                {'detail': 'You cannot report yourself.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # --- Duplicate guard ---
        if Signalement.objects.filter(auteur=request.user, cible=cible).exists():
            return Response(
                {'detail': 'You have already submitted a report against this user.'},
                status=status.HTTP_409_CONFLICT,
            )

        # --- Create ---
        signalement = Signalement.objects.create(
            auteur=request.user,
            cible=cible,
            raison=data['raison'],
            description=data.get('description'),
        )

        return Response(
            SignalementSerializer(signalement).data,
            status=status.HTTP_201_CREATED,
        )


class MySignalementsView(APIView):
    """
    GET /signalements/me
    List reports submitted by the authenticated user.
    Supports optional ?statut= filter (ouvert | en_cours | cloture).
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        qs = Signalement.objects.filter(
            auteur=request.user
        ).order_by('-date_signalement')

        statut = request.query_params.get('statut')
        if statut:
            qs = qs.filter(statut=statut)

        paginator = StandardPagination()
        page = paginator.paginate_queryset(qs, request)
        serializer = SignalementSerializer(page, many=True)
        return paginator.get_paginated_response(serializer.data)

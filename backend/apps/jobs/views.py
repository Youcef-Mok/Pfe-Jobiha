"""
Views for the Jobs module.
"""
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.db.models import Count, Q

from apps.jobs.models import Offre, Mission, SavedJob, Alerte
from apps.jobs.serializers import (
    OffreSerializer, CreateOffreSerializer, UpdateOffreSerializer,
    MissionSerializer,
    SavedJobSerializer, CreateSavedJobSerializer,
    AlerteSerializer, CreateAlerteSerializer, UpdateAlerteSerializer,
)
from apps.applications.models import Candidature
from apps.applications.serializers import CandidatureSerializer, CreateCandidatureSerializer
from core.pagination import StandardPagination


# ===========================================================================
# Offres
# ===========================================================================

class OffreListCreateView(APIView):
    """
    GET  /offres  → everyone sees all jobs (with filters + pagination)
    POST /offres  → only recruiters can post a job
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        queryset = Offre.objects.annotate(
            nb_candidatures=Count('candidatures')
        ).order_by('-id')

        # ── Filters ──────────────────────────────────────────────
        categorie = request.query_params.get('categorie')
        if categorie:
            queryset = queryset.filter(categorie__icontains=categorie)

        type_contrat = request.query_params.get('type_contrat')
        if type_contrat:
            queryset = queryset.filter(type_contrat__icontains=type_contrat)

        statut = request.query_params.get('statut', 'ouverte')
        if statut:
            queryset = queryset.filter(statut=statut)

        salaire_min = request.query_params.get('salaire_min')
        if salaire_min:
            queryset = queryset.filter(salaire__gte=float(salaire_min))

        date_debut = request.query_params.get('date_debut')
        if date_debut:
            queryset = queryset.filter(date_debut__gte=date_debut)

        # Free text search on titre and description
        q = request.query_params.get('q')
        if q:
            queryset = queryset.filter(
                Q(titre__icontains=q) | Q(description__icontains=q)
            )

        # ── Pagination ───────────────────────────────────────────
        paginator = StandardPagination()
        page = paginator.paginate_queryset(queryset, request)
        serializer = OffreSerializer(page, many=True, context={'request': request})
        return paginator.get_paginated_response(serializer.data)

    def post(self, request):
        if not hasattr(request.user, 'recruteur'):
            return Response(
                {'detail': 'Only recruiters can create offres.'},
                status=status.HTTP_403_FORBIDDEN
            )

        serializer = CreateOffreSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        offre = Offre.objects.create(
            recruteur=request.user.recruteur,
            **serializer.validated_data
        )
        return Response(
            OffreSerializer(offre, context={'request': request}).data,
            status=status.HTTP_201_CREATED
        )


class OffreDetailView(APIView):
    """
    GET    /offres/{id}  → anyone sees the job
    PATCH  /offres/{id}  → only the recruiter who owns it can edit
    DELETE /offres/{id}  → only the recruiter who owns it can delete
    """
    permission_classes = [IsAuthenticated]

    def get_offre(self, id):
        try:
            return Offre.objects.get(pk=id)
        except Offre.DoesNotExist:
            return None

    def get(self, request, id):
        offre = self.get_offre(id)
        if not offre:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        return Response(OffreSerializer(offre, context={'request': request}).data)

    def patch(self, request, id):
        offre = self.get_offre(id)
        if not offre:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        if not hasattr(request.user, 'recruteur') or offre.recruteur != request.user.recruteur:
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        serializer = UpdateOffreSerializer(data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        for field, value in serializer.validated_data.items():
            setattr(offre, field, value)
        offre.save()
        return Response(OffreSerializer(offre, context={'request': request}).data)

    def delete(self, request, id):
        offre = self.get_offre(id)
        if not offre:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        if not hasattr(request.user, 'recruteur') or offre.recruteur != request.user.recruteur:
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)
        offre.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class FermerOffreView(APIView):
    """
    POST /offres/{id}/fermer → recruiter closes the job
    """
    permission_classes = [IsAuthenticated]

    def post(self, request, id):
        try:
            offre = Offre.objects.get(pk=id)
        except Offre.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

        if not hasattr(request.user, 'recruteur') or offre.recruteur != request.user.recruteur:
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        offre.statut = 'fermee'
        offre.save(update_fields=['statut'])
        return Response(OffreSerializer(offre, context={'request': request}).data)


class MyOffresView(APIView):
    """
    GET /recruteurs/me/offres → recruiter sees only their own jobs (with filters + pagination)
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if not hasattr(request.user, 'recruteur'):
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        queryset = Offre.objects.filter(
            recruteur=request.user.recruteur
        ).annotate(
            nb_candidatures=Count('candidatures')
        ).order_by('-id')

        # Optional filter by statut
        statut = request.query_params.get('statut')
        if statut:
            queryset = queryset.filter(statut=statut)

        paginator = StandardPagination()
        page = paginator.paginate_queryset(queryset, request)
        serializer = OffreSerializer(page, many=True, context={'request': request})
        return paginator.get_paginated_response(serializer.data)


class OffreCandidaturesView(APIView):
    """
    GET  /offres/{id}/candidatures → recruiter sees who applied
    POST /offres/{id}/candidatures → candidate applies to the job
    """
    permission_classes = [IsAuthenticated]

    def get(self, request, id):
        try:
            offre = Offre.objects.get(pk=id)
        except Offre.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

        if not hasattr(request.user, 'recruteur') or offre.recruteur != request.user.recruteur:
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        candidatures = offre.candidatures.all()

        # Optional filter by statut
        statut = request.query_params.get('statut')
        if statut:
            candidatures = candidatures.filter(statut=statut)

        paginator = StandardPagination()
        page = paginator.paginate_queryset(candidatures, request)
        serializer = CandidatureSerializer(page, many=True)
        return paginator.get_paginated_response(serializer.data)

    def post(self, request, id):
        # Only candidates can apply
        if not hasattr(request.user, 'candidat'):
            return Response(
                {'detail': 'Only candidates can apply.'},
                status=status.HTTP_403_FORBIDDEN
            )

        try:
            offre = Offre.objects.get(pk=id)
        except Offre.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

        # Check if already applied — 409 Conflict
        if Candidature.objects.filter(candidat=request.user.candidat, offre=offre).exists():
            return Response(
                {'detail': 'You have already applied to this offer.'},
                status=status.HTTP_409_CONFLICT
            )

        serializer = CreateCandidatureSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        candidature = Candidature.objects.create(
            candidat=request.user.candidat,
            offre=offre,
            **serializer.validated_data
        )
        return Response(
            CandidatureSerializer(candidature).data,
            status=status.HTTP_201_CREATED
        )


# ===========================================================================
# Missions
# ===========================================================================

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _is_mission_participant(user, mission):
    """
    Returns True if the user is either the candidat or the recruteur
    linked to the mission's candidature.
    """
    candidature = mission.candidature
    if hasattr(user, 'candidat') and candidature.candidat == user.candidat:
        return True
    if hasattr(user, 'recruteur') and candidature.offre.recruteur == user.recruteur:
        return True
    return False


# ===========================================================================
# Mission views
# ===========================================================================

class MissionListCreateView(APIView):
    """
    GET /missions
    Returns missions scoped to the authenticated user:
    - candidat  → missions where candidature.candidat = me
    - recruteur → missions where candidature.offre.recruteur = me
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if hasattr(request.user, 'candidat'):
            queryset = Mission.objects.filter(
                candidature__candidat=request.user.candidat
            )
        elif hasattr(request.user, 'recruteur'):
            queryset = Mission.objects.filter(
                candidature__offre__recruteur=request.user.recruteur
            )
        else:
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        statut = request.query_params.get('statut')
        if statut:
            queryset = queryset.filter(statut=statut)

        queryset = queryset.select_related(
            'candidature__candidat', 'candidature__offre__recruteur'
        ).order_by('-id')

        paginator = StandardPagination()
        page = paginator.paginate_queryset(queryset, request)
        serializer = MissionSerializer(page, many=True, context={'request': request})
        return paginator.get_paginated_response(serializer.data)


class MissionDetailView(APIView):
    """GET /missions/{id}"""
    permission_classes = [IsAuthenticated]

    def get(self, request, id):
        try:
            mission = Mission.objects.select_related(
                'candidature__candidat', 'candidature__offre__recruteur'
            ).get(pk=id)
        except Mission.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        if not _is_mission_participant(request.user, mission):
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)
        return Response(MissionSerializer(mission, context={'request': request}).data)


class ValiderDebutView(APIView):
    """POST /missions/{id}/valider-debut"""
    permission_classes = [IsAuthenticated]

    def post(self, request, id):
        try:
            mission = Mission.objects.select_related(
                'candidature__candidat', 'candidature__offre__recruteur'
            ).get(pk=id)
        except Mission.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        if not _is_mission_participant(request.user, mission):
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)
        date_debut = request.data.get('date_debut')  # optional ISO datetime string
        try:
            from django.utils.dateparse import parse_datetime
            parsed = parse_datetime(date_debut) if date_debut else None
            mission.valider_debut(parsed)
        except Exception as e:
            return Response({'detail': str(e)}, status=status.HTTP_400_BAD_REQUEST)
        return Response(MissionSerializer(mission, context={'request': request}).data)


class ValiderFinView(APIView):
    """POST /missions/{id}/valider-fin"""
    permission_classes = [IsAuthenticated]

    def post(self, request, id):
        try:
            mission = Mission.objects.select_related(
                'candidature__candidat', 'candidature__offre__recruteur'
            ).get(pk=id)
        except Mission.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        if not _is_mission_participant(request.user, mission):
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)
        date_fin = request.data.get('date_fin')  # optional ISO datetime string
        try:
            from django.utils.dateparse import parse_datetime
            parsed = parse_datetime(date_fin) if date_fin else None
            mission.valider_fin(parsed)
        except Exception as e:
            return Response({'detail': str(e)}, status=status.HTTP_400_BAD_REQUEST)
        return Response(MissionSerializer(mission, context={'request': request}).data)


class AttestationView(APIView):
    """GET /missions/{id}/attestation — returns attestation data (JSON)."""
    permission_classes = [IsAuthenticated]

    def get(self, request, id):
        try:
            mission = Mission.objects.select_related(
                'candidature__candidat', 'candidature__offre__recruteur'
            ).get(pk=id)
        except Mission.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        if not _is_mission_participant(request.user, mission):
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)
        try:
            data = mission.generer_attestation()
        except Exception as e:
            return Response({'detail': str(e)}, status=status.HTTP_400_BAD_REQUEST)
        return Response(data)


class HistoriqueCandidatView(APIView):
    """
    GET /candidats/me/historique
    Full mission history for the authenticated candidat.
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if not hasattr(request.user, 'candidat'):
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        queryset = Mission.objects.filter(
            candidature__candidat=request.user.candidat
        ).select_related(
            'candidature__candidat', 'candidature__offre__recruteur'
        ).order_by('-id')

        statut = request.query_params.get('statut')
        if statut:
            queryset = queryset.filter(statut=statut)

        paginator = StandardPagination()
        page = paginator.paginate_queryset(queryset, request)
        serializer = MissionSerializer(page, many=True, context={'request': request})
        return paginator.get_paginated_response(serializer.data)


# ===========================================================================
# SavedJobs
# ===========================================================================

class SavedJobsView(APIView):
    """
    GET  /candidats/me/saved  → list saved jobs for the authenticated candidat
    POST /candidats/me/saved  → bookmark an offer (body: {offre_id})
    DELETE /candidats/me/saved/{offre_id} is handled separately via query param
    """
    permission_classes = [IsAuthenticated]

    def _require_candidat(self, request):
        if not hasattr(request.user, 'candidat'):
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)
        return None

    def get(self, request):
        err = self._require_candidat(request)
        if err:
            return err
        queryset = SavedJob.objects.filter(
            candidat=request.user.candidat
        ).select_related('offre__recruteur').order_by('-saved_at')
        paginator = StandardPagination()
        page = paginator.paginate_queryset(queryset, request)
        serializer = SavedJobSerializer(page, many=True, context={'request': request})
        return paginator.get_paginated_response(serializer.data)

    def post(self, request):
        err = self._require_candidat(request)
        if err:
            return err
        serializer = CreateSavedJobSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        offre_id = serializer.validated_data['offre_id']
        try:
            offre = Offre.objects.get(pk=offre_id)
        except Offre.DoesNotExist:
            return Response({'detail': 'Offre not found.'}, status=status.HTTP_404_NOT_FOUND)
        saved, created = SavedJob.objects.get_or_create(
            candidat=request.user.candidat, offre=offre
        )
        return Response(
            SavedJobSerializer(saved, context={'request': request}).data,
            status=status.HTTP_201_CREATED if created else status.HTTP_200_OK,
        )

    def delete(self, request):
        """DELETE /candidats/me/saved?offre_id=<id>"""
        err = self._require_candidat(request)
        if err:
            return err
        offre_id = request.query_params.get('offre_id')
        if not offre_id:
            return Response(
                {'detail': 'offre_id query param required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        deleted, _ = SavedJob.objects.filter(
            candidat=request.user.candidat, offre_id=offre_id
        ).delete()
        if not deleted:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        return Response(status=status.HTTP_204_NO_CONTENT)


# ===========================================================================
# Alertes
# ===========================================================================

class AlerteListCreateView(APIView):
    """
    GET  /candidats/me/alertes  → list alerts for the authenticated candidat
    POST /candidats/me/alertes  → create a new alert
    """
    permission_classes = [IsAuthenticated]

    def _require_candidat(self, request):
        if not hasattr(request.user, 'candidat'):
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)
        return None

    def get(self, request):
        err = self._require_candidat(request)
        if err:
            return err
        queryset = Alerte.objects.filter(
            candidat=request.user.candidat
        ).order_by('-cree_le')
        paginator = StandardPagination()
        page = paginator.paginate_queryset(queryset, request)
        serializer = AlerteSerializer(page, many=True)
        return paginator.get_paginated_response(serializer.data)

    def post(self, request):
        err = self._require_candidat(request)
        if err:
            return err
        serializer = CreateAlerteSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        alerte = Alerte.objects.create(
            candidat=request.user.candidat,
            **serializer.validated_data
        )
        return Response(
            AlerteSerializer(alerte).data,
            status=status.HTTP_201_CREATED,
        )


class AlerteDetailView(APIView):
    """
    GET    /candidats/me/alertes/{id}  → retrieve an alert
    PATCH  /candidats/me/alertes/{id}  → update (e.g. toggle actif)
    DELETE /candidats/me/alertes/{id}  → delete
    """
    permission_classes = [IsAuthenticated]

    def _get_alerte(self, request, id):
        if not hasattr(request.user, 'candidat'):
            return None, Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)
        try:
            alerte = Alerte.objects.get(pk=id, candidat=request.user.candidat)
            return alerte, None
        except Alerte.DoesNotExist:
            return None, Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

    def get(self, request, id):
        alerte, err = self._get_alerte(request, id)
        if err:
            return err
        return Response(AlerteSerializer(alerte).data)

    def patch(self, request, id):
        alerte, err = self._get_alerte(request, id)
        if err:
            return err
        serializer = UpdateAlerteSerializer(data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        for field, value in serializer.validated_data.items():
            setattr(alerte, field, value)
        alerte.save()
        return Response(AlerteSerializer(alerte).data)

    def delete(self, request, id):
        alerte, err = self._get_alerte(request, id)
        if err:
            return err
        alerte.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


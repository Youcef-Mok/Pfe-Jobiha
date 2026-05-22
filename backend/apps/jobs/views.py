"""
Views for the Jobs module.
"""
import math
from django.utils import timezone
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.parsers import MultiPartParser, FormParser
from django.core.files.storage import default_storage
from django.conf import settings
from django.db.models import Count, Q

from apps.jobs.models import Offre, Mission, SavedJob, Alerte, Interview
from apps.jobs.serializers import (
    OffreSerializer, CreateOffreSerializer, UpdateOffreSerializer,
    MissionSerializer, InterviewSerializer,
    SavedJobSerializer, CreateSavedJobSerializer,
    AlerteSerializer, CreateAlerteSerializer, UpdateAlerteSerializer,
)
from apps.applications.models import Candidature
from apps.applications.serializers import ApplicationSerializer, CreateCandidatureSerializer
from apps.reviews.models.evaluation import Evaluation
from core.pagination import StandardPagination


def _haversine(lat1, lon1, lat2, lon2):
    """Return distance in km between two lat/lng points."""
    R = 6371
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (math.sin(dlat / 2) ** 2
         + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2))
         * math.sin(dlon / 2) ** 2)
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))


# ===========================================================================
# Offres
# ===========================================================================

class OffreListCreateView(APIView):
    """
    GET  /offres  → everyone sees all jobs (with filters + pagination)
    POST /offres  → only recruiters can post a job
    """
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def get(self, request):
        queryset = Offre.objects.filter(
            is_published=True
        ).select_related('recruteur').order_by('-id')

        # ── Filters ──────────────────────────────────────────────
        q = request.query_params.get('q')
        if q:
            queryset = queryset.filter(
                Q(titre__icontains=q) | Q(description__icontains=q)
            )

        category = request.query_params.get('category')
        if category:
            queryset = queryset.filter(categorie__icontains=category)

        contract_type = request.query_params.get('contract_type')
        if contract_type:
            queryset = queryset.filter(type_contrat__icontains=contract_type)

        location = request.query_params.get('location')
        if location:
            queryset = queryset.filter(location__icontains=location)

        # Distance filter (haversine)
        max_dist = request.query_params.get('max_distance_km')
        user_lat = request.query_params.get('lat')
        user_lng = request.query_params.get('lng')
        if max_dist and user_lat and user_lng:
            try:
                max_km = float(max_dist)
                ulat, ulng = float(user_lat), float(user_lng)
                ids = [
                    o.id for o in queryset
                    if o.latitude is not None and o.longitude is not None
                    and _haversine(ulat, ulng, o.latitude, o.longitude) <= max_km
                ]
                queryset = queryset.filter(id__in=ids)
            except (ValueError, TypeError):
                pass

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

        model_data = serializer.to_model_data()
        uploaded = request.FILES.get('image')
        if uploaded:
            path = default_storage.save(f'offres/{uploaded.name}', uploaded)
            model_data['image_url'] = request.build_absolute_uri(settings.MEDIA_URL + path)
        model_data['date_debut'] = model_data.get('date_debut') or timezone.now().date()
        offre = Offre.objects.create(
            recruteur=request.user.recruteur,
            **model_data
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
    parser_classes = [MultiPartParser, FormParser]

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

    def put(self, request, id):
        offre = self.get_offre(id)
        if not offre:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        if not hasattr(request.user, 'recruteur') or offre.recruteur != request.user.recruteur:
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        serializer = UpdateOffreSerializer(data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        for field, value in serializer.to_model_data().items():
            setattr(offre, field, value)
        uploaded = request.FILES.get('image')
        if uploaded:
            path = default_storage.save(f'offres/{uploaded.name}', uploaded)
            offre.image_url = request.build_absolute_uri(settings.MEDIA_URL + path)
        offre.save()
        return Response(OffreSerializer(offre, context={'request': request}).data)

    # Keep PATCH as alias for PUT
    def patch(self, request, id):
        return self.put(request, id)

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

        offre.statut = 'closed'
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

        # Accept English status values (spec) and map to DB values
        statut = request.query_params.get('statut') or request.query_params.get('status')
        if statut:
            # English→French mapping; also pass through already-French values
            _STATUS_MAP = {'searching': 'searching', 'draft': 'draft', 'closed': 'closed'}
            queryset = queryset.filter(statut=_STATUS_MAP.get(statut, statut))

        paginator = StandardPagination()
        page = paginator.paginate_queryset(queryset, request)
        serializer = OffreSerializer(page, many=True, context={'request': request})
        return paginator.get_paginated_response(serializer.data)


class JobCandidatesView(APIView):
    """
    GET  /jobs/{id}/candidates → recruiter sees who applied
    POST /jobs/{id}/candidates → candidate applies to the job
    """
    permission_classes = [IsAuthenticated]

    def get(self, request, id):
        try:
            offre = Offre.objects.get(pk=id)
        except Offre.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

        if not hasattr(request.user, 'recruteur') or offre.recruteur != request.user.recruteur:
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        candidatures = offre.candidatures.select_related('candidat', 'offre__recruteur').all()

        # Optional filter by status
        status_param = request.query_params.get('status')
        if status_param:
            api_to_db = {'pending': 'en_attente', 'accepted': 'acceptee', 'rejected': 'refusee'}
            db_val = api_to_db.get(status_param, status_param)
            candidatures = candidatures.filter(statut=db_val)

        # Sorting
        sort = request.query_params.get('sort')
        if sort == 'recent':
            candidatures = candidatures.order_by('-date_postulation')
        elif sort == 'best':
            candidatures = candidatures.order_by('-candidat__note_globale')
        else:
            candidatures = candidatures.order_by('-date_postulation')

        paginator = StandardPagination()
        page = paginator.paginate_queryset(candidatures, request)
        serializer = ApplicationSerializer(page, many=True)
        return paginator.get_paginated_response(serializer.data)

    def post(self, request, id):
        if not hasattr(request.user, 'candidat'):
            return Response(
                {'detail': 'Only candidates can apply.'},
                status=status.HTTP_403_FORBIDDEN
            )

        try:
            offre = Offre.objects.get(pk=id)
        except Offre.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

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
            ApplicationSerializer(candidature).data,
            status=status.HTTP_201_CREATED
        )


# Keep legacy alias
OffreCandidaturesView = JobCandidatesView


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

        # Accept English status values (spec) or French DB values
        statut_param = request.query_params.get('statut') or request.query_params.get('status')
        if statut_param:
            _MISSION_STATUS = {
                'unconfirmed': 'en_attente',
                'in_progress': 'en_cours',
                'completed': 'terminee',
            }
            db_val = _MISSION_STATUS.get(statut_param, statut_param)
            queryset = queryset.filter(statut=db_val)

        queryset = queryset.select_related(
            'candidature__candidat', 'candidature__offre__recruteur'
        ).order_by('-id')

        paginator = StandardPagination()
        page = paginator.paginate_queryset(queryset, request)
        serializer = MissionSerializer(page, many=True, context={'request': request})
        return paginator.get_paginated_response(serializer.data)

    def post(self, request):
        """
        POST /missions — create a mission from an accepted candidature.
        Body: { job_id, start_date, end_date, location, image_url, summary }
        The candidature must be accepted and belong to the requesting user.
        """
        if not hasattr(request.user, 'recruteur'):
            return Response({'detail': 'Only recruiters can create missions.'}, status=status.HTTP_403_FORBIDDEN)

        job_id = request.data.get('job_id')
        if not job_id:
            return Response({'detail': 'job_id is required.'}, status=status.HTTP_400_BAD_REQUEST)

        candidature_id = request.data.get('candidature_id')
        if candidature_id:
            try:
                from apps.applications.models import Candidature
                candidature = Candidature.objects.select_related(
                    'offre__recruteur', 'candidat'
                ).get(pk=candidature_id)
            except Exception:
                return Response({'detail': 'Candidature not found.'}, status=status.HTTP_404_NOT_FOUND)
        else:
            # Fall back: find accepted candidature for the given job
            from apps.applications.models import Candidature
            candidature = Candidature.objects.filter(
                offre_id=job_id,
                offre__recruteur=request.user.recruteur,
                statut='acceptee',
                mission__isnull=True,
            ).select_related('offre__recruteur', 'candidat').first()
            if not candidature:
                return Response(
                    {'detail': 'No accepted candidature without a mission found for this job.'},
                    status=status.HTTP_404_NOT_FOUND,
                )

        if candidature.offre.recruteur != request.user.recruteur:
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        if hasattr(candidature, 'mission'):
            return Response({'detail': 'A mission already exists for this candidature.'}, status=status.HTTP_409_CONFLICT)

        from django.utils.dateparse import parse_datetime
        start_raw = request.data.get('start_date')
        end_raw = request.data.get('end_date')

        mission = Mission.objects.create(
            candidature=candidature,
            date_debut=parse_datetime(start_raw) if start_raw else None,
            date_fin=parse_datetime(end_raw) if end_raw else None,
            location=request.data.get('location', ''),
            image_url=request.data.get('image_url'),
            summary=request.data.get('summary') or candidature.offre.description,
            statut='en_attente',
        )
        return Response(
            MissionSerializer(mission, context={'request': request}).data,
            status=status.HTTP_201_CREATED,
        )


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


class MissionConfirmView(APIView):
    """PATCH /missions/:id/confirm — confirm a mission has started (sets statut=en_cours)."""
    permission_classes = [IsAuthenticated]

    def patch(self, request, id):
        try:
            mission = Mission.objects.select_related(
                'candidature__candidat', 'candidature__offre__recruteur'
            ).get(pk=id)
        except Mission.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        if not _is_mission_participant(request.user, mission):
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)
        if mission.statut not in ('en_attente',):
            return Response(
                {'detail': f'Cannot confirm a mission with status {mission.statut}.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        mission.statut = 'en_cours'
        mission.save(update_fields=['statut'])
        return Response(MissionSerializer(mission, context={'request': request}).data)


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


# ===========================================================================
# Map Jobs
# ===========================================================================

class MapJobsView(APIView):
    """
    GET /jobs/map → published offres with lat/lng set.
    Returns a flat list with distance computed via haversine if user sends lat/lng.
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        queryset = Offre.objects.filter(
            is_published=True,
            statut='searching',
            latitude__isnull=False,
            longitude__isnull=False,
        ).select_related('recruteur')

        # Filters
        q = request.query_params.get('q')
        if q:
            queryset = queryset.filter(
                Q(titre__icontains=q) | Q(description__icontains=q)
            )
        category = request.query_params.get('category')
        if category:
            queryset = queryset.filter(categorie__icontains=category)
        contract_type = request.query_params.get('contract_type')
        if contract_type:
            queryset = queryset.filter(type_contrat__icontains=contract_type)

        location = request.query_params.get('location')
        if location:
            queryset = queryset.filter(location__icontains=location)

        user_lat = request.query_params.get('lat')
        user_lng = request.query_params.get('lng')
        has_coords = False
        ulat = ulng = 0.0
        if user_lat and user_lng:
            try:
                ulat, ulng = float(user_lat), float(user_lng)
                has_coords = True
            except (ValueError, TypeError):
                pass

        results = []
        for o in queryset:
            dist = 'N/A'
            if has_coords:
                dist = round(_haversine(ulat, ulng, o.latitude, o.longitude), 1)
            results.append({
                'id': str(o.id),
                'title': o.titre,
                'company': o.recruteur.nom_structure if o.recruteur else None,
                'city': (o.location.split(',')[0].strip() if o.location else None),
                'category': o.categorie,
                'distance': dist,
                'hours': o.schedule_label,
                'salary': o.salaire,
                'contract_type': o.type_contrat,
                'rating': float(o.recruteur.note_globale) if o.recruteur and o.recruteur.note_globale is not None else None,
                'recruiter_avatar': getattr(o.recruteur, 'avatar_url', None) if o.recruteur else None,
                'lat': o.latitude,
                'lng': o.longitude,
                'image_asset': None,
            })

        return Response(results)


# ===========================================================================
# Mission Review
# ===========================================================================

class MissionReviewView(APIView):
    """PUT /missions/{id}/review → submit a review for the other party."""
    permission_classes = [IsAuthenticated]

    def put(self, request, id):
        try:
            mission = Mission.objects.select_related(
                'candidature__candidat', 'candidature__offre__recruteur'
            ).get(pk=id)
        except Mission.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

        if not _is_mission_participant(request.user, mission):
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        rating = request.data.get('rating')
        feedback = request.data.get('feedback', '')

        if not rating or int(rating) < 1 or int(rating) > 5:
            return Response(
                {'detail': 'rating must be between 1 and 5.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Determine who is being evaluated
        candidat = mission.candidature.candidat
        recruteur = mission.candidature.offre.recruteur
        if hasattr(request.user, 'candidat') and request.user.candidat == candidat:
            evalue = recruteur
        else:
            evalue = candidat

        # Prevent duplicate reviews
        if Evaluation.objects.filter(evaluateur=request.user, mission=mission).exists():
            return Response(
                {'detail': 'You have already reviewed this mission.'},
                status=status.HTTP_409_CONFLICT,
            )

        Evaluation.objects.create(
            mission=mission,
            evaluateur=request.user,
            evalue=evalue,
            note=int(rating),
            commentaire=feedback,
        )
        return Response({'detail': 'Review submitted.'})


# ===========================================================================
# Interviews
# ===========================================================================

class InterviewListCreateView(APIView):
    """
    GET  /interviews → list interviews for the user
    POST /interviews → recruiter schedules an interview
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        queryset = Interview.objects.filter(
            Q(candidate=request.user) | Q(recruiter=request.user)
        ).select_related('candidate', 'recruiter', 'job').order_by('-scheduled_date')

        upcoming = request.query_params.get('upcoming')
        if upcoming and upcoming.lower() == 'true':
            queryset = queryset.filter(
                scheduled_date__gte=timezone.now(),
                status='scheduled',
            )

        serializer = InterviewSerializer(queryset, many=True)
        return Response(serializer.data)

    def post(self, request):
        if not hasattr(request.user, 'recruteur'):
            return Response({'detail': 'Only recruiters can schedule interviews.'},
                            status=status.HTTP_403_FORBIDDEN)

        candidate_id = request.data.get('candidate_id')
        job_id = request.data.get('job_id')
        scheduled_date = request.data.get('scheduled_date')
        notes = request.data.get('notes', '')

        if not all([candidate_id, job_id, scheduled_date]):
            return Response(
                {'detail': 'candidate_id, job_id, and scheduled_date are required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        from apps.users.models import Utilisateur
        try:
            candidate = Utilisateur.objects.get(pk=candidate_id)
        except Utilisateur.DoesNotExist:
            return Response({'detail': 'Candidate not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            job = Offre.objects.get(pk=job_id)
        except Offre.DoesNotExist:
            return Response({'detail': 'Job not found.'}, status=status.HTTP_404_NOT_FOUND)

        interview = Interview.objects.create(
            candidate=candidate,
            recruiter=request.user,
            job=job,
            scheduled_date=scheduled_date,
            notes=notes,
        )
        return Response(
            InterviewSerializer(interview).data,
            status=status.HTTP_201_CREATED,
        )


class InterviewDetailView(APIView):
    """GET/PUT/DELETE /interviews/{id}"""
    permission_classes = [IsAuthenticated]

    def _get_interview(self, id, user):
        try:
            interview = Interview.objects.select_related(
                'candidate', 'recruiter', 'job'
            ).get(pk=id)
        except Interview.DoesNotExist:
            return None, Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        if interview.candidate != user and interview.recruiter != user:
            return None, Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)
        return interview, None

    def get(self, request, id):
        interview, err = self._get_interview(id, request.user)
        if err:
            return err
        return Response(InterviewSerializer(interview).data)

    def put(self, request, id):
        interview, err = self._get_interview(id, request.user)
        if err:
            return err
        if 'scheduled_date' in request.data:
            interview.scheduled_date = request.data['scheduled_date']
        if 'notes' in request.data:
            interview.notes = request.data['notes']
        interview.save()
        return Response(InterviewSerializer(interview).data)

    def delete(self, request, id):
        interview, err = self._get_interview(id, request.user)
        if err:
            return err
        interview.status = 'cancelled'
        interview.save(update_fields=['status'])
        return Response(status=status.HTTP_204_NO_CONTENT)


class InterviewCompleteView(APIView):
    """PUT /interviews/{id}/complete → mark as completed."""
    permission_classes = [IsAuthenticated]

    def put(self, request, id):
        try:
            interview = Interview.objects.select_related(
                'candidate', 'recruiter', 'job'
            ).get(pk=id)
        except Interview.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

        if interview.candidate != request.user and interview.recruiter != request.user:
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        interview.status = 'completed'
        if 'notes' in request.data:
            interview.notes = request.data['notes']
        interview.save(update_fields=['status', 'notes'])
        return Response(InterviewSerializer(interview).data)


# ===========================================================================
# JobComment
# ===========================================================================

class JobCommentListCreateView(APIView):
    """GET/POST /jobs/:id/comments"""
    permission_classes = [IsAuthenticated]

    def get(self, request, id):
        from apps.jobs.models.job_comment import JobComment
        comments = JobComment.objects.filter(offre_id=id).select_related('auteur').order_by('-date_question')
        result = []
        for c in comments:
            prenom = ((getattr(c.auteur, 'prenom', '') or '').strip() if c.auteur else '')
            nom = ((getattr(c.auteur, 'nom', '') or '').strip() if c.auteur else '')
            initials = (prenom[:1] + nom[:1]).upper() if (prenom or nom) else ''
            author_name = f"{prenom} {nom}".strip()
            result.append({
                'id': c.id,
                'initials': initials,
                'author_name': author_name,
                'date': c.date_question.isoformat() if c.date_question else '',
                'question': c.question,
                'recruitor_label': '',
                'recruitor_date': c.date_reponse.isoformat() if c.date_reponse else '',
                'reply': c.reponse or '',
            })
        return Response(result)

    def post(self, request, id):
        try:
            offre = Offre.objects.get(pk=id)
        except Offre.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        question = request.data.get('question', '').strip()
        if not question:
            return Response({'detail': 'question is required.'}, status=status.HTTP_400_BAD_REQUEST)
        from apps.jobs.models.job_comment import JobComment
        comment = JobComment.objects.create(
            offre=offre, auteur=request.user, question=question,
        )
        return Response({
            'id': comment.id,
            'initials': (((request.user.prenom or '')[:1] + (request.user.nom or '')[:1]).upper()),
            'author_name': f"{request.user.prenom or ''} {request.user.nom or ''}".strip(),
            'date': comment.date_question.isoformat(),
            'question': comment.question,
            'recruitor_label': '',
            'recruitor_date': '',
            'reply': '',
        }, status=status.HTTP_201_CREATED)


class JobCommentReplyView(APIView):
    """POST /jobs/:jobId/comments/:commentId/reply — recruiter replies"""
    permission_classes = [IsAuthenticated]

    def post(self, request, job_id, comment_id):
        from apps.jobs.models.job_comment import JobComment
        try:
            comment = JobComment.objects.select_related('offre__recruteur', 'auteur').get(pk=comment_id, offre_id=job_id)
        except JobComment.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        if not hasattr(request.user, 'recruteur') or comment.offre.recruteur != request.user.recruteur:
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)
        reply = request.data.get('reply', '').strip()
        if not reply:
            return Response({'detail': 'reply is required.'}, status=status.HTTP_400_BAD_REQUEST)
        from django.utils import timezone as tz
        comment.reponse = reply
        comment.date_reponse = tz.now()
        comment.save(update_fields=['reponse', 'date_reponse'])
        prenom = ((getattr(comment.auteur, 'prenom', '') or '').strip() if comment.auteur else '')
        nom = ((getattr(comment.auteur, 'nom', '') or '').strip() if comment.auteur else '')
        return Response({
            'id': comment.id,
            'initials': (prenom[:1] + nom[:1]).upper() if (prenom or nom) else '',
            'author_name': f"{prenom} {nom}".strip(),
            'date': comment.date_question.isoformat(),
            'question': comment.question,
            'recruitor_label': getattr(request.user.recruteur, 'titre_poste', '') or '',
            'recruitor_date': comment.date_reponse.isoformat(),
            'reply': comment.reponse,
        })


# ===========================================================================
# MissionTeamMember
# ===========================================================================

class MissionTeamView(APIView):
    """GET/POST /missions/:id/team"""
    permission_classes = [IsAuthenticated]

    def get(self, request, id):
        try:
            mission = Mission.objects.select_related('candidature__candidat', 'candidature__offre__recruteur').get(pk=id)
        except Mission.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        if not _is_mission_participant(request.user, mission):
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)
        from apps.jobs.models.mission_team_member import MissionTeamMember
        members = MissionTeamMember.objects.filter(mission=mission)
        return Response([
            {'id': m.id, 'name': m.name, 'role': m.role, 'rating': m.rating, 'avatar_url': m.avatar_url}
            for m in members
        ])

    def post(self, request, id):
        try:
            mission = Mission.objects.select_related('candidature__candidat', 'candidature__offre__recruteur').get(pk=id)
        except Mission.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        if not _is_mission_participant(request.user, mission):
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)
        name = request.data.get('name', '').strip()
        role = request.data.get('role', '').strip()
        if not name or not role:
            return Response({'detail': 'name and role are required.'}, status=status.HTTP_400_BAD_REQUEST)
        from apps.jobs.models.mission_team_member import MissionTeamMember
        member = MissionTeamMember.objects.create(
            mission=mission,
            name=name,
            role=role,
            rating=float(request.data.get('rating', 0.0)),
            avatar_url=request.data.get('avatar_url'),
        )
        return Response(
            {'id': member.id, 'name': member.name, 'role': member.role, 'rating': member.rating, 'avatar_url': member.avatar_url},
            status=status.HTTP_201_CREATED,
        )


class MissionTeamMemberDetailView(APIView):
    """DELETE /missions/:id/team/:memberId"""
    permission_classes = [IsAuthenticated]

    def delete(self, request, id, member_id):
        try:
            mission = Mission.objects.select_related('candidature__candidat', 'candidature__offre__recruteur').get(pk=id)
        except Mission.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        if not _is_mission_participant(request.user, mission):
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)
        from apps.jobs.models.mission_team_member import MissionTeamMember
        deleted, _ = MissionTeamMember.objects.filter(pk=member_id, mission=mission).delete()
        if not deleted:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        return Response(status=status.HTTP_204_NO_CONTENT)


# ===========================================================================
# Job Statistics
# ===========================================================================

class JobStatisticsView(APIView):
    """GET /jobs/:id/statistics"""
    permission_classes = [IsAuthenticated]

    def get(self, request, id):
        try:
            offre = Offre.objects.get(pk=id)
        except Offre.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        if not hasattr(request.user, 'recruteur') or offre.recruteur != request.user.recruteur:
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)
        from apps.applications.models import Candidature
        total = Candidature.objects.filter(offre=offre).count()
        pending = Candidature.objects.filter(offre=offre, statut='en_attente').count()
        accepted = Candidature.objects.filter(offre=offre, statut='acceptee').count()
        rejected = Candidature.objects.filter(offre=offre, statut='refusee').count()
        return Response({
            'job_id': str(offre.id),
            'view_count': offre.view_count,
            'total_applications': total,
            'pending_applications': pending,
            'accepted_applications': accepted,
            'rejected_applications': rejected,
        })


# ===========================================================================
# Stub for not-yet-implemented endpoints
# ===========================================================================

class StubView(APIView):
    """Temporary stub — returns 501 for every HTTP method."""
    permission_classes = [IsAuthenticated]

    def handle(self, request, *args, **kwargs):
        return Response({'detail': 'not implemented'}, status=501)

    get = post = put = patch = delete = handle

"""
Views for the Jobs module.
"""
import math
from django.utils import timezone
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
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

        print("=" * 80)
        print("DEBUG POST /api/v1/jobs - request.data:")
        print(request.data)
        print("=" * 80)

        serializer = CreateOffreSerializer(data=request.data)
        if not serializer.is_valid():
            print("=" * 80)
            print("DEBUG POST /api/v1/jobs - serializer.errors:")
            print(serializer.errors)
            print("=" * 80)
        serializer.is_valid(raise_exception=True)
        
        # Map API field names to DB field names
        data = serializer.validated_data
        offre = Offre.objects.create(
            recruteur=request.user.recruteur,
            titre=data.get('title'),
            type_contrat=data.get('contract_type'),
            description=data.get('description'),
            candidate_count=data.get('candidate_count', 1),
            salaire=data.get('salary'),
            is_published=data.get('is_published', False),
            categorie=data.get('department', ''),
            location=data.get('location', ''),
            schedule_label=data.get('schedule_label'),
            logo_url=data.get('logo_url'),
            date_debut=data.get('date_debut'),
            date_fin=data.get('date_fin'),
            latitude=data.get('latitude'),
            longitude=data.get('longitude'),
            statut='draft' if not data.get('is_published', False) else 'searching',
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
        
        # Mark this as a detail view so serializer includes candidates and comments
        offre._detail_view = True
        return Response(OffreSerializer(offre, context={'request': request}).data)

    def put(self, request, id):
        offre = self.get_offre(id)
        if not offre:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        if not hasattr(request.user, 'recruteur') or offre.recruteur != request.user.recruteur:
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        print("=" * 80)
        print(f"DEBUG PATCH /api/v1/jobs/{id} - request.data:")
        print(request.data)
        print("=" * 80)

        serializer = UpdateOffreSerializer(data=request.data, partial=True)
        if not serializer.is_valid():
            print("=" * 80)
            print(f"DEBUG PATCH /api/v1/jobs/{id} - serializer.errors:")
            print(serializer.errors)
            print("=" * 80)
        serializer.is_valid(raise_exception=True)
        
        # Map API field names to DB field names
        data = serializer.validated_data
        field_mapping = {
            'title': 'titre',
            'contract_type': 'type_contrat',
            'department': 'categorie',
            'salary': 'salaire',
            'status': 'statut',
        }
        
        for api_field, db_field in field_mapping.items():
            if api_field in data:
                setattr(offre, db_field, data[api_field])
        
        # Direct mappings (same name in API and DB)
        for field in ['description', 'candidate_count', 'is_published', 'location',
                      'schedule_label', 'logo_url', 'date_debut', 'date_fin',
                      'latitude', 'longitude']:
            if field in data:
                setattr(offre, field, data[field])
        
        # Auto-update statut when is_published changes
        if 'is_published' in data:
            if data['is_published']:
                offre.statut = 'searching'
            else:
                offre.statut = 'draft'
        
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
    GET /jobs/mine → recruiter sees only their own jobs (with filters + pagination)
    Query params: status, posted_within, department
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if not hasattr(request.user, 'recruteur'):
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        queryset = Offre.objects.filter(
            recruteur=request.user.recruteur
        ).annotate(
            nb_candidatures=Count('candidatures')
        ).order_by('-created_at')

        # DEBUG
        print("=" * 80)
        print(f"posted_within reçu: {request.query_params.get('posted_within')}")
        print(f"created_at des offres: {list(queryset.values_list('created_at', flat=True))}")
        print("=" * 80)

        # Filter by status (API values: draft, searching, closed)
        status_param = request.query_params.get('status')
        if status_param:
            # Map French UI labels to DB values if needed
            status_map = {
                'Brouillon': 'draft',
                'Publié': 'searching',
                'Terminé': 'closed',
            }
            db_status = status_map.get(status_param, status_param)
            queryset = queryset.filter(statut=db_status)

        # Filter by posted_within (3d, 7d, 30d, 90d, 180d)
        posted_within = request.query_params.get('posted_within')
        if posted_within:
            from datetime import timedelta
            days_map = {'3d': 3, '7d': 7, '30d': 30, '90d': 90, '180d': 180}
            days = days_map.get(posted_within)
            if days:
                cutoff = timezone.now() - timedelta(days=days)
                print("=" * 80)
                print(f"date seuil calculée: {cutoff}")
                print(f"après filtre: {queryset.filter(created_at__gte=cutoff).count()}")
                print("=" * 80)
                queryset = queryset.filter(created_at__gte=cutoff)

        # Filter by department
        department = request.query_params.get('department')
        if department:
            queryset = queryset.filter(categorie=department)

        # DEBUG
        print("=" * 80)
        print(f"nombre de résultats: {queryset.count()}")
        print("=" * 80)

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

        # Optional filter by status (API values: nouveau, examine, archive)
        status_param = request.query_params.get('status')
        if status_param:
            # Map API status to DB status
            # Note: The API spec uses nouveau/examine/archive which don't directly map
            # to candidature statut. This might need custom status field or logic.
            api_to_db = {
                'nouveau': 'en_attente',
                'examine': 'acceptee',
                'archive': 'refusee'
            }
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

        # Build response using CandidateListSerializer
        from apps.users.serializers_candidate import CandidateListSerializer
        
        results = []
        for candidature in candidatures:
            serializer = CandidateListSerializer(
                candidature.candidat,
                context={'candidature': candidature}
            )
            results.append(serializer.data)

        paginator = StandardPagination()
        page = paginator.paginate_queryset(results, request)
        return paginator.get_paginated_response(page if page is not None else results)

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
    Query params: status, job_id, max_duration, department
    
    POST /missions
    Creates a new mission (from accepted candidature)
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

        # Filter by status (API values: unconfirmed, in_progress, completed)
        status_param = request.query_params.get('status')
        if status_param:
            # Map API status to DB status
            status_map = {
                'unconfirmed': 'en_attente',
                'in_progress': 'en_cours',
                'completed': 'terminee',
                'cancelled': 'annulee',
                # Also support French UI labels
                'Non confirmée': 'en_attente',
                'En cours': 'en_cours',
                'Terminé': 'terminee',
            }
            db_status = status_map.get(status_param, status_param)
            queryset = queryset.filter(statut=db_status)

        # Filter by job_id
        job_id = request.query_params.get('job_id')
        if job_id:
            queryset = queryset.filter(candidature__offre_id=job_id)

        # Filter by max_duration (7d, 14d, 30d, 90d, 180d)
        max_duration = request.query_params.get('max_duration')
        if max_duration:
            from datetime import timedelta
            days_map = {'7d': 7, '14d': 14, '30d': 30, '90d': 90, '180d': 180}
            days = days_map.get(max_duration)
            if days:
                # Filter missions with duration <= days
                from django.db.models import F, ExpressionWrapper, fields
                from django.db.models.functions import Extract
                queryset = queryset.filter(
                    date_debut__isnull=False,
                    date_fin__isnull=False
                ).annotate(
                    duration_days=ExpressionWrapper(
                        Extract(F('date_fin') - F('date_debut'), 'epoch') / 86400,
                        output_field=fields.FloatField()
                    )
                ).filter(duration_days__lte=days)

        # Filter by department
        department = request.query_params.get('department')
        if department:
            queryset = queryset.filter(candidature__offre__categorie=department)

        queryset = queryset.select_related(
            'candidature__candidat', 'candidature__offre__recruteur'
        ).order_by('-id')

        paginator = StandardPagination()
        page = paginator.paginate_queryset(queryset, request)
        serializer = MissionSerializer(page, many=True, context={'request': request})
        return paginator.get_paginated_response(serializer.data)

    def post(self, request):
        """Create a mission from an accepted candidature."""
        if not hasattr(request.user, 'recruteur'):
            return Response(
                {'detail': 'Only recruiters can create missions.'},
                status=status.HTTP_403_FORBIDDEN
            )

        # Get required fields from request
        job_id = request.data.get('job_id')
        candidate_name = request.data.get('candidate_name')
        start_date = request.data.get('start_date')
        end_date = request.data.get('end_date')
        location = request.data.get('location', '')
        image_url = request.data.get('image_url')

        if not all([job_id, start_date, end_date]):
            return Response(
                {'detail': 'job_id, start_date, and end_date are required.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Find the candidature
        try:
            offre = Offre.objects.get(pk=job_id, recruteur=request.user.recruteur)
        except Offre.DoesNotExist:
            return Response({'detail': 'Job not found.'}, status=status.HTTP_404_NOT_FOUND)

        # Find accepted candidature for this job
        candidature = Candidature.objects.filter(
            offre=offre,
            statut='acceptee'
        ).first()

        if not candidature:
            return Response(
                {'detail': 'No accepted candidature found for this job.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Check if mission already exists
        if hasattr(candidature, 'mission'):
            return Response(
                {'detail': 'Mission already exists for this candidature.'},
                status=status.HTTP_409_CONFLICT
            )

        # Parse dates
        from django.utils.dateparse import parse_datetime
        parsed_start = parse_datetime(start_date)
        parsed_end = parse_datetime(end_date)

        # Create mission
        mission = Mission.objects.create(
            candidature=candidature,
            date_debut=parsed_start,
            date_fin=parsed_end,
            location=location,
            image_url=image_url,
            statut='en_attente'  # unconfirmed
        )

        return Response(
            MissionSerializer(mission, context={'request': request}).data,
            status=status.HTTP_201_CREATED
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


class MissionConfirmView(APIView):
    """PATCH /missions/{id}/confirm - Confirm unconfirmed mission"""
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
        
        if mission.statut != 'en_attente':
            return Response(
                {'detail': 'Mission is not in unconfirmed status.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Transition to in_progress
        mission.statut = 'en_cours'
        mission.save(update_fields=['statut'])
        
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
                'id': o.id,
                'title': o.titre,
                'company': o.recruteur.nom_structure if o.recruteur else None,
                'category': o.categorie,
                'distance': dist,
                'hours': None,
                'salary': o.salaire,
                'contract_type': o.type_contrat,
                'rating': o.recruteur.note_globale if o.recruteur else None,
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
    Query params: upcoming, status, scheduled_within, department
    POST /interviews → recruiter schedules an interview
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        queryset = Interview.objects.filter(
            Q(candidate=request.user) | Q(recruiter=request.user)
        ).select_related('candidate', 'recruiter', 'job').order_by('-scheduled_date')

        # Filter by upcoming
        upcoming = request.query_params.get('upcoming')
        if upcoming and upcoming.lower() == 'true':
            queryset = queryset.filter(
                scheduled_date__gte=timezone.now(),
                status='scheduled',
            )

        # Filter by status (API values: scheduled, completed, cancelled)
        status_param = request.query_params.get('status')
        if status_param:
            # Map French UI labels to DB values if needed
            status_map = {
                'Planifié': 'scheduled',
                'Terminé': 'completed',
                'Annulé': 'cancelled',
            }
            db_status = status_map.get(status_param, status_param)
            queryset = queryset.filter(status=db_status)

        # Filter by scheduled_within (today, this_week, this_month, next_month)
        scheduled_within = request.query_params.get('scheduled_within')
        if scheduled_within:
            from datetime import timedelta
            now = timezone.now()
            
            if scheduled_within == 'today':
                start = now.replace(hour=0, minute=0, second=0, microsecond=0)
                end = start + timedelta(days=1)
                queryset = queryset.filter(scheduled_date__gte=start, scheduled_date__lt=end)
            elif scheduled_within == 'this_week':
                # Current week (Monday to Sunday)
                start = now - timedelta(days=now.weekday())
                start = start.replace(hour=0, minute=0, second=0, microsecond=0)
                end = start + timedelta(days=7)
                queryset = queryset.filter(scheduled_date__gte=start, scheduled_date__lt=end)
            elif scheduled_within == 'this_month':
                start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
                # Next month
                if now.month == 12:
                    end = start.replace(year=now.year + 1, month=1)
                else:
                    end = start.replace(month=now.month + 1)
                queryset = queryset.filter(scheduled_date__gte=start, scheduled_date__lt=end)
            elif scheduled_within == 'next_month':
                # Start of next month
                if now.month == 12:
                    start = now.replace(year=now.year + 1, month=1, day=1, hour=0, minute=0, second=0, microsecond=0)
                    end = start.replace(month=2)
                else:
                    start = now.replace(month=now.month + 1, day=1, hour=0, minute=0, second=0, microsecond=0)
                    if start.month == 12:
                        end = start.replace(year=start.year + 1, month=1)
                    else:
                        end = start.replace(month=start.month + 1)
                queryset = queryset.filter(scheduled_date__gte=start, scheduled_date__lt=end)

        # Filter by department
        department = request.query_params.get('department')
        if department:
            queryset = queryset.filter(job__categorie=department)

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
            job = Offre.objects.get(pk=job_id, recruteur=request.user.recruteur)
        except Offre.DoesNotExist:
            return Response({'detail': 'Job not found.'}, status=status.HTTP_404_NOT_FOUND)

        # Parse scheduled_date
        from django.utils.dateparse import parse_datetime
        parsed_date = parse_datetime(scheduled_date)
        if not parsed_date:
            return Response(
                {'detail': 'Invalid scheduled_date format. Use ISO8601.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Find candidature to link interview
        candidature = Candidature.objects.filter(
            candidat=candidate.candidat if hasattr(candidate, 'candidat') else None,
            offre=job
        ).first()

        interview = Interview.objects.create(
            candidate=candidate,
            recruiter=request.user,
            job=job,
            candidature=candidature,
            scheduled_date=parsed_date,
            notes=notes,
            status='scheduled'
        )

        return Response(
            InterviewSerializer(interview).data,
            status=status.HTTP_201_CREATED
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
# Stub for not-yet-implemented endpoints
# ===========================================================================

class StubView(APIView):
    """Temporary stub — returns 501 for every HTTP method."""
    permission_classes = [IsAuthenticated]

    def handle(self, request, *args, **kwargs):
        return Response({'detail': 'not implemented'}, status=501)

    get = post = put = patch = delete = handle

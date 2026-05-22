from rest_framework import serializers
from apps.jobs.models.offre import Offre
from apps.jobs.models.mission import Mission
from apps.jobs.models.saved_job import SavedJob
from apps.jobs.models.alerte import Alerte
from apps.jobs.models.interview import Interview


# ---------------------------------------------------------------------------
# Offre serializers
# ---------------------------------------------------------------------------


class OffreSerializer(serializers.ModelSerializer):
    """
    Read serializer for list / detail — maps to the API-spec OffreResponse.
    Flutter JobModel.fromJson expects snake_case field names.
    """
    id = serializers.SerializerMethodField()
    title = serializers.CharField(source='titre', read_only=True)
    company_name = serializers.SerializerMethodField()
    recruiter_id = serializers.SerializerMethodField()
    recruiter_name = serializers.SerializerMethodField()
    recruiter_role = serializers.SerializerMethodField()
    recruiter_avatar_asset = serializers.SerializerMethodField()
    department = serializers.SerializerMethodField()
    contract_type = serializers.CharField(source='type_contrat', read_only=True)
    posted_at = serializers.SerializerMethodField()
    status = serializers.CharField(source='statut', read_only=True)
    logo_asset = serializers.SerializerMethodField()
    location = serializers.SerializerMethodField()
    schedule_label = serializers.SerializerMethodField()
    salary = serializers.FloatField(source='salaire', read_only=True)
    candidates = serializers.SerializerMethodField()
    comments = serializers.SerializerMethodField()

    class Meta:
        model  = Offre
        fields = [
            'id', 'title', 'company_name', 'recruiter_id', 'recruiter_name',
            'recruiter_role', 'recruiter_avatar_asset', 'department',
            'contract_type', 'posted_at', 'status', 'candidate_count',
            'view_count', 'logo_asset', 'is_published', 'salary',
            'location', 'schedule_label', 'candidates', 'comments',
        ]

    def get_id(self, obj):
        return str(obj.id)

    def get_posted_at(self, obj):
        # Use created_at if available, otherwise fall back to date_debut
        if obj.created_at:
            return obj.created_at.isoformat()
        if obj.date_debut:
            return f"{obj.date_debut.isoformat()}T00:00:00"
        return None

    def get_company_name(self, obj):
        return getattr(obj.recruteur, 'nom_structure', None) or ''

    def get_logo_asset(self, obj):
        return getattr(obj.recruteur, 'logo_url', None)

    def get_recruiter_id(self, obj):
        return str(obj.recruteur_id)

    def get_recruiter_name(self, obj):
        r = obj.recruteur
        return f"{r.prenom} {r.nom}" if r else ''

    def get_recruiter_role(self, obj):
        return getattr(obj.recruteur, 'titre_poste', '') or ''

    def get_recruiter_avatar_asset(self, obj):
        return getattr(obj.recruteur, 'avatar_url', None)

    def get_department(self, obj):
        return obj.categorie or None

    def get_location(self, obj):
        # Return the location field (city name) if available
        # Only use lat/long as fallback if location is empty
        location = getattr(obj, 'location', None)
        if location:
            return location
        # Fallback to coordinates if no location text
        if obj.latitude is not None and obj.longitude is not None:
            return f"{obj.latitude}, {obj.longitude}"
        return None

    def get_schedule_label(self, obj):
        return getattr(obj, 'schedule_label', None) or obj.type_contrat or None

    def get_candidates(self, obj):
        """
        Flutter JobCandidateModel.fromJson expects:
          initials, name, role, rating (double), avatar_url (String?)
        Only included in detail view (GET /jobs/:id)
        """
        if not hasattr(obj, 'candidatures'):
            return None

        result = []
        for candidature in obj.candidatures.select_related('candidat').all():
            c = candidature.candidat
            full_name = f"{c.prenom} {c.nom}"
            initials = ''.join(p[0].upper() for p in full_name.split() if p)[:2]
            result.append({
                'initials': initials or '??',
                'name': full_name,
                'role': getattr(c, 'titre_poste', None) or 'candidat',
                'rating': float(c.note_globale) if c.note_globale is not None else 0.0,
                'avatar_url': getattr(c, 'avatar_url', None),
            })
        return result

    def get_comments(self, obj):
        """
        API spec expects: initials, author_name, date, question,
        recruitor_label, recruitor_date, reply (snake_case)
        """
        from apps.jobs.models.job_comment import JobComment

        # Only included in detail view
        if not hasattr(obj, '_detail_view'):
            return None

        comments = JobComment.objects.filter(offre=obj).select_related('auteur').order_by('-date_question')
        result = []
        for comment in comments:
            author = comment.auteur
            full_name = f"{author.prenom} {author.nom}"
            initials = ''.join(p[0].upper() for p in full_name.split() if p)[:2]

            date_str = comment.date_question.strftime('%d %b.')
            recruitor_date = ''
            if comment.date_reponse:
                from django.utils import timezone
                delta = timezone.now() - comment.date_reponse
                if delta.days == 0:
                    if delta.seconds < 3600:
                        recruitor_date = f"Il y a {delta.seconds // 60} min"
                    else:
                        recruitor_date = f"Il y a {delta.seconds // 3600}h"
                else:
                    recruitor_date = comment.date_reponse.strftime('%d %b.')

            result.append({
                'id': comment.id,
                'initials': initials or '??',
                'author_name': full_name,
                'date': date_str,
                'question': comment.question,
                'recruitor_label': 'Recruteur',
                'recruitor_date': recruitor_date,
                'reply': comment.reponse or '',
            })
        return result


class CreateOffreSerializer(serializers.Serializer):
    """
    Write serializer — accepts API-spec field names (snake_case English).
    Maps to Offre model field names internally.
    """
    title         = serializers.CharField(max_length=200)
    description   = serializers.CharField()
    category      = serializers.CharField(max_length=100, required=False, default='')
    contract_type = serializers.CharField(max_length=50)
    start_date    = serializers.DateField(required=False, allow_null=True)
    end_date      = serializers.DateField(required=False, allow_null=True)
    salary        = serializers.FloatField(required=False, allow_null=True)
    candidate_count = serializers.IntegerField(default=1)
    is_published  = serializers.BooleanField(default=False)
    location      = serializers.CharField(max_length=200, required=False, allow_blank=True)
    schedule_label = serializers.CharField(max_length=50, required=False, allow_blank=True, allow_null=True)
    logo_url      = serializers.CharField(max_length=500, required=False, allow_blank=True, allow_null=True)
    latitude      = serializers.FloatField(required=False, allow_null=True)
    longitude     = serializers.FloatField(required=False, allow_null=True)

    # Ignore these fields if they arrive from the frontend (mocked data)
    company_name          = serializers.CharField(required=False, allow_blank=True)
    recruiter_id          = serializers.CharField(required=False, allow_blank=True)
    recruiter_name        = serializers.CharField(required=False, allow_blank=True)
    recruiter_role        = serializers.CharField(required=False, allow_blank=True)
    recruiter_avatar_asset = serializers.CharField(required=False, allow_blank=True, allow_null=True)
    posted_at             = serializers.DateTimeField(required=False, allow_null=True)
    status                = serializers.CharField(required=False, allow_blank=True)
    view_count            = serializers.IntegerField(required=False)
    candidates            = serializers.ListField(required=False)
    comments              = serializers.ListField(required=False)

    def to_model_data(self):
        """Return a dict with Offre model field names."""
        data = self.validated_data
        return {
            'titre':        data['title'],
            'description':  data['description'],
            'categorie':    data.get('category', ''),
            'type_contrat': data['contract_type'],
            'date_debut':   data.get('start_date'),
            'date_fin':     data.get('end_date'),
            'salaire':      data.get('salary'),
            'latitude':     data.get('latitude'),
            'longitude':    data.get('longitude'),
        }


OFFRE_STATUT_CHOICES = ["searching", "draft", "closed"]

class UpdateOffreSerializer(serializers.Serializer):
    """
    Write serializer — accepts API-spec field names for PATCH /jobs/:id.
    Also accepts legacy French field names for backward compat.
    """
    title         = serializers.CharField(max_length=200, required=False)
    description   = serializers.CharField(required=False, allow_null=True, allow_blank=True)
    category      = serializers.CharField(max_length=100, required=False)
    contract_type = serializers.CharField(max_length=50, required=False)
    start_date    = serializers.DateField(required=False, allow_null=True)
    end_date      = serializers.DateField(required=False, allow_null=True)
    salary        = serializers.FloatField(required=False, allow_null=True)
    candidate_count = serializers.IntegerField(required=False)
    is_published  = serializers.BooleanField(required=False)
    location      = serializers.CharField(max_length=200, required=False, allow_blank=True)
    schedule_label = serializers.CharField(max_length=50, required=False, allow_blank=True, allow_null=True)
    logo_url      = serializers.CharField(max_length=500, required=False, allow_blank=True, allow_null=True)
    latitude      = serializers.FloatField(required=False, allow_null=True)
    longitude     = serializers.FloatField(required=False, allow_null=True)
    status        = serializers.ChoiceField(choices=OFFRE_STATUT_CHOICES, required=False)

    def to_model_data(self):
        """Return a dict with Offre model field names."""
        data = self.validated_data
        mapping = {
            'title': 'titre', 'category': 'categorie',
            'contract_type': 'type_contrat', 'start_date': 'date_debut',
            'end_date': 'date_fin', 'salary': 'salaire', 'status': 'statut',
        }
        result = {}
        for spec_key, model_key in mapping.items():
            if spec_key in data:
                result[model_key] = data[spec_key]
        for pass_through in ('description', 'latitude', 'longitude'):
            if pass_through in data:
                result[pass_through] = data[pass_through]
        return result


# ---------------------------------------------------------------------------
# Mission serializers
# ---------------------------------------------------------------------------

class MissionSerializer(serializers.ModelSerializer):
    """
    Read serializer — maps to the API-spec MissionResponse.
    API spec expects snake_case field names with specific mappings.
    """
    id = serializers.SerializerMethodField()
    job_id = serializers.SerializerMethodField()
    job_title = serializers.SerializerMethodField()
    company_name = serializers.SerializerMethodField()
    department = serializers.SerializerMethodField()
    start_date = serializers.SerializerMethodField()
    end_date = serializers.SerializerMethodField()
    location = serializers.CharField(read_only=True, allow_blank=True)
    status = serializers.SerializerMethodField()
    recruiter_name = serializers.SerializerMethodField()
    candidate_name = serializers.SerializerMethodField()
    candidate_rating = serializers.SerializerMethodField()
    recruiter_rating = serializers.SerializerMethodField()
    candidate_feedback = serializers.SerializerMethodField()
    recruiter_feedback = serializers.SerializerMethodField()
    summary = serializers.CharField(read_only=True, allow_null=True)
    image_url = serializers.CharField(read_only=True, allow_null=True)
    team = serializers.SerializerMethodField()

    class Meta:
        model  = Mission
        fields = [
            'id', 'job_id', 'job_title', 'company_name', 'department',
            'start_date', 'end_date', 'location', 'recruiter_name',
            'candidate_name', 'candidate_rating', 'recruiter_rating',
            'candidate_feedback', 'recruiter_feedback', 'status',
            'summary', 'image_url', 'team',
        ]

    # Status mapping: DB -> API
    _STATUS_MAP = {
        'en_attente': 'unconfirmed',
        'en_cours':   'in_progress',
        'terminee':   'completed',
        'annulee':    'cancelled',
    }

    def get_id(self, obj):
        return str(obj.id)

    def get_job_id(self, obj):
        return str(obj.candidature.offre.id)

    def get_status(self, obj):
        return self._STATUS_MAP.get(obj.statut, obj.statut)

    def get_job_title(self, obj):
        return obj.candidature.offre.titre

    def get_company_name(self, obj):
        return obj.candidature.offre.recruteur.nom_structure or ''

    def get_department(self, obj):
        return obj.candidature.offre.categorie

    def get_start_date(self, obj):
        return obj.date_debut.isoformat() if obj.date_debut else None

    def get_end_date(self, obj):
        return obj.date_fin.isoformat() if obj.date_fin else None

    def get_recruiter_name(self, obj):
        r = obj.candidature.offre.recruteur
        return f"{r.prenom} {r.nom}"

    def get_candidate_name(self, obj):
        c = obj.candidature.candidat
        return f"{c.prenom} {c.nom}"

    def get_candidate_rating(self, obj):
        """Rating given BY the candidate TO the recruiter for this mission."""
        from apps.reviews.models import Evaluation
        recruteur = obj.candidature.offre.recruteur
        ev = Evaluation.objects.filter(mission=obj, evalue=recruteur).first()
        return float(ev.note) if ev else 0.0

    def get_recruiter_rating(self, obj):
        """Rating given BY the recruiter TO the candidate for this mission."""
        from apps.reviews.models import Evaluation
        candidat = obj.candidature.candidat
        ev = Evaluation.objects.filter(mission=obj, evalue=candidat).first()
        return float(ev.note) if ev else 0.0

    def get_candidate_feedback(self, obj):
        """Feedback left BY the candidate."""
        from apps.reviews.models import Evaluation
        candidat = obj.candidature.candidat
        ev = Evaluation.objects.filter(mission=obj, evaluateur=candidat).first()
        return (ev.commentaire or '') if ev else ''

    def get_recruiter_feedback(self, obj):
        """Feedback left BY the recruiter."""
        from apps.reviews.models import Evaluation
        recruteur = obj.candidature.offre.recruteur
        ev = Evaluation.objects.filter(mission=obj, evaluateur=recruteur).first()
        return (ev.commentaire or '') if ev else ''

    def get_team(self, obj):
        """
        API spec expects: name, role, rating, avatar_url (snake_case)
        Returns team members from MissionTeamMember model.
        """
        from apps.jobs.models import MissionTeamMember
        return [
            {
                'name': m.name,
                'role': m.role,
                'rating': float(m.rating),
                'avatar_url': m.avatar_url,
            }
            for m in MissionTeamMember.objects.filter(mission=obj)
        ]


# ---------------------------------------------------------------------------
# Interview serializer
# ---------------------------------------------------------------------------

class InterviewSerializer(serializers.ModelSerializer):
    """
    Read serializer — maps to the API-spec InterviewResponse.
    API spec expects snake_case field names.
    """
    id = serializers.SerializerMethodField()
    candidate_id = serializers.SerializerMethodField()
    candidate_name = serializers.SerializerMethodField()
    candidate_avatar = serializers.SerializerMethodField()
    job_id = serializers.SerializerMethodField()
    job_title = serializers.CharField(source='job.titre', read_only=True)
    department = serializers.SerializerMethodField()
    scheduled_date = serializers.DateTimeField(read_only=True)
    status = serializers.CharField(read_only=True)
    notes = serializers.CharField(read_only=True, allow_null=True)

    class Meta:
        model = Interview
        fields = [
            'id', 'candidate_id', 'candidate_name', 'candidate_avatar',
            'job_id', 'job_title', 'department', 'scheduled_date',
            'status', 'notes',
        ]

    def get_id(self, obj):
        return str(obj.id)

    def get_candidate_id(self, obj):
        return str(obj.candidate_id)  # avoids extra DB hit

    def get_job_id(self, obj):
        return str(obj.job_id)        # avoids extra DB hit

    def get_candidate_name(self, obj):
        return f"{obj.candidate.prenom} {obj.candidate.nom}"

    def get_candidate_avatar(self, obj):
        return getattr(obj.candidate, 'avatar_url', None)

    def get_department(self, obj):
        return obj.job.categorie if obj.job else None


# ---------------------------------------------------------------------------
# SavedJob serializers
# ---------------------------------------------------------------------------

class SavedJobSerializer(serializers.ModelSerializer):
    offre = OffreSerializer(read_only=True)

    class Meta:
        model  = SavedJob
        fields = ['id', 'offre', 'saved_at']


class CreateSavedJobSerializer(serializers.Serializer):
    offre_id = serializers.IntegerField()


# ---------------------------------------------------------------------------
# Alerte serializers
# ---------------------------------------------------------------------------

class AlerteSerializer(serializers.ModelSerializer):
    class Meta:
        model  = Alerte
        fields = [
            'id', 'titre', 'categorie', 'type_contrat',
            'salaire_min', 'localisation', 'actif', 'cree_le',
        ]
        read_only_fields = ['id', 'cree_le']


class CreateAlerteSerializer(serializers.Serializer):
    titre        = serializers.CharField(max_length=200, required=False, allow_blank=True)
    categorie    = serializers.CharField(max_length=100, required=False, allow_blank=True)
    type_contrat = serializers.CharField(max_length=50,  required=False, allow_blank=True)
    salaire_min  = serializers.FloatField(required=False, allow_null=True)
    localisation = serializers.CharField(max_length=200, required=False, allow_blank=True)
    actif        = serializers.BooleanField(required=False, default=True)


class UpdateAlerteSerializer(serializers.Serializer):
    titre        = serializers.CharField(max_length=200, required=False, allow_blank=True)
    categorie    = serializers.CharField(max_length=100, required=False, allow_blank=True)
    type_contrat = serializers.CharField(max_length=50,  required=False, allow_blank=True)
    salaire_min  = serializers.FloatField(required=False, allow_null=True)
    localisation = serializers.CharField(max_length=200, required=False, allow_blank=True)
    actif        = serializers.BooleanField(required=False)
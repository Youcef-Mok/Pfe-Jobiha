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
    description = serializers.CharField(read_only=True)
    company_name = serializers.SerializerMethodField()
    contract_type = serializers.CharField(source='type_contrat', read_only=True)
    posted_at = serializers.SerializerMethodField()
    status = serializers.CharField(source='statut', read_only=True)
    logo_asset = serializers.SerializerMethodField()
    recruiter_id = serializers.SerializerMethodField()
    recruiter_name = serializers.SerializerMethodField()
    recruiter_avatar_asset = serializers.SerializerMethodField()
    department = serializers.SerializerMethodField()
    city = serializers.SerializerMethodField()
    location = serializers.SerializerMethodField()
    schedule_label = serializers.SerializerMethodField()
    latitude = serializers.FloatField(read_only=True)
    longitude = serializers.FloatField(read_only=True)
    salary = serializers.FloatField(source='salaire', read_only=True)
    candidates = serializers.SerializerMethodField()
    comments = serializers.SerializerMethodField()

    class Meta:
        model  = Offre
        fields = [
            'id', 'title', 'description', 'company_name', 'contract_type', 'posted_at',
            'status', 'candidate_count', 'view_count', 'logo_asset',
            'is_published', 'salary',
            'recruiter_id', 'recruiter_name', 'recruiter_avatar_asset',
            'department', 'city', 'location', 'schedule_label', 'latitude', 'longitude',
            'candidates', 'comments',
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
        return getattr(obj, 'image_url', None) or getattr(obj.recruteur, 'logo_url', None)

    def get_recruiter_id(self, obj):
        return str(obj.recruteur_id)

    def get_recruiter_name(self, obj):
        r = obj.recruteur
        return f"{r.prenom} {r.nom}" if r else ''

    def get_recruiter_avatar_asset(self, obj):
        return getattr(obj.recruteur, 'avatar_url', None)

    def get_department(self, obj):
        # categorie maps to department in the spec
        return obj.categorie or None

    def get_location(self, obj):
        return getattr(obj, 'location', None)

    def get_city(self, obj):
        loc = (getattr(obj, 'location', None) or '').strip()
        if not loc:
            return None
        return loc.split(',')[0].strip()

    def get_schedule_label(self, obj):
        return getattr(obj, 'schedule_label', None) or obj.type_contrat or None

    def get_candidates(self, obj):
        """
        Flutter JobCandidateModel.fromJson expects:
          initials, name, role, rating (double), avatar_url (String?)
        """
        result = []
        for candidature in obj.candidatures.select_related('candidat').all():
            c = candidature.candidat
            full_name = f"{c.prenom} {c.nom}"
            initials = ''.join(p[0].upper() for p in full_name.split() if p)[:2]
            result.append({
                'initials': initials or '?',
                'name': full_name,
                'role': getattr(c, 'titre_poste', None) or 'candidat',
                'rating': float(c.note_globale) if c.note_globale is not None else 0.0,
                'avatar_url': getattr(c, 'avatar_url', None),
            })
        return result

    def get_comments(self, obj):
        from apps.jobs.models.job_comment import JobComment
        comments = JobComment.objects.filter(offre=obj).select_related('auteur')
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
        return result


class CreateOffreSerializer(serializers.Serializer):
    """
    Write serializer — accepts API-spec field names (snake_case English).
    Maps to Offre model field names internally.
    """
    title        = serializers.CharField(max_length=200)
    description  = serializers.CharField()
    category     = serializers.CharField(max_length=100, required=False, default='')
    contract_type = serializers.CharField(max_length=50)
    start_date   = serializers.DateField(required=False)
    end_date     = serializers.DateField(required=False, allow_null=True)
    salary       = serializers.FloatField(required=False, allow_null=True)
    latitude     = serializers.FloatField(required=False, allow_null=True)
    longitude    = serializers.FloatField(required=False, allow_null=True)

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
    title        = serializers.CharField(max_length=200, required=False)
    description  = serializers.CharField(required=False)
    category     = serializers.CharField(max_length=100, required=False)
    contract_type = serializers.CharField(max_length=50, required=False)
    start_date   = serializers.DateField(required=False)
    end_date     = serializers.DateField(required=False, allow_null=True)
    salary       = serializers.FloatField(required=False, allow_null=True)
    latitude     = serializers.FloatField(required=False, allow_null=True)
    longitude    = serializers.FloatField(required=False, allow_null=True)
    status       = serializers.ChoiceField(choices=OFFRE_STATUT_CHOICES, required=False)

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
    Flutter MissionModel.fromJson expects:
      id (String), job_title (String), company_name (String),
      start_date (String, required), end_date (String, required),
      location (String), recruiter_name (String), candidate_name (String),
      candidate_rating (num → double, required), recruiter_rating (num → double, required),
      candidate_feedback (String, required), recruiter_feedback (String, required),
      status (String), summary (String?), image_url (String?), team (List?)
    """
    id = serializers.SerializerMethodField()
    job_title = serializers.SerializerMethodField()
    company_name = serializers.SerializerMethodField()
    start_date = serializers.SerializerMethodField()
    end_date = serializers.SerializerMethodField()
    status = serializers.SerializerMethodField()
    recruiter_name = serializers.SerializerMethodField()
    candidate_name = serializers.SerializerMethodField()
    candidate_rating = serializers.SerializerMethodField()
    recruiter_rating = serializers.SerializerMethodField()
    candidate_feedback = serializers.SerializerMethodField()
    recruiter_feedback = serializers.SerializerMethodField()
    description = serializers.SerializerMethodField()
    summary = serializers.SerializerMethodField()
    team = serializers.SerializerMethodField()

    job_id = serializers.SerializerMethodField()
    recruiter_id = serializers.SerializerMethodField()
    candidate_id = serializers.SerializerMethodField()

    class Meta:
        model  = Mission
        fields = [
            'id', 'job_id', 'recruiter_id', 'candidate_id',
            'job_title', 'company_name', 'start_date', 'end_date',
            'location', 'recruiter_name', 'candidate_name',
            'candidate_rating', 'recruiter_rating',
            'candidate_feedback', 'recruiter_feedback',
            'status', 'description', 'summary', 'image_url', 'team',
        ]

    def get_job_id(self, obj):
        return str(obj.candidature.offre.id)

    def get_recruiter_id(self, obj):
        return str(obj.candidature.offre.recruteur.id)

    def get_candidate_id(self, obj):
        return str(obj.candidature.candidat.id)

    _STATUS_MAP = {
        'en_attente': 'unconfirmed',
        'en_cours': 'in_progress',
        'terminee': 'completed',
    }

    def get_id(self, obj):
        return str(obj.id)

    def get_status(self, obj):
        return self._STATUS_MAP.get(obj.statut, obj.statut)

    def get_job_title(self, obj):
        return obj.candidature.offre.titre

    def get_company_name(self, obj):
        return obj.candidature.offre.recruteur.nom_structure or ''

    def get_start_date(self, obj):
        # Flutter: json['start_date'] as String (required — no null)
        if obj.date_debut:
            return obj.date_debut.isoformat()
        # Fall back to ISO placeholder so Flutter can DateTime.parse() without crashing
        return '1970-01-01T00:00:00'

    def get_end_date(self, obj):
        # Flutter: json['end_date'] as String (required — no null)
        if obj.date_fin:
            return obj.date_fin.isoformat()
        return '1970-01-01T00:00:00'

    def get_recruiter_name(self, obj):
        r = obj.candidature.offre.recruteur
        return f"{r.prenom} {r.nom}"

    def get_candidate_name(self, obj):
        c = obj.candidature.candidat
        return f"{c.prenom} {c.nom}"

    def get_candidate_rating(self, obj):
        """Rating given to the candidate for this mission.
        Flutter casts as (num).toDouble() — must not be null.
        """
        candidat = obj.candidature.candidat
        ev = obj.evaluations.filter(evalue=candidat).first()
        return float(ev.note) if ev else 0.0

    def get_recruiter_rating(self, obj):
        """Rating given to the recruiter for this mission.
        Flutter casts as (num).toDouble() — must not be null.
        """
        recruteur = obj.candidature.offre.recruteur
        return float(recruteur.note_globale) if recruteur.note_globale is not None else 0.0

    def get_candidate_feedback(self, obj):
        """Textual feedback left by the candidate.
        Flutter: json['candidate_feedback'] as String (required).
        Pull from the evaluation comment if available, else empty string.
        """
        candidat = obj.candidature.candidat
        ev = obj.evaluations.filter(evalue=candidat).first()
        return (ev.commentaire or '') if ev else ''

    def get_recruiter_feedback(self, obj):
        """Textual feedback left by the recruiter.
        Flutter: json['recruiter_feedback'] as String (required).
        """
        recruteur = obj.candidature.offre.recruteur
        ev = obj.evaluations.filter(evalue=recruteur).first()
        return (ev.commentaire or '') if ev else ''

    def get_summary(self, obj):
        return getattr(obj, 'summary', None)

    def get_description(self, obj):
        return getattr(obj.candidature.offre, 'description', '') or ''

    def get_team(self, obj):
        """
        Flutter MissionMemberModel.fromJson expects:
          name (String), role (String), rating (num → double), avatar_url (String?)
        Build from other candidatures on the same offre (i.e. team members).
        Returns [] if no team data — Flutter defaults to empty list.
        """
        result = []
        for cand in obj.candidature.offre.candidatures.select_related('candidat').exclude(
            pk=obj.candidature.pk
        ):
            c = cand.candidat
            result.append({
                'name': f"{c.prenom} {c.nom}",
                'role': 'candidat',
                'rating': float(c.note_globale) if c.note_globale is not None else 0.0,
                'avatar_url': None,
            })
        return result


# ---------------------------------------------------------------------------
# Interview serializer
# ---------------------------------------------------------------------------

class InterviewSerializer(serializers.ModelSerializer):
    """
    Read serializer — maps to the API-spec InterviewResponse.
    """
    id = serializers.SerializerMethodField()
    candidate_id = serializers.SerializerMethodField()
    candidate_name = serializers.SerializerMethodField()
    candidate_avatar = serializers.SerializerMethodField()
    job_id = serializers.SerializerMethodField()
    job_title = serializers.CharField(source='job.titre', read_only=True)
    department = serializers.SerializerMethodField()

    class Meta:
        model = Interview
        fields = [
            'id', 'candidate_id', 'candidate_name', 'candidate_avatar',
            'job_id', 'job_title', 'department', 'scheduled_date', 'status', 'notes',
        ]

    def get_id(self, obj):
        return str(obj.id)

    def get_candidate_id(self, obj):
        return str(obj.candidate_id)

    def get_job_id(self, obj):
        return str(obj.job_id)

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

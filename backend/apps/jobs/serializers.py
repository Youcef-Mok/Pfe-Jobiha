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
    Flutter JobModel.fromJson expects:
      id (String), title (String), company_name (String), contract_type (String?),
      posted_at (String), status (String), candidate_count (int?), view_count (int?),
      logo_asset (String?), is_published (bool?), candidates (List?), comments (List?)
    """
    id = serializers.SerializerMethodField()
    title = serializers.CharField(source='titre', read_only=True)
    company_name = serializers.SerializerMethodField()
    contract_type = serializers.CharField(source='type_contrat', read_only=True)
    posted_at = serializers.DateField(source='date_debut', read_only=True)
    status = serializers.CharField(source='statut', read_only=True)
    logo_asset = serializers.SerializerMethodField()
    candidates = serializers.SerializerMethodField()
    comments = serializers.SerializerMethodField()

    class Meta:
        model  = Offre
        fields = [
            'id', 'title', 'company_name', 'contract_type', 'posted_at',
            'status', 'candidate_count', 'view_count', 'logo_asset',
            'is_published', 'candidates', 'comments',
        ]

    def get_id(self, obj):
        # Flutter: json['id'] as String
        return str(obj.id)

    def get_company_name(self, obj):
        # Flutter: json['company_name'] as String (required — must not be null)
        return getattr(obj.recruteur, 'nom_structure', None) or ''

    def get_logo_asset(self, obj):
        # Placeholder — no logo field on model yet.
        return None

    def get_candidates(self, obj):
        """
        Flutter JobCandidateModel.fromJson expects:
          initials (String), name (String), role (String),
          rating (num → double), avatarUrl (String?)
        Build from accepted candidatures.
        """
        result = []
        for candidature in obj.candidatures.select_related('candidat').all():
            c = candidature.candidat
            full_name = f"{c.prenom} {c.nom}"
            initials = ''.join(p[0].upper() for p in full_name.split() if p)[:2]
            result.append({
                'initials': initials or '?',
                'name': full_name,
                'role': 'candidat',
                'rating': float(c.note_globale) if c.note_globale is not None else 0.0,
                'avatarUrl': None,
            })
        return result

    def get_comments(self, obj):
        # No comment model exists yet — return empty list as Flutter expects List?
        return []


class CreateOffreSerializer(serializers.Serializer):
    titre        = serializers.CharField(max_length=200)
    description  = serializers.CharField()
    categorie    = serializers.CharField(max_length=100)
    date_debut   = serializers.DateField()
    date_fin     = serializers.DateField(required=False, allow_null=True)
    salaire      = serializers.FloatField(required=False, allow_null=True)
    type_contrat = serializers.CharField(max_length=50)
    latitude     = serializers.FloatField(required=False, allow_null=True)
    longitude    = serializers.FloatField(required=False, allow_null=True)


OFFRE_STATUT_CHOICES = ["searching", "draft", "closed"]

class UpdateOffreSerializer(serializers.Serializer):
    titre        = serializers.CharField(max_length=200, required=False)
    description  = serializers.CharField(required=False)
    categorie    = serializers.CharField(max_length=100, required=False)
    date_debut   = serializers.DateField(required=False)
    date_fin     = serializers.DateField(required=False, allow_null=True)
    salaire      = serializers.FloatField(required=False, allow_null=True)
    type_contrat = serializers.CharField(max_length=50, required=False)
    latitude     = serializers.FloatField(required=False, allow_null=True)
    longitude    = serializers.FloatField(required=False, allow_null=True)
    # Added — allows the recruiter to change offer status via PATCH (spec requirement).
    statut       = serializers.ChoiceField(
        choices=OFFRE_STATUT_CHOICES, required=False
    )


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
    status = serializers.CharField(source='statut', read_only=True)
    recruiter_name = serializers.SerializerMethodField()
    candidate_name = serializers.SerializerMethodField()
    candidate_rating = serializers.SerializerMethodField()
    recruiter_rating = serializers.SerializerMethodField()
    candidate_feedback = serializers.SerializerMethodField()
    recruiter_feedback = serializers.SerializerMethodField()
    summary = serializers.SerializerMethodField()
    team = serializers.SerializerMethodField()

    class Meta:
        model  = Mission
        fields = [
            'id', 'job_title', 'company_name', 'start_date', 'end_date',
            'location', 'recruiter_name', 'candidate_name',
            'candidate_rating', 'recruiter_rating',
            'candidate_feedback', 'recruiter_feedback',
            'status', 'summary', 'image_url', 'team',
        ]

    def get_id(self, obj):
        # Flutter: json['id'] as String
        return str(obj.id)

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
        ev = obj.evaluations.filter(evalue=recruteur).first()
        return float(ev.note) if ev else 0.0

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
        # Flutter: json['summary'] as String? — nullable OK
        return None

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
    candidate_id = serializers.IntegerField(source='candidate.id', read_only=True)
    candidate_name = serializers.SerializerMethodField()
    candidate_avatar = serializers.SerializerMethodField()
    job_id = serializers.IntegerField(source='job.id', read_only=True)
    job_title = serializers.CharField(source='job.titre', read_only=True)

    class Meta:
        model = Interview
        fields = [
            'id', 'candidate_id', 'candidate_name', 'candidate_avatar',
            'job_id', 'job_title', 'scheduled_date', 'status', 'notes',
        ]

    def get_candidate_name(self, obj):
        return f"{obj.candidate.prenom} {obj.candidate.nom}"

    def get_candidate_avatar(self, obj):
        # No avatar field on model yet.
        return None


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
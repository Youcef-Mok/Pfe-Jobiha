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
    """
    title = serializers.CharField(source='titre', read_only=True)
    company_name = serializers.SerializerMethodField()
    contract_type = serializers.CharField(source='type_contrat', read_only=True)
    posted_at = serializers.DateField(source='date_debut', read_only=True)
    status = serializers.CharField(source='statut', read_only=True)
    logo_asset = serializers.SerializerMethodField()

    class Meta:
        model  = Offre
        fields = [
            'id', 'title', 'company_name', 'contract_type', 'posted_at',
            'status', 'candidate_count', 'view_count', 'logo_asset',
            'is_published',
        ]

    def get_company_name(self, obj):
        return getattr(obj.recruteur, 'nom_structure', None)

    def get_logo_asset(self, obj):
        # Placeholder — no logo field on model yet.
        return None


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
    """
    job_title = serializers.SerializerMethodField()
    company_name = serializers.SerializerMethodField()
    start_date = serializers.DateTimeField(source='date_debut', read_only=True)
    end_date = serializers.DateTimeField(source='date_fin', read_only=True)
    status = serializers.CharField(source='statut', read_only=True)
    recruiter_name = serializers.SerializerMethodField()
    candidate_name = serializers.SerializerMethodField()
    candidate_rating = serializers.SerializerMethodField()
    recruiter_rating = serializers.SerializerMethodField()

    class Meta:
        model  = Mission
        fields = [
            'id', 'job_title', 'company_name', 'start_date', 'end_date',
            'location', 'recruiter_name', 'candidate_name',
            'candidate_rating', 'recruiter_rating', 'status', 'image_url',
        ]

    def get_job_title(self, obj):
        return obj.candidature.offre.titre

    def get_company_name(self, obj):
        return obj.candidature.offre.recruteur.nom_structure

    def get_recruiter_name(self, obj):
        r = obj.candidature.offre.recruteur
        return f"{r.prenom} {r.nom}"

    def get_candidate_name(self, obj):
        c = obj.candidature.candidat
        return f"{c.prenom} {c.nom}"

    def get_candidate_rating(self, obj):
        """Rating given to the candidate for this mission, if any."""
        candidat = obj.candidature.candidat
        eval_qs = obj.evaluations.filter(evalue=candidat)
        ev = eval_qs.first()
        return ev.note if ev else None

    def get_recruiter_rating(self, obj):
        """Rating given to the recruiter for this mission, if any."""
        recruteur = obj.candidature.offre.recruteur
        eval_qs = obj.evaluations.filter(evalue=recruteur)
        ev = eval_qs.first()
        return ev.note if ev else None


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
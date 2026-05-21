from rest_framework import serializers
from apps.applications.models.candidature import Candidature


# ---------------------------------------------------------------------------
# Application (Candidature) — API-spec read serializer
# ---------------------------------------------------------------------------

class ApplicationSerializer(serializers.ModelSerializer):
    """
    Read serializer — maps Candidature to the ApplicationResponse shape
    required by the API spec. All field names must be snake_case.
    """
    id = serializers.SerializerMethodField()
    job_id = serializers.SerializerMethodField()
    job_title = serializers.CharField(source='offre.titre', read_only=True)
    company_name = serializers.SerializerMethodField()
    department = serializers.CharField(source='offre.categorie', read_only=True)
    logo_asset = serializers.SerializerMethodField()
    status = serializers.SerializerMethodField()
    applied_at = serializers.DateTimeField(source='date_postulation', read_only=True)
    location = serializers.SerializerMethodField()
    contract_type = serializers.CharField(source='offre.type_contrat', read_only=True)
    schedule_label = serializers.SerializerMethodField()
    interview_date = serializers.SerializerMethodField()
    candidate_name = serializers.SerializerMethodField()
    candidate_avatar = serializers.SerializerMethodField()
    candidate_domain = serializers.SerializerMethodField()
    candidate_rating = serializers.SerializerMethodField()
    motivation_letter = serializers.CharField(source='message_personnalise', read_only=True)

    class Meta:
        model = Candidature
        fields = [
            'id', 'job_id', 'job_title', 'company_name', 'department',
            'logo_asset', 'status', 'applied_at', 'location',
            'contract_type', 'schedule_label', 'interview_date',
            'candidate_name', 'candidate_avatar', 'candidate_domain',
            'candidate_rating', 'motivation_letter',
        ]

    # Status mapping: DB -> API
    _STATUS_MAP = {
        'en_attente': 'pending',
        'acceptee': 'accepted',
        'refusee': 'rejected',
    }

    def get_id(self, obj):
        return str(obj.id)

    def get_job_id(self, obj):
        return str(obj.offre.id)

    def get_status(self, obj):
        return self._STATUS_MAP.get(obj.statut, obj.statut)

    def get_company_name(self, obj):
        return getattr(obj.offre.recruteur, 'nom_structure', '') or ''

    def get_logo_asset(self, obj):
        return getattr(obj.offre, 'logo_url', None)

    def get_location(self, obj):
        return getattr(obj.offre, 'location', '') or ''

    def get_schedule_label(self, obj):
        return getattr(obj.offre, 'schedule_label', None)

    def get_interview_date(self, obj):
        """Returns formatted interview date string or null."""
        from apps.jobs.models import Interview
        interview = Interview.objects.filter(candidature=obj).first()
        if interview and interview.scheduled_date:
            return f"Entretien prévu le {interview.scheduled_date.strftime('%d %b.')}"
        return None

    def get_candidate_name(self, obj):
        c = obj.candidat
        return f"{c.prenom} {c.nom}"

    def get_candidate_avatar(self, obj):
        return getattr(obj.candidat, 'avatar_url', None)

    def get_candidate_domain(self, obj):
        return getattr(obj.candidat, 'domain', None)

    def get_candidate_rating(self, obj):
        rating = getattr(obj.candidat, 'note_globale', None)
        return float(rating) if rating is not None else 0.0


class CreateCandidatureSerializer(serializers.Serializer):
    message_personnalise = serializers.CharField(required=False, allow_blank=True, allow_null=True)
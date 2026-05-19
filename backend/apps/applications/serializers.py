from rest_framework import serializers
from apps.applications.models.candidature import Candidature


# ---------------------------------------------------------------------------
# Application (Candidature) — API-spec read serializer
# ---------------------------------------------------------------------------

class ApplicationSerializer(serializers.ModelSerializer):
    """
    Read serializer — maps Candidature to the ApplicationResponse shape
    required by the API spec.
    """
    job_id = serializers.IntegerField(source='offre.id', read_only=True)
    job_title = serializers.CharField(source='offre.titre', read_only=True)
    company_name = serializers.SerializerMethodField()
    logo_asset = serializers.SerializerMethodField()
    status = serializers.SerializerMethodField()
    applied_at = serializers.DateField(source='date_postulation', read_only=True)
    location = serializers.SerializerMethodField()
    contract_type = serializers.CharField(source='offre.type_contrat', read_only=True)
    schedule_label = serializers.SerializerMethodField()
    motivation_letter = serializers.CharField(
        source='message_personnalise', read_only=True
    )

    # Candidate-derived fields
    candidate_name = serializers.SerializerMethodField()
    candidate_avatar = serializers.SerializerMethodField()
    candidate_domain = serializers.SerializerMethodField()
    candidate_rating = serializers.SerializerMethodField()

    class Meta:
        model = Candidature
        fields = [
            'id', 'job_id', 'job_title', 'company_name', 'logo_asset',
            'status', 'applied_at', 'location', 'contract_type',
            'schedule_label', 'candidate_name', 'candidate_avatar',
            'candidate_domain', 'candidate_rating', 'motivation_letter',
        ]

    # -- status mapping --
    _STATUS_MAP = {
        'en_attente': 'pending',
        'accepte': 'accepted',
        'refuse': 'rejected',
    }

    def get_status(self, obj):
        return self._STATUS_MAP.get(obj.statut, obj.statut)

    # -- offre-derived --
    def get_company_name(self, obj):
        return getattr(obj.offre.recruteur, 'nom_structure', None)

    def get_logo_asset(self, obj):
        # Placeholder — no logo field on model yet; return None.
        return None

    def get_location(self, obj):
        offre = obj.offre
        if offre.latitude is not None and offre.longitude is not None:
            return f"{offre.latitude}, {offre.longitude}"
        return None

    def get_schedule_label(self, obj):
        return obj.offre.type_contrat

    # -- candidat-derived --
    def get_candidate_name(self, obj):
        c = obj.candidat
        return f"{c.prenom} {c.nom}"

    def get_candidate_avatar(self, obj):
        # No avatar field on model yet; return None.
        return None

    def get_candidate_domain(self, obj):
        c = obj.candidat
        return getattr(c, 'experience', None)

    def get_candidate_rating(self, obj):
        return getattr(obj.candidat, 'note_globale', None)


class CreateCandidatureSerializer(serializers.Serializer):
    message_personnalise = serializers.CharField(required=False, allow_blank=True, allow_null=True)
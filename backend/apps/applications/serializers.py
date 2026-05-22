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
    department = serializers.SerializerMethodField()
    logo_asset = serializers.SerializerMethodField()
    status = serializers.SerializerMethodField()
    applied_at = serializers.SerializerMethodField()
    location = serializers.SerializerMethodField()
    contract_type = serializers.CharField(source='offre.type_contrat', read_only=True)
    schedule_label = serializers.SerializerMethodField()
    interview_date = serializers.SerializerMethodField()
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
            'id', 'job_id', 'job_title', 'company_name', 'department',
            'logo_asset', 'status', 'applied_at', 'location',
            'contract_type', 'schedule_label', 'interview_date',
            'candidate_name', 'candidate_avatar', 'candidate_domain',
            'candidate_rating', 'motivation_letter',
        ]

    # Status mapping: DB -> API — matches actual DB values stored by the views
    _STATUS_MAP = {
        'en_attente': 'pending',
        'acceptee':   'accepted',
        'refusee':    'rejected',
        # Fallbacks for any old rows with the previous French form
        'accepte':    'accepted',
        'refuse':     'rejected',
    }

    def get_id(self, obj):
        return str(obj.id)

    def get_job_id(self, obj):
        return str(obj.offre_id)  # avoids extra DB hit

    def get_status(self, obj):
        return self._STATUS_MAP.get(obj.statut, obj.statut)

    def get_applied_at(self, obj):
        if obj.date_postulation:
            return obj.date_postulation.isoformat()
        return None

    # -- offre-derived --

    def get_company_name(self, obj):
        return getattr(obj.offre.recruteur, 'nom_structure', '') or ''

    def get_logo_asset(self, obj):
        return getattr(obj.offre.recruteur, 'logo_url', None)  # logo lives on recruteur

    def get_location(self, obj):
        offre = obj.offre
        if offre.latitude is not None and offre.longitude is not None:
            return f"{offre.latitude}, {offre.longitude}"
        return getattr(offre, 'location', None)

    def get_schedule_label(self, obj):
        return getattr(obj.offre, 'schedule_label', None) or obj.offre.type_contrat or None

    def get_department(self, obj):
        return obj.offre.categorie or None

    def get_interview_date(self, obj):
        try:
            interview = obj.offre.interviews.filter(candidate=obj.candidat).first()
            if interview and interview.scheduled_date:
                d = interview.scheduled_date
                return d.isoformat() if hasattr(d, 'isoformat') else str(d)
        except Exception:
            pass
        return None

    # -- candidate-derived --

    def get_candidate_name(self, obj):
        c = obj.candidat
        return f"{c.prenom} {c.nom}"

    def get_candidate_avatar(self, obj):
        return getattr(obj.candidat, 'avatar_url', None)

    def get_candidate_domain(self, obj):
        c = obj.candidat
        return getattr(c, 'titre_poste', None) or getattr(c, 'experience', None)

    def get_candidate_rating(self, obj):
        rating = getattr(obj.candidat, 'note_globale', None)
        return float(rating) if rating is not None else 0.0


class CreateCandidatureSerializer(serializers.Serializer):
    message_personnalise = serializers.CharField(required=False, allow_blank=True, allow_null=True)
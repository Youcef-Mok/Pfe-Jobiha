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
    API spec expects snake_case field names.
    """
    id = serializers.SerializerMethodField()
    title = serializers.CharField(source='titre', read_only=True)
    company_name = serializers.SerializerMethodField()
    recruiter_id = serializers.SerializerMethodField()
    recruiter_name = serializers.SerializerMethodField()
    recruiter_role = serializers.SerializerMethodField()
    recruiter_avatar_asset = serializers.SerializerMethodField()
    department = serializers.CharField(source='categorie', read_only=True)
    contract_type = serializers.CharField(source='type_contrat', read_only=True)
    posted_at = serializers.DateTimeField(source='created_at', read_only=True)
    status = serializers.CharField(source='statut', read_only=True)
    logo_asset = serializers.CharField(source='logo_url', read_only=True, allow_null=True)
    location = serializers.CharField(read_only=True, allow_blank=True)
    schedule_label = serializers.CharField(read_only=True, allow_null=True)
    candidates = serializers.SerializerMethodField()
    comments = serializers.SerializerMethodField()

    class Meta:
        model  = Offre
        fields = [
            'id', 'title', 'company_name', 'recruiter_id', 'recruiter_name',
            'recruiter_role', 'recruiter_avatar_asset', 'department',
            'contract_type', 'posted_at', 'status', 'candidate_count',
            'view_count', 'logo_asset', 'is_published', 'location',
            'schedule_label', 'candidates', 'comments',
        ]

    def get_id(self, obj):
        return str(obj.id)

    def get_company_name(self, obj):
        return getattr(obj.recruteur, 'nom_structure', '') or ''

    def get_recruiter_id(self, obj):
        return str(obj.recruteur.id) if obj.recruteur else None

    def get_recruiter_name(self, obj):
        if obj.recruteur:
            return f"{obj.recruteur.prenom} {obj.recruteur.nom}"
        return ''

    def get_recruiter_role(self, obj):
        return getattr(obj.recruteur, 'titre_poste', '') or ''

    def get_recruiter_avatar_asset(self, obj):
        return getattr(obj.recruteur, 'avatar_url', None)

    def get_candidates(self, obj):
        """
        API spec expects: initials, name, role, rating, avatar_url (snake_case)
        Only included in detail view (GET /jobs/:id)
        """
        # Check if this is a detail view (has candidatures prefetched)
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
                'role': getattr(c, 'titre_poste', '') or '',
                'rating': float(c.note_globale) if c.note_globale is not None else 0.0,
                'avatar_url': getattr(c, 'avatar_url', None),
            })
        return result

    def get_comments(self, obj):
        """
        API spec expects: initials, author_name, date, question,
        recruitor_label, recruitor_date, reply (snake_case)
        """
        from apps.jobs.models import JobComment
        
        # Only included in detail view
        if not hasattr(obj, '_detail_view'):
            return None
            
        comments = JobComment.objects.filter(offre=obj).select_related('auteur').order_by('-date_question')
        result = []
        for comment in comments:
            author = comment.auteur
            full_name = f"{author.prenom} {author.nom}"
            initials = ''.join(p[0].upper() for p in full_name.split() if p)[:2]
            
            # Format dates
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
    title = serializers.CharField(max_length=200)
    contract_type = serializers.CharField(max_length=50)
    description = serializers.CharField()
    candidate_count = serializers.IntegerField(default=1)
    salary = serializers.FloatField(required=False, allow_null=True)
    is_published = serializers.BooleanField(default=False)
    # Optional fields
    department = serializers.CharField(max_length=100, required=False, allow_blank=True)
    location = serializers.CharField(max_length=200, required=False, allow_blank=True)
    schedule_label = serializers.CharField(max_length=50, required=False, allow_blank=True, allow_null=True)
    logo_url = serializers.CharField(max_length=500, required=False, allow_blank=True, allow_null=True)
    date_debut = serializers.DateField(required=False, allow_null=True)
    date_fin = serializers.DateField(required=False, allow_null=True)
    latitude = serializers.FloatField(required=False, allow_null=True)
    longitude = serializers.FloatField(required=False, allow_null=True)
    
    # Ignore ces champs s'ils arrivent du frontend (données mockées)
    company_name = serializers.CharField(required=False, allow_blank=True)
    recruiter_id = serializers.CharField(required=False, allow_blank=True)
    recruiter_name = serializers.CharField(required=False, allow_blank=True)
    recruiter_role = serializers.CharField(required=False, allow_blank=True)
    recruiter_avatar_asset = serializers.CharField(required=False, allow_blank=True, allow_null=True)
    posted_at = serializers.DateTimeField(required=False, allow_null=True)
    status = serializers.CharField(required=False, allow_blank=True)
    view_count = serializers.IntegerField(required=False)
    candidates = serializers.ListField(required=False)
    comments = serializers.ListField(required=False)


OFFRE_STATUT_CHOICES = ["searching", "draft", "closed"]

class UpdateOffreSerializer(serializers.Serializer):
    title = serializers.CharField(max_length=200, required=False)
    contract_type = serializers.CharField(max_length=50, required=False)
    description = serializers.CharField(required=False, allow_null=True, allow_blank=True)
    candidate_count = serializers.IntegerField(required=False)
    salary = serializers.FloatField(required=False, allow_null=True)
    is_published = serializers.BooleanField(required=False)
    department = serializers.CharField(max_length=100, required=False, allow_blank=True)
    location = serializers.CharField(max_length=200, required=False, allow_blank=True)
    schedule_label = serializers.CharField(max_length=50, required=False, allow_blank=True, allow_null=True)
    logo_url = serializers.CharField(max_length=500, required=False, allow_blank=True, allow_null=True)
    date_debut = serializers.DateField(required=False, allow_null=True)
    date_fin = serializers.DateField(required=False, allow_null=True)
    latitude = serializers.FloatField(required=False, allow_null=True)
    longitude = serializers.FloatField(required=False, allow_null=True)
    status = serializers.ChoiceField(choices=OFFRE_STATUT_CHOICES, required=False)


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
    recruiter_name = serializers.SerializerMethodField()
    candidate_name = serializers.SerializerMethodField()
    candidate_rating = serializers.SerializerMethodField()
    recruiter_rating = serializers.SerializerMethodField()
    candidate_feedback = serializers.SerializerMethodField()
    recruiter_feedback = serializers.SerializerMethodField()
    status = serializers.SerializerMethodField()
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
        'en_cours': 'in_progress',
        'terminee': 'completed',
        'annulee': 'cancelled',
    }

    def get_id(self, obj):
        return str(obj.id)

    def get_job_id(self, obj):
        return str(obj.candidature.offre.id)

    def get_job_title(self, obj):
        return obj.candidature.offre.titre

    def get_company_name(self, obj):
        return obj.candidature.offre.recruteur.nom_structure or ''

    def get_department(self, obj):
        return obj.candidature.offre.categorie

    def get_start_date(self, obj):
        if obj.date_debut:
            return obj.date_debut.isoformat()
        return None

    def get_end_date(self, obj):
        if obj.date_fin:
            return obj.date_fin.isoformat()
        return None

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

    def get_status(self, obj):
        return self._STATUS_MAP.get(obj.statut, obj.statut)

    def get_team(self, obj):
        """
        API spec expects: name, role, rating, avatar_url (snake_case)
        Returns team members from MissionTeamMember model.
        """
        from apps.jobs.models import MissionTeamMember
        
        team_members = MissionTeamMember.objects.filter(mission=obj)
        result = []
        for member in team_members:
            result.append({
                'name': member.name,
                'role': member.role,
                'rating': float(member.rating),
                'avatar_url': member.avatar_url,
            })
        return result


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
        return str(obj.candidate.id)

    def get_candidate_name(self, obj):
        return f"{obj.candidate.prenom} {obj.candidate.nom}"

    def get_candidate_avatar(self, obj):
        return getattr(obj.candidate, 'avatar_url', None)

    def get_job_id(self, obj):
        return str(obj.job.id)

    def get_department(self, obj):
        return obj.job.categorie


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
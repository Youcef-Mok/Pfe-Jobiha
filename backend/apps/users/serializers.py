"""
Serializers for the Auth + Profiles module.
All field names and structures match the OpenAPI spec exactly.
"""
from rest_framework import serializers
from apps.users.models import Utilisateur, Candidat, Recruteur, Disponibilite
from apps.users.models.settings import UserSettings
from apps.uploads.models import Media
from apps.reviews.models.evaluation import Evaluation


# ---------------------------------------------------------------------------
# Shared / Nested serializers
# ---------------------------------------------------------------------------

class DisponibiliteSerializer(serializers.ModelSerializer):
    """Read serializer — maps to the Disponibilite schema."""

    class Meta:
        model = Disponibilite
        fields = ['id', 'jour', 'heure_debut', 'heure_fin']


class DisponibiliteRequestSerializer(serializers.Serializer):
    """Write serializer — maps to DisponibiliteRequest schema."""
    JOUR_CHOICES = [
        ('lundi', 'lundi'), ('mardi', 'mardi'), ('mercredi', 'mercredi'),
        ('jeudi', 'jeudi'), ('vendredi', 'vendredi'),
        ('samedi', 'samedi'), ('dimanche', 'dimanche'),
    ]

    jour        = serializers.ChoiceField(choices=JOUR_CHOICES)
    heure_debut = serializers.TimeField()
    heure_fin   = serializers.TimeField()


class MediaSerializer(serializers.ModelSerializer):
    """Read serializer — maps to the Media schema."""

    class Meta:
        model  = Media
        fields = ['id', 'url', 'type_media', 'description', 'created_at']


# ---------------------------------------------------------------------------
# Utilisateur (base user)
# ---------------------------------------------------------------------------

class UtilisateurSerializer(serializers.ModelSerializer):
    """Read serializer — maps to UtilisateurResponse schema."""
    role = serializers.SerializerMethodField()

    class Meta:
        model  = Utilisateur
        fields = [
            'id', 'nom', 'prenom', 'email', 'telephone',
            'latitude', 'longitude', 'date_inscription',
            'est_verifie', 'statut_compte', 'role',
        ]

    def get_role(self, obj):
        return obj.role


class UpdateUtilisateurSerializer(serializers.Serializer):
    """Write serializer — maps to UpdateUtilisateurRequest schema."""
    nom       = serializers.CharField(max_length=100, required=False)
    prenom    = serializers.CharField(max_length=100, required=False)
    telephone = serializers.CharField(max_length=20, required=False, allow_blank=True)
    latitude  = serializers.FloatField(required=False, allow_null=True)
    longitude = serializers.FloatField(required=False, allow_null=True)


# ---------------------------------------------------------------------------
# Auth
# ---------------------------------------------------------------------------

class RegisterCandidatSerializer(serializers.Serializer):
    """Maps to RegisterCandidatRequest schema."""
    nom          = serializers.CharField(max_length=100)
    prenom       = serializers.CharField(max_length=100)
    email        = serializers.EmailField()
    mot_de_passe = serializers.CharField(min_length=8, write_only=True)
    telephone    = serializers.CharField(max_length=20, required=False, allow_blank=True)
    latitude     = serializers.FloatField(required=False, allow_null=True)
    longitude    = serializers.FloatField(required=False, allow_null=True)
    competences  = serializers.ListField(
        child=serializers.CharField(), required=False, default=list
    )
    experience   = serializers.CharField(required=False, allow_blank=True, default='')


class RegisterRecruteurSerializer(serializers.Serializer):
    """Maps to RegisterRecruteurRequest schema."""
    nom            = serializers.CharField(max_length=100)
    prenom         = serializers.CharField(max_length=100)
    email          = serializers.EmailField()
    mot_de_passe   = serializers.CharField(min_length=8, write_only=True)
    telephone      = serializers.CharField(max_length=20, required=False, allow_blank=True)
    latitude       = serializers.FloatField(required=False, allow_null=True)
    longitude      = serializers.FloatField(required=False, allow_null=True)
    nom_structure  = serializers.CharField(max_length=200, required=False, default='')
    type_structure = serializers.CharField(max_length=100, required=False, default='')
    description    = serializers.CharField(required=False, allow_blank=True, default='')


class LoginSerializer(serializers.Serializer):
    """Maps to LoginRequest schema."""
    email        = serializers.EmailField()
    mot_de_passe = serializers.CharField()


class ChangePasswordSerializer(serializers.Serializer):
    """Maps to ChangePasswordRequest schema."""
    ancien_mot_de_passe  = serializers.CharField()
    nouveau_mot_de_passe = serializers.CharField(min_length=8)


# ---------------------------------------------------------------------------
# Candidat
# ---------------------------------------------------------------------------

class CandidatSerializer(serializers.ModelSerializer):
    """
    Read serializer — maps to CandidatResponse schema.
    Portfolio is served via the Media.candidat FK reverse relation ('medias').
    The duplicate M2M on Candidat has been removed; 'medias' is the single
    source of truth for a candidate's portfolio items.
    """
    role           = serializers.SerializerMethodField()
    disponibilites = DisponibiliteSerializer(many=True, read_only=True)
    portfolio      = MediaSerializer(many=True, read_only=True, source='medias')

    class Meta:
        model  = Candidat
        fields = [
            'id', 'nom', 'prenom', 'email', 'telephone',
            'latitude', 'longitude', 'date_inscription',
            'est_verifie', 'statut_compte', 'role',
            'competences', 'experience', 'note_globale',
            'disponibilites', 'portfolio',
        ]

    def get_role(self, obj):
        return 'candidat'


class CandidatPublicSerializer(serializers.ModelSerializer):
    """Read serializer — maps to CandidatPublicResponse (no PII)."""
    disponibilites = DisponibiliteSerializer(many=True, read_only=True)
    portfolio      = MediaSerializer(many=True, read_only=True, source='medias')

    class Meta:
        model  = Candidat
        fields = [
            'id', 'nom', 'prenom', 'competences', 'experience',
            'note_globale', 'disponibilites', 'portfolio',
        ]


class UpdateCandidatSerializer(serializers.Serializer):
    """Write serializer — maps to UpdateCandidatRequest schema."""
    competences = serializers.ListField(
        child=serializers.CharField(), required=False
    )
    experience  = serializers.CharField(required=False, allow_blank=True)


# ---------------------------------------------------------------------------
# Recruteur
# ---------------------------------------------------------------------------

class RecruteurSerializer(serializers.ModelSerializer):
    """Read serializer — maps to RecruteurResponse schema."""
    role = serializers.SerializerMethodField()

    class Meta:
        model  = Recruteur
        fields = [
            'id', 'nom', 'prenom', 'email', 'telephone',
            'latitude', 'longitude', 'date_inscription',
            'est_verifie', 'statut_compte', 'role',
            'nom_structure', 'type_structure', 'description', 'note_globale',
        ]

    def get_role(self, obj):
        return 'recruteur'


class RecruteurPublicSerializer(serializers.ModelSerializer):
    """Read serializer — maps to RecruteurPublicResponse (public-facing)."""

    class Meta:
        model  = Recruteur
        fields = [
            'id', 'nom', 'prenom', 'nom_structure', 'type_structure',
            'description', 'note_globale',
        ]


class UpdateRecruteurSerializer(serializers.Serializer):
    """Write serializer — maps to UpdateRecruteurRequest schema."""
    nom_structure  = serializers.CharField(max_length=200, required=False)
    type_structure = serializers.CharField(max_length=100, required=False)
    description    = serializers.CharField(required=False, allow_blank=True)


class ForgotPasswordSerializer(serializers.Serializer):
    email = serializers.EmailField()


class ResetPasswordSerializer(serializers.Serializer):
    email                = serializers.EmailField()
    otp                  = serializers.CharField(min_length=6, max_length=6)
    nouveau_mot_de_passe = serializers.CharField(min_length=8)


# ---------------------------------------------------------------------------
# UserMe — flattened profile for GET /users/me
# ---------------------------------------------------------------------------

class UserMeSerializer(serializers.Serializer):
    """
    Read serializer — returns a unified, flattened profile regardless of
    whether the user is a Candidat or Recruteur.
    """
    id = serializers.SerializerMethodField()
    name = serializers.SerializerMethodField()
    role = serializers.SerializerMethodField()
    domain = serializers.SerializerMethodField()
    company = serializers.SerializerMethodField()
    location = serializers.SerializerMethodField()
    latitude = serializers.SerializerMethodField()
    longitude = serializers.SerializerMethodField()
    bio = serializers.SerializerMethodField()
    avatar_url = serializers.SerializerMethodField()
    followers_count = serializers.SerializerMethodField()
    missions_count = serializers.SerializerMethodField()
    rating = serializers.SerializerMethodField()
    account_type = serializers.SerializerMethodField()

    def get_id(self, obj):
        return str(obj.id)

    def _profile(self, obj):
        """Return the child profile (Candidat or Recruteur) if it exists."""
        for attr in ('candidat', 'recruteur'):
            try:
                return getattr(obj, attr)
            except Exception:
                continue
        return None

    def get_name(self, obj):
        return f"{obj.prenom} {obj.nom}"

    def get_role(self, obj):
        # 'role' in the spec = job title / domain (not account type)
        p = self._profile(obj)
        if isinstance(p, Candidat):
            return getattr(p, 'titre_poste', None) or p.experience or ''
        if isinstance(p, Recruteur):
            return getattr(p, 'titre_poste', None) or p.type_structure or ''
        return ''

    def get_domain(self, obj):
        p = self._profile(obj)
        if p and getattr(p, 'domain', None):
            return p.domain
        if isinstance(p, Candidat):
            comps = getattr(p, 'competences', None)
            if comps:
                return comps[0] if isinstance(comps, list) else str(comps)
            return p.experience or None
        if isinstance(p, Recruteur):
            return p.type_structure or None
        return None

    def get_company(self, obj):
        p = self._profile(obj)
        if isinstance(p, Recruteur):
            return p.nom_structure or ''
        return ''

    def get_location(self, obj):
        # Return text location if available, else GPS coords, else empty
        loc = getattr(obj, 'location', None)
        if loc:
            return loc
        if obj.latitude is not None and obj.longitude is not None:
            return f"{obj.latitude}, {obj.longitude}"
        return ''

    def get_latitude(self, obj):
        return obj.latitude

    def get_longitude(self, obj):
        return obj.longitude

    def get_bio(self, obj):
        if getattr(obj, 'bio', None):
            return obj.bio
        p = self._profile(obj)
        if isinstance(p, Recruteur):
            return p.description or ''
        if isinstance(p, Candidat):
            return p.experience or ''
        return ''

    def get_avatar_url(self, obj):
        return getattr(obj, 'avatar_url', None)

    def get_followers_count(self, obj):
        return 0

    def get_missions_count(self, obj):
        p = self._profile(obj)
        if isinstance(p, Candidat):
            return p.candidatures.filter(mission__isnull=False).count()
        return 0

    def get_rating(self, obj):
        p = self._profile(obj)
        if p and hasattr(p, 'note_globale'):
            return float(p.note_globale) if p.note_globale is not None else 0.0
        return 0.0

    def get_account_type(self, obj):
        # 'account_type' = 'candidat' or 'recruteur' (the actual account role)
        return obj.role


# ---------------------------------------------------------------------------
# Review — maps Evaluation to the API-spec ReviewResponse
# ---------------------------------------------------------------------------

class ReviewSerializer(serializers.ModelSerializer):
    """
    Read serializer for GET /users/:id/reviews.
    Sources data from the Evaluation model.
    """
    id = serializers.SerializerMethodField()
    author_name = serializers.SerializerMethodField()
    author_role = serializers.SerializerMethodField()
    author_avatar = serializers.SerializerMethodField()
    rating = serializers.SerializerMethodField()
    comment = serializers.SerializerMethodField()
    recruiter_reply = serializers.SerializerMethodField()
    recruiter_name = serializers.SerializerMethodField()
    recruiter_reply_date = serializers.SerializerMethodField()

    class Meta:
        model = Evaluation
        fields = [
            'id', 'author_name', 'author_role', 'author_avatar',
            'rating', 'comment', 'recruiter_reply', 'recruiter_name',
            'recruiter_reply_date',
        ]

    def get_id(self, obj):
        return str(obj.id)

    def get_author_name(self, obj):
        return f"{obj.evaluateur.prenom} {obj.evaluateur.nom}"

    def get_author_role(self, obj):
        return obj.evaluateur.role

    def get_author_avatar(self, obj):
        return None

    def get_rating(self, obj):
        return float(obj.note)

    def get_comment(self, obj):
        return obj.commentaire or ''

    def get_recruiter_reply(self, obj):
        return obj.recruiter_reply

    def get_recruiter_name(self, obj):
        if obj.recruiter_name:
            return obj.recruiter_name
        try:
            recruteur = obj.mission.candidature.offre.recruteur
            return f"{recruteur.prenom} {recruteur.nom}"
        except Exception:
            return None

    def get_recruiter_reply_date(self, obj):
        if obj.recruiter_reply_date is None:
            return None
        return obj.recruiter_reply_date.isoformat()


# ---------------------------------------------------------------------------
# UserSettings
# ---------------------------------------------------------------------------

class UserSettingsSerializer(serializers.ModelSerializer):
    """Read/write serializer for user preferences."""

    class Meta:
        model = UserSettings
        fields = ['notifications_enabled', 'dark_mode', 'language_code']
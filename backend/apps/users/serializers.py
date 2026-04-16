"""
Serializers for the Auth + Profiles module.
All field names and structures match the OpenAPI spec exactly.
"""
from rest_framework import serializers
from apps.users.models import Utilisateur, Candidat, Recruteur, Disponibilite
from apps.uploads.models import Media


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

    jour = serializers.ChoiceField(choices=JOUR_CHOICES)
    heure_debut = serializers.TimeField()
    heure_fin = serializers.TimeField()


class MediaSerializer(serializers.ModelSerializer):
    """
    Read serializer — maps to the Media schema.
    Maps model fields to spec field names via `source`.
    """
    type_media = serializers.CharField(source='type')
    created_at = serializers.DateField(source='date_ajout')

    class Meta:
        model = Media
        fields = ['id', 'url', 'type_media', 'description', 'created_at']


# ---------------------------------------------------------------------------
# Utilisateur (base user)
# ---------------------------------------------------------------------------

class UtilisateurSerializer(serializers.ModelSerializer):
    """Read serializer — maps to UtilisateurResponse schema."""
    role = serializers.SerializerMethodField()

    class Meta:
        model = Utilisateur
        fields = [
            'id', 'nom', 'prenom', 'email', 'telephone',
            'latitude', 'longitude', 'date_inscription',
            'est_verifie', 'statut_compte', 'role',
        ]

    def get_role(self, obj):
        return obj.role


class UpdateUtilisateurSerializer(serializers.Serializer):
    """Write serializer — maps to UpdateUtilisateurRequest schema."""
    nom = serializers.CharField(max_length=100, required=False)
    prenom = serializers.CharField(max_length=100, required=False)
    telephone = serializers.CharField(max_length=20, required=False, allow_blank=True)
    latitude = serializers.FloatField(required=False, allow_null=True)
    longitude = serializers.FloatField(required=False, allow_null=True)


# ---------------------------------------------------------------------------
# Auth
# ---------------------------------------------------------------------------

class RegisterCandidatSerializer(serializers.Serializer):
    """Maps to RegisterCandidatRequest schema."""
    nom = serializers.CharField(max_length=100)
    prenom = serializers.CharField(max_length=100)
    email = serializers.EmailField()
    mot_de_passe = serializers.CharField(min_length=8, write_only=True)
    telephone = serializers.CharField(max_length=20, required=False, allow_blank=True)
    latitude = serializers.FloatField(required=False, allow_null=True)
    longitude = serializers.FloatField(required=False, allow_null=True)
    competences = serializers.ListField(
        child=serializers.CharField(), required=False, default=list
    )
    experience = serializers.CharField(required=False, allow_blank=True, default='')


class RegisterRecruteurSerializer(serializers.Serializer):
    """Maps to RegisterRecruteurRequest schema."""
    nom = serializers.CharField(max_length=100)
    prenom = serializers.CharField(max_length=100)
    email = serializers.EmailField()
    mot_de_passe = serializers.CharField(min_length=8, write_only=True)
    telephone = serializers.CharField(max_length=20, required=False, allow_blank=True)
    latitude = serializers.FloatField(required=False, allow_null=True)
    longitude = serializers.FloatField(required=False, allow_null=True)
    # Optional at registration — Flutter collects these on the profile screen
    # and sends them via PATCH /recruteurs/me afterwards.
    nom_structure = serializers.CharField(max_length=200, required=False, default='')
    type_structure = serializers.CharField(max_length=100, required=False, default='')
    description = serializers.CharField(required=False, allow_blank=True, default='')


class LoginSerializer(serializers.Serializer):
    """Maps to LoginRequest schema."""
    email = serializers.EmailField()
    mot_de_passe = serializers.CharField()


class ChangePasswordSerializer(serializers.Serializer):
    """Maps to ChangePasswordRequest schema."""
    ancien_mot_de_passe = serializers.CharField()
    nouveau_mot_de_passe = serializers.CharField(min_length=8)


# ---------------------------------------------------------------------------
# Candidat
# ---------------------------------------------------------------------------

class CandidatSerializer(serializers.ModelSerializer):
    """
    Read serializer — maps to CandidatResponse schema (allOf UtilisateurResponse).
    Works because Candidat inherits all Utilisateur fields via multi-table inheritance.
    """
    role = serializers.SerializerMethodField()
    disponibilites = DisponibiliteSerializer(many=True, read_only=True)
    portfolio = MediaSerializer(many=True, read_only=True)

    class Meta:
        model = Candidat
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
    portfolio = MediaSerializer(many=True, read_only=True)

    class Meta:
        model = Candidat
        fields = [
            'id', 'nom', 'prenom', 'competences', 'experience',
            'note_globale', 'disponibilites', 'portfolio',
        ]


class UpdateCandidatSerializer(serializers.Serializer):
    """Write serializer — maps to UpdateCandidatRequest schema."""
    competences = serializers.ListField(
        child=serializers.CharField(), required=False
    )
    experience = serializers.CharField(required=False, allow_blank=True)


# ---------------------------------------------------------------------------
# Recruteur
# ---------------------------------------------------------------------------

class RecruteurSerializer(serializers.ModelSerializer):
    """Read serializer — maps to RecruteurResponse schema (allOf UtilisateurResponse)."""
    role = serializers.SerializerMethodField()

    class Meta:
        model = Recruteur
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
        model = Recruteur
        fields = [
            'id', 'nom', 'prenom', 'nom_structure', 'type_structure',
            'description', 'note_globale',
        ]


class UpdateRecruteurSerializer(serializers.Serializer):
    """Write serializer — maps to UpdateRecruteurRequest schema."""
    nom_structure = serializers.CharField(max_length=200, required=False)
    type_structure = serializers.CharField(max_length=100, required=False)
    description = serializers.CharField(required=False, allow_blank=True)

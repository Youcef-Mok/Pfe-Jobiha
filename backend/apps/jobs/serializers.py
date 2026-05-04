from rest_framework import serializers
from apps.jobs.models.offre import Offre
from apps.jobs.models.mission import Mission
from apps.jobs.models.saved_job import SavedJob
from apps.jobs.models.alerte import Alerte


# ---------------------------------------------------------------------------
# Offre serializers
# ---------------------------------------------------------------------------


class OffreSerializer(serializers.ModelSerializer):
    recruteur       = serializers.SerializerMethodField()
    nb_candidatures = serializers.SerializerMethodField()

    class Meta:
        model  = Offre
        fields = [
            'id', 'titre', 'description', 'categorie',
            'date_debut', 'date_fin', 'salaire', 'type_contrat',
            'latitude', 'longitude', 'statut',
            'recruteur', 'nb_candidatures',
        ]

    def get_recruteur(self, obj):
        return {
            'id':             obj.recruteur.id,
            'nom_structure':  obj.recruteur.nom_structure,
            'type_structure': obj.recruteur.type_structure,
            'note_globale':   obj.recruteur.note_globale,
        }

    def get_nb_candidatures(self, obj):
        # If the view annotated the queryset, use it (no extra query).
        # If not (e.g. single retrieve without annotation), fall back to count().
        if hasattr(obj, 'nb_candidatures'):
            return obj.nb_candidatures
        return obj.candidatures.count()    




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


OFFRE_STATUT_CHOICES = ["ouverte", "fermee", "pourvue"]

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
    candidature     = serializers.SerializerMethodField()
    attestation_url = serializers.SerializerMethodField()

    class Meta:
        model  = Mission
        fields = [
            'id', 'statut', 'date_debut', 'date_fin',
            'duree_heures', 'candidature', 'attestation_url',
        ]

    def get_candidature(self, obj):
        c = obj.candidature
        return {
            'id': c.id,
            'candidat': {
                'id':     c.candidat.id,
                'nom':    c.candidat.nom,
                'prenom': c.candidat.prenom,
            },
            'offre': {
                'id':            c.offre.id,
                'titre':         c.offre.titre,
                'nom_structure': c.offre.recruteur.nom_structure,
            },
        }

    def get_attestation_url(self, obj):
        if obj.statut == 'terminee':
            request = self.context.get('request')
            url = f'/api/v1/missions/{obj.id}/attestation'
            return request.build_absolute_uri(url) if request else url
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
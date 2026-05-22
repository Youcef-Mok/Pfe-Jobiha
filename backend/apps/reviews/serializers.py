"""
Serializers for the Evaluations & Signalements module.
All field names and structures match openapi_evaluations.json exactly.
"""
from rest_framework import serializers
from apps.reviews.models.evaluation import Evaluation
from apps.reviews.models.signalement import Signalement


# ---------------------------------------------------------------------------
# Nested helpers
# ---------------------------------------------------------------------------

class _UserMiniSerializer(serializers.Serializer):
    """Minimal user snippet used inside evaluations (id, nom, prenom)."""
    id     = serializers.IntegerField()
    nom    = serializers.CharField()
    prenom = serializers.CharField()


class _MissionMiniSerializer(serializers.Serializer):
    """Minimal mission snippet used inside EvaluationResponse."""
    id    = serializers.IntegerField()
    titre = serializers.CharField()


# ---------------------------------------------------------------------------
# Evaluation
# ---------------------------------------------------------------------------

class EvaluationRequestSerializer(serializers.Serializer):
    """
    Write serializer — maps to EvaluationRequest schema.
    POST /evaluations
    """
    mission_id  = serializers.IntegerField(
        help_text="ID of the completed mission being rated"
    )
    evalue_id   = serializers.IntegerField(
        help_text="ID of the user being rated"
    )
    note        = serializers.IntegerField(min_value=1, max_value=5)
    commentaire = serializers.CharField(required=False, allow_null=True, allow_blank=True)


class EvaluationSerializer(serializers.ModelSerializer):
    """
    Read serializer — maps to EvaluationResponse schema.
    Used by GET /evaluations/{id}, GET /missions/{id}/evaluations,
    GET /utilisateurs/{id}/evaluations, and inside ReputationSerializer.
    """
    evaluateur = serializers.SerializerMethodField()
    evalue     = serializers.SerializerMethodField()
    mission    = serializers.SerializerMethodField()

    class Meta:
        model  = Evaluation
        fields = [
            'id', 'note', 'commentaire', 'date_evaluation',
            'evaluateur', 'evalue', 'mission',
        ]

    def get_evaluateur(self, obj):
        return {
            'id':     obj.evaluateur.id,
            'nom':    obj.evaluateur.nom,
            'prenom': obj.evaluateur.prenom,
        }

    def get_evalue(self, obj):
        return {
            'id':     obj.evalue.id,
            'nom':    obj.evalue.nom,
            'prenom': obj.evalue.prenom,
        }

    def get_mission(self, obj):
        # titre is pulled from mission → candidature → offre
        try:
            titre = obj.mission.candidature.offre.titre
        except Exception:
            titre = None
        return {
            'id':    obj.mission.id,
            'titre': titre,
        }


class PaginatedEvaluationsSerializer(serializers.Serializer):
    """Maps to PaginatedEvaluations schema."""
    count    = serializers.IntegerField()
    next     = serializers.URLField(allow_null=True)
    previous = serializers.URLField(allow_null=True)
    results  = EvaluationSerializer(many=True)


# ---------------------------------------------------------------------------
# Reputation
# ---------------------------------------------------------------------------

class _DistributionSerializer(serializers.Serializer):
    """Star-rating breakdown (count per value 1-5)."""
    one   = serializers.IntegerField(source='1', default=0)
    two   = serializers.IntegerField(source='2', default=0)
    three = serializers.IntegerField(source='3', default=0)
    four  = serializers.IntegerField(source='4', default=0)
    five  = serializers.IntegerField(source='5', default=0)


class ReputationSerializer(serializers.Serializer):
    """
    Read serializer — maps to ReputationResponse schema.
    GET /utilisateurs/{id}/reputation
    """
    utilisateur_id      = serializers.IntegerField()
    note_globale        = serializers.FloatField()
    total_missions      = serializers.IntegerField()
    distribution        = serializers.DictField(
        child=serializers.IntegerField(),
        help_text="Count of ratings per star value (keys: '1' through '5')"
    )
    derniers_commentaires = EvaluationSerializer(many=True)


# ---------------------------------------------------------------------------
# Signalement
# ---------------------------------------------------------------------------

class SignalementRequestSerializer(serializers.Serializer):
    """
    Write serializer — maps to SignalementRequest schema.
    POST /signalements
    """
    cible_id    = serializers.IntegerField(
        help_text="ID of the user being reported"
    )
    raison      = serializers.CharField(max_length=200)
    description = serializers.CharField(required=False, allow_null=True, allow_blank=True)


class SignalementSerializer(serializers.ModelSerializer):
    """
    Read serializer — maps to SignalementResponse schema.
    Used by POST /signalements, GET /signalements/me,
    GET /admin/signalements, POST /admin/signalements/{id}/traiter.
    """
    auteur         = serializers.SerializerMethodField()
    cible          = serializers.SerializerMethodField()
    administrateur = serializers.SerializerMethodField()

    class Meta:
        model  = Signalement
        fields = [
            'id', 'raison', 'description', 'date_signalement',
            'statut', 'decision', 'auteur', 'cible', 'administrateur',
        ]

    def get_auteur(self, obj):
        return {
            'id':     obj.auteur.id,
            'nom':    obj.auteur.nom,
            'prenom': obj.auteur.prenom,
        }

    def get_cible(self, obj):
        return {
            'id':     obj.cible.id,
            'nom':    obj.cible.nom,
            'prenom': obj.cible.prenom,
        }

    def get_administrateur(self, obj):
        if obj.administrateur is None:
            return None
        return {
            'id':  obj.administrateur.id,
            'nom': obj.administrateur.nom,
        }


class PaginatedSignalementsSerializer(serializers.Serializer):
    """Maps to PaginatedSignalements schema."""
    count    = serializers.IntegerField()
    next     = serializers.URLField(allow_null=True)
    previous = serializers.URLField(allow_null=True)
    results  = SignalementSerializer(many=True)


class TraiterSignalementSerializer(serializers.Serializer):
    """
    Write serializer for admin action.
    POST /admin/signalements/{id}/traiter
    """
    STATUT_CHOICES = [('en_cours', 'En cours'), ('cloture', 'Clôturé')]

    statut   = serializers.ChoiceField(choices=STATUT_CHOICES)
    decision = serializers.CharField(max_length=1000)
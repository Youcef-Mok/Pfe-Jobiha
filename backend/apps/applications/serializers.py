from rest_framework import serializers
from apps.applications.models import Candidature


class CandidatureSerializer(serializers.ModelSerializer):
    candidat = serializers.SerializerMethodField()
    offre    = serializers.SerializerMethodField()

    class Meta:
        model = Candidature
        fields = [
            'id', 'date_postulation', 'message_personnalise',
            'statut', 'candidat', 'offre',
        ]

    def get_candidat(self, obj):
        return {
            'id':           obj.candidat.id,
            'nom':          obj.candidat.nom,
            'prenom':       obj.candidat.prenom,
            'competences':  obj.candidat.competences,   # ← was missing
            'note_globale': obj.candidat.note_globale,  # ← was missing
        }

    def get_offre(self, obj):
        return {
            'id':    obj.offre.id,
            'titre': obj.offre.titre,
        }


class CreateCandidatureSerializer(serializers.Serializer):
    message_personnalise = serializers.CharField(required=False, allow_blank=True, allow_null=True)
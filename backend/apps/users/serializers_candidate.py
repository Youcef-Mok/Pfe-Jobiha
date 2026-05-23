"""
Serializers for candidate-related endpoints.
"""
from rest_framework import serializers
from apps.users.models import Candidat


class CandidateListSerializer(serializers.ModelSerializer):
    """
    Serializer for GET /jobs/:jobId/candidates
    API spec expects: id, name, title, photo_url, rating, reviews_count,
    is_top_rated, cover_letter, status (snake_case)
    """
    id = serializers.SerializerMethodField()
    name = serializers.SerializerMethodField()
    title = serializers.CharField(source='titre_poste', read_only=True)
    photo_url = serializers.CharField(source='avatar_url', read_only=True, allow_null=True)
    rating = serializers.SerializerMethodField()
    reviews_count = serializers.SerializerMethodField()
    is_top_rated = serializers.SerializerMethodField()
    cover_letter = serializers.CharField(source='experience', read_only=True)
    status = serializers.SerializerMethodField()

    class Meta:
        model = Candidat
        fields = [
            'id', 'name', 'title', 'photo_url', 'rating',
            'reviews_count', 'is_top_rated', 'cover_letter', 'status'
        ]

    def get_id(self, obj):
        return str(obj.id)

    def get_name(self, obj):
        return f"{obj.prenom} {obj.nom}"

    def get_rating(self, obj):
        return float(obj.note_globale) if obj.note_globale is not None else 0.0

    def get_reviews_count(self, obj):
        """Count evaluations received by this candidate."""
        from apps.reviews.models import Evaluation
        return Evaluation.objects.filter(evalue=obj).count()

    def get_is_top_rated(self, obj):
        """Top rated if rating >= 4.5"""
        rating = obj.note_globale or 0.0
        return rating >= 4.5

    def get_status(self, obj):
        """
        Get candidature status for this candidate.
        This requires the candidature to be passed in context.
        """
        candidature = self.context.get('candidature')
        if candidature:
            status_map = {
                'en_attente': 'nouveau',
                'acceptee': 'examine',
                'refusee': 'archive',
            }
            # If candidature has a custom status field for candidate view
            return status_map.get(candidature.statut, 'nouveau')
        return 'nouveau'

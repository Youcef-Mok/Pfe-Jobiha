from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated

from apps.jobs.models import Offre, Mission
from apps.jobs.serializers import (
    OffreSerializer, CreateOffreSerializer, UpdateOffreSerializer,
    MissionSerializer,
)
from apps.applications.models import Candidature
from apps.applications.serializers import CandidatureSerializer


# ===========================================================================
# Offres
# ===========================================================================

class OffreListCreateView(APIView):
    """
    GET  /offres  → everyone sees all jobs
    POST /offres  → only recruiters can post a job
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        from django.db.models import Count
        offres = Offre.objects.annotate(
           nb_candidatures=Count('candidatures')
        ).order_by('-id')
        serializer = OffreSerializer(offres, many=True, context={'request': request})
        return Response(serializer.data)

    def post(self, request):
        if not hasattr(request.user, 'recruteur'):
            return Response({'detail': 'Only recruiters can create offres.'}, status=status.HTTP_403_FORBIDDEN)

        serializer = CreateOffreSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        offre = Offre.objects.create(
            recruteur=request.user.recruteur,
            **serializer.validated_data
        )
        return Response(OffreSerializer(offre, context={'request': request}).data, status=status.HTTP_201_CREATED)


class OffreDetailView(APIView):
    """
    GET    /offres/{id}  → anyone sees the job
    PATCH  /offres/{id}  → only the recruiter who owns it can edit
    DELETE /offres/{id}  → only the recruiter who owns it can delete
    """
    permission_classes = [IsAuthenticated]

    def get_offre(self, id):
        try:
            return Offre.objects.get(pk=id)
        except Offre.DoesNotExist:
            return None

    def get(self, request, id):
        offre = self.get_offre(id)
        if not offre:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        return Response(OffreSerializer(offre, context={'request': request}).data)

    def patch(self, request, id):
        offre = self.get_offre(id)
        if not offre:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        if not hasattr(request.user, 'recruteur') or offre.recruteur != request.user.recruteur:
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        serializer = UpdateOffreSerializer(data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        for field, value in serializer.validated_data.items():
            setattr(offre, field, value)
        offre.save()
        return Response(OffreSerializer(offre, context={'request': request}).data)

    def delete(self, request, id):
        offre = self.get_offre(id)
        if not offre:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        if not hasattr(request.user, 'recruteur') or offre.recruteur != request.user.recruteur:
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)
        offre.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class FermerOffreView(APIView):
    """
    POST /offres/{id}/fermer → recruiter closes the job
    """
    permission_classes = [IsAuthenticated]

    def post(self, request, id):
        try:
            offre = Offre.objects.get(pk=id)
        except Offre.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

        if not hasattr(request.user, 'recruteur') or offre.recruteur != request.user.recruteur:
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        offre.statut = 'fermee'
        offre.save(update_fields=['statut'])
        return Response(OffreSerializer(offre, context={'request': request}).data)


class MyOffresView(APIView):
    """
    GET /recruteurs/me/offres → recruiter sees only their own jobs
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if not hasattr(request.user, 'recruteur'):
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        offres = Offre.objects.filter(recruteur=request.user.recruteur).order_by('-id')
        serializer = OffreSerializer(offres, many=True, context={'request': request})
        return Response(serializer.data)


class OffreCandidaturesView(APIView):
    """
    GET /offres/{id}/candidatures → recruiter sees who applied to their job
    """
    permission_classes = [IsAuthenticated]

    def get(self, request, id):
        try:
            offre = Offre.objects.get(pk=id)
        except Offre.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)

        if not hasattr(request.user, 'recruteur') or offre.recruteur != request.user.recruteur:
            return Response({'detail': 'Forbidden.'}, status=status.HTTP_403_FORBIDDEN)

        candidatures = offre.candidatures.all()
        serializer = CandidatureSerializer(candidatures, many=True)
        return Response(serializer.data)


# ===========================================================================
# Missions
# ===========================================================================

class MissionDetailView(APIView):
    """
    GET /missions/{id} → view a mission
    """
    permission_classes = [IsAuthenticated]

    def get(self, request, id):
        try:
            mission = Mission.objects.get(pk=id)
        except Mission.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        return Response(MissionSerializer(mission, context={'request': request}).data)


class ValiderDebutView(APIView):
    """
    POST /missions/{id}/valider-debut → confirm mission started
    """
    permission_classes = [IsAuthenticated]

    def post(self, request, id):
        try:
            mission = Mission.objects.get(pk=id)
        except Mission.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        try:
            mission.valider_debut()
        except Exception as e:
            return Response({'detail': str(e)}, status=status.HTTP_400_BAD_REQUEST)
        return Response(MissionSerializer(mission, context={'request': request}).data)


class ValiderFinView(APIView):
    """
    POST /missions/{id}/valider-fin → confirm mission ended
    """
    permission_classes = [IsAuthenticated]

    def post(self, request, id):
        try:
            mission = Mission.objects.get(pk=id)
        except Mission.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        try:
            mission.valider_fin()
        except Exception as e:
            return Response({'detail': str(e)}, status=status.HTTP_400_BAD_REQUEST)
        return Response(MissionSerializer(mission, context={'request': request}).data)


class AttestationView(APIView):
    """
    GET /missions/{id}/attestation → get mission certificate data
    """
    permission_classes = [IsAuthenticated]

    def get(self, request, id):
        try:
            mission = Mission.objects.get(pk=id)
        except Mission.DoesNotExist:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        try:
            data = mission.generer_attestation()
        except Exception as e:
            return Response({'detail': str(e)}, status=status.HTTP_400_BAD_REQUEST)
        return Response(data)

"""
Role-based permissions for the PetitsJobs API.
"""
from rest_framework.permissions import BasePermission


class IsCandidat(BasePermission):
    """Allow access only to users with a Candidat profile."""

    def has_permission(self, request, view):
        return (
            request.user
            and hasattr(request.user, 'candidat')
        )


class IsRecruteur(BasePermission):
    """Allow access only to users with a Recruteur profile."""

    def has_permission(self, request, view):
        return (
            request.user
            and hasattr(request.user, 'recruteur')
        )


class IsAdmin(BasePermission):
    """Allow access only to Administrateur users."""

    def has_permission(self, request, view):
        if not request.user:
            return False
        from apps.users.models import Administrateur
        return Administrateur.objects.filter(email=request.user.email).exists()

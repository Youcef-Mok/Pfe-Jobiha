from rest_framework.permissions import BasePermission


class IsCandidat(BasePermission):
    """Allow access only to users with a Candidat profile."""

    def has_permission(self, request, view):
        if not hasattr(request.user, 'pk') or request.user.pk is None:
            return False
        try:
            request.user.candidat
            return True
        except Exception:
            return False


class IsRecruteur(BasePermission):
    """Allow access only to users with a Recruteur profile."""

    def has_permission(self, request, view):
        if not hasattr(request.user, 'pk') or request.user.pk is None:
            return False
        try:
            request.user.recruteur
            return True
        except Exception:
            return False


class IsAdmin(BasePermission):
    """Allow access only to admin users (linked to Administrateur)."""

    def has_permission(self, request, view):
        if not hasattr(request.user, 'pk') or request.user.pk is None:
            return False
        from apps.users.models import Administrateur
        return Administrateur.objects.filter(email=request.user.email).exists()

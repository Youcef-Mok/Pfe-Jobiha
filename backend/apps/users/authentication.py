#  backend/apps/users/authentication.py

"""
Custom JWT authentication that works with Utilisateur (plain models.Model)
instead of Django's default auth User model.

simplejwt's default JWTAuthentication uses get_user_model() which expects
AbstractUser. We override get_user() to query Utilisateur directly.
"""
from rest_framework_simplejwt.authentication import JWTAuthentication as BaseJWTAuthentication
from rest_framework_simplejwt.exceptions import AuthenticationFailed, InvalidToken
from rest_framework_simplejwt.settings import api_settings


class JWTAuthentication(BaseJWTAuthentication):
    """
    JWT authentication backend for Utilisateur model.

    Token payload contains 'user_id' which maps to Utilisateur.id.
    """

    def get_user(self, validated_token):
        from apps.users.models import Utilisateur

        try:
            user_id = validated_token[api_settings.USER_ID_CLAIM]
        except KeyError:
            raise InvalidToken('Token contained no recognizable user identification')

        try:
            user = Utilisateur.objects.get(pk=user_id)
        except Utilisateur.DoesNotExist:
            raise AuthenticationFailed('User not found')

        if user.statut_compte != 'actif':
            raise AuthenticationFailed('User account is disabled')

        return user

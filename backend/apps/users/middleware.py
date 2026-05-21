# apps/users/middleware.py

from channels.db import database_sync_to_async
from channels.middleware import BaseMiddleware
from django.contrib.auth.models import AnonymousUser
from rest_framework_simplejwt.tokens import AccessToken
from apps.users.models import Utilisateur
from urllib.parse import parse_qs


class JWTAuthMiddleware(BaseMiddleware):
    """
    Custom middleware to authenticate WebSocket connections using JWT tokens.
    
    The token can be passed in two ways:
    1. As a query parameter: ws://host/path/?token=<jwt_token>
    2. In the Authorization header (if supported by the client)
    """

    async def __call__(self, scope, receive, send):
        # Extract token from query string
        query_string = scope.get('query_string', b'').decode()
        query_params = parse_qs(query_string)
        token = query_params.get('token', [None])[0]

        # If no token in query string, try headers
        if not token:
            headers = dict(scope.get('headers', []))
            auth_header = headers.get(b'authorization', b'').decode()
            if auth_header.startswith('Bearer '):
                token = auth_header[7:]

        # Authenticate user
        if token:
            scope['user'] = await self.get_user_from_token(token)
        else:
            scope['user'] = AnonymousUser()

        return await super().__call__(scope, receive, send)

    @database_sync_to_async
    def get_user_from_token(self, token):
        """Validate JWT token and return the associated user."""
        try:
            access_token = AccessToken(token)
            user_id = access_token.get('user_id')
            user = Utilisateur.objects.get(id=user_id)
            return user
        except Exception as e:
            print(f"[JWTAuthMiddleware] Token validation failed: {e}")
            return AnonymousUser()

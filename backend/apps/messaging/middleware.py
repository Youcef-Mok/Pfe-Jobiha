from channels.middleware import BaseMiddleware
from channels.db import database_sync_to_async


class JWTWebSocketMiddleware(BaseMiddleware):

    async def __call__(self, scope, receive, send):
        query_string = scope.get("query_string", b"").decode()
        params = dict(
            pair.split("=") for pair in query_string.split("&") if "=" in pair
        )
        token = params.get("token")

        if token:
            scope["user"] = await self._get_user(token)
        else:
            # Anonymous — consumer will reject on connect()
            from apps.users.models import Utilisateur

            class AnonymousUser:
                is_authenticated = False
                pk = None

            scope["user"] = AnonymousUser()

        return await super().__call__(scope, receive, send)

    @database_sync_to_async
    def _get_user(self, token):
        try:
            from apps.users.authentication import JWTAuthentication
            auth = JWTAuthentication()
            validated = auth.get_validated_token(token)
            return auth.get_user(validated)
        except Exception:
            class AnonymousUser:
                is_authenticated = False
                pk = None
            return AnonymousUser()

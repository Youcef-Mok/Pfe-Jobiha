"""
ASGI config for config project.
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from django.core.asgi import get_asgi_application
from channels.routing import ProtocolTypeRouter, URLRouter
from apps.messaging.routing import websocket_urlpatterns
from apps.messaging.middleware import JWTWebSocketMiddleware

django_asgi_app = get_asgi_application()

application = ProtocolTypeRouter({
    'http': django_asgi_app,
    'websocket': JWTWebSocketMiddleware(
        URLRouter(websocket_urlpatterns)
    ),
})

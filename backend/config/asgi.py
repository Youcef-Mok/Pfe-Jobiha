import os
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')

from django.core.asgi import get_asgi_application
django_asgi_app = get_asgi_application()  # ← moved up here, before any app imports

from channels.routing import ProtocolTypeRouter, URLRouter
from channels.auth import AuthMiddlewareStack
from django.urls import path
from apps.messaging.consumers import ChatConsumer, NotificationConsumer
from apps.users.middleware import JWTAuthMiddleware

application = ProtocolTypeRouter({
    'http': django_asgi_app,
    'websocket': JWTAuthMiddleware(
        URLRouter([
            path('ws/chat/<int:conversation_id>/', ChatConsumer.as_asgi()),
            path('ws/notifications/', NotificationConsumer.as_asgi()),
        ])
    ),
})
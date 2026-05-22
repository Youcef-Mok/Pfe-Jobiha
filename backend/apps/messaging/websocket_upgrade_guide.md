# WebSocket Real-Time Upgrade Guide

> This document explains how to upgrade the current polling-based messaging
> system to real-time WebSockets using **Django Channels** + **Flutter
> web_socket_channel**.  The REST architecture was designed intentionally
> so this upgrade is a *swap*, not a rewrite.

---

## What Stays the Same

| Component | Why it survives |
|-----------|----------------|
| `Message` model | WebSockets still store messages in the DB via the same model. |
| `MessageSerializer` / `ConversationSummarySerializer` | REST endpoints remain as fallback for history, pagination, and offline sync. |
| REST views (`ConversationListView`, `ConversationDetailView`, etc.) | Used for initial page load and older message pagination. |
| `ChatRepository` (Flutter) | Still used for fetching history, sending REST fallback, marking read. |
| `ActiveChatState` / `ConversationListState` (Flutter) | The state shape doesn't change — only *how* new messages enter it. |

---

## Django Backend Changes

### 1. Install dependencies

```bash
pip install channels channels-redis daphne
```

### 2. ASGI configuration

```python
# config/asgi.py
import os
from channels.routing import ProtocolTypeRouter, URLRouter
from django.core.asgi import get_asgi_application
from apps.messaging.routing import websocket_urlpatterns
from apps.messaging.middleware import JWTWebSocketMiddleware

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')

application = ProtocolTypeRouter({
    "http": get_asgi_application(),
    "websocket": JWTWebSocketMiddleware(
        URLRouter(websocket_urlpatterns)
    ),
})
```

### 3. WebSocket routing

```python
# apps/messaging/routing.py
from django.urls import path
from . import consumers

websocket_urlpatterns = [
    path('ws/chat/<int:partner_id>/', consumers.ChatConsumer.as_asgi()),
]
```

### 4. ChatConsumer

```python
# apps/messaging/consumers.py
import json
from channels.generic.websocket import AsyncJsonWebsocketConsumer
from channels.db import database_sync_to_async
from apps.messaging.models.message import Message
from apps.messaging.serializers import MessageSerializer

class ChatConsumer(AsyncJsonWebsocketConsumer):
    async def connect(self):
        self.user = self.scope["user"]
        self.partner_id = self.scope["url_route"]["kwargs"]["partner_id"]

        # Unique room name for the pair (sorted IDs = same room for both)
        ids = sorted([self.user.pk, self.partner_id])
        self.room_group = f"chat_{ids[0]}_{ids[1]}"

        await self.channel_layer.group_add(self.room_group, self.channel_name)
        await self.accept()

    async def disconnect(self, code):
        await self.channel_layer.group_discard(self.room_group, self.channel_name)

    async def receive_json(self, content):
        contenu = content.get("contenu", "").strip()
        if not contenu:
            return

        message = await self._save_message(contenu)

        # Broadcast to the room
        await self.channel_layer.group_send(
            self.room_group,
            {
                "type": "chat.message",
                "message": message,
            },
        )

    async def chat_message(self, event):
        await self.send_json(event["message"])

    @database_sync_to_async
    def _save_message(self, contenu):
        msg = Message.objects.create(
            expediteur_id=self.user.pk,
            destinataire_id=self.partner_id,
            contenu=contenu,
        )
        msg = Message.objects.select_related("expediteur", "destinataire").get(pk=msg.pk)
        return MessageSerializer(msg).data
```

### 5. JWT middleware for WebSocket

```python
# apps/messaging/middleware.py
from channels.middleware import BaseMiddleware
from channels.db import database_sync_to_async
from apps.users.authentication import JWTAuthentication

class JWTWebSocketMiddleware(BaseMiddleware):
    async def __call__(self, scope, receive, send):
        # Extract token from query string: ws://…?token=<jwt>
        query = dict(
            x.split("=") for x in scope["query_string"].decode().split("&") if "=" in x
        )
        token = query.get("token")
        if token:
            scope["user"] = await self._get_user(token)
        return await super().__call__(scope, receive, send)

    @database_sync_to_async
    def _get_user(self, token):
        from rest_framework.request import Request
        from django.http import HttpRequest
        auth = JWTAuthentication()
        # Reuse existing JWT logic
        validated = auth.get_validated_token(token)
        return auth.get_user(validated)
```

### 6. Settings update

```python
# config/settings.py — add:
INSTALLED_APPS += ['channels', 'daphne']
ASGI_APPLICATION = 'config.asgi.application'
CHANNEL_LAYERS = {
    'default': {
        'BACKEND': 'channels_redis.core.RedisChannelLayer',
        'CONFIG': {
            'hosts': [('127.0.0.1', 6379)],
        },
    },
}
```

---

## Flutter Frontend Changes

### 1. Add dependency

```yaml
# pubspec.yaml
dependencies:
  web_socket_channel: ^2.4.0
```

### 2. ChatWebSocketService

```dart
// lib/features/messaging/data/chat_websocket_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'models/chat_model.dart';

class ChatWebSocketService {
  WebSocketChannel? _channel;
  final _messageController = StreamController<MessageModel>.broadcast();

  Stream<MessageModel> get onMessage => _messageController.stream;

  void connect(int partnerId, String accessToken) {
    final uri = Uri.parse(
      'ws://YOUR_HOST/ws/chat/$partnerId/?token=$accessToken',
    );
    _channel = WebSocketChannel.connect(uri);
    _channel!.stream.listen(
      (data) {
        final json = jsonDecode(data as String) as Map<String, dynamic>;
        _messageController.add(MessageModel.fromJson(json));
      },
      onError: (_) => _reconnect(partnerId, accessToken),
      onDone: () => _reconnect(partnerId, accessToken),
    );
  }

  void send(String contenu) {
    _channel?.sink.add(jsonEncode({'contenu': contenu}));
  }

  void _reconnect(int partnerId, String token) {
    Future.delayed(const Duration(seconds: 3), () {
      connect(partnerId, token);
    });
  }

  void dispose() {
    _channel?.sink.close();
    _messageController.close();
  }
}
```

### 3. Swap in ActiveChatNotifier

The **only change** in the notifier:

```dart
// BEFORE (polling):
void startPolling() {
  _pollTimer = Timer.periodic(5.seconds, (_) => _pollNewMessages());
}

// AFTER (WebSocket):
void connectWebSocket() {
  _wsService.connect(partnerId, accessToken);
  _wsService.onMessage.listen((msg) {
    state = state.copyWith(messages: [...state.messages, msg]);
  });
}
```

The rest of `ActiveChatNotifier` (sendMessage, loadMore, markAllRead) stays
identical because those still use REST.

---

## Why This Architecture Is WebSocket-Ready

1. **State shape is delivery-agnostic.**  `ActiveChatState.messages` is just a
   list.  Whether a new message comes from a poll response or a WebSocket
   event, it's appended the same way.

2. **Polling is isolated in two methods** (`startPolling` / `stopPolling`).
   Swapping them for `connectWebSocket` / `dispose` is a ~20-line change.

3. **REST endpoints survive.**  They handle history loading, pagination,
   mark-as-read — things WebSockets shouldn't do.

4. **The `ChatRemoteSource` stays as fallback.**  If the WebSocket
   disconnects, the app can silently fall back to polling until reconnected.

---

## Recommended Migration Order

1. Get Redis running (Docker: `docker run -p 6379:6379 redis`)
2. Install `channels` + `daphne`, update settings
3. Create `consumers.py`, `routing.py`, `middleware.py`
4. Test with a WebSocket client (e.g., Postman)
5. Add `web_socket_channel` to Flutter
6. Create `ChatWebSocketService`
7. Swap polling for WebSocket in `ActiveChatNotifier`
8. Keep polling as automatic fallback on WS disconnect

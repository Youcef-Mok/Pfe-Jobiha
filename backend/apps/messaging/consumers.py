import json
from channels.generic.websocket import AsyncJsonWebsocketConsumer
from channels.db import database_sync_to_async
from apps.messaging.models.message import Message
from apps.messaging.serializers import MessageSerializer


class ChatConsumer(AsyncJsonWebsocketConsumer):

    async def connect(self):
        self.user = self.scope.get("user")

        # Reject unauthenticated connections
        if not self.user or not self.user.is_authenticated:
            await self.close(code=4001)
            return

        self.partner_id = int(self.scope["url_route"]["kwargs"]["partner_id"])

        # Deterministic room name — same for both participants
        ids = sorted([self.user.pk, self.partner_id])
        self.room_group = f"chat_{ids[0]}_{ids[1]}"

        await self.channel_layer.group_add(self.room_group, self.channel_name)
        await self.accept()

    async def disconnect(self, code):
        if hasattr(self, "room_group"):
            await self.channel_layer.group_discard(self.room_group, self.channel_name)

    async def receive_json(self, content):
        contenu = content.get("contenu", "").strip()
        if not contenu:
            return

        message_data = await self._save_message(contenu)

        await self.channel_layer.group_send(
            self.room_group,
            {
                "type": "chat.message",
                "message": message_data,
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

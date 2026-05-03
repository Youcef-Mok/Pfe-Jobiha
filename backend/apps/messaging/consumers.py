from channels.generic.websocket import AsyncJsonWebsocketConsumer
from channels.db import database_sync_to_async
from apps.messaging.models.message import Message
from apps.messaging.serializers import MessageSerializer


class ChatConsumer(AsyncJsonWebsocketConsumer):
    """
    WebSocket consumer for real-time chat between two users.

    Supported incoming actions (via receive_json):
      {"type": "send_message",  "contenu": "..."}
      {"type": "mark_read"}
      {"type": "typing_start"}
      {"type": "typing_stop"}

    Outgoing events broadcast to the room group:
      chat.message       — new message (serialized MessageSerializer data)
      chat.read_receipt   — partner marked messages as read
      chat.typing         — partner started/stopped typing
    """

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

    # ── Incoming message dispatcher ──────────────────────────────────────────

    async def receive_json(self, content):
        action = content.get("type", "send_message")

        if action == "send_message":
            await self._handle_send_message(content)
        elif action == "mark_read":
            await self._handle_mark_read()
        elif action == "typing_start":
            await self._handle_typing(is_typing=True)
        elif action == "typing_stop":
            await self._handle_typing(is_typing=False)

    # ── Action handlers ──────────────────────────────────────────────────────

    async def _handle_send_message(self, content):
        contenu = content.get("contenu", "").strip()
        if not contenu:
            return

        message_data = await self._save_message(contenu)

        await self.channel_layer.group_send(
            self.room_group,
            {
                "type": "chat.message",
                "message": message_data,
                "sender_channel": self.channel_name,
            },
        )

    async def _handle_mark_read(self):
        """Mark all unread messages FROM the partner TO this user as read."""
        count = await self._mark_conversation_read()

        if count > 0:
            await self.channel_layer.group_send(
                self.room_group,
                {
                    "type": "chat.read_receipt",
                    "reader_id": self.user.pk,
                    "partner_id": self.partner_id,
                    "count": count,
                },
            )

    async def _handle_typing(self, is_typing):
        """Broadcast typing status to the room (excludes sender via user_id check on client)."""
        await self.channel_layer.group_send(
            self.room_group,
            {
                "type": "chat.typing",
                "user_id": self.user.pk,
                "is_typing": is_typing,
            },
        )

    # ── Group event handlers (called by channel_layer.group_send) ────────────

    async def chat_message(self, event):
        """Broadcast a new message to all room members (except the sender)."""
        # Skip echo to the sender — their client already has the message
        # from the REST response or from optimistic local append.
        # sender_channel is set by WS-originated sends;
        # sender_id is set by REST-originated broadcasts.
        if event.get("sender_channel") == self.channel_name:
            return
        if event.get("sender_id") == self.user.pk:
            return
        await self.send_json({
            "type": "new_message",
            "message": event["message"],
        })

    async def chat_read_receipt(self, event):
        """Notify the partner that their messages were read (skip the reader)."""
        # Don't echo read receipt back to the person who triggered it
        if event["reader_id"] == self.user.pk:
            return
        await self.send_json({
            "type": "read_receipt",
            "reader_id": event["reader_id"],
            "partner_id": event["partner_id"],
            "count": event["count"],
        })

    async def chat_typing(self, event):
        """Notify room members of typing status."""
        # Don't echo typing back to the sender
        if event["user_id"] == self.user.pk:
            return
        await self.send_json({
            "type": "typing",
            "user_id": event["user_id"],
            "is_typing": event["is_typing"],
        })

    # ── Database helpers ─────────────────────────────────────────────────────

    @database_sync_to_async
    def _save_message(self, contenu):
        msg = Message.objects.create(
            expediteur_id=self.user.pk,
            destinataire_id=self.partner_id,
            contenu=contenu,
        )
        msg = Message.objects.select_related("expediteur", "destinataire").get(pk=msg.pk)
        return MessageSerializer(msg).data

    @database_sync_to_async
    def _mark_conversation_read(self):
        return (
            Message.objects
            .filter(
                expediteur_id=self.partner_id,
                destinataire_id=self.user.pk,
                est_lu=False,
            )
            .update(est_lu=True)
        )
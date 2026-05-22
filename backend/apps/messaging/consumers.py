from channels.generic.websocket import AsyncJsonWebsocketConsumer
from channels.db import database_sync_to_async
from apps.messaging.models.message import Message
from apps.messaging.models.conversation import ConversationMember, ReadCursor
from apps.messaging.serializers import MessageSerializer


class ChatConsumer(AsyncJsonWebsocketConsumer):
    """
    WebSocket consumer for real-time chat (DM + group).

    Supported incoming actions (via receive_json):
      {"type": "send_message",  "contenu": "..."}
      {"type": "mark_read"}
      {"type": "typing_start"}
      {"type": "typing_stop"}

    Outgoing events broadcast to the room group:
      chat.message        — new message
      chat.read_receipt    — someone marked messages as read
      chat.typing          — someone started/stopped typing
      chat.member_update   — member added/removed (triggered by REST)
    """

    async def connect(self):
        self.user = self.scope.get("user")

        # Reject unauthenticated connections
        if not self.user or not self.user.is_authenticated:
            await self.close(code=4001)
            return

        self.conversation_id = int(self.scope["url_route"]["kwargs"]["conversation_id"])

        # Verify membership
        if not await self._is_member():
            await self.close(code=4003)
            return

        # Unified room name for both DMs and groups
        self.room_group = f"conv_{self.conversation_id}"

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
        """Update the user's ReadCursor to the latest message."""
        last_read_id = await self._update_read_cursor()

        if last_read_id:
            await self.channel_layer.group_send(
                self.room_group,
                {
                    "type": "chat.read_receipt",
                    "reader_id": self.user.pk,
                    "last_read_id": last_read_id,
                },
            )

    async def _handle_typing(self, is_typing):
        """Broadcast typing status to the room."""
        await self.channel_layer.group_send(
            self.room_group,
            {
                "type": "chat.typing",
                "user_id": self.user.pk,
                "is_typing": is_typing,
            },
        )

    # ── Group event handlers ─────────────────────────────────────────────────

    async def chat_message(self, event):
        """Broadcast a new message (skip sender)."""
        if event.get("sender_channel") == self.channel_name:
            return
        if event.get("sender_id") == self.user.pk:
            return
        await self.send_json({
            "type": "new_message",
            "message": event["message"],
        })

    async def chat_read_receipt(self, event):
        """Notify others that someone read messages (skip the reader)."""
        if event["reader_id"] == self.user.pk:
            return
        await self.send_json({
            "type": "read_receipt",
            "reader_id": event["reader_id"],
            "last_read_id": event["last_read_id"],
        })

    async def chat_typing(self, event):
        """Notify room of typing status (skip sender)."""
        if event["user_id"] == self.user.pk:
            return
        await self.send_json({
            "type": "typing",
            "user_id": event["user_id"],
            "is_typing": event["is_typing"],
        })

    async def chat_member_update(self, event):
        """Notify all members when someone is added/removed."""
        await self.send_json({
            "type": "member_update",
            "action": event["action"],
            "user_id": event["user_id"],
            "user_name": event.get("user_name", ""),
        })

    # ── Database helpers ─────────────────────────────────────────────────────

    @database_sync_to_async
    def _is_member(self):
        return ConversationMember.objects.filter(
            conversation_id=self.conversation_id,
            user_id=self.user.pk,
            left_at__isnull=True,
        ).exists()

    @database_sync_to_async
    def _save_message(self, contenu):
        msg = Message.objects.create(
            conversation_id=self.conversation_id,
            expediteur_id=self.user.pk,
            contenu=contenu,
        )
        msg = Message.objects.select_related("expediteur", "conversation").get(pk=msg.pk)
        return MessageSerializer(msg).data

    @database_sync_to_async
    def _update_read_cursor(self):
        last_msg_id = (
            Message.objects
            .filter(conversation_id=self.conversation_id)
            .order_by('-date_envoi')
            .values_list('id', flat=True)
            .first()
        )
        if last_msg_id:
            ReadCursor.objects.update_or_create(
                conversation_id=self.conversation_id,
                user_id=self.user.pk,
                defaults={'last_read_message_id': last_msg_id},
            )
        return last_msg_id
from django.contrib import admin

from .models import Message
from .models.conversation import Conversation, ConversationMember, ReadCursor

admin.site.register(Message)
admin.site.register(Conversation)
admin.site.register(ConversationMember)
admin.site.register(ReadCursor)

"""
Quick test script to verify unread_count is in the API response.
Run from backend directory: python test_unread_count.py
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from apps.messaging.models.conversation import Conversation
from apps.messaging.serializers import ConversationSerializer
from apps.users.models import Utilisateur

# Get a test user
user = Utilisateur.objects.first()
if not user:
    print("No users found in database")
    exit(1)

print(f"Testing with user: {user.prenom} {user.nom} (ID: {user.id})")

# Get conversations for this user
conversations = Conversation.objects.filter(
    memberships__user=user,
    memberships__left_at__isnull=True
).distinct()[:3]

print(f"\nFound {conversations.count()} conversations")

# Serialize with context
class FakeRequest:
    def __init__(self, user):
        self.user = user

fake_request = FakeRequest(user)
serializer = ConversationSerializer(
    conversations,
    many=True,
    context={'request': fake_request}
)

# Print the data
import json
data = serializer.data
print("\n" + "="*80)
print("SERIALIZED DATA:")
print("="*80)
for conv in data:
    print(f"\nConversation ID: {conv['id']}")
    print(f"  contact_name: {conv.get('contact_name')}")
    print(f"  is_unread: {conv.get('is_unread')}")
    print(f"  unread_count: {conv.get('unread_count')} ← THIS SHOULD BE A NUMBER")
    print(f"  last_message: {conv.get('last_message', '')[:50]}...")

print("\n" + "="*80)
if any('unread_count' in conv for conv in data):
    print("✅ SUCCESS: unread_count field is present in response")
else:
    print("❌ FAIL: unread_count field is MISSING from response")
print("="*80)

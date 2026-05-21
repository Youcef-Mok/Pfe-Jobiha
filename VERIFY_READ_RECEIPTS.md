# Read Receipt Verification Guide

## Quick Test Checklist

### Prerequisites
- [ ] Backend server running: `python manage.py runserver`
- [ ] Redis running (for WebSocket channels): `redis-server`
- [ ] Two test accounts created (User A and User B)
- [ ] Flutter app installed on device/emulator

---

## Test Scenario 1: Basic Read Receipt

### Setup:
1. User A logs in on Device 1
2. User B logs in on Device 2

### Steps:

#### Step 1: User A Sends Message
```
Device 1 (User A):
1. Open conversation with User B
2. Send message: "Hello, are you there?"
3. ✅ Verify: Message shows single gray checkmark ✓
```

#### Step 2: User B Opens Conversation
```
Device 2 (User B):
1. Open conversation with User A
2. ✅ Verify: Message "Hello, are you there?" is visible
```

**Expected Backend Logs:**
```
[MessagingController] markAsRead appelé: conversationId=1
[MessagingRepositoryApi] markAsRead appelé: conversationId=1
[MessagingRepositoryApi] markAsRead réussi
POST /api/v1/conversations/1/read-all → 200 OK
WebSocket broadcast: read_receipt to conv_1
```

#### Step 3: User A Sees Update
```
Device 1 (User A):
1. Stay on conversation screen
2. ✅ Verify: Message automatically updates to double purple checkmark ✓✓
3. ✅ Verify: No manual refresh needed
```

**Expected Flutter Logs:**
```
[PrivateMessageScreen] Read receipt received: readerId=2, lastReadId=10
[MessagingController] loadConversationMessages appelé: conversationId=1
[MessagingController] Mise à jour de la conversation avec X messages
```

---

## Test Scenario 2: Offline Sender

### Setup:
1. User A sends message
2. User A closes app or goes offline
3. User B reads message

### Steps:

#### Step 1: User A Sends and Goes Offline
```
Device 1 (User A):
1. Send message: "See you tomorrow"
2. Close app or turn off WiFi
3. Message shows single checkmark ✓
```

#### Step 2: User B Reads Message
```
Device 2 (User B):
1. Open conversation
2. Read message
3. Backend marks as read
```

#### Step 3: User A Comes Back Online
```
Device 1 (User A):
1. Open app
2. Open conversation with User B
3. ✅ Verify: Message now shows double checkmark ✓✓
```

**Why it works:**
- Backend stores read status in `ReadCursor` table
- When User A reloads, serializer computes `is_read=true`
- No real-time update needed (acceptable)

---

## Test Scenario 3: Multiple Messages

### Steps:

#### User A Sends Multiple Messages
```
Device 1 (User A):
1. Send: "Hey"
2. Send: "How are you?"
3. Send: "Are you free today?"
4. All show single checkmark ✓
```

#### User B Opens Chat
```
Device 2 (User B):
1. Open conversation
2. All messages visible
```

#### User A Sees Update
```
Device 1 (User A):
1. ✅ Verify: ALL messages update to double checkmark ✓✓
2. ✅ Verify: Update happens simultaneously
```

**Why it works:**
- `ReadCursor.last_read_message_id` points to latest message
- Serializer checks: `cursor.last_read_message_id >= message.id`
- All messages with `id <= last_read_id` show as read

---

## Test Scenario 4: Group Conversation

### Setup:
1. Create group with User A, User B, User C

### Steps:

#### User A Sends Message
```
Device 1 (User A):
1. Send message in group
2. Shows single checkmark ✓
```

#### User B Reads
```
Device 2 (User B):
1. Open group conversation
2. Read message
```

#### User A Sees Partial Read
```
Device 1 (User A):
1. ✅ Verify: Message still shows single checkmark ✓
   (because User C hasn't read yet)
```

#### User C Reads
```
Device 3 (User C):
1. Open group conversation
2. Read message
```

#### User A Sees Full Read
```
Device 1 (User A):
1. ✅ Verify: Message updates to double checkmark ✓✓
   (all members have read)
```

**Note:** Current implementation shows read when ANY member reads. For "read by all" logic, backend would need modification.

---

## Test Scenario 5: WebSocket Reconnection

### Steps:

#### Simulate Connection Loss
```
Device 1 (User A):
1. Open conversation
2. Turn off WiFi for 5 seconds
3. Turn WiFi back on
```

**Expected Logs:**
```
[WebSocket] Connection lost
[WebSocket] Scheduling reconnect in 3 seconds
[WebSocket] Reconnected successfully
```

#### Verify Functionality
```
Device 2 (User B):
1. Send message while User A was offline
2. User A should receive it after reconnection
```

---

## Test Scenario 6: Backend Verification

### Check Database State

#### Before User B Reads:
```sql
-- Connect to database
python manage.py dbshell

-- Check ReadCursor
SELECT * FROM messaging_readcursor 
WHERE conversation_id = 1;

-- Expected:
-- user_id | last_read_message_id
-- --------|---------------------
--    1    |        10
--    2    |        8            ← User B hasn't read latest
```

#### After User B Reads:
```sql
SELECT * FROM messaging_readcursor 
WHERE conversation_id = 1;

-- Expected:
-- user_id | last_read_message_id
-- --------|---------------------
--    1    |        10
--    2    |        10           ← ✅ Updated
```

### Check WebSocket Broadcast

#### Enable Django Channels Logging:
```python
# settings.py
LOGGING = {
    'version': 1,
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
        },
    },
    'loggers': {
        'channels': {
            'handlers': ['console'],
            'level': 'DEBUG',
        },
    },
}
```

#### Expected Logs:
```
[channels] Group send: conv_1
[channels] Event type: chat.read_receipt
[channels] Payload: {'reader_id': 2, 'last_read_id': 10}
```

---

## Test Scenario 7: API Endpoint Testing

### Using cURL:

#### 1. Login and Get Token
```bash
curl -X POST http://192.168.100.9:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "usera@test.com", "password": "password123"}'

# Response:
# {"access": "eyJ0eXAiOiJKV1QiLCJhbGc...", "refresh": "..."}
```

#### 2. Mark Conversation as Read
```bash
curl -X POST http://192.168.100.9:8000/api/v1/conversations/1/read-all \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc..." \
  -H "Content-Type: application/json"

# Expected Response:
# {"last_read_id": 10}
```

#### 3. Get Messages with Read Status
```bash
curl -X GET http://192.168.100.9:8000/api/v1/conversations/1 \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc..."

# Expected Response:
# {
#   "results": [
#     {
#       "id": 10,
#       "contenu": "Hello",
#       "is_read": true,  ← ✅ Should be true
#       "is_mine": true,
#       ...
#     }
#   ]
# }
```

---

## Test Scenario 8: WebSocket Testing

### Using Browser Console:

```javascript
// 1. Get auth token from localStorage or login
const token = "eyJ0eXAiOiJKV1QiLCJhbGc...";

// 2. Connect to WebSocket
const ws = new WebSocket(`ws://192.168.100.9:8000/ws/chat/1/?token=${token}`);

// 3. Listen for messages
ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  console.log('Received:', data);
  
  if (data.type === 'read_receipt') {
    console.log('✅ Read receipt received!');
    console.log('Reader ID:', data.reader_id);
    console.log('Last Read ID:', data.last_read_id);
  }
};

// 4. Send mark_read event
ws.send(JSON.stringify({
  type: 'mark_read'
}));

// Expected console output:
// Received: {type: "read_receipt", reader_id: 2, last_read_id: 10}
// ✅ Read receipt received!
// Reader ID: 2
// Last Read ID: 10
```

---

## Common Issues & Solutions

### Issue 1: Checkmark Not Updating

**Symptoms:**
- User B reads message
- User A's checkmark stays single ✓

**Debug Steps:**
```
1. Check Flutter logs for WebSocket connection:
   [WebSocket] Connection lost
   → Solution: Check WiFi, backend running

2. Check backend logs for read receipt broadcast:
   POST /api/v1/conversations/1/read-all → 200 OK
   → If missing: Check if markAsRead() is called

3. Check Flutter logs for read receipt received:
   [PrivateMessageScreen] Read receipt received
   → If missing: Check WebSocket subscription
```

**Solutions:**
- Restart backend server
- Check Redis is running: `redis-cli ping` → should return `PONG`
- Check WebSocket URL in `api_endpoints.dart`
- Verify token is valid

### Issue 2: WebSocket Not Connecting

**Symptoms:**
- No real-time updates
- Flutter logs show connection errors

**Debug Steps:**
```
1. Check WebSocket URL:
   Expected: ws://192.168.100.9:8000/ws/chat/1/
   
2. Check backend routing:
   python manage.py show_urls | grep ws
   
3. Check ASGI configuration:
   # asgi.py should have:
   application = ProtocolTypeRouter({
       "http": get_asgi_application(),
       "websocket": AuthMiddlewareStack(
           URLRouter(messaging.routing.websocket_urlpatterns)
       ),
   })
```

**Solutions:**
- Use correct IP address (not localhost on physical device)
- Check firewall settings
- Verify Django Channels installed: `pip list | grep channels`

### Issue 3: Read Status Not Persisting

**Symptoms:**
- Checkmark updates, then reverts on reload

**Debug Steps:**
```
1. Check database:
   SELECT * FROM messaging_readcursor WHERE conversation_id = 1;
   
2. Check if ReadCursor is being updated:
   # In views.py, add logging:
   print(f"Updated ReadCursor: user={request.user.id}, last_read={last_read_id}")
```

**Solutions:**
- Check database migrations: `python manage.py migrate`
- Verify `mark_conversation_read()` service function
- Check for database transaction rollbacks

### Issue 4: Wrong User Sees Update

**Symptoms:**
- User B (reader) sees their own messages as read
- User A (sender) doesn't see update

**Debug Steps:**
```
1. Check serializer logic:
   # Should skip sender in broadcast:
   if event["reader_id"] == self.user.pk:
       return
   
2. Check is_mine field:
   # In MessageSerializer:
   obj.expediteur_id == request.user.id
```

**Solutions:**
- Verify `get_is_read()` logic in serializer
- Check `chat_read_receipt()` in consumer

---

## Performance Testing

### Load Test: Multiple Users

```python
# test_read_receipts.py
import asyncio
import websockets
import json

async def simulate_user(user_id, conversation_id, token):
    uri = f"ws://192.168.100.9:8000/ws/chat/{conversation_id}/?token={token}"
    async with websockets.connect(uri) as ws:
        # Send mark_read
        await ws.send(json.dumps({"type": "mark_read"}))
        
        # Listen for receipts
        async for message in ws:
            data = json.loads(message)
            if data["type"] == "read_receipt":
                print(f"User {user_id} received receipt: {data}")

# Run 10 concurrent users
async def main():
    tasks = [
        simulate_user(i, 1, f"token_{i}") 
        for i in range(10)
    ]
    await asyncio.gather(*tasks)

asyncio.run(main())
```

### Expected Results:
- ✅ All users receive read receipts
- ✅ No duplicate receipts
- ✅ Response time < 100ms

---

## Monitoring & Logging

### Enable Detailed Logging:

#### Flutter:
```dart
// In messaging_repository_api.dart
print('[DEBUG] markAsRead called: conversationId=$conversationId');
print('[DEBUG] Response: ${response.data}');
```

#### Django:
```python
# In views.py
import logging
logger = logging.getLogger(__name__)

logger.info(f"User {request.user.id} marking conversation {conv_id} as read")
logger.info(f"Updated ReadCursor: last_read_id={last_read_id}")
```

### Check Logs:
```bash
# Flutter logs
flutter logs

# Django logs
tail -f /path/to/django.log

# Redis logs (WebSocket)
redis-cli monitor
```

---

## Success Criteria

### ✅ All Tests Pass When:

1. **Immediate Update:**
   - User B opens chat → User A sees double checkmark within 1 second

2. **Persistence:**
   - User A closes and reopens app → checkmark still double

3. **Offline Handling:**
   - User A offline → User B reads → User A comes back → sees double checkmark

4. **Multiple Messages:**
   - All messages update simultaneously when read

5. **WebSocket Resilience:**
   - Connection drops → auto-reconnects → functionality restored

6. **Database Consistency:**
   - `ReadCursor` table reflects actual read status
   - No orphaned or incorrect entries

7. **Performance:**
   - Read receipt delivery < 1 second
   - No UI lag or freezing
   - Works with 100+ messages in conversation

---

## Rollback Plan

If issues occur in production:

### Quick Disable:
```dart
// In private_message_screen.dart
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      ref.read(messagingControllerProvider.notifier)
         .loadConversationMessages(widget.conversation.id);
      
      // ❌ Comment out these lines to disable:
      // ref.read(messagingControllerProvider.notifier)
      //    .markAsRead(widget.conversation.id);
      // _initWebSocket();
    }
  });
}
```

### Revert Commits:
```bash
git log --oneline
# Find commit before read receipt changes
git revert <commit-hash>
```

---

**Testing Status:** ⏳ Pending  
**Last Updated:** 2026-05-21  
**Next Steps:** Run Test Scenario 1-3 with real devices

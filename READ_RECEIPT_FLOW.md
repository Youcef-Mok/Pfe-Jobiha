# Read Receipt Flow Diagram

## Before Fix ❌

```
User A (Sender)                    Backend                    User B (Receiver)
     |                                |                              |
     |------ Send Message ----------->|                              |
     |<----- 201 Created -------------|                              |
     |                                |                              |
     | (Shows single checkmark)       |                              |
     |                                |                              |
     |                                |<----- Opens Chat ------------|
     |                                |                              |
     |                                |------ Load Messages -------->|
     |                                |                              |
     |                                |                              | (Reads messages)
     |                                |                              |
     | ❌ NO UPDATE                   | ❌ NO READ RECEIPT SENT      |
     |                                |                              |
     | (Still shows single checkmark) |                              |
```

---

## After Fix ✅

```
User A (Sender)                    Backend                    User B (Receiver)
     |                                |                              |
     |------ Send Message ----------->|                              |
     |<----- 201 Created -------------|                              |
     |                                |                              |
     | (Shows single checkmark)       |                              |
     |                                |                              |
     |                                |<----- Opens Chat ------------|
     |                                |                              |
     |                                |<----- Load Messages ---------|
     |                                |                              |
     |                                |<----- POST /read-all --------|  ✅ NEW
     |                                |                              |
     |                                | ✅ Update ReadCursor         |
     |                                |                              |
     |                                |------ Broadcast WS --------->|
     |<------ WS: read_receipt -------|                              |
     |                                |                              |
     | ✅ Reload Messages             |                              |
     |                                |                              |
     | (Shows double checkmark 💜)    |                              |
```

---

## Detailed Sequence Diagram

```
┌─────────┐                 ┌─────────┐                 ┌─────────┐
│ User A  │                 │ Backend │                 │ User B  │
│(Sender) │                 │         │                 │(Reader) │
└────┬────┘                 └────┬────┘                 └────┬────┘
     │                           │                           │
     │  1. Send Message          │                           │
     ├──────────────────────────>│                           │
     │                           │                           │
     │  2. 201 Created           │                           │
     │<──────────────────────────┤                           │
     │                           │                           │
     │  Message shows:           │                           │
     │  ✓ (single gray check)    │                           │
     │                           │                           │
     │                           │  3. User B opens chat     │
     │                           │<──────────────────────────┤
     │                           │                           │
     │                           │  4. GET /conversations/X  │
     │                           │<──────────────────────────┤
     │                           │                           │
     │                           │  5. Messages (isRead=false)│
     │                           ├──────────────────────────>│
     │                           │                           │
     │                           │  6. POST /read-all        │
     │                           │<──────────────────────────┤
     │                           │                           │
     │                           │  7. Update ReadCursor     │
     │                           │     (last_read_id = X)    │
     │                           │                           │
     │  8. WS: read_receipt      │  9. WS: read_receipt      │
     │     {reader_id: B,        │     {reader_id: B,        │
     │      last_read_id: X}     │      last_read_id: X}     │
     │<──────────────────────────┼──────────────────────────>│
     │                           │                           │
     │  10. Reload messages      │                           │
     ├──────────────────────────>│                           │
     │                           │                           │
     │  11. Messages (isRead=true)│                          │
     │<──────────────────────────┤                           │
     │                           │                           │
     │  Message now shows:       │                           │
     │  ✓✓ (double purple check) │                           │
     │                           │                           │
```

---

## Component Interaction

```
┌─────────────────────────────────────────────────────────────────┐
│                    PrivateMessageScreen                         │
│                                                                 │
│  initState() {                                                  │
│    ✅ loadConversationMessages()                                │
│    ✅ markAsRead()              ← NEW                           │
│    ✅ _initWebSocket()          ← NEW                           │
│  }                                                              │
│                                                                 │
│  _initWebSocket() {                                             │
│    wsService.connect()                                          │
│    wsService.readReceipts.listen((event) {                      │
│      ✅ loadConversationMessages()  ← Refresh on receipt        │
│    })                                                           │
│  }                                                              │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                  MessagingController                            │
│                                                                 │
│  markAsRead(conversationId) {                                   │
│    ✅ _repo.markAsRead(conversationId)                          │
│    ✅ loadConversationMessages(conversationId)                  │
│  }                                                              │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│              MessagingRepositoryApi                             │
│                                                                 │
│  markAsRead(conversationId) {                                   │
│    ✅ markConversationRead(int.parse(conversationId))           │
│  }                                                              │
│                                                                 │
│  markConversationRead(conversationId) {                         │
│    ✅ POST /conversations/<id>/read-all                         │
│  }                                                              │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Django Backend                               │
│                                                                 │
│  MarquerConvLueView.post() {                                    │
│    ✅ Update ReadCursor table                                   │
│    ✅ Broadcast WebSocket event                                 │
│  }                                                              │
│                                                                 │
│  ChatConsumer.chat_read_receipt() {                             │
│    ✅ Send to all members except reader                         │
│  }                                                              │
└─────────────────────────────────────────────────────────────────┘
```

---

## Database State Changes

### Before User B Opens Chat:

```sql
-- ReadCursor table
conversation_id | user_id | last_read_message_id
----------------|---------|---------------------
      1         |    A    |        10
      1         |    B    |        8            ← User B hasn't read latest

-- Message table (simplified)
id | conversation_id | expediteur_id | contenu
---|-----------------|---------------|----------
 9 |       1         |      A        | "Hello"
10 |       1         |      A        | "How are you?"  ← Unread by B
```

### After User B Opens Chat:

```sql
-- ReadCursor table
conversation_id | user_id | last_read_message_id
----------------|---------|---------------------
      1         |    A    |        10
      1         |    B    |        10           ← ✅ Updated to latest

-- Message table (unchanged)
id | conversation_id | expediteur_id | contenu
---|-----------------|---------------|----------
 9 |       1         |      A        | "Hello"
10 |       1         |      A        | "How are you?"  ← Now read by B
```

### Serializer Computation:

```python
# For User A viewing message #10:
# obj.expediteur_id == request.user.id (True, it's their message)
# Check User B's ReadCursor: last_read_message_id = 10
# 10 >= 10 → True → is_read = True ✅
```

---

## WebSocket Event Format

### Outgoing (Backend → Flutter):

```json
{
  "type": "read_receipt",
  "reader_id": 2,
  "last_read_id": 10
}
```

### Flutter Handling:

```dart
_wsService!.readReceipts.listen((event) {
  // event.readerId = 2 (User B)
  // event.lastReadId = 10
  
  // Reload messages to get updated isRead status
  ref.read(messagingControllerProvider.notifier)
     .loadConversationMessages(widget.conversation.id);
});
```

---

## Message Bubble Visual States

### Before Read:
```
┌─────────────────────────────┐
│ How are you?                │
│                             │
│                    10:30 ✓  │  ← Single gray checkmark
└─────────────────────────────┘
```

### After Read:
```
┌─────────────────────────────┐
│ How are you?                │
│                             │
│                    10:30 ✓✓ │  ← Double purple checkmark
└─────────────────────────────┘
```

### Code:
```dart
Icon(
  message.isRead ? Icons.done_all : Icons.done,
  size: 12,
  color: message.isRead
      ? const Color(0xFF401E66)  // Purple when read
      : const Color(0xFF7C7580), // Gray when not read
)
```

---

## Error Handling

### WebSocket Disconnection:
```
User A                    Backend                    User B
   |                         |                          |
   |  WS Connected           |                          |
   |<----------------------->|                          |
   |                         |                          |
   |  ❌ Connection Lost     |                          |
   |   X                     |                          |
   |                         |                          |
   |  ⏱️ Auto-reconnect      |                          |
   |   (3 seconds)           |                          |
   |                         |                          |
   |  ✅ Reconnected         |                          |
   |<----------------------->|                          |
   |                         |                          |
   |  Missed events?         |                          |
   |  → Reload on next       |                          |
   |    conversation open    |                          |
```

### REST API Fallback:
```
If WebSocket fails:
  ✅ Messages still marked as read via REST API
  ✅ Sender sees update when they reload conversation
  ❌ No real-time update (acceptable degradation)
```

---

## Performance Considerations

### Optimizations:
1. **Debouncing:** Only send read receipt once per conversation session
2. **Batching:** Group multiple read receipts if user scrolls quickly
3. **Caching:** Store read status locally to avoid unnecessary API calls

### Current Implementation:
- ✅ Single read receipt per conversation open
- ✅ WebSocket reconnection with exponential backoff
- ✅ Broadcast only to active conversation members
- ✅ Skip sender in read receipt broadcast

---

**Legend:**
- ✅ = Implemented
- ❌ = Not working / Missing
- ⏱️ = Automatic retry
- 💜 = Purple color (read status)

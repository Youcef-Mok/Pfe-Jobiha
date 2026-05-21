# Messaging Real-Time Fixes

## Summary
Fixed two critical bugs in the messaging system:
1. **Real-time message delivery** - Messages now appear instantly without leaving/re-entering chat
2. **Conversation list ordering** - Conversations are now sorted by last message time (newest first)

---

## Bug 1: Real-Time Message Delivery

### Problem
New messages only appeared after leaving and re-entering the chat screen. The WebSocket was connected but messages weren't updating the UI in real-time.

### Root Causes
1. **Backend**: WebSocket consumer was skipping the sender when broadcasting messages
2. **Frontend**: WebSocket `newMessages` stream wasn't being listened to in the chat screen

### Changes Made

#### Backend: `apps/messaging/consumers.py`
**Changed:** `chat_message` method to broadcast to ALL members including sender

**Before:**
```python
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
```

**After:**
```python
async def chat_message(self, event):
    """Broadcast a new message to ALL members (including sender for consistency)."""
    await self.send_json({
        "type": "new_message",
        "message": event["message"],
    })
```

**Why:** Broadcasting to all members (including sender) ensures consistency. The sender's UI will update via WebSocket just like other participants, preventing race conditions and ensuring everyone sees the same state.

#### Frontend: `private_message_screen.dart`

**Added:** WebSocket listener for new messages

1. **Added new subscription field:**
```dart
StreamSubscription? _newMessageSubscription;
```

2. **Added listener in `_initWebSocket()`:**
```dart
// Listen for new messages from WebSocket
_newMessageSubscription = _wsService!.newMessages.listen((messageDto) {
  print('[PrivateMessageScreen] New message received via WebSocket: ${messageDto.contenu}');
  // Reload conversation to show the new message
  ref
      .read(messagingControllerProvider.notifier)
      .loadConversationMessages(widget.conversation.id);
  
  // Scroll to bottom to show new message
  Future.delayed(const Duration(milliseconds: 300), () {
    if (mounted && _scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  });
});
```

3. **Added cleanup in `dispose()`:**
```dart
_newMessageSubscription?.cancel();
```

### How It Works Now

1. **User A sends message:**
   - Message saved to database via REST API
   - Backend broadcasts via WebSocket to all members (including User A)

2. **All connected users (including sender):**
   - Receive WebSocket event with new message
   - UI automatically reloads conversation messages
   - Screen auto-scrolls to show new message

3. **Result:**
   - Messages appear instantly for all users
   - No need to leave/re-enter chat
   - Consistent experience for sender and receivers

---

## Bug 2: Conversation List Ordering

### Problem
Conversation list was not consistently ordered by last message time. Active conversations didn't bubble to the top when new messages arrived.

### Root Cause
While the backend service already sorted conversations by last message date, the Flutter app wasn't re-sorting after:
- Loading conversations
- Receiving new messages via WebSocket
- Sending messages

### Changes Made

#### Frontend: `chat_controller.dart`

**Changed:** Added sorting in `_load()` and `loadConversationMessages()`

1. **In `_load()` method:**
```dart
// Sort conversations by last message time (newest first)
convs.sort((a, b) {
  final aTime = a.lastMessageTime ?? DateTime(2000);
  final bTime = b.lastMessageTime ?? DateTime(2000);
  return bTime.compareTo(aTime); // newest first
});
```

2. **In `loadConversationMessages()` method:**
```dart
// Re-sort conversations by last message time after updating
updatedConversations.sort((a, b) {
  final aTime = a.lastMessageTime ?? DateTime(2000);
  final bTime = b.lastMessageTime ?? DateTime(2000);
  return bTime.compareTo(aTime); // newest first
});
```

### How It Works Now

1. **Initial load:**
   - Backend returns conversations sorted by last message time
   - Flutter sorts again to ensure consistency

2. **New message received:**
   - Conversation is updated with new message
   - List is re-sorted
   - Active conversation moves to top

3. **Result:**
   - Most recent conversations always at the top
   - List updates in real-time as messages arrive
   - Consistent ordering across all scenarios

---

## Testing

### Test Real-Time Messages

1. **Setup:**
   - Open chat between User A and User B on two devices
   - Ensure both are connected (check WebSocket logs)

2. **Test:**
   - User A sends: "Hello"
   - **Expected:** Message appears instantly on both screens
   - User B sends: "Hi there"
   - **Expected:** Message appears instantly on both screens

3. **Verify logs:**
   ```
   [ChatWebSocketService] WebSocket connected successfully
   [PrivateMessageScreen] New message received via WebSocket: Hello
   ```

### Test Conversation Ordering

1. **Setup:**
   - Have 3+ conversations with different last message times
   - Open messaging screen

2. **Test:**
   - Note the order (newest first)
   - Send a message in an older conversation
   - **Expected:** That conversation moves to the top
   - Receive a message in another conversation
   - **Expected:** That conversation moves to the top

3. **Verify:**
   - Most recent conversation is always at position 0
   - Order updates without manual refresh

---

## Files Modified

### Backend
- `backend/apps/messaging/consumers.py` - Broadcast messages to all members

### Frontend
- `frontend/lib/features/messaging/screens/private_message_screen.dart` - Listen to WebSocket new messages
- `frontend/lib/features/messaging/domain/chat_controller.dart` - Sort conversations by last message time

---

## Technical Details

### WebSocket Message Flow

```
User A sends message
    ↓
REST API: POST /conversations/{id}/messages
    ↓
Message saved to database
    ↓
Backend broadcasts via WebSocket to group "conv_{id}"
    ↓
All connected members receive:
{
  "type": "new_message",
  "message": {
    "id": 123,
    "contenu": "Hello",
    "expediteur_id": 1,
    "date_envoi": "2026-05-21T10:30:00Z",
    ...
  }
}
    ↓
Flutter WebSocketService parses and emits to newMessages stream
    ↓
PrivateMessageScreen listener triggers
    ↓
Conversation messages reloaded
    ↓
UI updates with new message
    ↓
Auto-scroll to bottom
```

### Conversation Sorting Logic

```dart
// Sort by last message time, newest first
conversations.sort((a, b) {
  final aTime = a.lastMessageTime ?? DateTime(2000); // Default to old date if null
  final bTime = b.lastMessageTime ?? DateTime(2000);
  return bTime.compareTo(aTime); // Descending order
});
```

**Why DateTime(2000)?**
- Conversations with no messages get a default old date
- Ensures they appear at the bottom of the list
- Prevents null comparison errors

---

## Benefits

### Real-Time Messages
✅ Instant message delivery  
✅ No manual refresh needed  
✅ Consistent experience for all users  
✅ Auto-scroll to new messages  
✅ Works for both sender and receivers  

### Conversation Ordering
✅ Most recent conversations at top  
✅ Updates in real-time  
✅ Consistent across all scenarios  
✅ Easy to find active conversations  
✅ Better user experience  

---

## Troubleshooting

### Messages Still Not Appearing in Real-Time

1. **Check WebSocket connection:**
   ```
   [ChatWebSocketService] WebSocket connected successfully
   ```
   If not connected, check token and server status

2. **Check message broadcast:**
   - Backend should log: `group_send to conv_{id}`
   - Frontend should log: `New message received via WebSocket`

3. **Check listener is active:**
   - Verify `_newMessageSubscription` is not null
   - Check it's not being cancelled prematurely

### Conversation Order Not Updating

1. **Check lastMessageTime field:**
   - Verify backend returns `last_message_time` in API response
   - Check it's being parsed correctly in Flutter

2. **Check sorting is called:**
   - Add debug logs in sort functions
   - Verify sort is called after message updates

3. **Check state updates:**
   - Verify `state.copyWith()` is called after sorting
   - Check Riverpod is notifying listeners

---

## Next Steps

### Potential Enhancements

1. **Optimistic UI Updates:**
   - Show sent message immediately (before server confirmation)
   - Mark as "sending" until confirmed
   - Handle send failures gracefully

2. **Typing Indicators:**
   - Already supported in WebSocket consumer
   - Add UI to show "User is typing..."

3. **Message Status:**
   - Sent ✓
   - Delivered ✓✓
   - Read ✓✓ (blue)

4. **Pagination:**
   - Load older messages on scroll
   - Keep WebSocket for new messages only

5. **Offline Support:**
   - Queue messages when offline
   - Send when connection restored
   - Show offline indicator

---

## Conclusion

Both bugs are now fixed:
- ✅ Messages appear in real-time without refresh
- ✅ Conversations are properly ordered by last message time

The messaging system now provides a smooth, real-time chat experience comparable to modern messaging apps.

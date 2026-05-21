# Unread Count Fix Implementation

## Problem
The unread badge in the conversation list was hardcoded to always show "1" instead of displaying the actual number of unread messages.

## Solution
Added `unread_count` field throughout the backend and frontend to track and display the actual number of unread messages per conversation.

---

## Changes Made

### Backend Changes

#### 1. `backend/apps/messaging/serializers.py`

**Added `unread_count` field to `ConversationSerializer`:**
- Added `unread_count = serializers.SerializerMethodField()` to the serializer
- Added `'unread_count'` to the `fields` list in Meta class

**Implemented `get_unread_count()` method:**
```python
def get_unread_count(self, obj):
    """Return the actual count of unread messages for the current user."""
    request = self.context.get('request')
    if not request:
        return 0
    
    # Get the user's read cursor
    cursor = ReadCursor.objects.filter(conversation=obj, user=request.user).first()
    
    if not cursor or not cursor.last_read_message:
        # No cursor means all messages are unread (excluding user's own messages)
        return obj.messages.exclude(expediteur=request.user).count()
    
    # Count messages after the last read message (excluding user's own messages)
    return obj.messages.filter(
        id__gt=cursor.last_read_message_id
    ).exclude(
        expediteur=request.user
    ).count()
```

**Logic:**
- If no read cursor exists, count all messages (excluding user's own)
- If cursor exists, count messages with ID greater than `last_read_message_id`
- Always exclude messages sent by the current user

---

### Frontend Changes

#### 2. `frontend/lib/features/messaging/data/models/message_dto.dart`

**Updated `ConversationDto` class:**
- Added `final int unreadCount;` field
- Added `this.unreadCount = 0,` to constructor
- Added parsing in `fromJson()`: `unreadCount: json['unread_count'] as int? ?? 0,`

#### 3. `frontend/lib/features/messaging/domain/message_entity.dart`

**Updated `ConversationEntity` class:**
- Added `final int unreadCount;` field
- Added `this.unreadCount = 0,` to constructor

#### 4. `frontend/lib/features/messaging/data/models/chat_model.dart`

**Updated `ConversationModel` class:**
- Added `final int unreadCount;` field
- Added `this.unreadCount = 0,` to constructor
- Updated `toEntity()` to pass `unreadCount: unreadCount,`
- Updated `fromEntity()` to receive `unreadCount: entity.unreadCount,`

#### 5. `frontend/lib/features/messaging/data/repositories/messaging_repository_api.dart`

**Updated `_conversationDtoToEntity()` method:**
- Added `unreadCount: dto.unreadCount,` when creating ConversationEntity

**Updated other ConversationEntity instantiations:**
- Added `unreadCount: 0,` to fallback entities
- Added `unreadCount: conv.unreadCount,` when copying conversation with messages

#### 6. `frontend/lib/features/messaging/domain/chat_controller.dart`

**Updated `markAsRead()` method:**
- Added `unreadCount: 0,` when marking conversation as read

#### 7. `frontend/lib/features/messaging/screens/messaging_screen.dart`

**Updated unread badge display in `_ConversationItem`:**

**Changed condition:**
```dart
// Before: else if (c.isUnread)
// After:  else if (c.unreadCount > 0)
```

**Changed badge text:**
```dart
// Before: child: const Text('1', ...)
// After:  child: Text(c.unreadCount > 99 ? '99+' : '${c.unreadCount}', ...)
```

**Features:**
- Shows actual unread count (1, 2, 3, etc.)
- Displays "99+" for counts over 99
- Uses non-const Text widget to allow dynamic values

---

## How It Works

### Data Flow

1. **Backend calculates unread count:**
   - When fetching conversations, `ConversationSerializer.get_unread_count()` is called
   - It queries the database for messages after the user's `ReadCursor`
   - Returns the count excluding the user's own messages

2. **Frontend receives and parses:**
   - `ConversationDto.fromJson()` parses `unread_count` from API response
   - Value flows through: DTO → Entity → UI

3. **UI displays the count:**
   - Badge only shows when `unreadCount > 0`
   - Displays actual number or "99+" for large counts
   - Badge disappears when conversation is marked as read

### Read Cursor Logic

- **ReadCursor** tracks the last message ID each user has read in each conversation
- Unread count = messages with `id > last_read_message_id`
- When user opens a conversation, `markAsRead()` updates the cursor
- Next API call returns `unread_count: 0` for that conversation

---

## Testing Checklist

- [ ] Badge shows correct count (1, 2, 3, etc.) for unread messages
- [ ] Badge shows "99+" for conversations with 100+ unread messages
- [ ] Badge disappears when conversation is marked as read
- [ ] Badge doesn't show for user's own messages
- [ ] Count updates in real-time via WebSocket notifications
- [ ] Multiple conversations can have different unread counts
- [ ] Group conversations show correct unread counts

---

## Files Modified

### Backend (1 file)
- `backend/apps/messaging/serializers.py`

### Frontend (6 files)
- `frontend/lib/features/messaging/data/models/message_dto.dart`
- `frontend/lib/features/messaging/domain/message_entity.dart`
- `frontend/lib/features/messaging/data/models/chat_model.dart`
- `frontend/lib/features/messaging/data/repositories/messaging_repository_api.dart`
- `frontend/lib/features/messaging/domain/chat_controller.dart`
- `frontend/lib/features/messaging/screens/messaging_screen.dart`

---

## Benefits

✅ **Accurate information** - Users see exactly how many unread messages they have  
✅ **Better UX** - No more misleading "1" badge when there are multiple messages  
✅ **Scalable** - Handles any number of unread messages with "99+" cap  
✅ **Consistent** - Backend calculates count, ensuring accuracy across all clients  
✅ **Efficient** - Uses existing ReadCursor infrastructure, no new tables needed

# Unread Count Troubleshooting Guide

## Current Status

The `unread_count` field has been added to the backend serializer, but the badge is not showing. This guide will help diagnose and fix the issue.

## Backend Verification

### Step 1: Verify the serializer has unread_count

✅ **CONFIRMED** - The field is already added:
- `unread_count = serializers.SerializerMethodField()` is declared
- `'unread_count'` is in the `fields` list
- `get_unread_count()` method is implemented with debug logging

### Step 2: Test the backend response

Run this command from the `backend` directory:

```bash
python test_unread_count.py
```

This will show you:
- Whether `unread_count` appears in the serialized data
- The actual values being returned
- Debug output from the `get_unread_count()` method

**Expected output:**
```
Conversation ID: 123
  contact_name: John Doe
  is_unread: True
  unread_count: 3 ← THIS SHOULD BE A NUMBER
```

### Step 3: Restart Daphne

The Django server must be restarted for serializer changes to take effect:

```bash
# Stop the current Daphne process (Ctrl+C)
# Then restart:
daphne -b 0.0.0.0 -p 8000 config.asgi:application
```

### Step 4: Check the actual API response

Use curl or Postman to check the `/api/messaging/conversations/` endpoint:

```bash
curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:8000/api/messaging/conversations/
```

Look for `unread_count` in the JSON response. It should look like:
```json
{
  "id": 123,
  "contact_name": "John Doe",
  "is_unread": true,
  "unread_count": 3,
  ...
}
```

## Frontend Verification

### Step 1: Check the DTO is parsing unread_count

✅ **CONFIRMED** - Already added in `message_dto.dart`:
```dart
unreadCount: json['unread_count'] as int? ?? 0,
```

### Step 2: Check the Entity has the field

✅ **CONFIRMED** - Already added in `message_entity.dart`:
```dart
final int unreadCount;
```

### Step 3: Check the UI is using unread_count

✅ **CONFIRMED** - Already updated in `messaging_screen.dart`:
```dart
else if (c.unreadCount > 0 || c.isUnread)
  Container(
    child: Text(
      c.unreadCount > 0
          ? (c.unreadCount > 99 ? '99+' : '${c.unreadCount}')
          : '1',
      ...
    ),
  ),
```

### Step 4: Clear Flutter cache and rebuild

```bash
cd frontend
flutter clean
flutter pub get
flutter run
```

## Debug Checklist

- [ ] Backend: `unread_count` field is in `ConversationSerializer.Meta.fields`
- [ ] Backend: `get_unread_count()` method exists and has debug logging
- [ ] Backend: Daphne server has been restarted
- [ ] Backend: Test script confirms `unread_count` is in response
- [ ] Backend: API endpoint returns `unread_count` in JSON
- [ ] Frontend: DTO parses `unread_count` from JSON
- [ ] Frontend: Entity has `unreadCount` field
- [ ] Frontend: UI uses `c.unreadCount` to display badge
- [ ] Frontend: App has been rebuilt with `flutter clean`

## Common Issues

### Issue 1: Backend returns unread_count: 0 for all conversations

**Cause:** ReadCursor might not be set up correctly, or all messages are from the current user.

**Fix:** Check the debug logs in Django console:
```
[unread_count] conv 123 → cursor=456, unread count: 0
```

If the cursor is very recent, it means messages have been marked as read.

### Issue 2: Frontend shows '1' instead of actual count

**Cause:** The fallback logic is being used because `unreadCount` is 0 but `isUnread` is true.

**Fix:** This indicates a mismatch between `is_unread` and `unread_count` calculations. Check the backend logic.

### Issue 3: Badge doesn't show at all

**Cause:** Both `unreadCount` is 0 AND `isUnread` is false.

**Fix:** 
1. Verify the backend is returning `is_unread: true` for conversations with unread messages
2. Check if messages exist in the conversation
3. Verify the user is not the sender of the latest message

## Current Implementation

### Backend Logic (get_unread_count)

```python
def get_unread_count(self, obj):
    request = self.context.get('request')
    if not request:
        return 0
    
    cursor = ReadCursor.objects.filter(conversation=obj, user=request.user).first()
    
    if not cursor or not cursor.last_read_message:
        # No cursor = all messages are unread (excluding user's own)
        return obj.messages.exclude(expediteur=request.user).count()
    
    # Count messages after the cursor (excluding user's own)
    return obj.messages.filter(
        id__gt=cursor.last_read_message_id
    ).exclude(
        expediteur=request.user
    ).count()
```

### Frontend Logic (messaging_screen.dart)

```dart
else if (c.unreadCount > 0 || c.isUnread)
  Container(
    child: Text(
      c.unreadCount > 0
          ? (c.unreadCount > 99 ? '99+' : '${c.unreadCount}')
          : '1',  // Fallback if isUnread is true but count is 0
    ),
  ),
```

## Next Steps

1. **Run the test script** to verify backend is working
2. **Restart Daphne** to ensure changes are loaded
3. **Check API response** with curl to confirm field is present
4. **Rebuild Flutter app** to ensure latest code is running
5. **Check debug logs** in both Django console and Flutter console

If the issue persists after all these steps, share:
- Output from `test_unread_count.py`
- Django console logs showing `[unread_count]` messages
- Flutter console logs showing parsed DTO values

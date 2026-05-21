# Messaging Bugs Fixed

## Bug 1: Read Receipt Status Always Shows as "Viewed"

### Problem
The double-checkmark icon always displayed in purple (viewed state) even when the receiver hadn't opened the message.

### Root Cause
1. **Backend**: `MessageSerializer` didn't include an `is_read` field in the API response
2. **Frontend**: Repository hardcoded `isRead: false` when mapping messages from backend

### Solution

#### Backend Changes (`backend/apps/messaging/serializers.py`)
- Added `is_read` field to `MessageSerializer`
- Implemented `get_is_read()` method that:
  - Uses `ReadCursor` model to compute actual read status
  - For sender's messages: checks if the OTHER user has read the message
  - For received messages: checks if current user has read it
  - Returns `True` if `ReadCursor.last_read_message_id >= message.id`

#### Frontend Changes
1. **DTO** (`frontend/lib/features/messaging/data/models/message_dto.dart`)
   - Added `isRead` field to `MessageDto`
   - Updated `fromJson` to parse `is_read` from backend

2. **Repository** (`frontend/lib/features/messaging/data/repositories/messaging_repository_api.dart`)
   - Changed `_messageDtoToEntity()` to use real `dto.isRead` value instead of hardcoded `false`

3. **UI** (`frontend/lib/features/messaging/screens/private_message_screen.dart`)
   - Updated read receipt icon color logic:
     - **Purple** (`#401E66`) when `message.isRead == true` (viewed)
     - **Gray** (`#7C7580`) when `message.isRead == false` (sent but not viewed)

### Result
Read receipts now accurately reflect whether the receiver has opened and read the message.

---

## Bug 2: Date Separator Always Shows "aujourd'hui" (Today)

### Problem
The date separator above messages always displayed "aujourd'hui" regardless of the actual message date.

### Root Cause
The date separator text was hardcoded as a constant string instead of being computed from message timestamps.

### Solution

#### Frontend Changes (`frontend/lib/features/messaging/screens/private_message_screen.dart`)

1. **Added intl package import** for date formatting with French locale

2. **Created `_formatDateSeparator()` helper function**:
   - Compares message date against current date
   - Returns:
     - `"aujourd'hui"` if message sent today
     - `"hier"` if message sent yesterday
     - `"Lundi 13 janvier"` format (day name + day number + month name) for older messages
   - Uses `DateFormat('EEEE d MMMM', 'fr_FR')` for French date formatting

3. **Created `_buildMessagesWithDateSeparators()` helper function**:
   - Groups messages by calendar day
   - Inserts date separator widget before each new day's messages
   - Properly spaces separators with 24px vertical padding

4. **Updated message list rendering**:
   - Replaced hardcoded date separator with dynamic `_buildMessagesWithDateSeparators(conv)` call
   - Date separators now appear for each distinct day in the conversation

### Result
Date separators now display the correct date label based on each message's actual timestamp:
- "aujourd'hui" for today's messages
- "hier" for yesterday's messages  
- Full date (e.g., "Lundi 13 janvier") for older messages

---

## Files Modified

### Backend
- `backend/apps/messaging/serializers.py`

### Frontend
- `frontend/lib/features/messaging/data/models/message_dto.dart`
- `frontend/lib/features/messaging/data/repositories/messaging_repository_api.dart`
- `frontend/lib/features/messaging/screens/private_message_screen.dart`

---

## Testing Recommendations

1. **Read Receipt Status**:
   - Send a message and verify checkmark is gray
   - Have receiver open the conversation
   - Verify checkmark turns purple for sender

2. **Date Separators**:
   - View conversations with messages from today → should show "aujourd'hui"
   - View conversations with messages from yesterday → should show "hier"
   - View conversations with older messages → should show full date like "Lundi 13 janvier"
   - Verify multiple date separators appear when messages span multiple days

3. **Backend API**:
   - Test `GET /conversations/<id>/messages/` endpoint
   - Verify response includes `is_read` field for each message
   - Verify `is_read` value changes after calling `POST /conversations/<id>/read-all`

# WebSocket Notification System Implementation

## Overview
Replaced 5-second polling with WebSocket-driven real-time updates for the conversation list screen.

## Changes Made

### Backend Changes

#### 1. `backend/apps/messaging/consumers.py`
- **Added `NotificationConsumer` class**: A new WebSocket consumer that handles global notifications for users
  - Connects users to their personal notification channel: `notifications_{user_id}`
  - Listens for `new_message_notification` events
  - Broadcasts `new_message` events to connected clients

- **Updated `ChatConsumer._handle_send_message()`**: Now broadcasts to notification channels
  - After sending a message to the conversation group, it notifies all conversation members
  - Sends notification to each member's personal channel: `notifications_{member_id}`
  
- **Added `_get_conversation_member_ids()` helper**: Database query to fetch all active member IDs for a conversation

#### 2. `backend/config/asgi.py`
- **Added WebSocket route**: `ws/notifications/` → `NotificationConsumer`
- Updated imports to include `NotificationConsumer`

### Frontend Changes

#### 3. `frontend/lib/features/messaging/screens/messaging_screen.dart`
- **Removed polling mechanism**:
  - Removed `Timer? _refreshTimer` field
  - Removed `Timer.periodic()` in `initState()`
  - Removed timer cancellation in `dispose()`
  - Removed `import 'dart:async'`

- **Added WebSocket listener**:
  - Added `WebSocketChannel? _listenerChannel` field
  - Added `_connectGlobalListener()` method that:
    - Retrieves authentication token
    - Connects to `ws/notifications/` endpoint
    - Listens for incoming messages
    - Calls `refreshConversations()` when `new_message` event is received
  - Updated `dispose()` to close WebSocket connection
  - Added required imports: `dart:convert`, `web_socket_channel`, `api_endpoints`, `token_storage`

## How It Works

### Message Flow
1. User A sends a message in a conversation
2. `ChatConsumer` receives the message and:
   - Saves it to the database
   - Broadcasts to the conversation's WebSocket group (for real-time chat)
   - Broadcasts to all members' notification channels
3. User B's conversation list screen receives the notification via `NotificationConsumer`
4. The list screen automatically refreshes to show the new message

### Benefits
- **Real-time updates**: No delay waiting for the next poll
- **Reduced server load**: No unnecessary polling requests every 5 seconds
- **Better UX**: Instant updates when messages arrive
- **Scalable**: WebSocket connections are more efficient than repeated HTTP requests

## WebSocket Endpoints

### Chat WebSocket (existing)
- **URL**: `ws://host/ws/chat/<conversation_id>/?token=<jwt>`
- **Purpose**: Real-time messaging within a specific conversation
- **Events**: `new_message`, `read_receipt`, `typing`, `member_update`

### Notifications WebSocket (new)
- **URL**: `ws://host/ws/notifications/?token=<jwt>`
- **Purpose**: Global notifications for conversation list updates
- **Events**: `new_message` (with `conversation_id`)

## Testing Checklist
- [ ] User receives instant updates in conversation list when a new message arrives
- [ ] No polling requests visible in network tab
- [ ] WebSocket connection established on conversation list screen
- [ ] Connection properly closed when leaving the screen
- [ ] Works for both direct messages and group conversations
- [ ] Multiple users can receive notifications simultaneously
- [ ] Reconnection works if WebSocket connection drops

## Notes
- The private chat screen behavior remains unchanged
- Message sending logic is not modified
- Authentication uses JWT tokens passed as query parameters
- WebSocket connections auto-reconnect on failure (handled by `web_socket_channel` package)

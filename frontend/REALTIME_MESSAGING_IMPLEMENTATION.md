# Real-Time Messaging Implementation

## Overview

This document describes the complete real-time messaging implementation using WebSockets (in-memory, no persistence). The implementation follows clean architecture principles and uses Riverpod for state management.

## Architecture

```
lib/features/messaging/
├── domain/
│   └── message_entity.dart          (existing - domain entities)
├── data/
│   ├── models/
│   │   ├── chat_model.dart          (existing - data models)
│   │   └── message_dto.dart         (NEW - backend JSON DTOs)
│   ├── datasources/
│   │   └── messaging_remote_datasource.dart  (NEW - REST API calls)
│   ├── services/
│   │   └── websocket_service.dart   (NEW - WebSocket management)
│   ├── repositories/
│   │   └── messaging_repository_api.dart     (NEW - repository implementation)
│   └── providers/
│       ├── conversation_list_notifier.dart   (NEW - inbox state)
│       ├── active_chat_notifier.dart         (NEW - chat state)
│       └── messaging_providers.dart          (NEW - Riverpod providers)
```

## Backend Analysis

### WebSocket Connection

- **URL Pattern**: `ws://<host>/ws/chat/<conversation_id>/?token=<jwt_token>`
- **Authentication**: JWT token passed as query parameter
- **Channel Group**: `conv_{conversation_id}`

### Client → Server Messages

```json
{"type": "send_message", "contenu": "message text"}
{"type": "mark_read"}
{"type": "typing_start"}
{"type": "typing_stop"}
```

### Server → Client Messages

```json
// New message
{"type": "new_message", "message": {...}}

// Read receipt
{"type": "read_receipt", "reader_id": 123, "last_read_id": 456}

// Typing indicator
{"type": "typing", "user_id": 123, "is_typing": true}

// Member update
{"type": "member_update", "action": "added", "user_id": 123, "user_name": "John Doe"}
```

### REST API Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/conversations` | Fetch conversation list (inbox) |
| GET | `/conversations/<id>?page=1` | Fetch paginated messages |
| POST | `/conversations/<id>/messages` | Send a message |
| POST | `/conversations/<id>/read-all` | Mark conversation as read |
| POST | `/conversations` | Get or create DM |
| POST | `/conversations/group` | Create group conversation |

### Message JSON Shape (MessageSerializer)

```json
{
  "id": 123,
  "contenu": "message text",
  "date_envoi": "2024-01-15T10:30:00Z",
  "conversation_id": 456,
  "expediteur": {
    "id": 789,
    "nom": "Doe",
    "prenom": "John"
  }
}
```

### Paginated Response (StandardPagination)

```json
{
  "count": 100,
  "next": "http://...?page=2",
  "previous": null,
  "results": [...],
  "read_cursors": {
    "123": 456  // user_id: last_read_message_id
  }
}
```

## Implementation Details

### 1. WebSocket Service (`websocket_service.dart`)

**Purpose**: Manages WebSocket connection for a single conversation.

**Features**:
- Auto-reconnect with 3-second delay on disconnect/error
- Typed broadcast streams for each event type
- Send methods for all client→server message types
- Proper disposal to prevent memory leaks

**Key Methods**:
```dart
void connect()                    // Connect and start listening
void sendMessage(String contenu)  // Send message via WebSocket
void sendMarkRead()               // Mark conversation as read
void sendTypingStart()            // Send typing start
void sendTypingStop()             // Send typing stop
void dispose()                    // Close connection and streams
```

**Streams**:
```dart
Stream<MessageDto> newMessages
Stream<ReadReceiptEvent> readReceipts
Stream<TypingEvent> typing
Stream<MemberUpdateEvent> memberUpdates
```

### 2. Remote Data Source (`messaging_remote_datasource.dart`)

**Purpose**: Wraps all Dio HTTP calls for messaging endpoints.

**Methods**:
- `getConversations()` - GET /conversations
- `getMessages(conversationId, page)` - GET /conversations/<id>?page=X
- `sendMessage(conversationId, contenu)` - POST /conversations/<id>/messages
- `markConversationRead(conversationId)` - POST /conversations/<id>/read-all
- `getOrCreateConversation(contactId)` - POST /conversations
- `createGroup(groupName, memberIds)` - POST /conversations/group

### 3. Repository (`messaging_repository_api.dart`)

**Purpose**: Wraps remote data source with error handling and entity conversion.

**Features**:
- Try/catch with DioException handling
- Friendly French error messages
- Converts DTOs to domain entities
- Returns typed domain entities

**Error Messages**:
- 403: "Accès refusé."
- 404: "Conversation introuvable."
- 400: "Requête invalide."
- Timeout: "Délai d'attente dépassé. Vérifiez votre connexion."
- Connection: "Impossible de joindre le serveur. Vérifiez votre connexion."

### 4. Conversation List Notifier (`conversation_list_notifier.dart`)

**Purpose**: Manages the conversation list (inbox) state.

**State**:
```dart
class ConversationListState {
  final List<ConversationEntity> conversations;
  final bool isLoading;
  final String? error;
}
```

**Features**:
- Loads conversations on construction
- Polling support with 5-second interval (silent refresh)
- Pull-to-refresh support
- No loading flicker on subsequent polls

**Methods**:
```dart
Future<void> refresh()  // Manual refresh
void startPolling()     // Start 5-second polling
void stopPolling()      // Stop polling
```

### 5. Active Chat Notifier (`active_chat_notifier.dart`)

**Purpose**: Manages a single active chat conversation state.

**State**:
```dart
class ActiveChatState {
  final List<MessageEntity> messages;
  final bool isLoading;
  final bool isSending;
  final bool hasMore;
  final int currentPage;
  final String? error;
  final bool partnerIsTyping;
  final Map<int, bool> typingUsers;
  final bool initialLoadDone;
  final int? partnerLastReadId;
}
```

**Lifecycle**:
1. **Construction**: Fetch first page via REST
2. **After REST**: Connect WebSocket
3. **WebSocket Events**: Listen and update state
4. **Disposal**: Cancel subscriptions, close WebSocket

**WebSocket Event Handlers**:

- **new_message**:
  - Append if not duplicate (check by ID)
  - Call `sendMarkRead()` if chat is open
  - Trigger inbox refresh

- **read_receipt**:
  - Update `partnerLastReadId` in state
  - Trigger inbox refresh

- **typing**:
  - Update `typingUsers` map + `partnerIsTyping` bool
  - Auto-clear after 4 seconds as safety net

- **member_update**:
  - Trigger inbox refresh

**Lifecycle Methods**:
```dart
void onChatOpened()   // Set flag, call sendMarkRead()
void onChatClosed()   // Clear flag
```

**Public Methods**:
```dart
Future<void> sendMessage(String content)  // POST via REST
void sendTypingStart()                    // Delegate to WebSocket
void sendTypingStop()                     // Delegate to WebSocket
void sendMarkRead()                       // Send via WebSocket
Future<void> loadMore()                   // Fetch next page
Future<void> refresh()                    // Re-fetch page 1
Future<void> markAllRead()                // Call sendMarkRead()
```

**Deduplication**:
- Messages are deduplicated by ID before appending
- Prevents duplicate messages from REST + WebSocket race conditions

### 6. Providers (`messaging_providers.dart`)

**Repository Provider**:
```dart
final messagingRepositoryProvider = Provider<MessagingRepositoryApi>((ref) {
  final dataSource = MessagingRemoteDataSource();
  return MessagingRepositoryApi(dataSource);
});
```

**Conversation List Provider**:
```dart
final conversationListProvider =
    StateNotifierProvider<ConversationListNotifier, ConversationListState>((ref) {
  final repository = ref.watch(messagingRepositoryProvider);
  return ConversationListNotifier(repository);
});
```

**Active Chat Provider** (autoDispose + family):
```dart
final activeChatProvider = StateNotifierProvider.autoDispose
    .family<ActiveChatNotifier, ActiveChatState, int>((ref, conversationId) {
  final repository = ref.watch(messagingRepositoryProvider);
  final authState = ref.watch(authProvider);
  final currentUserId = authState.userId ?? 0;

  void onMessagesChanged() {
    ref.read(conversationListProvider.notifier).refresh();
  }

  return ActiveChatNotifier(
    conversationId: conversationId,
    currentUserId: currentUserId,
    repository: repository,
    onMessagesChanged: onMessagesChanged,
  );
});
```

**Key Features**:
- `autoDispose`: WebSocket closes when screen is popped
- `family`: Keyed by conversation ID (int)
- `onMessagesChanged`: Callback to refresh inbox when messages arrive

## Usage in UI (Example)

### Conversation List Screen

```dart
class ConversationListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(conversationListProvider);

    // Start polling when screen is visible
    ref.listen(conversationListProvider, (_, __) {
      ref.read(conversationListProvider.notifier).startPolling();
    });

    if (state.isLoading && state.conversations.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text(state.error!));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(conversationListProvider.notifier).refresh(),
      child: ListView.builder(
        itemCount: state.conversations.length,
        itemBuilder: (context, index) {
          final conv = state.conversations[index];
          return ListTile(
            title: Text(conv.contactName),
            subtitle: Text(conv.lastMessage),
            trailing: conv.isUnread ? Icon(Icons.circle, size: 12) : null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    conversationId: int.parse(conv.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

### Chat Screen

```dart
class ChatScreen extends ConsumerStatefulWidget {
  final int conversationId;

  const ChatScreen({required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    // Notify when chat is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeChatProvider(widget.conversationId).notifier).onChatOpened();
    });

    // Load more on scroll
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == 0) {
        ref.read(activeChatProvider(widget.conversationId).notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    ref.read(activeChatProvider(widget.conversationId).notifier).onChatClosed();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activeChatProvider(widget.conversationId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        subtitle: state.partnerIsTyping ? Text('typing...') : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final msg = state.messages[state.messages.length - 1 - index];
                return MessageBubble(message: msg);
              },
            ),
          ),
          MessageInput(
            controller: _controller,
            onSend: () {
              final text = _controller.text.trim();
              if (text.isNotEmpty) {
                ref.read(activeChatProvider(widget.conversationId).notifier)
                    .sendMessage(text);
                _controller.clear();
              }
            },
            onTypingStart: () {
              ref.read(activeChatProvider(widget.conversationId).notifier)
                  .sendTypingStart();
            },
            onTypingStop: () {
              ref.read(activeChatProvider(widget.conversationId).notifier)
                  .sendTypingStop();
            },
          ),
        ],
      ),
    );
  }
}
```

## Verification Checklist

- [x] No screen or widget file was modified
- [x] No existing endpoint constant was changed
- [x] No existing class was duplicated or renamed
- [x] Field names in fromJson() match actual backend JSON keys
- [x] WebSocket URL and auth method match actual backend
- [x] Duplicate message guard is present (check by message ID)
- [x] Auto-reconnect is implemented in WebSocket service
- [x] Typing auto-clear timer (4 seconds) is implemented
- [x] autoDispose is used on active chat provider
- [x] Conversation list refreshes on new message/read receipt/member update

## Dependencies Required

Add these to `pubspec.yaml`:

```yaml
dependencies:
  web_socket_channel: ^2.4.0
  flutter_riverpod: ^2.4.0
  dio: ^5.3.0
  flutter_secure_storage: ^9.0.0
```

## Token Storage

The implementation uses `TokenStorage.getAccessToken()` to retrieve the JWT token for WebSocket authentication. This is already implemented in the project at:

```
lib/core/storage/token_storage.dart
```

## API Endpoints

All endpoints are already defined in:

```
lib/core/api/api_endpoints.dart
```

The WebSocket URL helper is:
```dart
static String chatWebSocket(int conversationId, String token) =>
    '$_wsBase/ws/chat/$conversationId/?token=$token';
```

## State Management Flow

```
User Action (UI)
    ↓
Provider Method Call
    ↓
Notifier Method
    ↓
Repository Method
    ↓
Remote Data Source (REST API)
    ↓
Backend Response
    ↓
DTO → Entity Conversion
    ↓
State Update
    ↓
UI Rebuild
```

## WebSocket Flow

```
Notifier Construction
    ↓
Fetch First Page (REST)
    ↓
Connect WebSocket
    ↓
Subscribe to Streams
    ↓
Server Event
    ↓
Stream Listener
    ↓
State Update
    ↓
UI Rebuild
```

## Error Handling

All errors are caught and converted to friendly French messages:

- Network errors: Connection timeout, receive timeout, connection error
- HTTP errors: 400, 403, 404, 409, 500
- WebSocket errors: Auto-reconnect with 3-second delay

## Memory Management

- WebSocket service is disposed when notifier is disposed
- Stream subscriptions are cancelled on disposal
- Timers are cancelled on disposal
- `autoDispose` ensures cleanup when screen is popped

## Testing Notes

To test the implementation:

1. **Conversation List**: Open the inbox, verify conversations load
2. **Polling**: Wait 5 seconds, verify silent refresh
3. **Open Chat**: Tap a conversation, verify messages load
4. **Send Message**: Type and send, verify message appears
5. **Receive Message**: Send from another device, verify real-time arrival
6. **Typing Indicator**: Type in one device, verify indicator on other
7. **Read Receipt**: Open chat, verify read receipt sent
8. **Load More**: Scroll to top, verify older messages load
9. **Reconnect**: Disconnect network, reconnect, verify auto-reconnect
10. **Dispose**: Pop chat screen, verify WebSocket closes

## Future Enhancements

- Image/file message support
- Message reactions
- Message editing/deletion
- Voice messages
- Push notifications integration
- Offline message queue
- Message search
- Conversation archiving

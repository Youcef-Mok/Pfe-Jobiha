# Messaging Quick Start Guide

## Installation

Add to `pubspec.yaml`:

```yaml
dependencies:
  web_socket_channel: ^2.4.0
```

Then run:
```bash
flutter pub get
```

## Import Providers

```dart
import 'package:job_app/features/messaging/data/providers/messaging_providers.dart';
```

## 1. Display Conversation List (Inbox)

```dart
class MyInboxScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(conversationListProvider);

    if (state.isLoading && state.conversations.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: state.conversations.length,
      itemBuilder: (context, index) {
        final conv = state.conversations[index];
        return ListTile(
          title: Text(conv.contactName),
          subtitle: Text(conv.lastMessage),
          trailing: conv.isUnread ? Badge() : null,
          onTap: () {
            // Navigate to chat screen
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
    );
  }
}
```

## 2. Start/Stop Polling

```dart
// Start polling when screen is visible
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(conversationListProvider.notifier).startPolling();
  });
}

// Stop polling when screen is disposed
@override
void dispose() {
  ref.read(conversationListProvider.notifier).stopPolling();
  super.dispose();
}
```

## 3. Pull-to-Refresh

```dart
RefreshIndicator(
  onRefresh: () => ref.read(conversationListProvider.notifier).refresh(),
  child: ListView(...),
)
```

## 4. Display Chat Messages

```dart
class ChatScreen extends ConsumerStatefulWidget {
  final int conversationId;

  const ChatScreen({required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  @override
  void initState() {
    super.initState();
    
    // Notify when chat is opened (marks as read)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeChatProvider(widget.conversationId).notifier).onChatOpened();
    });
  }

  @override
  void dispose() {
    // Notify when chat is closed
    ref.read(activeChatProvider(widget.conversationId).notifier).onChatClosed();
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
          // Messages list
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final msg = state.messages[state.messages.length - 1 - index];
                return MessageBubble(
                  message: msg,
                  isRead: state.partnerLastReadId != null &&
                      int.parse(msg.id) <= state.partnerLastReadId!,
                );
              },
            ),
          ),
          
          // Input field
          MessageInput(
            onSend: (text) {
              ref.read(activeChatProvider(widget.conversationId).notifier)
                  .sendMessage(text);
            },
          ),
        ],
      ),
    );
  }
}
```

## 5. Send a Message

```dart
final notifier = ref.read(activeChatProvider(conversationId).notifier);
await notifier.sendMessage('Hello!');
```

## 6. Typing Indicators

```dart
TextField(
  onChanged: (text) {
    if (text.isNotEmpty) {
      ref.read(activeChatProvider(conversationId).notifier).sendTypingStart();
    } else {
      ref.read(activeChatProvider(conversationId).notifier).sendTypingStop();
    }
  },
)
```

## 7. Load More Messages (Pagination)

```dart
final scrollController = ScrollController();

@override
void initState() {
  super.initState();
  scrollController.addListener(() {
    // Load more when scrolled to top
    if (scrollController.position.pixels == 0) {
      ref.read(activeChatProvider(widget.conversationId).notifier).loadMore();
    }
  });
}

ListView.builder(
  controller: scrollController,
  reverse: true,
  // ...
)
```

## 8. Show Loading State

```dart
final state = ref.watch(activeChatProvider(conversationId));

if (state.isLoading && state.messages.isEmpty) {
  return Center(child: CircularProgressIndicator());
}

if (state.isSending) {
  // Show sending indicator
}
```

## 9. Handle Errors

```dart
final state = ref.watch(activeChatProvider(conversationId));

if (state.error != null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(state.error!)),
  );
}
```

## 10. Read Receipts

```dart
// Display double check marks for read messages
final msg = state.messages[index];
final isRead = state.partnerLastReadId != null &&
    int.parse(msg.id) <= state.partnerLastReadId!;

Icon(
  isRead ? Icons.done_all : Icons.done,
  color: isRead ? Colors.blue : Colors.grey,
)
```

## Common Patterns

### Message Bubble Widget

```dart
class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isRead;

  const MessageBubble({
    required this.message,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isMine ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: message.isMine ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                if (message.isMine) ...[
                  SizedBox(width: 4),
                  Icon(
                    isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: isRead ? Colors.blue : Colors.grey,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
```

### Message Input Widget

```dart
class MessageInput extends StatefulWidget {
  final Function(String) onSend;

  const MessageInput({required this.onSend});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              final text = _controller.text.trim();
              if (text.isNotEmpty) {
                widget.onSend(text);
                _controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
```

## State Properties Reference

### ConversationListState

```dart
state.conversations  // List<ConversationEntity>
state.isLoading      // bool
state.error          // String?
```

### ActiveChatState

```dart
state.messages           // List<MessageEntity>
state.isLoading          // bool (loading more messages)
state.isSending          // bool (sending a message)
state.hasMore            // bool (more messages available)
state.currentPage        // int
state.error              // String?
state.partnerIsTyping    // bool
state.typingUsers        // Map<int, bool>
state.initialLoadDone    // bool
state.partnerLastReadId  // int? (for read receipts)
```

## Notifier Methods Reference

### ConversationListNotifier

```dart
.refresh()        // Manually refresh conversations
.startPolling()   // Start 5-second polling
.stopPolling()    // Stop polling
```

### ActiveChatNotifier

```dart
.onChatOpened()           // Call when screen opens
.onChatClosed()           // Call when screen closes
.sendMessage(text)        // Send a message
.sendTypingStart()        // Send typing indicator
.sendTypingStop()         // Stop typing indicator
.sendMarkRead()           // Mark as read
.loadMore()               // Load older messages
.refresh()                // Refresh messages
.markAllRead()            // Mark all as read
```

## Troubleshooting

### WebSocket not connecting

1. Check that the backend WebSocket server is running
2. Verify the WebSocket URL in `api_endpoints.dart`
3. Check that the JWT token is valid
4. Check network connectivity

### Messages not appearing in real-time

1. Verify WebSocket connection is established
2. Check browser/app console for WebSocket errors
3. Verify the conversation ID is correct
4. Check that the user is a member of the conversation

### Duplicate messages

The implementation includes deduplication by message ID. If you still see duplicates:
1. Check that message IDs are unique
2. Verify the deduplication logic in `active_chat_notifier.dart`

### Typing indicator stuck

The implementation includes a 4-second auto-clear timer. If it's still stuck:
1. Check that `sendTypingStop()` is called when appropriate
2. Verify the timer is not being cancelled prematurely

## Performance Tips

1. Use `autoDispose` to clean up WebSocket connections
2. Implement pagination for large conversation lists
3. Use `const` constructors for widgets when possible
4. Debounce typing indicators to reduce WebSocket traffic
5. Use `ListView.builder` for efficient list rendering

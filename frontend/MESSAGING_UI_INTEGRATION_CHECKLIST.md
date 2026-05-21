# Messaging UI Integration Checklist

This checklist guides you through integrating the new real-time messaging providers with the existing UI screens.

## Prerequisites

- [x] All provider files created
- [x] Dependencies added to `pubspec.yaml`
- [x] `flutter pub get` executed

## Step 1: Update Dependencies

### File: `pubspec.yaml`

```yaml
dependencies:
  web_socket_channel: ^2.4.0  # Add this line
```

Run:
```bash
flutter pub get
```

## Step 2: Update Conversation List Screen

### File: `lib/features/messaging/screens/messaging_screen.dart`

**Current**: Uses mock data or old provider  
**Update to**: Use `conversationListProvider`

#### Changes needed:

1. **Import the new provider**:
```dart
import '../data/providers/messaging_providers.dart';
```

2. **Change widget to ConsumerWidget or ConsumerStatefulWidget**:
```dart
// Before
class MessagingScreen extends StatefulWidget

// After
class MessagingScreen extends ConsumerStatefulWidget
```

3. **Watch the provider**:
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {  // Add WidgetRef ref
  final state = ref.watch(conversationListProvider);
  
  // Use state.conversations instead of mock data
  // Use state.isLoading for loading indicator
  // Use state.error for error display
}
```

4. **Add polling lifecycle**:
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(conversationListProvider.notifier).startPolling();
  });
}

@override
void dispose() {
  ref.read(conversationListProvider.notifier).stopPolling();
  super.dispose();
}
```

5. **Add pull-to-refresh**:
```dart
RefreshIndicator(
  onRefresh: () => ref.read(conversationListProvider.notifier).refresh(),
  child: ListView.builder(...),
)
```

**Checklist**:
- [ ] Import added
- [ ] Widget changed to Consumer variant
- [ ] Provider watched
- [ ] Polling started in initState
- [ ] Polling stopped in dispose
- [ ] Pull-to-refresh added
- [ ] Loading state handled
- [ ] Error state handled

## Step 3: Update Chat Screen

### File: `lib/features/messaging/screens/chat_screen.dart`

**Current**: Uses mock data or old provider  
**Update to**: Use `activeChatProvider`

#### Changes needed:

1. **Import the new provider**:
```dart
import '../data/providers/messaging_providers.dart';
```

2. **Change widget to ConsumerStatefulWidget**:
```dart
// Before
class ChatScreen extends StatefulWidget

// After
class ChatScreen extends ConsumerStatefulWidget
```

3. **Add conversationId parameter** (if not already present):
```dart
final int conversationId;

const ChatScreen({required this.conversationId});
```

4. **Watch the provider**:
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {  // Add WidgetRef ref
  final state = ref.watch(activeChatProvider(widget.conversationId));
  
  // Use state.messages instead of mock data
  // Use state.isLoading for loading indicator
  // Use state.isSending for send button state
  // Use state.partnerIsTyping for typing indicator
}
```

5. **Add lifecycle methods**:
```dart
@override
void initState() {
  super.initState();
  
  // Notify when chat is opened (marks as read)
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(activeChatProvider(widget.conversationId).notifier).onChatOpened();
  });
  
  // Add scroll listener for pagination
  _scrollController.addListener(() {
    if (_scrollController.position.pixels == 0) {
      ref.read(activeChatProvider(widget.conversationId).notifier).loadMore();
    }
  });
}

@override
void dispose() {
  // Notify when chat is closed
  ref.read(activeChatProvider(widget.conversationId).notifier).onChatClosed();
  _scrollController.dispose();
  super.dispose();
}
```

6. **Update send message logic**:
```dart
void _sendMessage() {
  final text = _controller.text.trim();
  if (text.isNotEmpty) {
    ref.read(activeChatProvider(widget.conversationId).notifier)
        .sendMessage(text);
    _controller.clear();
  }
}
```

7. **Add typing indicators**:
```dart
TextField(
  controller: _controller,
  onChanged: (text) {
    if (text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      ref.read(activeChatProvider(widget.conversationId).notifier)
          .sendTypingStart();
    } else if (text.isEmpty && _isTyping) {
      _isTyping = false;
      ref.read(activeChatProvider(widget.conversationId).notifier)
          .sendTypingStop();
    }
  },
)
```

8. **Display typing indicator in AppBar**:
```dart
AppBar(
  title: Text('Chat'),
  subtitle: state.partnerIsTyping ? Text('typing...') : null,
)
```

9. **Display read receipts**:
```dart
// In message bubble
final isRead = state.partnerLastReadId != null &&
    int.parse(message.id) <= state.partnerLastReadId!;

Icon(
  isRead ? Icons.done_all : Icons.done,
  size: 14,
  color: isRead ? Colors.blue : Colors.grey,
)
```

**Checklist**:
- [ ] Import added
- [ ] Widget changed to ConsumerStatefulWidget
- [ ] conversationId parameter added
- [ ] Provider watched
- [ ] onChatOpened called in initState
- [ ] onChatClosed called in dispose
- [ ] Scroll listener added for pagination
- [ ] Send message updated
- [ ] Typing indicators added
- [ ] Typing indicator displayed in AppBar
- [ ] Read receipts displayed
- [ ] Loading state handled
- [ ] Error state handled

## Step 4: Update Message Bubble Widget

### File: `lib/features/messaging/widgets/message_bubble.dart`

#### Changes needed:

1. **Add isRead parameter**:
```dart
final bool isRead;

const MessageBubble({
  required this.message,
  required this.isRead,  // Add this
});
```

2. **Display read receipt**:
```dart
if (message.isMine) ...[
  SizedBox(width: 4),
  Icon(
    isRead ? Icons.done_all : Icons.done,
    size: 14,
    color: isRead ? Colors.blue : Colors.grey,
  ),
]
```

**Checklist**:
- [ ] isRead parameter added
- [ ] Read receipt icon displayed
- [ ] Icon color changes based on read status

## Step 5: Update Navigation

### File: `lib/features/messaging/screens/chat_list_screen.dart` (or wherever conversations are listed)

#### Changes needed:

1. **Pass conversationId as int**:
```dart
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChatScreen(
        conversationId: int.parse(conversation.id),  // Parse to int
      ),
    ),
  );
}
```

**Checklist**:
- [ ] conversationId parsed to int
- [ ] Navigation updated

## Step 6: Remove Old Providers (Optional)

If you have old mock providers or repositories:

### Files to check:
- `lib/features/messaging/data/providers/chat_provider.dart`
- `lib/features/messaging/data/providers/messaging_provider.dart`
- `lib/features/messaging/data/repositories/chat_repository_mock.dart`
- `lib/features/messaging/data/repositories/messaging_repository_mock.dart`

**Action**: 
- [ ] Remove old provider imports from screens
- [ ] Optionally delete old mock files (or keep for testing)

## Step 7: Test the Integration

### Manual Testing Checklist:

#### Conversation List
- [ ] Conversations load on app start
- [ ] Loading indicator shows while loading
- [ ] Conversations display correctly
- [ ] Unread indicators show
- [ ] Last message preview shows
- [ ] Pull-to-refresh works
- [ ] Polling updates list every 5 seconds
- [ ] Tapping conversation opens chat

#### Chat Screen
- [ ] Messages load when opening chat
- [ ] Loading indicator shows while loading
- [ ] Messages display correctly (mine vs theirs)
- [ ] Scroll to bottom on open
- [ ] Send button works
- [ ] Message appears after sending
- [ ] Typing indicator appears when typing
- [ ] Typing indicator shows in AppBar
- [ ] Typing indicator clears after stopping
- [ ] Read receipts update
- [ ] Scroll to top loads more messages
- [ ] WebSocket connects (check logs)
- [ ] Real-time messages arrive
- [ ] Back button closes chat properly

#### Error Handling
- [ ] Network errors show friendly messages
- [ ] Timeout errors handled
- [ ] Invalid conversation ID handled
- [ ] WebSocket disconnect handled
- [ ] WebSocket reconnect works

#### Memory Management
- [ ] No memory leaks (check with DevTools)
- [ ] WebSocket closes when leaving chat
- [ ] Polling stops when leaving inbox
- [ ] No errors in console after navigation

## Step 8: Update Existing Widgets (If Needed)

### Contact Widgets
File: `lib/features/messaging/widgets/contact_widgets.dart`

If this widget displays conversations, update it to use the new provider.

**Checklist**:
- [ ] Reviewed and updated if needed

### Message Actions Sheet
File: `lib/features/messaging/widgets/message_actions_sheet.dart`

If this widget has actions like "Mark as Read", update to use the new provider.

**Checklist**:
- [ ] Reviewed and updated if needed

## Step 9: Configuration

### Update WebSocket URL

File: `lib/core/api/api_endpoints.dart`

Verify the WebSocket URL is correct:

```dart
// For physical device
static const String _wsBase = 'ws://192.168.100.9:8000';

// For emulator
// static const String _wsBase = 'ws://10.0.2.2:8000';

// For production
// static const String _wsBase = 'wss://api.petitsjobs.dz';
```

**Checklist**:
- [ ] WebSocket URL verified
- [ ] Correct URL uncommented

## Step 10: Final Verification

### Code Review Checklist:
- [ ] All imports are correct
- [ ] No unused imports
- [ ] No compilation errors
- [ ] No warnings in console
- [ ] All TODOs addressed
- [ ] Code formatted (`flutter format .`)
- [ ] No debug print statements left

### Functionality Checklist:
- [ ] All features from Step 7 tested
- [ ] Tested on multiple devices/emulators
- [ ] Tested with multiple users
- [ ] Tested with poor network conditions
- [ ] Tested with airplane mode (offline handling)

### Performance Checklist:
- [ ] No frame drops during scrolling
- [ ] No memory leaks
- [ ] WebSocket reconnects quickly
- [ ] Polling doesn't cause UI jank
- [ ] Large message lists scroll smoothly

## Common Issues and Solutions

### Issue: WebSocket not connecting
**Solution**: 
1. Check backend is running
2. Verify WebSocket URL in `api_endpoints.dart`
3. Check JWT token is valid
4. Check network connectivity

### Issue: Messages not appearing in real-time
**Solution**:
1. Check WebSocket connection in logs
2. Verify conversation ID is correct
3. Check user is member of conversation
4. Check backend WebSocket consumer is working

### Issue: Duplicate messages
**Solution**:
1. Verify deduplication logic in `active_chat_notifier.dart`
2. Check message IDs are unique
3. Check both REST and WebSocket aren't adding same message

### Issue: Typing indicator stuck
**Solution**:
1. Verify `sendTypingStop()` is called
2. Check 4-second auto-clear timer
3. Check WebSocket connection

### Issue: Read receipts not updating
**Solution**:
1. Verify `onChatOpened()` is called
2. Check `sendMarkRead()` is being called
3. Check WebSocket connection
4. Check backend read_receipt event

### Issue: Polling causing performance issues
**Solution**:
1. Increase polling interval (default 5 seconds)
2. Stop polling when app is in background
3. Use silent refresh (already implemented)

## Additional Resources

- **Technical Documentation**: `REALTIME_MESSAGING_IMPLEMENTATION.md`
- **Quick Start Guide**: `MESSAGING_QUICK_START.md`
- **Implementation Summary**: `MESSAGING_IMPLEMENTATION_SUMMARY.md`
- **Backend API**: `backend/API_QUICK_REFERENCE.md`

## Support

If you encounter issues:
1. Check the documentation files listed above
2. Check backend logs for WebSocket errors
3. Check browser/app console for client errors
4. Use Flutter DevTools to debug state
5. Add debug print statements in notifiers

## Completion

Once all checkboxes are marked:
- [ ] All steps completed
- [ ] All tests passed
- [ ] Documentation reviewed
- [ ] Ready for production

Congratulations! Your real-time messaging feature is now fully integrated! 🎉

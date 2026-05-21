# Real-Time Messaging Flow Diagrams

## 1. Sending a Message Flow

```
┌─────────────┐
│    User     │
│  Types &    │
│  Taps Send  │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  UI (ChatScreen)                        │
│  onPressed: () {                        │
│    ref.read(activeChatProvider(id)     │
│       .notifier).sendMessage(text)     │
│  }                                      │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  ActiveChatNotifier                     │
│  sendMessage(content) {                 │
│    state = state.copyWith(              │
│      isSending: true                    │
│    );                                   │
│    final msg = await _repository        │
│      .sendMessage(conversationId,       │
│                   content);             │
│    // Deduplicate & append              │
│    state = state.copyWith(              │
│      messages: [...messages, msg],      │
│      isSending: false                   │
│    );                                   │
│    _onMessagesChanged(); // Refresh     │
│  }                                      │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  MessagingRepositoryApi                 │
│  sendMessage(conversationId, contenu) { │
│    try {                                │
│      final response = await _dataSource │
│        .sendMessage(conversationId,     │
│                     contenu);           │
│      final dto = MessageDto.fromJson(   │
│        response.data                    │
│      );                                 │
│      return _messageDtoToEntity(dto);   │
│    } on DioException catch (e) {        │
│      throw Exception(_friendlyError(e));│
│    }                                    │
│  }                                      │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  MessagingRemoteDataSource              │
│  sendMessage(conversationId, contenu) { │
│    return await _dio.post(              │
│      ApiEndpoints.sendMessage(          │
│        conversationId                   │
│      ),                                 │
│      data: {'contenu': contenu}         │
│    );                                   │
│  }                                      │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  Backend (Django)                       │
│  POST /conversations/<id>/messages      │
│  {                                      │
│    "contenu": "Hello!"                  │
│  }                                      │
│                                         │
│  1. Save message to database            │
│  2. Broadcast via WebSocket:            │
│     channel_layer.group_send(           │
│       f'conv_{conv_id}',                │
│       {                                 │
│         'type': 'chat.message',         │
│         'message': MessageSerializer(   │
│           message                       │
│         ).data,                         │
│         'sender_id': request.user.pk    │
│       }                                 │
│     )                                   │
│  3. Return message JSON                 │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  Response                               │
│  {                                      │
│    "id": 123,                           │
│    "contenu": "Hello!",                 │
│    "date_envoi": "2024-01-15T10:30:00Z",│
│    "conversation_id": 456,              │
│    "expediteur": {                      │
│      "id": 789,                         │
│      "nom": "Doe",                      │
│      "prenom": "John"                   │
│    }                                    │
│  }                                      │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  UI Rebuilds                            │
│  • Message appears in chat              │
│  • Send button re-enabled               │
│  • Scroll to bottom                     │
└─────────────────────────────────────────┘
```

## 2. Receiving a Message Flow (Real-Time)

```
┌─────────────────────────────────────────┐
│  Backend (Django)                       │
│  Another user sends a message           │
│                                         │
│  channel_layer.group_send(              │
│    f'conv_{conv_id}',                   │
│    {                                    │
│      'type': 'chat.message',            │
│      'message': {...},                  │
│      'sender_id': other_user_id         │
│    }                                    │
│  )                                      │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  WebSocket Connection                   │
│  ws://host/ws/chat/456/?token=jwt       │
│                                         │
│  Receives JSON:                         │
│  {                                      │
│    "type": "new_message",               │
│    "message": {                         │
│      "id": 124,                         │
│      "contenu": "Hi there!",            │
│      "date_envoi": "2024-01-15T10:31:00Z",│
│      "conversation_id": 456,            │
│      "expediteur": {                    │
│        "id": 999,                       │
│        "nom": "Smith",                  │
│        "prenom": "Jane"                 │
│      }                                  │
│    }                                    │
│  }                                      │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  ChatWebSocketService                   │
│  _handleMessage(data) {                 │
│    final json = jsonDecode(data);       │
│    final type = json['type'];           │
│                                         │
│    if (type == 'new_message') {         │
│      final msgJson = json['message'];   │
│      final msg = MessageDto.fromJson(   │
│        msgJson                          │
│      );                                 │
│      _newMessageController.add(msg);    │
│    }                                    │
│  }                                      │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  Stream<MessageDto> newMessages         │
│  (Broadcast Stream)                     │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  ActiveChatNotifier                     │
│  _newMessageSub = _wsService!           │
│    .newMessages.listen((msgDto) {       │
│                                         │
│    final msg = MessageEntity(...);      │
│                                         │
│    // Deduplicate by ID                 │
│    if (!state.messages.any(             │
│      (m) => m.id == msg.id              │
│    )) {                                 │
│      state = state.copyWith(            │
│        messages: [...messages, msg]     │
│      );                                 │
│                                         │
│      // Mark as read if chat is open    │
│      if (_chatIsOpen) {                 │
│        sendMarkRead();                  │
│      }                                  │
│                                         │
│      // Trigger inbox refresh           │
│      _onMessagesChanged();              │
│    }                                    │
│  });                                    │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  UI Rebuilds                            │
│  • New message appears in chat          │
│  • Scroll to bottom                     │
│  • Read receipt sent (if chat is open)  │
│                                         │
│  Inbox Refreshes                        │
│  • Last message updated                 │
│  • Unread count updated                 │
└─────────────────────────────────────────┘
```

## 3. Typing Indicator Flow

```
┌─────────────┐
│    User     │
│  Starts     │
│  Typing     │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  UI (ChatScreen)                        │
│  TextField(                             │
│    onChanged: (text) {                  │
│      if (text.isNotEmpty) {             │
│        ref.read(activeChatProvider(id)  │
│           .notifier).sendTypingStart(); │
│      } else {                           │
│        ref.read(activeChatProvider(id)  │
│           .notifier).sendTypingStop();  │
│      }                                  │
│    }                                    │
│  )                                      │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  ActiveChatNotifier                     │
│  sendTypingStart() {                    │
│    _wsService?.sendTypingStart();       │
│  }                                      │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  ChatWebSocketService                   │
│  sendTypingStart() {                    │
│    if (_isConnected && _channel != null)│
│      final payload = jsonEncode({       │
│        'type': 'typing_start'           │
│      });                                │
│      _channel!.sink.add(payload);       │
│    }                                    │
│  }                                      │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  Backend (Django)                       │
│  Receives: {"type": "typing_start"}     │
│                                         │
│  async def _handle_typing(              │
│    self, is_typing                      │
│  ):                                     │
│    await self.channel_layer.group_send( │
│      self.room_group,                   │
│      {                                  │
│        'type': 'chat.typing',           │
│        'user_id': self.user.pk,         │
│        'is_typing': is_typing           │
│      }                                  │
│    )                                    │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  WebSocket (Other User)                 │
│  Receives:                              │
│  {                                      │
│    "type": "typing",                    │
│    "user_id": 789,                      │
│    "is_typing": true                    │
│  }                                      │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  ChatWebSocketService (Other User)      │
│  _handleMessage(data) {                 │
│    if (type == 'typing') {              │
│      final event = TypingEvent(         │
│        userId: json['user_id'],         │
│        isTyping: json['is_typing']      │
│      );                                 │
│      _typingController.add(event);      │
│    }                                    │
│  }                                      │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  ActiveChatNotifier (Other User)        │
│  _typingSub = _wsService!.typing        │
│    .listen((event) {                    │
│                                         │
│    if (event.userId != currentUserId) { │
│      final updatedTyping = Map.from(    │
│        state.typingUsers                │
│      );                                 │
│      updatedTyping[event.userId] =      │
│        event.isTyping;                  │
│                                         │
│      state = state.copyWith(            │
│        typingUsers: updatedTyping,      │
│        partnerIsTyping: event.isTyping  │
│      );                                 │
│                                         │
│      // Auto-clear after 4 seconds      │
│      if (event.isTyping) {              │
│        _typingClearTimer?.cancel();     │
│        _typingClearTimer = Timer(       │
│          Duration(seconds: 4),          │
│          () {                           │
│            // Clear typing state        │
│          }                              │
│        );                               │
│      }                                  │
│    }                                    │
│  });                                    │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  UI Rebuilds (Other User)               │
│  AppBar(                                │
│    subtitle: state.partnerIsTyping      │
│      ? Text('typing...')                │
│      : null                             │
│  )                                      │
└─────────────────────────────────────────┘
```

## 4. Read Receipt Flow

```
┌─────────────┐
│    User     │
│   Opens     │
│    Chat     │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  ChatScreen.initState()                 │
│  WidgetsBinding.instance               │
│    .addPostFrameCallback((_) {          │
│    ref.read(activeChatProvider(id)      │
│       .notifier).onChatOpened();        │
│  });                                    │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  ActiveChatNotifier                     │
│  onChatOpened() {                       │
│    _chatIsOpen = true;                  │
│    if (_wsService?.isConnected == true) │
│      sendMarkRead();                    │
│    }                                    │
│  }                                      │
│                                         │
│  sendMarkRead() {                       │
│    _wsService?.sendMarkRead();          │
│  }                                      │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  ChatWebSocketService                   │
│  sendMarkRead() {                       │
│    if (_isConnected && _channel != null)│
│      final payload = jsonEncode({       │
│        'type': 'mark_read'              │
│      });                                │
│      _channel!.sink.add(payload);       │
│    }                                    │
│  }                                      │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  Backend (Django)                       │
│  Receives: {"type": "mark_read"}        │
│                                         │
│  async def _handle_mark_read(self):     │
│    last_read_id = await                 │
│      self._update_read_cursor()         │
│                                         │
│    if last_read_id:                     │
│      await self.channel_layer.group_send│
│        self.room_group,                 │
│        {                                │
│          'type': 'chat.read_receipt',   │
│          'reader_id': self.user.pk,     │
│          'last_read_id': last_read_id   │
│        }                                │
│      )                                  │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  WebSocket (Other User)                 │
│  Receives:                              │
│  {                                      │
│    "type": "read_receipt",              │
│    "reader_id": 789,                    │
│    "last_read_id": 124                  │
│  }                                      │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  ChatWebSocketService (Other User)      │
│  _handleMessage(data) {                 │
│    if (type == 'read_receipt') {        │
│      final event = ReadReceiptEvent(    │
│        readerId: json['reader_id'],     │
│        lastReadId: json['last_read_id'] │
│      );                                 │
│      _readReceiptController.add(event); │
│    }                                    │
│  }                                      │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  ActiveChatNotifier (Other User)        │
│  _readReceiptSub = _wsService!          │
│    .readReceipts.listen((event) {       │
│                                         │
│    if (event.readerId != currentUserId) │
│      state = state.copyWith(            │
│        partnerLastReadId:               │
│          event.lastReadId               │
│      );                                 │
│      _onMessagesChanged(); // Refresh   │
│    }                                    │
│  });                                    │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  UI Rebuilds (Other User)               │
│  • Double check marks turn blue         │
│  • Read receipts update                 │
│                                         │
│  MessageBubble(                         │
│    isRead: state.partnerLastReadId !=   │
│      null && int.parse(msg.id) <=       │
│      state.partnerLastReadId!           │
│  )                                      │
│                                         │
│  Icon(                                  │
│    isRead ? Icons.done_all : Icons.done,│
│    color: isRead ? Colors.blue :        │
│      Colors.grey                        │
│  )                                      │
└─────────────────────────────────────────┘
```

## 5. Pagination Flow

```
┌─────────────┐
│    User     │
│  Scrolls    │
│   to Top    │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  ScrollController Listener              │
│  _scrollController.addListener(() {     │
│    if (_scrollController.position       │
│        .pixels == 0) {                  │
│      ref.read(activeChatProvider(id)    │
│         .notifier).loadMore();          │
│    }                                    │
│  });                                    │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  ActiveChatNotifier                     │
│  loadMore() async {                     │
│    if (!state.hasMore || state.isLoading│
│      return;                            │
│                                         │
│    state = state.copyWith(              │
│      isLoading: true                    │
│    );                                   │
│                                         │
│    final nextPage = state.currentPage + │
│      1;                                 │
│    final result = await _repository     │
│      .getMessages(conversationId,       │
│                   nextPage);            │
│                                         │
│    // Prepend older messages            │
│    state = state.copyWith(              │
│      messages: [                        │
│        ...result.messages,              │
│        ...state.messages                │
│      ],                                 │
│      hasMore: result.hasMore,           │
│      currentPage: nextPage,             │
│      isLoading: false                   │
│    );                                   │
│  }                                      │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  MessagingRepositoryApi                 │
│  getMessages(conversationId, page) {    │
│    final response = await _dataSource   │
│      .getMessages(conversationId, page);│
│    final dto = PaginatedMessagesDto     │
│      .fromJson(response.data);          │
│                                         │
│    return (                             │
│      messages: dto.results.map(         │
│        _messageDtoToEntity              │
│      ).toList(),                        │
│      hasMore: dto.next != null,         │
│      readCursors: dto.readCursors       │
│    );                                   │
│  }                                      │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  Backend (Django)                       │
│  GET /conversations/456?page=2          │
│                                         │
│  Returns:                               │
│  {                                      │
│    "count": 100,                        │
│    "next": "http://...?page=3",         │
│    "previous": "http://...?page=1",     │
│    "results": [                         │
│      {...}, {...}, ...                  │
│    ]                                    │
│  }                                      │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  UI Rebuilds                            │
│  • Older messages prepended to list     │
│  • Scroll position maintained           │
│  • Loading indicator hidden             │
└─────────────────────────────────────────┘
```

## 6. Auto-Reconnect Flow

```
┌─────────────────────────────────────────┐
│  Network Disconnects                    │
│  (WiFi off, airplane mode, etc.)        │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  WebSocket Connection                   │
│  _channel.stream.listen(                │
│    _handleMessage,                      │
│    onError: _handleError,  ◄────────────┤
│    onDone: _handleDone     ◄────────────┤
│  );                                     │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  ChatWebSocketService                   │
│  _handleError(error) {                  │
│    _isConnected = false;                │
│    if (!_disposed) {                    │
│      _scheduleReconnect();              │
│    }                                    │
│  }                                      │
│                                         │
│  _handleDone() {                        │
│    _isConnected = false;                │
│    if (!_disposed) {                    │
│      _scheduleReconnect();              │
│    }                                    │
│  }                                      │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  _scheduleReconnect()                   │
│  _reconnectTimer?.cancel();             │
│  _reconnectTimer = Timer(               │
│    Duration(seconds: 3),                │
│    () {                                 │
│      if (!_disposed) {                  │
│        _connectInternal();              │
│      }                                  │
│    }                                    │
│  );                                     │
└──────┬──────────────────────────────────┘
       │
       │ Wait 3 seconds...
       │
       ▼
┌─────────────────────────────────────────┐
│  _connectInternal()                     │
│  try {                                  │
│    _channel = WebSocketChannel.connect( │
│      Uri.parse(wsUrl)                   │
│    );                                   │
│    _isConnected = true;                 │
│    _channel!.stream.listen(...);        │
│  } catch (e) {                          │
│    _isConnected = false;                │
│    _scheduleReconnect(); // Try again   │
│  }                                      │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  Connection Restored                    │
│  • WebSocket reconnected                │
│  • Real-time events resume              │
│  • No data loss (REST API still works)  │
└─────────────────────────────────────────┘
```

## Legend

```
┌─────────┐
│  Box    │  = Component or Step
└─────────┘

    │
    ▼         = Flow Direction

◄───────      = Callback or Event
```

## Key Takeaways

1. **Dual Path**: Messages can arrive via REST (send) or WebSocket (receive)
2. **Deduplication**: Messages are deduplicated by ID to prevent duplicates
3. **Auto-Reconnect**: WebSocket automatically reconnects on disconnect
4. **Lifecycle**: Chat notifier manages WebSocket lifecycle
5. **State Updates**: All state changes trigger UI rebuilds
6. **Error Handling**: Errors are caught and converted to friendly messages
7. **Memory Management**: Resources are cleaned up on dispose

// lib/features/messaging/data/providers/active_chat_notifier.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/message_entity.dart';
import '../repositories/messaging_repository_api.dart';
import '../services/websocket_service.dart';

/// State for an active chat conversation.
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

  const ActiveChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.error,
    this.partnerIsTyping = false,
    this.typingUsers = const {},
    this.initialLoadDone = false,
    this.partnerLastReadId,
  });

  ActiveChatState copyWith({
    List<MessageEntity>? messages,
    bool? isLoading,
    bool? isSending,
    bool? hasMore,
    int? currentPage,
    String? error,
    bool? partnerIsTyping,
    Map<int, bool>? typingUsers,
    bool? initialLoadDone,
    int? partnerLastReadId,
  }) {
    return ActiveChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
      partnerIsTyping: partnerIsTyping ?? this.partnerIsTyping,
      typingUsers: typingUsers ?? this.typingUsers,
      initialLoadDone: initialLoadDone ?? this.initialLoadDone,
      partnerLastReadId: partnerLastReadId ?? this.partnerLastReadId,
    );
  }
}

/// Notifier for an active chat conversation.
/// Manages messages, WebSocket connection, and real-time events.
class ActiveChatNotifier extends StateNotifier<ActiveChatState> {
  final int conversationId;
  final int currentUserId;
  final MessagingRepositoryApi _repository;
  final void Function() _onMessagesChanged;

  ChatWebSocketService? _wsService;
  StreamSubscription? _newMessageSub;
  StreamSubscription? _readReceiptSub;
  StreamSubscription? _typingSub;
  StreamSubscription? _memberUpdateSub;
  Timer? _typingClearTimer;
  bool _chatIsOpen = false;

  ActiveChatNotifier({
    required this.conversationId,
    required this.currentUserId,
    required MessagingRepositoryApi repository,
    required void Function() onMessagesChanged,
  })  : _repository = repository,
        _onMessagesChanged = onMessagesChanged,
        super(const ActiveChatState()) {
    _initialize();
  }

  /// Initialize: fetch first page, then connect WebSocket.
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Fetch first page via REST
      final result = await _repository.getMessages(conversationId, 1);
      
      // Sort messages by timestamp (oldest first)
      final messages = result.messages..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // Extract partner's last read ID from read cursors
      int? partnerLastReadId;
      if (result.readCursors != null) {
        for (final entry in result.readCursors!.entries) {
          if (entry.key != currentUserId) {
            partnerLastReadId = entry.value;
            break;
          }
        }
      }

      state = state.copyWith(
        messages: messages,
        hasMore: result.hasMore,
        currentPage: 1,
        isLoading: false,
        initialLoadDone: true,
        partnerLastReadId: partnerLastReadId,
      );

      // Connect WebSocket
      await _connectWebSocket();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        initialLoadDone: true,
      );
    }
  }

  /// Connect to WebSocket and subscribe to events.
  Future<void> _connectWebSocket() async {
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) return;

      final wsUrl = ApiEndpoints.chatWebSocket(conversationId, token);
      _wsService = ChatWebSocketService(
        conversationId: conversationId,
        wsUrl: wsUrl,
      );
      _wsService!.connect();

      // Subscribe to new messages
      _newMessageSub = _wsService!.newMessages.listen((msgDto) {
        final msg = MessageEntity(
          id: msgDto.id,
          senderId: msgDto.senderId,
          content: msgDto.content,
          timestamp: DateTime.parse(msgDto.timestamp),
          isRead: false,
          isMine: msgDto.senderId == currentUserId.toString(),
          type: MessageType.text,
        );

        // Deduplicate by ID
        if (!state.messages.any((m) => m.id == msg.id)) {
          state = state.copyWith(
            messages: [...state.messages, msg],
          );

          // Mark as read if chat is open
          if (_chatIsOpen) {
            sendMarkRead();
          }

          // Trigger inbox refresh
          _onMessagesChanged();
        }
      });

      // Subscribe to read receipts
      _readReceiptSub = _wsService!.readReceipts.listen((event) {
        if (event.readerId != currentUserId) {
          state = state.copyWith(partnerLastReadId: event.lastReadId);
          _onMessagesChanged();
        }
      });

      // Subscribe to typing indicators
      _typingSub = _wsService!.typing.listen((event) {
        if (event.userId != currentUserId) {
          final updatedTyping = Map<int, bool>.from(state.typingUsers);
          updatedTyping[event.userId] = event.isTyping;

          state = state.copyWith(
            typingUsers: updatedTyping,
            partnerIsTyping: event.isTyping,
          );

          // Auto-clear after 4 seconds as safety net
          if (event.isTyping) {
            _typingClearTimer?.cancel();
            _typingClearTimer = Timer(const Duration(seconds: 4), () {
              final cleared = Map<int, bool>.from(state.typingUsers);
              cleared[event.userId] = false;
              state = state.copyWith(
                typingUsers: cleared,
                partnerIsTyping: false,
              );
            });
          }
        }
      });

      // Subscribe to member updates
      _memberUpdateSub = _wsService!.memberUpdates.listen((event) {
        _onMessagesChanged();
      });
    } catch (e) {
      // WebSocket connection failed, but REST still works
    }
  }

  /// Called when the chat screen is opened.
  void onChatOpened() {
    _chatIsOpen = true;
    // Immediately mark as read if WebSocket is connected
    if (_wsService?.isConnected == true) {
      sendMarkRead();
    }
  }

  /// Called when the chat screen is closed.
  void onChatClosed() {
    _chatIsOpen = false;
  }

  /// Send a message via REST API.
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    state = state.copyWith(isSending: true, error: null);

    try {
      print('[ActiveChatNotifier] sendMessage appelé avec: "$content"');
      final msg = await _repository.sendMessage(conversationId.toString(), content);
      print('[ActiveChatNotifier] Message reçu du repository: id=${msg.id}, isMine=${msg.isMine}');
      
      // Mark as mine
      final myMsg = MessageEntity(
        id: msg.id,
        senderId: msg.senderId,
        content: msg.content,
        timestamp: msg.timestamp,
        isRead: msg.isRead,
        isMine: true,
        type: msg.type,
      );

      print('[ActiveChatNotifier] Message créé: id=${myMsg.id}');

      // Deduplicate by ID before appending
      if (!state.messages.any((m) => m.id == myMsg.id)) {
        print('[ActiveChatNotifier] Ajout du message à la liste (${state.messages.length} messages actuels)');
        state = state.copyWith(
          messages: [...state.messages, myMsg],
          isSending: false,
        );
        print('[ActiveChatNotifier] Message ajouté, total: ${state.messages.length}');
      } else {
        print('[ActiveChatNotifier] Message déjà présent, skip');
        state = state.copyWith(isSending: false);
      }

      // Trigger inbox refresh
      _onMessagesChanged();
      print('[ActiveChatNotifier] sendMessage terminé avec succès');
    } catch (e, stackTrace) {
      print('[ActiveChatNotifier] ❌ EXCEPTION dans sendMessage:');
      print('[ActiveChatNotifier] Exception: $e');
      print('[ActiveChatNotifier] StackTrace:');
      print(stackTrace);
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
      );
    }
  }

  /// Send typing start indicator.
  void sendTypingStart() {
    _wsService?.sendTypingStart();
  }

  /// Send typing stop indicator.
  void sendTypingStop() {
    _wsService?.sendTypingStop();
  }

  /// Mark all messages as read.
  void sendMarkRead() {
    _wsService?.sendMarkRead();
  }

  /// Load more (older) messages.
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final nextPage = state.currentPage + 1;
      final result = await _repository.getMessages(conversationId, nextPage);

      // Sort messages by timestamp (oldest first)
      final newMessages = result.messages..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // Prepend older messages
      state = state.copyWith(
        messages: [...newMessages, ...state.messages],
        hasMore: result.hasMore,
        currentPage: nextPage,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh messages (re-fetch page 1).
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.getMessages(conversationId, 1);

      // Sort messages by timestamp (oldest first)
      final messages = result.messages..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      state = state.copyWith(
        messages: messages,
        hasMore: result.hasMore,
        currentPage: 1,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Mark all messages as read (public method).
  Future<void> markAllRead() async {
    if (_chatIsOpen) {
      sendMarkRead();
    }
  }

  @override
  void dispose() {
    _typingClearTimer?.cancel();
    _newMessageSub?.cancel();
    _readReceiptSub?.cancel();
    _typingSub?.cancel();
    _memberUpdateSub?.cancel();
    _wsService?.dispose();
    super.dispose();
  }
}

// lib/features/messaging/data/providers/chat_provider.dart
//
// Riverpod providers for the messaging feature.
//
// Architecture:
//   ChatRepository (DI)  →  ConversationListNotifier (inbox)
//                         →  ActiveChatNotifier      (single chat + WebSocket)
//
// Updated for unified conversations: family key is conversationId (int).

import 'dart:async';
import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/chat_repository.dart';
import '../models/chat_model.dart';
import '../chat_websocket_service.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

const _kConversationPollInterval = Duration(seconds: 5);

// ── Repository provider ───────────────────────────────────────────────────────

final chatRepositoryProvider = Provider<ChatRepository>(
  (_) => ChatRepository(),
);

// =============================================================================
//  CONVERSATION LIST (inbox)
// =============================================================================

/// State for the conversation list screen.
class ConversationListState {
  final List<ConversationModel> conversations;
  final bool isLoading;
  final String? error;

  const ConversationListState({
    this.conversations = const [],
    this.isLoading = false,
    this.error,
  });

  ConversationListState copyWith({
    List<ConversationModel>? conversations,
    bool? isLoading,
    String? error,
  }) =>
      ConversationListState(
        conversations: conversations ?? this.conversations,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class ConversationListNotifier extends StateNotifier<ConversationListState> {
  final ChatRepository _repo;
  Timer? _pollTimer;

  ConversationListNotifier(this._repo)
      : super(const ConversationListState(isLoading: true)) {
    loadConversations();
  }

  /// Fetch conversations from the API.
  Future<void> loadConversations() async {
    // Don't set loading on subsequent polls (avoids UI flicker)
    if (state.conversations.isEmpty) {
      state = state.copyWith(isLoading: true, error: null);
    }
    try {
      final conversations = await _repo.fetchConversations();
      state = state.copyWith(
        conversations: conversations,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Start periodic refresh. Call from screen's initState.
  void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_kConversationPollInterval, (_) {
      loadConversations();
    });
  }

  /// Stop polling. Call from screen's dispose.
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

final conversationListProvider =
    StateNotifierProvider<ConversationListNotifier, ConversationListState>(
  (ref) => ConversationListNotifier(ref.watch(chatRepositoryProvider)),
);

// =============================================================================
//  ACTIVE CHAT (single conversation — WebSocket powered)
// =============================================================================

/// State for a single chat conversation.
class ActiveChatState {
  final List<MessageModel> messages;
  final bool isLoading;
  final bool isSending;
  final bool hasMore;
  final int currentPage;
  final String? error;
  final bool partnerIsTyping;

  /// Map of userId → isTyping for group chats.
  final Map<int, bool> typingUsers;

  /// True once the initial message batch has finished loading.
  final bool initialLoadDone;

  /// The ID of the last message the partner has read (for seen indicator).
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
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isSending,
    bool? hasMore,
    int? currentPage,
    String? error,
    bool? partnerIsTyping,
    Map<int, bool>? typingUsers,
    bool? initialLoadDone,
    int? partnerLastReadId,
  }) =>
      ActiveChatState(
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

class ActiveChatNotifier extends StateNotifier<ActiveChatState> {
  final ChatRepository _repo;
  final int conversationId;
  final VoidCallback? _onMessagesChanged;
  late final ChatWebSocketService _ws;
  StreamSubscription? _msgSub;
  StreamSubscription? _readSub;
  StreamSubscription? _typingSub;
  StreamSubscription? _memberSub;
  Timer? _typingTimer;

  /// True only while ChatScreen is mounted and visible.
  bool _isChatOpen = false;

  /// True once the WebSocket handshake completes successfully.
  bool _wsConnected = false;

  ActiveChatNotifier(this._repo, this.conversationId, {VoidCallback? onMessagesChanged})
      : _onMessagesChanged = onMessagesChanged,
        super(const ActiveChatState(isLoading: true)) {
    _ws = ChatWebSocketService(conversationId: conversationId);
    _initialLoad();
  }

  // ── Lifecycle — called by ChatScreen ─────────────────────────────────────

  void onChatOpened() {
    _isChatOpen = true;
    if (_wsConnected) {
      _ws.sendMarkRead();
    }
  }

  void onChatClosed() {
    _isChatOpen = false;
  }

  // ── Initial load ──────────────────────────────────────────────────────────

  Future<void> _initialLoad() async {
    try {
      final result = await _repo.fetchMessages(conversationId);
      final chronological = result.messages.reversed.toList();
      state = state.copyWith(
        messages: chronological,
        isLoading: false,
        hasMore: result.hasMore,
        initialLoadDone: true,
        partnerLastReadId: result.partnerLastReadId,
        error: null,
      );

      // Connect WebSocket after initial REST load
      await _ws.connect();
      _wsConnected = true;
      _listenToWebSocket();

      if (_isChatOpen) {
        _ws.sendMarkRead();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  // ── WebSocket listeners ───────────────────────────────────────────────────

  void _listenToWebSocket() {
    _msgSub = _ws.onMessage.listen((event) {
      if (!mounted) return;
      final isDuplicate = state.messages.any((m) => m.id == event.message.id);
      if (!isDuplicate) {
        state = state.copyWith(
          messages: [...state.messages, event.message],
        );
        if (_isChatOpen) {
          _ws.sendMarkRead();
        }
        _onMessagesChanged?.call();
      }
    });

    _readSub = _ws.onReadReceipt.listen((event) {
      if (!mounted) return;
      // Update the partner's last-read cursor so the UI can show
      // a "seen" indicator on sent messages up to this ID.
      state = state.copyWith(partnerLastReadId: event.lastReadId);
      _onMessagesChanged?.call();
    });

    _typingSub = _ws.onTyping.listen((event) {
      if (!mounted) return;
      final updated = Map<int, bool>.from(state.typingUsers);
      updated[event.userId] = event.isTyping;
      if (!event.isTyping) updated.remove(event.userId);

      state = state.copyWith(
        typingUsers: updated,
        partnerIsTyping: updated.values.any((v) => v),
      );

      // Auto-clear typing after 4 seconds (safety net)
      if (event.isTyping) {
        _typingTimer?.cancel();
        _typingTimer = Timer(const Duration(seconds: 4), () {
          if (mounted) {
            final cleared = Map<int, bool>.from(state.typingUsers);
            cleared.remove(event.userId);
            state = state.copyWith(
              typingUsers: cleared,
              partnerIsTyping: cleared.values.any((v) => v),
            );
          }
        });
      }
    });

    _memberSub = _ws.onMemberUpdate.listen((event) {
      if (!mounted) return;
      // Refresh conversation list to reflect member changes
      _onMessagesChanged?.call();
    });
  }

  // ── Send message (via REST) ──────────────────────────────────────────────

  Future<void> sendMessage(String contenu) async {
    if (contenu.trim().isEmpty) return;

    state = state.copyWith(isSending: true);
    try {
      final msg = await _repo.sendMessage(
        conversationId: conversationId,
        contenu: contenu.trim(),
      );

      final isDuplicate = state.messages.any((m) => m.id == msg.id);
      if (!isDuplicate) {
        state = state.copyWith(
          messages: [...state.messages, msg],
          isSending: false,
          error: null,
        );
        _onMessagesChanged?.call();
      } else {
        state = state.copyWith(isSending: false, error: null);
      }
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  // ── Typing indicators ─────────────────────────────────────────────────────

  void sendTypingStart() => _ws.sendTypingStart();
  void sendTypingStop() => _ws.sendTypingStop();

  // ── Manual refresh ────────────────────────────────────────────────────────

  Future<void> refresh() async {
    try {
      final result = await _repo.fetchMessages(conversationId);
      final chronological = result.messages.reversed.toList();
      state = state.copyWith(
        messages: chronological,
        hasMore: result.hasMore,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  // ── Mark all read ─────────────────────────────────────────────────────────

  void markAllRead() {
    if (_isChatOpen) {
      _ws.sendMarkRead();
    }
  }

  // ── Load earlier messages (pagination) ────────────────────────────────────

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoading: true);
    try {
      final nextPage = state.currentPage + 1;
      final result = await _repo.fetchMessages(conversationId, page: nextPage);
      final olderChronological = result.messages.reversed.toList();
      state = state.copyWith(
        messages: [...olderChronological, ...state.messages],
        isLoading: false,
        hasMore: result.hasMore,
        currentPage: nextPage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    _readSub?.cancel();
    _typingSub?.cancel();
    _memberSub?.cancel();
    _typingTimer?.cancel();
    _ws.dispose();
    super.dispose();
  }
}

/// Family provider keyed by conversation ID.
/// autoDispose tears down the notifier + WebSocket when ChatScreen is popped.
final activeChatProvider = StateNotifierProvider.autoDispose
    .family<ActiveChatNotifier, ActiveChatState, int>(
  (ref, conversationId) => ActiveChatNotifier(
    ref.watch(chatRepositoryProvider),
    conversationId,
    onMessagesChanged: () {
      ref.read(conversationListProvider.notifier).loadConversations();
    },
  ),
);
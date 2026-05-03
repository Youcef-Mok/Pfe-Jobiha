// lib/features/messaging/data/providers/chat_provider.dart
//
// Riverpod providers for the messaging feature.
//
// Architecture:
//   ChatRepository (DI)  →  ConversationListNotifier (inbox)
//                         →  ActiveChatNotifier      (single chat + WebSocket)
//
// The ActiveChatNotifier now uses WebSocket for real-time events
// (new messages, read receipts, typing) and falls back to REST for
// initial load, pagination, and mark-as-read.

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

  /// True once the initial message batch has finished loading.
  /// The UI uses this flag to trigger the first scroll-to-bottom.
  final bool initialLoadDone;

  const ActiveChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.error,
    this.partnerIsTyping = false,
    this.initialLoadDone = false,
  });

  ActiveChatState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isSending,
    bool? hasMore,
    int? currentPage,
    String? error,
    bool? partnerIsTyping,
    bool? initialLoadDone,
  }) =>
      ActiveChatState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        isSending: isSending ?? this.isSending,
        hasMore: hasMore ?? this.hasMore,
        currentPage: currentPage ?? this.currentPage,
        error: error,
        partnerIsTyping: partnerIsTyping ?? this.partnerIsTyping,
        initialLoadDone: initialLoadDone ?? this.initialLoadDone,
      );
}

class ActiveChatNotifier extends StateNotifier<ActiveChatState> {
  final ChatRepository _repo;
  final int partnerId;
  final VoidCallback? _onMessagesChanged;
  late final ChatWebSocketService _ws;
  StreamSubscription? _msgSub;
  StreamSubscription? _readSub;
  StreamSubscription? _typingSub;
  Timer? _typingTimer;

  /// True only while ChatScreen is mounted and visible.
  /// Guards all sendMarkRead() calls so messages are never auto-marked
  /// read unless the user is actually looking at the conversation.
  bool _isChatOpen = false;

  /// True once the WebSocket handshake completes successfully.
  /// Prevents sendMarkRead() from firing before the channel is ready.
  bool _wsConnected = false;

  ActiveChatNotifier(this._repo, this.partnerId, {VoidCallback? onMessagesChanged})
      : _onMessagesChanged = onMessagesChanged,
        super(const ActiveChatState(isLoading: true)) {
    _ws = ChatWebSocketService(partnerId: partnerId);
    _initialLoad();
  }

  // ── Lifecycle — called by ChatScreen ─────────────────────────────────────

  /// Call from ChatScreen.initState (via addPostFrameCallback).
  /// Marks the chat as visible and fires the initial mark-read.
  void onChatOpened() {
    _isChatOpen = true;
    // Only send mark_read if the WebSocket is already connected.
    // If it isn't yet (initial load still in progress), the mark_read
    // will fire once _initialLoad() finishes and sees _isChatOpen == true.
    if (_wsConnected) {
      _ws.sendMarkRead();
    }
  }

  /// Call from ChatScreen.dispose.
  /// Prevents further auto-read signals after the screen is gone.
  void onChatClosed() {
    _isChatOpen = false;
  }

  // ── Initial load ──────────────────────────────────────────────────────────

  Future<void> _initialLoad() async {
    try {
      final result = await _repo.fetchMessages(partnerId);
      // API returns newest-first pages; reverse so the ListView shows
      // messages chronologically (oldest at top, newest at bottom).
      final chronological = result.messages.reversed.toList();
      state = state.copyWith(
        messages: chronological,
        isLoading: false,
        hasMore: result.hasMore,
        initialLoadDone: true,
        error: null,
      );

      // Connect WebSocket after initial REST load
      await _ws.connect();
      _wsConnected = true;
      _listenToWebSocket();

      // Now that the WS is live, fire mark_read if the screen is already
      // visible (onChatOpened may have run while we were still loading).
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
        // Only mark read if the user is actually looking at the chat screen.
        if (_isChatOpen) {
          _ws.sendMarkRead();
        }
        // Refresh the inbox so the last-message preview stays current.
        _onMessagesChanged?.call();
      }
    });

    _readSub = _ws.onReadReceipt.listen((event) {
      if (!mounted) return;

      bool anyChanged = false;
      final updated = state.messages.map((m) {
        // Mark messages that were sent TO the reader (they received & read them)
        if (m.destinataire.id == event.readerId && !m.estLu) {
          anyChanged = true;
          return m.copyWith(estLu: true);
        }
        return m;
      }).toList();

      // Only trigger a rebuild if at least one message actually changed.
      if (anyChanged) {
        state = state.copyWith(messages: updated);
      }
    });

    _typingSub = _ws.onTyping.listen((event) {
      if (!mounted) return;
      state = state.copyWith(partnerIsTyping: event.isTyping);

      // Auto-clear typing after 4 seconds (safety net)
      if (event.isTyping) {
        _typingTimer?.cancel();
        _typingTimer = Timer(const Duration(seconds: 4), () {
          if (mounted) {
            state = state.copyWith(partnerIsTyping: false);
          }
        });
      }
    });
  }

  // ── Send message (via REST, optimistic local append) ─────────────────────

  Future<void> sendMessage(String contenu) async {
    if (contenu.trim().isEmpty) return;

    state = state.copyWith(isSending: true);
    try {
      final msg = await _repo.sendMessage(
        destinataireId: partnerId,
        contenu: contenu.trim(),
      );

      final isDuplicate = state.messages.any((m) => m.id == msg.id);
      if (!isDuplicate) {
        state = state.copyWith(
          messages: [...state.messages, msg],
          isSending: false,
          error: null,
        );
        // Refresh the inbox so the last-message preview stays current.
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
      final result = await _repo.fetchMessages(partnerId);
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

  // ── Mark all read (manual, e.g. called from UI) ───────────────────────────

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
      final result = await _repo.fetchMessages(partnerId, page: nextPage);
      // Reverse to chronological order, then prepend (older messages go on top).
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
    _typingTimer?.cancel();
    _ws.dispose();
    super.dispose();
  }
}

/// Family provider keyed by partner user ID.
/// Uses autoDispose so the notifier (and its WebSocket) is torn down when
/// the ChatScreen is popped. This prevents stale connections from
/// accidentally marking messages as read while the user isn't viewing
/// the conversation.
final activeChatProvider = StateNotifierProvider.autoDispose
    .family<ActiveChatNotifier, ActiveChatState, int>(
  (ref, partnerId) => ActiveChatNotifier(
    ref.watch(chatRepositoryProvider),
    partnerId,
    onMessagesChanged: () {
      // Push-refresh the inbox so the last-message preview updates instantly.
      ref.read(conversationListProvider.notifier).loadConversations();
    },
  ),
);
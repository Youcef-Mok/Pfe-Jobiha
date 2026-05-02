// lib/features/messaging/data/providers/chat_provider.dart
//
// Riverpod providers for the messaging feature.
//
// Architecture:
//   ChatRepository (DI)  →  ConversationListNotifier (inbox)
//                         →  ActiveChatNotifier      (single chat, family)
//
// Polling:
//   - Conversation list: every 15 seconds
//   - Active chat: every 5 seconds
//   These timers are started/stopped by the screens via startPolling/stopPolling.
//   When WebSockets are added later, replace the Timer with a stream listener.

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/chat_repository.dart';
import '../models/chat_model.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

const _kConversationPollInterval = Duration(seconds: 15);
const _kChatPollInterval = Duration(seconds: 5);

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

  /// Start periodic refresh.  Call from screen's initState.
  void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_kConversationPollInterval, (_) {
      loadConversations();
    });
  }

  /// Stop polling.  Call from screen's dispose.
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
//  ACTIVE CHAT (single conversation)
// =============================================================================

/// State for a single chat conversation.
class ActiveChatState {
  final List<MessageModel> messages;
  final bool isLoading;
  final bool isSending;
  final bool hasMore;
  final int currentPage;
  final String? error;

  const ActiveChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.error,
  });

  ActiveChatState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isSending,
    bool? hasMore,
    int? currentPage,
    String? error,
  }) =>
      ActiveChatState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        isSending: isSending ?? this.isSending,
        hasMore: hasMore ?? this.hasMore,
        currentPage: currentPage ?? this.currentPage,
        error: error,
      );
}

class ActiveChatNotifier extends StateNotifier<ActiveChatState> {
  final ChatRepository _repo;
  final int partnerId;
  Timer? _pollTimer;

  ActiveChatNotifier(this._repo, this.partnerId)
      : super(const ActiveChatState(isLoading: true)) {
    _initialLoad();
  }

  // ── Initial load ──────────────────────────────────────────────────────────

  Future<void> _initialLoad() async {
    try {
      final result = await _repo.fetchMessages(partnerId);
      state = state.copyWith(
        messages: result.messages,
        isLoading: false,
        hasMore: result.hasMore,
        error: null,
      );
      // Mark all as read on open
      _repo.markConversationRead(partnerId).catchError((_) {});
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  // ── Send message ──────────────────────────────────────────────────────────

  Future<void> sendMessage(String contenu) async {
    if (contenu.trim().isEmpty) return;

    state = state.copyWith(isSending: true);
    try {
      final msg = await _repo.sendMessage(
        destinataireId: partnerId,
        contenu: contenu.trim(),
      );
      state = state.copyWith(
        messages: [...state.messages, msg],
        isSending: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  // ── Poll for new messages ─────────────────────────────────────────────────

  void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_kChatPollInterval, (_) {
      _pollNewMessages();
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _pollNewMessages() async {
    try {
      final result = await _repo.fetchMessages(partnerId);
      if (!mounted) return;
      // Only update if there are new messages (avoid unnecessary rebuilds)
      if (result.messages.length != state.messages.length ||
          (result.messages.isNotEmpty &&
              state.messages.isNotEmpty &&
              result.messages.last.id != state.messages.last.id)) {
        state = state.copyWith(
          messages: result.messages,
          hasMore: result.hasMore,
        );
      }
    } catch (_) {
      // Silent fail on poll — don't disrupt the user
    }
  }

  // ── Manual refresh ────────────────────────────────────────────────────────

  Future<void> refresh() async {
    try {
      final result = await _repo.fetchMessages(partnerId);
      state = state.copyWith(
        messages: result.messages,
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

  Future<void> markAllRead() async {
    try {
      await _repo.markConversationRead(partnerId);
    } catch (_) {
      // Non-critical — silent fail
    }
  }

  // ── Load earlier messages (pagination) ────────────────────────────────────

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoading: true);
    try {
      final nextPage = state.currentPage + 1;
      final result = await _repo.fetchMessages(partnerId, page: nextPage);
      state = state.copyWith(
        messages: [...result.messages, ...state.messages],
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
    _pollTimer?.cancel();
    super.dispose();
  }
}

/// Family provider keyed by partner user ID.
/// Each open chat gets its own notifier instance.
final activeChatProvider =
    StateNotifierProvider.family<ActiveChatNotifier, ActiveChatState, int>(
  (ref, partnerId) =>
      ActiveChatNotifier(ref.watch(chatRepositoryProvider), partnerId),
);

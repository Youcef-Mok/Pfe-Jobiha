// lib/features/messaging/data/providers/conversation_list_notifier.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/message_entity.dart';
import '../repositories/messaging_repository_api.dart';

/// State for the conversation list (inbox).
class ConversationListState {
  final List<ConversationEntity> conversations;
  final bool isLoading;
  final String? error;

  const ConversationListState({
    this.conversations = const [],
    this.isLoading = false,
    this.error,
  });

  ConversationListState copyWith({
    List<ConversationEntity>? conversations,
    bool? isLoading,
    String? error,
  }) {
    return ConversationListState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for the conversation list (inbox).
/// Loads conversations on construction and supports polling.
class ConversationListNotifier extends StateNotifier<ConversationListState> {
  final MessagingRepositoryApi _repository;
  Timer? _pollingTimer;

  ConversationListNotifier(this._repository) : super(const ConversationListState()) {
    _loadConversations();
  }

  /// Load conversations from the API.
  Future<void> _loadConversations({bool silent = false}) async {
    if (!silent) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final conversations = await _repository.getConversations();
      state = state.copyWith(
        conversations: conversations,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh conversations (public method for pull-to-refresh).
  Future<void> refresh() async {
    await _loadConversations(silent: false);
  }

  /// Start polling for new conversations every 5 seconds.
  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _loadConversations(silent: true);
    });
  }

  /// Stop polling.
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}

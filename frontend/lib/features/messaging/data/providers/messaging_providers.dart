// lib/features/messaging/data/providers/messaging_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/messaging_remote_datasource.dart';
import '../repositories/messaging_repository_api.dart';
import 'conversation_list_notifier.dart';
import 'active_chat_notifier.dart';
import '../../../auth/providers/auth_providers.dart';

// ── Repository provider ────────────────────────────────────────────────────────

/// Provider for the messaging repository.
final messagingRepositoryProvider = Provider<MessagingRepositoryApi>((ref) {
  final dataSource = MessagingRemoteDataSource();
  return MessagingRepositoryApi(dataSource);
});

// ── Conversation list provider ─────────────────────────────────────────────────

/// Provider for the conversation list (inbox).
final conversationListProvider =
    StateNotifierProvider<ConversationListNotifier, ConversationListState>((ref) {
  final repository = ref.watch(messagingRepositoryProvider);
  return ConversationListNotifier(repository);
});

// ── Active chat provider ───────────────────────────────────────────────────────

/// Provider for an active chat conversation.
/// Uses autoDispose to close WebSocket when the screen is popped.
/// Family keyed by conversation ID.
final activeChatProvider = StateNotifierProvider.autoDispose
    .family<ActiveChatNotifier, ActiveChatState, int>((ref, conversationId) {
  final repository = ref.watch(messagingRepositoryProvider);
  final authState = ref.watch(authProvider);
  final currentUserId = authState.userId ?? 0;

  // Callback to refresh the conversation list when messages change
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

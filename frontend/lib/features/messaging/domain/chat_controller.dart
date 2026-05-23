import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/features/messaging/data/repositories/messaging_repository.dart';
import 'package:job_app/features/messaging/domain/message_entity.dart';

class MessagingState {
  final List<ConversationEntity> conversations;
  final List<ConversationEntity> invitations;
  final bool isLoading;
  final String activeTab; // 'messages' | 'invitations'
  final Set<String> blockedIds;
  final Set<String> restrictedIds;

  const MessagingState({
    this.conversations = const [],
    this.invitations = const [],
    this.isLoading = false,
    this.activeTab = 'messages',
    this.blockedIds = const <String>{},
    this.restrictedIds = const <String>{},
  });

  MessagingState copyWith({
    List<ConversationEntity>? conversations,
    List<ConversationEntity>? invitations,
    bool? isLoading,
    String? activeTab,
    Set<String>? blockedIds,
    Set<String>? restrictedIds,
  }) {
    return MessagingState(
      conversations: conversations ?? this.conversations,
      invitations: invitations ?? this.invitations,
      isLoading: isLoading ?? this.isLoading,
      activeTab: activeTab ?? this.activeTab,
      blockedIds: blockedIds ?? this.blockedIds,
      restrictedIds: restrictedIds ?? this.restrictedIds,
    );
  }
}

class MessagingController extends StateNotifier<MessagingState> {
  final MessagingRepository _repo;

  MessagingController(this._repo) : super(const MessagingState()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true);
    final convs = await _repo.getConversations();
    final invs = await _repo.getInvitations();
    final blockedIds = await _repo.getBlockedIds();
    final restrictedIds = await _repo.getRestrictedIds();
    state = state.copyWith(
      conversations: convs,
      invitations: invs,
      blockedIds: blockedIds,
      restrictedIds: restrictedIds,
      isLoading: false,
    );
  }

  void setTab(String tab) => state = state.copyWith(activeTab: tab);

  Future<void> sendMessage(String conversationId, String content) async {
    await _repo.sendMessage(conversationId, content);
    await _load();
  }

  Future<void> sendImageMessage(String conversationId, String imagePath) async {
    await _repo.sendImageMessage(conversationId, imagePath);
    await _load();
  }

  Future<void> sendFileMessage(String conversationId, String filePath) async {
    await _repo.sendFileMessage(conversationId, filePath);
    await _load();
  }

  Future<void> acceptInvitation(String conversationId) async {
    await _repo.acceptInvitation(conversationId);
    await _load();
  }

  Future<void> declineInvitation(String conversationId) async {
    await _repo.declineInvitation(conversationId);
    await _load();
  }

  Future<void> deleteConversations(List<String> ids) async {
    await _repo.deleteConversations(ids);
    await _load();
  }

  Future<ConversationEntity> createGroup(
    String groupName,
    List<int> memberIds,
  ) async {
    final conv = await _repo.createGroup(groupName, memberIds);
    await _load();
    return conv;
  }

  Future<void> blockContact(String conversationId) async {
    await _repo.blockContact(conversationId);
    await _load();
  }

  Future<void> unblockContact(String conversationId) async {
    await _repo.unblockContact(conversationId);
    await _load();
  }

  Future<void> restrictContact(String conversationId) async {
    await _repo.restrictContact(conversationId);
    await _load();
  }

  Future<void> unrestrictContact(String conversationId) async {
    await _repo.unrestrictContact(conversationId);
    await _load();
  }

  Future<ConversationEntity> getOrCreateConversation({
    required String contactName,
    required String contactRole,
    String? contactAvatar,
  }) async {
    final conversation = await _repo.getOrCreateConversation(
      contactName: contactName,
      contactRole: contactRole,
      contactAvatar: contactAvatar,
    );
    await _load();
    return conversation;
  }

  Future<ConversationEntity> getOrCreateConversationById(int contactId) async {
    final conversation = await _repo.getOrCreateConversationById(contactId);
    await _load();
    return conversation;
  }
}

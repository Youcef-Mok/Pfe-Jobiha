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
    print('[MessagingController] MessagingController initialisé');
    _load();
  }

  Future<void> _load() async {
    print('[MessagingController] _load appelé');
    state = state.copyWith(isLoading: true);
    try {
      final convs = await _repo.getConversations();
      print('[MessagingController] Loaded ${convs.length} conversations');
      for (final c in convs) {
        print('[MessagingController] Conv id=${c.id} isGroup=${c.isGroup} name="${c.contactName}" groupName="${c.groupName}"');
      }
      
      // Sort conversations by last message time (newest first)
      convs.sort((a, b) {
        final aTime = a.lastMessageTime ?? DateTime(2000);
        final bTime = b.lastMessageTime ?? DateTime(2000);
        return bTime.compareTo(aTime); // newest first
      });
      
      print("state mis à jour avec: ${convs.length} convs");
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
      print('[MessagingController] _load terminé, isLoading: false');
    } catch (e, stackTrace) {
      print('[MessagingController] ERREUR dans _load: $e');
      print('[MessagingController] StackTrace: $stackTrace');
      state = state.copyWith(isLoading: false);
    }
  }

  // Public method to refresh conversations list
  Future<void> refreshConversations() async {
    await _load();
  }

  void setTab(String tab) => state = state.copyWith(activeTab: tab);

  Future<void> loadConversationMessages(String conversationId) async {
    print('[MessagingController] loadConversationMessages appelé: conversationId=$conversationId');
    try {
      final conversationWithMessages = await _repo.getConversationById(conversationId);
      
      // Update the conversation in the list with the loaded messages
      final updatedConversations = state.conversations.map((conv) {
        if (conv.id == conversationId) {
          print('[MessagingController] Mise à jour de la conversation avec ${conversationWithMessages.messages.length} messages');
          return conversationWithMessages;
        }
        return conv;
      }).toList();
      
      // Re-sort conversations by last message time after updating
      updatedConversations.sort((a, b) {
        final aTime = a.lastMessageTime ?? DateTime(2000);
        final bTime = b.lastMessageTime ?? DateTime(2000);
        return bTime.compareTo(aTime); // newest first
      });
      
      state = state.copyWith(conversations: updatedConversations);
      print('[MessagingController] loadConversationMessages terminé');
    } catch (e, stackTrace) {
      print('[MessagingController] Error loading conversation messages: $e');
      print('[MessagingController] StackTrace: $stackTrace');
    }
  }

  Future<void> markAsRead(String conversationId) async {
    print('[MessagingController] markAsRead appelé: conversationId=$conversationId');
    try {
      await _repo.markAsRead(conversationId);
      print('[MessagingController] markAsRead réussi');
      
      // Immediately update isUnread to false in the local state
      final updatedConversations = state.conversations.map((conv) {
        if (conv.id == conversationId) {
          return ConversationEntity(
            id: conv.id,
            contactName: conv.contactName,
            contactRole: conv.contactRole,
            contactAvatar: conv.contactAvatar,
            isOnline: conv.isOnline,
            lastMessage: conv.lastMessage,
            lastMessageTime: conv.lastMessageTime,
            isUnread: false, // Mark as read
            unreadCount: 0, // Reset unread count
            isInvitation: conv.isInvitation,
            messages: conv.messages,
            isGroup: conv.isGroup,
            groupName: conv.groupName,
            memberAvatars: conv.memberAvatars,
            memberNames: conv.memberNames,
          );
        }
        return conv;
      }).toList();
      
      state = state.copyWith(conversations: updatedConversations);
      
      // Also reload conversation to get updated messages
      await loadConversationMessages(conversationId);
    } catch (e, stackTrace) {
      print('[MessagingController] Error marking conversation as read: $e');
      print('[MessagingController] StackTrace: $stackTrace');
    }
  }

  Future<void> sendMessage(String conversationId, String content) async {
    print('[MessagingController] sendMessage appelé: conversationId=$conversationId');
    try {
      await _repo.sendMessage(conversationId, content);
      print('[MessagingController] sendMessage réussi, rechargement des conversations');
      await loadConversationMessages(conversationId);
    } catch (e, stackTrace) {
      print('[MessagingController] ERREUR dans sendMessage: $e');
      print('[MessagingController] StackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<void> sendImageMessage(String conversationId, String imagePath) async {
    await _repo.sendImageMessage(conversationId, imagePath);
    await loadConversationMessages(conversationId);
  }

  Future<void> sendFileMessage(String conversationId, String filePath) async {
    await _repo.sendFileMessage(conversationId, filePath);
    await loadConversationMessages(conversationId);
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
    print('[DEBUG] createGroup called with groupName="$groupName" memberIds=$memberIds');
    final conversation = await _repo.createGroup(groupName, memberIds);
    print('[DEBUG] createGroup returned, now calling _load()');
    await _load();
    print('[DEBUG] _load() completed after createGroup');
    return conversation;
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
}

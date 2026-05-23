import '../../domain/message_entity.dart';

abstract class MessagingRepository {
  Future<List<ConversationEntity>> getConversations();
  Future<List<ConversationEntity>> getInvitations();
  Future<MessageEntity> sendMessage(String conversationId, String content);
  Future<void> sendImageMessage(String conversationId, String imagePath);
  Future<void> sendFileMessage(String conversationId, String filePath);
  Future<void> acceptInvitation(String conversationId);
  Future<void> declineInvitation(String conversationId);
  Future<void> deleteConversations(List<String> ids);
  Future<ConversationEntity> createGroup(String groupName, List<int> memberIds);
  Future<void> markAsRead(String conversationId);
  Future<Set<String>> getBlockedIds();
  Future<Set<String>> getRestrictedIds();
  Future<void> blockContact(String conversationId);
  Future<void> unblockContact(String conversationId);
  Future<void> restrictContact(String conversationId);
  Future<void> unrestrictContact(String conversationId);
  Future<ConversationEntity> getOrCreateConversation({
    required String contactName,
    required String contactRole,
    String? contactAvatar,
  });
}

class ConversationEntity {
  final String id;
  final String contactName;
  final String? contactTag;
  final String lastMessage;
  final String lastMessageTime;
  final bool isUnread;
  final bool isPinned;
  final String? avatarUrl;

  const ConversationEntity({
    required this.id,
    required this.contactName,
    this.contactTag,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.isUnread,
    required this.isPinned,
    this.avatarUrl,
  });
}
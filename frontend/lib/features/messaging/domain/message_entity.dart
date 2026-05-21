enum MessageType { text, invitation, image, file }

class MessageEntity {
  final String id;
  final String senderId;
  final String? content;
  final DateTime timestamp;
  final bool isRead;
  final bool isMine;
  final MessageType type;

  const MessageEntity({
    required this.id,
    required this.senderId,
    this.content,
    required this.timestamp,
    required this.isRead,
    required this.isMine,
    this.type = MessageType.text,
  });
}

class ConversationEntity {
  final String id;
  final String contactName;
  final String contactRole;
  final String? contactAvatar;
  final bool isOnline;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool isUnread;
  final int unreadCount;
  final bool isInvitation;
  final List<MessageEntity> messages;
  // Group support
  final bool isGroup;
  final String? groupName;
  final List<String> memberAvatars;
  final List<String> memberNames;

  const ConversationEntity({
    required this.id,
    required this.contactName,
    required this.contactRole,
    this.contactAvatar,
    required this.isOnline,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.isUnread,
    this.unreadCount = 0,
    this.isInvitation = false,
    this.messages = const [],
    this.isGroup = false,
    this.groupName,
    this.memberAvatars = const [],
    this.memberNames = const [],
  });
}

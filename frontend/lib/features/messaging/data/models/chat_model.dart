import 'package:job_app/features/messaging/domain/message_entity.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String? content;
  final DateTime timestamp;
  final bool isRead;
  final bool isMine;
  final MessageType type;

  const MessageModel({
    required this.id,
    required this.senderId,
    this.content,
    required this.timestamp,
    required this.isRead,
    required this.isMine,
    this.type = MessageType.text,
  });

  MessageEntity toEntity() => MessageEntity(
        id: id,
        senderId: senderId,
        content: content,
        timestamp: timestamp,
        isRead: isRead,
        isMine: isMine,
        type: type,
      );

  factory MessageModel.fromEntity(MessageEntity entity) => MessageModel(
        id: entity.id,
        senderId: entity.senderId,
        content: entity.content,
        timestamp: entity.timestamp,
        isRead: entity.isRead,
        isMine: entity.isMine,
        type: entity.type,
      );
}

class ConversationModel {
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
  final List<MessageModel> messages;
  final bool isGroup;
  final String? groupName;
  final List<String> memberAvatars;
  final List<String> memberNames;

  const ConversationModel({
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

  ConversationEntity toEntity() => ConversationEntity(
        id: id,
        contactName: contactName,
        contactRole: contactRole,
        contactAvatar: contactAvatar,
        isOnline: isOnline,
        lastMessage: lastMessage,
        lastMessageTime: lastMessageTime,
        isUnread: isUnread,
        unreadCount: unreadCount,
        isInvitation: isInvitation,
        messages: messages.map((m) => m.toEntity()).toList(),
        isGroup: isGroup,
        groupName: groupName,
        memberAvatars: memberAvatars,
        memberNames: memberNames,
      );

  factory ConversationModel.fromEntity(ConversationEntity entity) =>
      ConversationModel(
        id: entity.id,
        contactName: entity.contactName,
        contactRole: entity.contactRole,
        contactAvatar: entity.contactAvatar,
        isOnline: entity.isOnline,
        lastMessage: entity.lastMessage,
        lastMessageTime: entity.lastMessageTime,
        isUnread: entity.isUnread,
        unreadCount: entity.unreadCount,
        isInvitation: entity.isInvitation,
        messages: entity.messages.map(MessageModel.fromEntity).toList(),
        isGroup: entity.isGroup,
        groupName: entity.groupName,
        memberAvatars: entity.memberAvatars,
        memberNames: entity.memberNames,
      );
}

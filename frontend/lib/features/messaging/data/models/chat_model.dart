import 'package:job_app/features/messaging/domain/conversation_entity.dart';
import 'package:job_app/features/messaging/domain/message_entity.dart';

class ConversationModel {
  final String id;
  final String contactName;
  final String? contactTag;
  final String lastMessage;
  final String lastMessageTime;
  final bool isUnread;
  final bool isPinned;
  final String? avatarUrl;

  const ConversationModel({
    required this.id,
    required this.contactName,
    this.contactTag,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.isUnread,
    required this.isPinned,
    this.avatarUrl,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      ConversationModel(
        id: json['id'] as String,
        contactName: json['contact_name'] as String,
        contactTag: json['contact_tag'] as String?,
        lastMessage: json['last_message'] as String,
        lastMessageTime: json['last_message_time'] as String,
        isUnread: json['is_unread'] as bool? ?? false,
        isPinned: json['is_pinned'] as bool? ?? false,
        avatarUrl: json['avatar_url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'contact_name': contactName,
        'contact_tag': contactTag,
        'last_message': lastMessage,
        'last_message_time': lastMessageTime,
        'is_unread': isUnread,
        'is_pinned': isPinned,
        'avatar_url': avatarUrl,
      };

  ConversationEntity toEntity() => ConversationEntity(
        id: id,
        contactName: contactName,
        contactTag: contactTag,
        lastMessage: lastMessage,
        lastMessageTime: lastMessageTime,
        isUnread: isUnread,
        isPinned: isPinned,
        avatarUrl: avatarUrl,
      );

  factory ConversationModel.fromEntity(ConversationEntity entity) =>
      ConversationModel(
        id: entity.id,
        contactName: entity.contactName,
        contactTag: entity.contactTag,
        lastMessage: entity.lastMessage,
        lastMessageTime: entity.lastMessageTime,
        isUnread: entity.isUnread,
        isPinned: entity.isPinned,
        avatarUrl: entity.avatarUrl,
      );
}

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final String sentAt;
  final bool isMe;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.sentAt,
    required this.isMe,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id'] as String,
        conversationId: json['conversation_id'] as String,
        senderId: json['sender_id'] as String,
        content: json['content'] as String,
        sentAt: json['sent_at'] as String,
        isMe: json['is_me'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversation_id': conversationId,
        'sender_id': senderId,
        'content': content,
        'sent_at': sentAt,
        'is_me': isMe,
      };

  MessageEntity toEntity() => MessageEntity(
        id: id,
        conversationId: conversationId,
        senderId: senderId,
        content: content,
        sentAt: sentAt,
        isMe: isMe,
      );

  factory MessageModel.fromEntity(MessageEntity entity) => MessageModel(
        id: entity.id,
        conversationId: entity.conversationId,
        senderId: entity.senderId,
        content: entity.content,
        sentAt: entity.sentAt,
        isMe: entity.isMe,
      );
}
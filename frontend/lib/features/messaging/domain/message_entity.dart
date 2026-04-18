class MessageEntity {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final String sentAt;
  final bool isMe;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.sentAt,
    required this.isMe,
  });
}
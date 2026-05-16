// lib/features/messaging/domain/message_entity.dart

class MessageEntity {
  final int id;
  final String contenu;
  final DateTime dateEnvoi;
  final int conversationId;
  final int expediteurId;
  final String expediteurNom;
  final String expediteurPrenom;

  const MessageEntity({
    required this.id,
    required this.contenu,
    required this.dateEnvoi,
    required this.conversationId,
    required this.expediteurId,
    required this.expediteurNom,
    required this.expediteurPrenom,
  });

  /// Whether this message was sent by the given user ID.
  bool isSentBy(int userId) => expediteurId == userId;
}
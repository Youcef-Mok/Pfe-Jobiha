// lib/features/messaging/domain/message_entity.dart

class MessageEntity {
  final int id;
  final String contenu;
  final DateTime dateEnvoi;
  final bool estLu;
  final int expediteurId;
  final String expediteurNom;
  final String expediteurPrenom;
  final int destinataireId;
  final String destinataireNom;
  final String destinatairePrenom;

  const MessageEntity({
    required this.id,
    required this.contenu,
    required this.dateEnvoi,
    required this.estLu,
    required this.expediteurId,
    required this.expediteurNom,
    required this.expediteurPrenom,
    required this.destinataireId,
    required this.destinataireNom,
    required this.destinatairePrenom,
  });

  /// Whether this message was sent by the given user ID.
  bool isSentBy(int userId) => expediteurId == userId;
}
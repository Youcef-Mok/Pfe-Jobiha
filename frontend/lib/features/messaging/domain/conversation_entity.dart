// lib/features/messaging/domain/conversation_entity.dart

import 'message_entity.dart';

class ConversationEntity {
  final int interlocuteurId;
  final String interlocuteurNom;
  final String interlocuteurPrenom;
  final String? interlocuteurRole;
  final MessageEntity dernierMessage;
  final int nbNonLus;

  const ConversationEntity({
    required this.interlocuteurId,
    required this.interlocuteurNom,
    required this.interlocuteurPrenom,
    this.interlocuteurRole,
    required this.dernierMessage,
    required this.nbNonLus,
  });

  /// Display name for the conversation partner.
  String get contactDisplayName => '$interlocuteurPrenom $interlocuteurNom';

  /// Initials for avatar fallback (no photo support yet).
  String get contactInitials {
    final first = interlocuteurPrenom.isNotEmpty ? interlocuteurPrenom[0] : '';
    final last = interlocuteurNom.isNotEmpty ? interlocuteurNom[0] : '';
    return '$first$last'.toUpperCase();
  }

  /// Whether there are unread messages.
  bool get hasUnread => nbNonLus > 0;
}
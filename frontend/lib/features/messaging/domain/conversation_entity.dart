// lib/features/messaging/domain/conversation_entity.dart

import 'message_entity.dart';

class MemberBrief {
  final int id;
  final String nom;
  final String prenom;
  final String? role;

  const MemberBrief({
    required this.id,
    required this.nom,
    required this.prenom,
    this.role,
  });
}

class ConversationEntity {
  final int conversationId;
  final String type; // 'direct' | 'group'
  final String? groupName;

  /// For DMs: the partner's info. Null for groups.
  final int? interlocuteurId;
  final String? interlocuteurNom;
  final String? interlocuteurPrenom;
  final String? interlocuteurRole;

  /// For groups: list of active members. Null for DMs.
  final List<MemberBrief>? members;

  final MessageEntity dernierMessage;
  final int nbNonLus;

  const ConversationEntity({
    required this.conversationId,
    required this.type,
    this.groupName,
    this.interlocuteurId,
    this.interlocuteurNom,
    this.interlocuteurPrenom,
    this.interlocuteurRole,
    this.members,
    required this.dernierMessage,
    required this.nbNonLus,
  });

  bool get isDirect => type == 'direct';
  bool get isGroup => type == 'group';

  /// Display name: partner name for DMs, group name for groups.
  String get displayName {
    if (isDirect) {
      return '${interlocuteurPrenom ?? ''} ${interlocuteurNom ?? ''}'.trim();
    }
    return groupName ?? 'Groupe';
  }

  /// Initials for avatar fallback.
  String get initials {
    if (isDirect) {
      final first = (interlocuteurPrenom ?? '').isNotEmpty ? interlocuteurPrenom![0] : '';
      final last = (interlocuteurNom ?? '').isNotEmpty ? interlocuteurNom![0] : '';
      return '$first$last'.toUpperCase();
    }
    return (groupName ?? 'G').substring(0, 1).toUpperCase();
  }

  /// Whether there are unread messages.
  bool get hasUnread => nbNonLus > 0;
}
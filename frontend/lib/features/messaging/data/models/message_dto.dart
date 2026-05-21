// lib/features/messaging/data/models/message_dto.dart

/// Data Transfer Object matching the backend MessageSerializer JSON shape.
class MessageDto {
  final int id;
  final String contenu;
  final String dateEnvoi;
  final int conversationId;
  final ExpediteurDto expediteur;
  final bool isMine;
  final bool isRead;

  const MessageDto({
    required this.id,
    required this.contenu,
    required this.dateEnvoi,
    required this.conversationId,
    required this.expediteur,
    required this.isMine,
    required this.isRead,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) {
    return MessageDto(
      id: json['id'] as int,
      contenu: json['contenu'] as String,
      dateEnvoi: json['date_envoi'] as String,
      conversationId: json['conversation_id'] as int,
      expediteur: ExpediteurDto.fromJson(json['expediteur'] as Map<String, dynamic>),
      isMine: json['is_mine'] as bool? ?? false,
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'contenu': contenu,
        'date_envoi': dateEnvoi,
        'conversation_id': conversationId,
        'expediteur': expediteur.toJson(),
        'is_read': isRead,
      };
}

class ExpediteurDto {
  final int id;
  final String nom;
  final String prenom;

  const ExpediteurDto({
    required this.id,
    required this.nom,
    required this.prenom,
  });

  factory ExpediteurDto.fromJson(Map<String, dynamic> json) {
    return ExpediteurDto(
      id: json['id'] as int,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'prenom': prenom,
      };
}

/// Paginated messages response matching StandardPagination.
class PaginatedMessagesDto {
  final int count;
  final String? next;
  final String? previous;
  final List<MessageDto> results;
  final Map<String, int>? readCursors; // Only on first page

  const PaginatedMessagesDto({
    required this.count,
    this.next,
    this.previous,
    required this.results,
    this.readCursors,
  });

  factory PaginatedMessagesDto.fromJson(Map<String, dynamic> json) {
    return PaginatedMessagesDto(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List)
          .map((e) => MessageDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      readCursors: json['read_cursors'] != null
          ? (json['read_cursors'] as Map<String, dynamic>).map(
              (k, v) => MapEntry(k, v as int),
            )
          : null,
    );
  }
}

/// Conversation DTO matching ConversationSerializer.
class ConversationDto {
  final int id;
  final String contactName;
  final String contactRole;
  final String? contactAvatar;
  final bool isOnline;
  final String? lastMessage;
  final String? lastMessageTime;
  final bool isUnread;
  final bool isInvitation;
  final bool isGroup;
  final String? groupName;
  final List<String> memberAvatars;
  final List<String> memberNames;

  const ConversationDto({
    required this.id,
    required this.contactName,
    required this.contactRole,
    this.contactAvatar,
    required this.isOnline,
    this.lastMessage,
    this.lastMessageTime,
    required this.isUnread,
    required this.isInvitation,
    this.isGroup = false,
    this.groupName,
    this.memberAvatars = const [],
    this.memberNames = const [],
  });

  factory ConversationDto.fromJson(Map<String, dynamic> json) {
    return ConversationDto(
      id: json['id'] as int,
      contactName: (json['contact_name'] as String?) ?? '',
      contactRole: (json['contact_role'] as String?) ?? '',
      contactAvatar: json['contact_avatar'] as String?,
      isOnline: json['is_online'] as bool? ?? false,
      lastMessage: json['last_message'] as String?,
      lastMessageTime: json['last_message_time'] as String?,
      isUnread: json['is_unread'] as bool? ?? false,
      isInvitation: json['is_invitation'] as bool? ?? false,
      isGroup: json['is_group'] as bool? ?? false,
      groupName: json['group_name'] as String?,
      memberAvatars: (json['member_avatars'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      memberNames: (json['member_names'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }
}

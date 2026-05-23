// lib/features/messaging/data/models/message_dto.dart

/// Data Transfer Object matching the backend MessageSerializer JSON shape.
/// Backend returns: {id: str, sender_id: str, content: str, timestamp: ISO8601,
///                   is_read: bool, is_mine: bool, type: str}
class MessageDto {
  final String id;
  final String senderId;
  final String content;
  final String timestamp;
  final bool isMine;
  final bool isRead;
  final String type; // 'text', 'image', or 'file'

  const MessageDto({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.isMine,
    required this.isRead,
    this.type = 'text',
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) {
    return MessageDto(
      id: json['id'].toString(),
      senderId: json['sender_id'].toString(),
      content: json['content'] as String? ?? '',
      timestamp: json['timestamp'] as String,
      isMine: json['is_mine'] as bool? ?? false,
      isRead: json['is_read'] as bool? ?? false,
      type: json['type'] as String? ?? 'text',
    );
  }
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

/// Conversation DTO matching ConversationSummarySerializer / ConversationSerializer.
class ConversationDto {
  final int id;
  final String contactName;
  final String contactRole;
  final String? contactAvatar;
  final bool isOnline;
  final String? lastMessage;
  final String? lastMessageTime;
  final bool isUnread;
  final int unreadCount;
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
    this.unreadCount = 0,
    required this.isInvitation,
    this.isGroup = false,
    this.groupName,
    this.memberAvatars = const [],
    this.memberNames = const [],
  });

  factory ConversationDto.fromJson(Map<String, dynamic> json) {
    return ConversationDto(
      // Backend returns id as string from SerializerMethodField
      id: int.parse(json['id'].toString()),
      contactName: (json['contact_name'] as String?) ?? '',
      contactRole: (json['contact_role'] as String?) ?? '',
      contactAvatar: json['contact_avatar'] as String?,
      isOnline: json['is_online'] as bool? ?? false,
      lastMessage: json['last_message'] as String?,
      lastMessageTime: json['last_message_time'] as String?,
      isUnread: json['is_unread'] as bool? ?? false,
      unreadCount: json['unread_count'] as int? ?? 0,
      isInvitation: json['is_invitation'] as bool? ?? false,
      isGroup: json['is_group'] as bool? ?? false,
      groupName: json['group_name'] as String?,
      memberAvatars: (json['member_avatars'] as List<dynamic>?)
              ?.map((e) => e?.toString() ?? '')
              .toList() ??
          const [],
      memberNames: (json['member_names'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }
}

import 'package:dio/dio.dart';
import 'package:job_app/core/api/api_client.dart';
import 'package:job_app/core/api/api_endpoints.dart';
import 'package:job_app/features/messaging/data/models/chat_model.dart';
import 'package:job_app/features/messaging/data/repositories/messaging_repository.dart';
import 'package:job_app/features/messaging/domain/message_entity.dart';

/// Implémentation API réelle du repository.
/// Appelle le backend Django REST via Dio.
class MessagingRepositoryMock implements MessagingRepository {
  final Dio _dio = ApiClient.instance;

  @override
  Future<List<ConversationEntity>> getConversations() async {
    final response = await _dio.get(ApiEndpoints.conversations);
    final List<dynamic> data = response.data is List
        ? response.data as List<dynamic>
        : (response.data['results'] as List<dynamic>?) ?? [];
    return data
        .map((json) => _conversationFromJson(json as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<List<ConversationEntity>> getInvitations() async {
    final response = await _dio.get(ApiEndpoints.conversationsInvitations);
    final List<dynamic> data = response.data is List
        ? response.data as List<dynamic>
        : (response.data['results'] as List<dynamic>?) ?? [];
    return data
        .map((json) => _conversationFromJson(json as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<ConversationEntity> getConversationById(String conversationId) async {
    // Mock implementation - returns empty conversation
    final conversations = await getConversations();
    return conversations.firstWhere(
      (c) => c.id == conversationId,
      orElse: () => ConversationEntity(
        id: conversationId,
        contactName: '',
        contactRole: '',
        contactAvatar: null,
        isOnline: false,
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        isUnread: false,
        isInvitation: false,
        messages: const [],
      ),
    );
  }

  @override
  Future<void> sendMessage(String conversationId, String content) async {
    final id = int.tryParse(conversationId) ?? 0;
    await _dio.post(
      ApiEndpoints.sendMessage(id),
      data: {'content': content, 'type': 'text'},
    );
  }

  @override
  Future<void> sendImageMessage(String conversationId, String imagePath) async {
    final id = int.tryParse(conversationId) ?? 0;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imagePath),
      'type': 'image',
    });
    await _dio.post(ApiEndpoints.sendImageMessage(id), data: formData);
  }

  @override
  Future<void> sendFileMessage(String conversationId, String filePath) async {
    final id = int.tryParse(conversationId) ?? 0;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'type': 'file',
    });
    await _dio.post(ApiEndpoints.sendFileMessage(id), data: formData);
  }

  @override
  Future<void> acceptInvitation(String conversationId) async {
    final id = int.tryParse(conversationId) ?? 0;
    await _dio.put(ApiEndpoints.acceptConversation(id));
  }

  @override
  Future<void> declineInvitation(String conversationId) async {
    final id = int.tryParse(conversationId) ?? 0;
    await _dio.delete(ApiEndpoints.declineConversation(id));
  }

  @override
  Future<void> deleteConversations(List<String> ids) async {
    await _dio.delete(
      ApiEndpoints.deleteConversations,
      data: {'ids': ids},
    );
  }

  @override
  Future<Set<String>> getBlockedIds() async {
    try {
      final response = await _dio.get(ApiEndpoints.userBlocked);
      final List<dynamic> data = response.data is List
          ? response.data as List<dynamic>
          : (response.data['results'] as List<dynamic>?) ?? [];
      return data.map((item) => item['id']?.toString() ?? '').toSet();
    } catch (e) {
      // Si l'endpoint échoue, retourner un set vide pour ne pas bloquer le chargement
      return <String>{};
    }
  }

  @override
  Future<Set<String>> getRestrictedIds() async {
    try {
      final response = await _dio.get(ApiEndpoints.userRestricted);
      // Backend retourne: { "restricted_ids": ["1", "2", "3"] }
      final data = response.data as Map<String, dynamic>;
      final List<dynamic> ids = data['restricted_ids'] as List<dynamic>? ?? [];
      return ids.map((item) => item.toString()).toSet();
    } catch (e) {
      // Si l'endpoint échoue, retourner un set vide pour ne pas bloquer le chargement
      return <String>{};
    }
  }

  @override
  Future<void> blockContact(String conversationId) async {
    await _dio.post(
      ApiEndpoints.userBlocked,
      data: {'contact_id': conversationId},
    );
  }

  @override
  Future<void> unblockContact(String conversationId) async {
    await _dio.delete(ApiEndpoints.unblockUser(conversationId));
  }

  @override
  Future<void> restrictContact(String conversationId) async {
    await _dio.post(
      ApiEndpoints.userRestricted,
      data: {'contact_id': conversationId},
    );
  }

  @override
  Future<void> unrestrictContact(String conversationId) async {
    await _dio.delete(ApiEndpoints.unrestrictUser(conversationId));
  }

  @override
  Future<ConversationEntity> getOrCreateConversation({
    required String contactName,
    required String contactRole,
    String? contactAvatar,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.conversations,
      data: {
        'contact_name': contactName,
        'contact_role': contactRole,
        if (contactAvatar != null) 'contact_avatar': contactAvatar,
      },
    );
    return _conversationFromJson(response.data as Map<String, dynamic>).toEntity();
  }

  @override
  Future<void> createGroup(
    String groupName,
    List<String> memberNames,
    List<String?> memberAvatars,
  ) async {
    await _dio.post(
      ApiEndpoints.createGroup,
      data: {
        'group_name': groupName,
        'member_names': memberNames,
        'member_avatars': memberAvatars.whereType<String>().toList(),
      },
    );
  }

  /// Helper pour convertir JSON en ConversationModel
  ConversationModel _conversationFromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id']?.toString() ?? '',
      contactName: json['contact_name'] as String? ?? '',
      contactRole: json['contact_role'] as String? ?? '',
      contactAvatar: json['contact_avatar'] as String?,
      isOnline: json['is_online'] as bool? ?? false,
      lastMessage: json['last_message'] as String? ?? '',
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'] as String)
          : DateTime.now(),
      isUnread: json['is_unread'] as bool? ?? false,
      isInvitation: json['is_invitation'] as bool? ?? false,
      isGroup: json['is_group'] as bool? ?? false,
      groupName: json['group_name'] as String?,
      memberAvatars: (json['member_avatars'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      memberNames: (json['member_names'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => _messageFromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Helper pour convertir JSON en MessageModel
  MessageModel _messageFromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      content: json['content'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      isRead: json['is_read'] as bool? ?? false,
      isMine: json['is_mine'] as bool? ?? false,
      type: _parseMessageType(json['type'] as String?),
    );
  }

  /// Helper pour parser le type de message
  MessageType _parseMessageType(String? type) {
    switch (type) {
      case 'image':
        return MessageType.image;
      case 'file':
        return MessageType.file;
      default:
        return MessageType.text;
    }
  }
}


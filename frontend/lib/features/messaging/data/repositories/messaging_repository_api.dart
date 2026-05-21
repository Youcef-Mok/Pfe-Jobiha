// lib/features/messaging/data/repositories/messaging_repository_api.dart

import 'package:dio/dio.dart';
import '../../domain/message_entity.dart';
import '../datasources/messaging_remote_datasource.dart';
import '../models/message_dto.dart';
import '../models/chat_model.dart';
import 'messaging_repository.dart';

/// API implementation of the messaging repository.
/// Wraps remote data source with error handling and entity conversion.
class MessagingRepositoryApi implements MessagingRepository {
  final MessagingRemoteDataSource _dataSource;

  MessagingRepositoryApi(this._dataSource) {
    print('[MessagingRepositoryApi] MessagingRepositoryApi initialisé');
  }

  /// Fetch conversation list (inbox).
  @override
  Future<List<ConversationEntity>> getConversations() async {
    print('[MessagingRepositoryApi] getConversations appelé');
    try {
      final response = await _dataSource.getConversations();
      print("réponse brute: ${response.data}");
      final list = response.data as List;
      final result = list
          .map((json) => _conversationDtoToEntity(
                ConversationDto.fromJson(json as Map<String, dynamic>),
              ))
          .toList();
      print("conversations parsées: ${result.length}");
      return result;
    } on DioException catch (e) {
      print('[MessagingRepositoryApi] DioException dans getConversations: ${e.message}');
      print('[MessagingRepositoryApi] Response: ${e.response?.data}');
      throw Exception(_friendlyError(e));
    } catch (e, stackTrace) {
      print('[MessagingRepositoryApi] ERREUR dans getConversations: $e');
      print('[MessagingRepositoryApi] StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Fetch a single conversation with its messages.
  Future<ConversationEntity> getConversationById(String conversationId) async {
    print('[MessagingRepositoryApi] getConversationById appelé avec id: $conversationId');
    try {
      final convId = int.parse(conversationId);
      final result = await getMessages(convId, 1);
      
      // Get the conversation from the list to have the metadata
      final conversations = await getConversations();
      final conv = conversations.firstWhere(
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
      
      // Messages are already sorted in ascending order by getMessages
      print('[MessagingRepositoryApi] getConversationById returning ${result.messages.length} messages');
      
      // Return the conversation with messages
      return ConversationEntity(
        id: conv.id,
        contactName: conv.contactName,
        contactRole: conv.contactRole,
        contactAvatar: conv.contactAvatar,
        isOnline: conv.isOnline,
        lastMessage: conv.lastMessage,
        lastMessageTime: conv.lastMessageTime,
        isUnread: conv.isUnread,
        isInvitation: conv.isInvitation,
        messages: result.messages,
      );
    } on DioException catch (e) {
      print('[MessagingRepositoryApi] getConversationById error: ${_friendlyError(e)}');
      throw Exception(_friendlyError(e));
    }
  }

  /// Fetch paginated messages for a conversation.
  /// Returns (messages, hasMore, readCursors).
  Future<({List<MessageEntity> messages, bool hasMore, Map<int, int>? readCursors})>
      getMessages(int conversationId, int page) async {
    print('[MessagingRepositoryApi] getMessages appelé avec conversationId: $conversationId, page: $page');
    try {
      final response = await _dataSource.getMessages(conversationId, page);
      print('[MessagingRepositoryApi] getMessages response:');
      print(response.data);
      final dto = PaginatedMessagesDto.fromJson(response.data as Map<String, dynamic>);

      // Backend returns messages in descending order (newest first)
      // We need to reverse them to get ascending order (oldest first) for display
      final messages = dto.results.map(_messageDtoToEntity).toList();
      final sortedMessages = _sortMessagesAscending(messages);
      
      final hasMore = dto.next != null;
      final readCursors = dto.readCursors?.map((k, v) => MapEntry(int.parse(k), v));

      print('[MessagingRepositoryApi] Returning ${sortedMessages.length} messages in ascending order');
      return (messages: sortedMessages, hasMore: hasMore, readCursors: readCursors);
    } on DioException catch (e) {
      print('[MessagingRepositoryApi] getMessages error: ${_friendlyError(e)}');
      throw Exception(_friendlyError(e));
    }
  }

  /// Send a message via REST API.
  Future<MessageEntity> _sendMessageInternal(int conversationId, String contenu) async {
    try {
      final response = await _dataSource.sendMessage(conversationId, contenu);
      final dto = MessageDto.fromJson(response.data as Map<String, dynamic>);
      return _messageDtoToEntity(dto);
    } on DioException catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  /// Mark conversation as read.
  Future<void> markConversationRead(int conversationId) async {
    try {
      await _dataSource.markConversationRead(conversationId);
    } on DioException catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  /// Get or create a DM conversation.
  Future<ConversationEntity> _getOrCreateConversationInternal(int contactId) async {
    try {
      final response = await _dataSource.getOrCreateConversation(contactId);
      final dto = ConversationDto.fromJson(response.data as Map<String, dynamic>);
      return _conversationDtoToEntity(dto);
    } on DioException catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  /// Create a group conversation.
  Future<ConversationEntity> _createGroupInternal(String groupName, List<int> memberIds) async {
    try {
      final response = await _dataSource.createGroup(groupName, memberIds);
      final dto = ConversationDto.fromJson(response.data as Map<String, dynamic>);
      return _conversationDtoToEntity(dto);
    } on DioException catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // ── Interface implementation ───────────────────────────────────────────────

  @override
  Future<List<ConversationEntity>> getInvitations() async {
    print('[MessagingRepositoryApi] getInvitations appelé');
    try {
      final response = await _dataSource.getInvitations();
      print("réponse brute invitations: ${response.data}");
      final list = response.data as List;
      final result = list
          .map((json) => _conversationDtoToEntity(
                ConversationDto.fromJson(json as Map<String, dynamic>),
              ))
          .toList();
      print("invitations parsées: ${result.length}");
      return result;
    } on DioException catch (e) {
      print('[MessagingRepositoryApi] DioException dans getInvitations: ${e.message}');
      print('[MessagingRepositoryApi] Response: ${e.response?.data}');
      throw Exception(_friendlyError(e));
    } catch (e, stackTrace) {
      print('[MessagingRepositoryApi] ERREUR dans getInvitations: $e');
      print('[MessagingRepositoryApi] StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> sendMessage(String conversationId, String content) async {
    print('[MessagingRepositoryApi] sendMessage appelé: conversationId=$conversationId, content=$content');
    try {
      final convId = int.parse(conversationId);
      final message = await _sendMessageInternal(convId, content);
      print('[MessagingRepositoryApi] sendMessage réussi: message id=${message.id}');
    } catch (e, stackTrace) {
      print('[MessagingRepositoryApi] ERREUR dans sendMessage: $e');
      print('[MessagingRepositoryApi] StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> sendImageMessage(String conversationId, String imagePath) async {
    print('[MessagingRepositoryApi] sendImageMessage appelé: conversationId=$conversationId');
    try {
      final convId = int.parse(conversationId);
      await _dataSource.sendImageMessage(convId, imagePath);
      print('[MessagingRepositoryApi] sendImageMessage réussi');
    } on DioException catch (e) {
      print('[MessagingRepositoryApi] sendImageMessage error: ${_friendlyError(e)}');
      throw Exception(_friendlyError(e));
    }
  }

  @override
  Future<void> sendFileMessage(String conversationId, String filePath) async {
    print('[MessagingRepositoryApi] sendFileMessage appelé: conversationId=$conversationId');
    try {
      final convId = int.parse(conversationId);
      await _dataSource.sendFileMessage(convId, filePath);
      print('[MessagingRepositoryApi] sendFileMessage réussi');
    } on DioException catch (e) {
      print('[MessagingRepositoryApi] sendFileMessage error: ${_friendlyError(e)}');
      throw Exception(_friendlyError(e));
    }
  }

  @override
  Future<void> acceptInvitation(String conversationId) async {
    print('[MessagingRepositoryApi] acceptInvitation appelé: conversationId=$conversationId');
    try {
      final convId = int.parse(conversationId);
      await _dataSource.acceptInvitation(convId);
      print('[MessagingRepositoryApi] acceptInvitation réussi');
    } on DioException catch (e) {
      print('[MessagingRepositoryApi] acceptInvitation error: ${_friendlyError(e)}');
      throw Exception(_friendlyError(e));
    }
  }

  @override
  Future<void> declineInvitation(String conversationId) async {
    print('[MessagingRepositoryApi] declineInvitation appelé: conversationId=$conversationId');
    try {
      final convId = int.parse(conversationId);
      await _dataSource.declineInvitation(convId);
      print('[MessagingRepositoryApi] declineInvitation réussi');
    } on DioException catch (e) {
      print('[MessagingRepositoryApi] declineInvitation error: ${_friendlyError(e)}');
      throw Exception(_friendlyError(e));
    }
  }

  @override
  Future<void> deleteConversations(List<String> ids) async {
    print('[MessagingRepositoryApi] deleteConversations appelé: ids=$ids');
    try {
      await _dataSource.deleteConversations(ids);
      print('[MessagingRepositoryApi] deleteConversations réussi');
    } on DioException catch (e) {
      print('[MessagingRepositoryApi] deleteConversations error: ${_friendlyError(e)}');
      throw Exception(_friendlyError(e));
    }
  }

  @override
  Future<ConversationEntity> createGroup(
    String groupName,
    List<String> memberNames,
    List<String?> memberAvatars,
  ) async {
    // Convert member names to IDs (this is a simplified implementation)
    // In a real implementation, you'd need to resolve names to IDs first
    final memberIds = <int>[];
    return await _createGroupInternal(groupName, memberIds);
  }

  @override
  Future<Set<String>> getBlockedIds() async {
    print('[MessagingRepositoryApi] getBlockedIds appelé');
    try {
      final response = await _dataSource.getBlockedIds();
      final List<dynamic> data = response.data is List
          ? response.data as List<dynamic>
          : (response.data['results'] as List<dynamic>?) ?? [];
      return data.map((item) => item['id']?.toString() ?? '').toSet();
    } catch (e) {
      print('[MessagingRepositoryApi] getBlockedIds error: $e');
      return <String>{};
    }
  }

  @override
  Future<Set<String>> getRestrictedIds() async {
    print('[MessagingRepositoryApi] getRestrictedIds appelé');
    try {
      final response = await _dataSource.getRestrictedIds();
      final data = response.data as Map<String, dynamic>;
      final List<dynamic> ids = data['restricted_ids'] as List<dynamic>? ?? [];
      return ids.map((item) => item.toString()).toSet();
    } catch (e) {
      print('[MessagingRepositoryApi] getRestrictedIds error: $e');
      return <String>{};
    }
  }

  @override
  Future<void> blockContact(String conversationId) async {
    print('[MessagingRepositoryApi] blockContact appelé: conversationId=$conversationId');
    try {
      final convId = int.parse(conversationId);
      await _dataSource.blockContact(convId);
      print('[MessagingRepositoryApi] blockContact réussi');
    } on DioException catch (e) {
      print('[MessagingRepositoryApi] blockContact error: ${_friendlyError(e)}');
      throw Exception(_friendlyError(e));
    }
  }

  @override
  Future<void> unblockContact(String conversationId) async {
    print('[MessagingRepositoryApi] unblockContact appelé: conversationId=$conversationId');
    try {
      await _dataSource.unblockContact(conversationId);
      print('[MessagingRepositoryApi] unblockContact réussi');
    } on DioException catch (e) {
      print('[MessagingRepositoryApi] unblockContact error: ${_friendlyError(e)}');
      throw Exception(_friendlyError(e));
    }
  }

  @override
  Future<void> restrictContact(String conversationId) async {
    print('[MessagingRepositoryApi] restrictContact appelé: conversationId=$conversationId');
    try {
      final convId = int.parse(conversationId);
      await _dataSource.restrictContact(convId);
      print('[MessagingRepositoryApi] restrictContact réussi');
    } on DioException catch (e) {
      print('[MessagingRepositoryApi] restrictContact error: ${_friendlyError(e)}');
      throw Exception(_friendlyError(e));
    }
  }

  @override
  Future<void> unrestrictContact(String conversationId) async {
    print('[MessagingRepositoryApi] unrestrictContact appelé: conversationId=$conversationId');
    try {
      await _dataSource.unrestrictContact(conversationId);
      print('[MessagingRepositoryApi] unrestrictContact réussi');
    } on DioException catch (e) {
      print('[MessagingRepositoryApi] unrestrictContact error: ${_friendlyError(e)}');
      throw Exception(_friendlyError(e));
    }
  }

  @override
  Future<ConversationEntity> getOrCreateConversation({
    required String contactName,
    required String contactRole,
    String? contactAvatar,
  }) async {
    // This is a simplified implementation
    // In a real implementation, you'd need to resolve the contact name to an ID first
    throw UnimplementedError('getOrCreateConversation with named parameters not yet implemented');
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  MessageEntity _messageDtoToEntity(MessageDto dto) {
    return MessageEntity(
      id: dto.id.toString(),
      senderId: dto.expediteur.id.toString(),
      content: dto.contenu,
      timestamp: DateTime.parse(dto.dateEnvoi),
      isRead: dto.isRead, // Use real backend value
      isMine: dto.isMine,
      type: MessageType.text,
    );
  }

  ConversationEntity _conversationDtoToEntity(ConversationDto dto) {
    return ConversationEntity(
      id: dto.id.toString(),
      contactName: dto.contactName,
      contactRole: dto.contactRole ?? '',
      contactAvatar: dto.contactAvatar,
      isOnline: dto.isOnline,
      lastMessage: dto.lastMessage ?? '',
      lastMessageTime: dto.lastMessageTime != null
          ? DateTime.parse(dto.lastMessageTime!)
          : DateTime.now(),
      isUnread: dto.isUnread,
      isInvitation: dto.isInvitation,
      messages: const [],
      isGroup: dto.isGroup,
      groupName: dto.groupName,
      memberAvatars: dto.memberAvatars,
      memberNames: dto.memberNames,
    );
  }

  /// Sort messages in ascending order (oldest first, newest last) for display.
  List<MessageEntity> _sortMessagesAscending(List<MessageEntity> messages) {
    final sorted = List<MessageEntity>.from(messages);
    sorted.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return sorted;
  }

  String _friendlyError(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    if (status == 403) return 'Accès refusé.';
    if (status == 404) return 'Conversation introuvable.';
    if (status == 400) {
      if (data is Map && data.containsKey('detail')) {
        return data['detail'] as String;
      }
      return 'Requête invalide.';
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Délai d\'attente dépassé. Vérifiez votre connexion.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Impossible de joindre le serveur. Vérifiez votre connexion.';
    }

    return 'Erreur inattendue (${status ?? "réseau"}).';
  }
}

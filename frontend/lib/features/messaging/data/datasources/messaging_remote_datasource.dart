// lib/features/messaging/data/datasources/messaging_remote_datasource.dart

import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';

/// Remote data source for messaging REST API calls.
/// Returns raw Response objects for the repository to handle.
class MessagingRemoteDataSource {
  final Dio _dio = ApiClient.instance;

  /// GET /conversations - fetch conversation list (inbox).
  Future<Response> getConversations() async {
    return await _dio.get(ApiEndpoints.conversations);
  }

  /// GET /conversations/<id> - fetch paginated messages.
  Future<Response> getMessages(int conversationId, int page) async {
    print('[MessagingRemoteDataSource] getMessages appelé: conversationId=$conversationId, page=$page');
    print('[MessagingRemoteDataSource] URL: ${ApiEndpoints.conversation(conversationId)}');
    return await _dio.get(
      ApiEndpoints.conversation(conversationId),
      queryParameters: {'page': page},
    );
  }

  /// POST /conversations/<id>/messages - send a message.
  Future<Response> sendMessage(int conversationId, String contenu) async {
    return await _dio.post(
      ApiEndpoints.sendMessage(conversationId),
      data: {'contenu': contenu},
    );
  }

  /// POST /conversations/<id>/read-all - mark conversation as read.
  Future<Response> markConversationRead(int conversationId) async {
    return await _dio.post(ApiEndpoints.marquerConvLue(conversationId));
  }

  /// POST /conversations - get or create DM conversation.
  Future<Response> getOrCreateConversation(int contactId) async {
    return await _dio.post(
      ApiEndpoints.conversations,
      data: {'contact_id': contactId},
    );
  }

  /// POST /conversations/group - create group conversation.
  Future<Response> createGroup(String groupName, List<int> memberIds) async {
    return await _dio.post(
      ApiEndpoints.createGroup,
      data: {
        'group_name': groupName,
        'member_ids': memberIds,
      },
    );
  }

  /// GET /conversations/invitations - fetch invitations.
  Future<Response> getInvitations() async {
    return await _dio.get(ApiEndpoints.conversationsInvitations);
  }

  /// POST /conversations/<id>/messages/image - send image message.
  Future<Response> sendImageMessage(int conversationId, String imagePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imagePath),
    });
    return await _dio.post(
      ApiEndpoints.sendImageMessage(conversationId),
      data: formData,
    );
  }

  /// POST /conversations/<id>/messages/file - send file message.
  Future<Response> sendFileMessage(int conversationId, String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    return await _dio.post(
      ApiEndpoints.sendFileMessage(conversationId),
      data: formData,
    );
  }

  /// PUT /conversations/<id>/accept - accept invitation.
  Future<Response> acceptInvitation(int conversationId) async {
    return await _dio.put(ApiEndpoints.acceptConversation(conversationId));
  }

  /// DELETE /conversations/<id>/decline - decline invitation.
  Future<Response> declineInvitation(int conversationId) async {
    return await _dio.delete(ApiEndpoints.declineConversation(conversationId));
  }

  /// DELETE /conversations - bulk delete conversations.
  Future<Response> deleteConversations(List<String> ids) async {
    return await _dio.delete(
      ApiEndpoints.deleteConversations,
      data: {'ids': ids},
    );
  }

  /// POST /conversations/<id>/block - block contact.
  Future<Response> blockContact(int conversationId) async {
    return await _dio.post(ApiEndpoints.conversationBlock(conversationId));
  }

  /// DELETE /conversations/<id>/block - unblock contact.
  Future<Response> unblockContact(String conversationId) async {
    return await _dio.delete(ApiEndpoints.conversationUnblock(int.parse(conversationId)));
  }

  /// POST /users/me/restricted - restrict contact.
  Future<Response> restrictContact(int conversationId) async {
    return await _dio.post(ApiEndpoints.userRestricted, data: {'conversation_id': conversationId});
  }

  /// DELETE /users/me/restricted/<contactId> - unrestrict contact.
  Future<Response> unrestrictContact(String contactId) async {
    return await _dio.delete(ApiEndpoints.unrestrictUser(contactId));
  }

  /// GET /users/me/blocked - get blocked user IDs.
  Future<Response> getBlockedIds() async {
    return await _dio.get(ApiEndpoints.userBlocked);
  }

  /// GET /users/me/restricted - get restricted user IDs.
  Future<Response> getRestrictedIds() async {
    return await _dio.get(ApiEndpoints.userRestricted);
  }
}

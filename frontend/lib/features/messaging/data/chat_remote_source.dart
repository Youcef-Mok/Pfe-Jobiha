// lib/features/messaging/data/chat_remote_source.dart
//
// Raw Dio API calls for all messaging endpoints.
// Updated for unified conversations (DM + group).

import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

class ChatRemoteSource {
  final Dio _dio = ApiClient.instance;

  // ── GET /messages/conversations ──────────────────────────────────────────
  /// Fetch all conversation summaries for the authenticated user.
  Future<Response> fetchConversations() {
    return _dio.get(ApiEndpoints.conversations);
  }

  // ── GET /messages/conversations/{convId} ─────────────────────────────────
  /// Fetch paginated messages in a conversation.
  Future<Response> fetchMessages(int convId, {int? page}) {
    return _dio.get(
      ApiEndpoints.conversation(convId),
      queryParameters: {if (page != null) 'page': page},
    );
  }

  // ── POST /messages ──────────────────────────────────────────────────────
  /// Send a new message.
  Future<Response> sendMessage({
    required int conversationId,
    required String contenu,
  }) {
    return _dio.post(
      ApiEndpoints.sendMessage,
      data: {
        'conversation_id': conversationId,
        'contenu': contenu,
      },
    );
  }

  // ── POST /messages/conversations/{convId}/lire-tout ─────────────────────
  /// Mark all unread messages in a conversation as read.
  Future<Response> markConversationRead(int convId) {
    return _dio.post(ApiEndpoints.marquerConvLue(convId));
  }

  // ── POST /messages/dm/{userId} ──────────────────────────────────────────
  /// Get or create a direct conversation with a user.
  Future<Response> getOrCreateDm(int userId) {
    return _dio.post(ApiEndpoints.getOrCreateDm(userId));
  }

  // ── POST /messages/groups ───────────────────────────────────────────────
  /// Create a new group conversation.
  Future<Response> createGroup({
    required String nom,
    required List<int> memberIds,
  }) {
    return _dio.post(
      ApiEndpoints.createGroup,
      data: {
        'nom': nom,
        'member_ids': memberIds,
      },
    );
  }

  // ── GET /messages/groups/{id}/members ───────────────────────────────────
  /// Fetch group members.
  Future<Response> fetchGroupMembers(int groupId) {
    return _dio.get(ApiEndpoints.groupMembers(groupId));
  }

  // ── POST /messages/groups/{id}/members/add ─────────────────────────────
  /// Add a member to a group.
  Future<Response> addGroupMember(int groupId, int userId) {
    return _dio.post(
      ApiEndpoints.addGroupMember(groupId),
      data: {'user_id': userId},
    );
  }

  // ── DELETE /messages/groups/{id}/members/{userId} ──────────────────────
  /// Remove a member from a group (or leave).
  Future<Response> removeGroupMember(int groupId, int userId) {
    return _dio.delete(ApiEndpoints.removeGroupMember(groupId, userId));
  }
}
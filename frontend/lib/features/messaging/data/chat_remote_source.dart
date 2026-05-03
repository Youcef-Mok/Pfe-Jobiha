// lib/features/messaging/data/chat_remote_source.dart
//
// Raw Dio API calls for all messaging endpoints.
// No error handling here — the repository layer wraps these.

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

  // ── GET /messages/conversations/{userId} ─────────────────────────────────
  /// Fetch paginated messages between the auth user and [userId].
  Future<Response> fetchMessages(int userId, {int? page}) {
    return _dio.get(
      ApiEndpoints.conversation(userId),
      queryParameters: {if (page != null) 'page': page},
    );
  }

  // ── POST /messages ──────────────────────────────────────────────────────
  /// Send a new message.
  Future<Response> sendMessage({
    required int destinataireId,
    required String contenu,
  }) {
    return _dio.post(
      ApiEndpoints.sendMessage,
      data: {
        'destinataire_id': destinataireId,
        'contenu': contenu,
      },
    );
  }

  // ── POST /messages/{id}/lire ────────────────────────────────────────────
  /// Mark a single message as read.
  Future<Response> markMessageRead(int messageId) {
    return _dio.post(ApiEndpoints.marquerMessageLu(messageId));
  }

  // ── POST /messages/conversations/{userId}/lire-tout ─────────────────────
  /// Mark all unread messages in a conversation as read.
  Future<Response> markConversationRead(int userId) {
    return _dio.post(ApiEndpoints.marquerConvLue(userId));
  }
}
// lib/features/messaging/data/repositories/chat_repository.dart
//
// Concrete repository wrapping ChatRemoteSource with error handling.
// Updated for unified conversations (DM + group).

import 'package:dio/dio.dart';
import '../chat_remote_source.dart';
import '../models/chat_model.dart';

class ChatRepository {
  final ChatRemoteSource _source = ChatRemoteSource();

  // ── Conversations ────────────────────────────────────────────────────────

  /// Fetch all conversation summaries for the authenticated user.
  Future<List<ConversationModel>> fetchConversations() async {
    try {
      final response = await _source.fetchConversations();
      final List data = response.data as List;
      return data
          .map((json) =>
              ConversationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // ── Messages (paginated) ─────────────────────────────────────────────────

  /// Fetch messages in a conversation.
  Future<({List<MessageModel> messages, bool hasMore})> fetchMessages(
    int convId, {
    int? page,
  }) async {
    try {
      final response = await _source.fetchMessages(convId, page: page);
      final data = response.data as Map<String, dynamic>;
      final results = (data['results'] as List)
          .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
          .toList();
      final hasMore = data['next'] != null;
      return (messages: results, hasMore: hasMore);
    } on DioException catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // ── Send message ─────────────────────────────────────────────────────────

  /// Send a message and return the created MessageModel.
  Future<MessageModel> sendMessage({
    required int conversationId,
    required String contenu,
  }) async {
    try {
      final response = await _source.sendMessage(
        conversationId: conversationId,
        contenu: contenu,
      );
      return MessageModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // ── Mark read ────────────────────────────────────────────────────────────

  /// Mark all unread messages in a conversation as read.
  Future<void> markConversationRead(int convId) async {
    try {
      await _source.markConversationRead(convId);
    } on DioException catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // ── DM shortcut ──────────────────────────────────────────────────────────

  /// Get or create a DM conversation with a user. Returns conversation details.
  Future<Map<String, dynamic>> getOrCreateDm(int userId) async {
    try {
      final response = await _source.getOrCreateDm(userId);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // ── Group management ─────────────────────────────────────────────────────

  /// Create a group conversation.
  Future<Map<String, dynamic>> createGroup({
    required String nom,
    required List<int> memberIds,
  }) async {
    try {
      final response = await _source.createGroup(
        nom: nom,
        memberIds: memberIds,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  /// Add a member to a group.
  Future<void> addGroupMember(int groupId, int userId) async {
    try {
      await _source.addGroupMember(groupId, userId);
    } on DioException catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  /// Remove a member (or leave).
  Future<void> removeGroupMember(int groupId, int userId) async {
    try {
      await _source.removeGroupMember(groupId, userId);
    } on DioException catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // ── Error helper ─────────────────────────────────────────────────────────

  String _friendlyError(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    if (status == 403) return 'Accès refusé.';
    if (status == 404) return 'Ressource introuvable.';

    if (data is Map) {
      if (data.containsKey('detail')) return data['detail'] as String;
      final messages = <String>[];
      data.forEach((key, value) {
        if (value is List) messages.add(value.join(' '));
      });
      if (messages.isNotEmpty) return messages.join('\n');
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
// lib/features/messaging/data/repositories/chat_repository.dart
//
// Concrete repository that wraps ChatRemoteSource with error handling.
// Follows the same pattern as AuthRepository — catch DioException,
// throw user-friendly Exception strings.

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

  /// Fetch messages between auth user and [userId].
  /// Returns a record with the parsed messages and whether more pages exist.
  Future<({List<MessageModel> messages, bool hasMore})> fetchMessages(
    int userId, {
    int? page,
  }) async {
    try {
      final response = await _source.fetchMessages(userId, page: page);
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
    required int destinataireId,
    required String contenu,
  }) async {
    try {
      final response = await _source.sendMessage(
        destinataireId: destinataireId,
        contenu: contenu,
      );
      return MessageModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // ── Mark read ────────────────────────────────────────────────────────────

  /// Mark a single message as read.
  Future<void> markMessageRead(int messageId) async {
    try {
      await _source.markMessageRead(messageId);
    } on DioException catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  /// Mark all unread messages in a conversation as read.
  Future<void> markConversationRead(int userId) async {
    try {
      await _source.markConversationRead(userId);
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

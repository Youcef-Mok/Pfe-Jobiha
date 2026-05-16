// lib/features/messaging/data/chat_websocket_service.dart
//
// Manages a single WebSocket connection to the Django Channels ChatConsumer.
// Exposes typed streams for new messages, read receipts, typing, and member updates.
// Updated to use conversationId instead of partnerId.

import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/storage/token_storage.dart';
import 'models/chat_model.dart';

/// Events emitted by the WebSocket service.
class WsNewMessage {
  final MessageModel message;
  const WsNewMessage(this.message);
}

class WsReadReceipt {
  final int readerId;
  final int lastReadId;
  const WsReadReceipt({
    required this.readerId,
    required this.lastReadId,
  });
}

class WsTyping {
  final int userId;
  final bool isTyping;
  const WsTyping({required this.userId, required this.isTyping});
}

class WsMemberUpdate {
  final String action; // 'added' | 'removed'
  final int userId;
  final String userName;
  const WsMemberUpdate({
    required this.action,
    required this.userId,
    required this.userName,
  });
}

class ChatWebSocketService {
  final int conversationId;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _disposed = false;

  // ── Typed broadcast streams ───────────────────────────────────────────────
  final _messageController = StreamController<WsNewMessage>.broadcast();
  final _readReceiptController = StreamController<WsReadReceipt>.broadcast();
  final _typingController = StreamController<WsTyping>.broadcast();
  final _memberUpdateController = StreamController<WsMemberUpdate>.broadcast();

  Stream<WsNewMessage> get onMessage => _messageController.stream;
  Stream<WsReadReceipt> get onReadReceipt => _readReceiptController.stream;
  Stream<WsTyping> get onTyping => _typingController.stream;
  Stream<WsMemberUpdate> get onMemberUpdate => _memberUpdateController.stream;

  ChatWebSocketService({required this.conversationId});

  // ── Connect ───────────────────────────────────────────────────────────────

  Future<void> connect() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null || _disposed) return;

    final uri = Uri.parse(ApiEndpoints.chatWebSocket(conversationId, token));
    _channel = WebSocketChannel.connect(uri);

    _subscription = _channel!.stream.listen(
      _onData,
      onError: (_) => _reconnect(),
      onDone: () => _reconnect(),
    );
  }

  void _onData(dynamic raw) {
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      final type = data['type'] as String?;

      switch (type) {
        case 'new_message':
          final msg = MessageModel.fromJson(
            data['message'] as Map<String, dynamic>,
          );
          _messageController.add(WsNewMessage(msg));
          break;

        case 'read_receipt':
          _readReceiptController.add(WsReadReceipt(
            readerId: data['reader_id'] as int,
            lastReadId: data['last_read_id'] as int,
          ));
          break;

        case 'typing':
          _typingController.add(WsTyping(
            userId: data['user_id'] as int,
            isTyping: data['is_typing'] as bool,
          ));
          break;

        case 'member_update':
          _memberUpdateController.add(WsMemberUpdate(
            action: data['action'] as String,
            userId: data['user_id'] as int,
            userName: data['user_name'] as String? ?? '',
          ));
          break;
      }
    } catch (_) {
      // Ignore malformed messages
    }
  }

  // ── Send actions ──────────────────────────────────────────────────────────

  void sendMessage(String contenu) {
    _send({'type': 'send_message', 'contenu': contenu});
  }

  void sendMarkRead() {
    _send({'type': 'mark_read'});
  }

  void sendTypingStart() {
    _send({'type': 'typing_start'});
  }

  void sendTypingStop() {
    _send({'type': 'typing_stop'});
  }

  void _send(Map<String, dynamic> data) {
    _channel?.sink.add(jsonEncode(data));
  }

  // ── Reconnect ─────────────────────────────────────────────────────────────

  void _reconnect() {
    if (_disposed) return;
    _subscription?.cancel();
    _channel?.sink.close();
    Future.delayed(const Duration(seconds: 3), () {
      if (!_disposed) connect();
    });
  }

  // ── Dispose ───────────────────────────────────────────────────────────────

  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    _channel?.sink.close();
    _messageController.close();
    _readReceiptController.close();
    _typingController.close();
    _memberUpdateController.close();
  }
}
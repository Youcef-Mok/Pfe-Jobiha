// lib/features/messaging/data/services/websocket_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/message_dto.dart';

/// WebSocket service for a single conversation.
/// Manages connection, reconnection, and typed event streams.
class ChatWebSocketService {
  final int conversationId;
  final String wsUrl;

  WebSocketChannel? _channel;
  StreamController<MessageDto>? _newMessageController;
  StreamController<ReadReceiptEvent>? _readReceiptController;
  StreamController<TypingEvent>? _typingController;
  StreamController<MemberUpdateEvent>? _memberUpdateController;

  Timer? _reconnectTimer;
  bool _disposed = false;
  bool _isConnected = false;

  ChatWebSocketService({
    required this.conversationId,
    required this.wsUrl,
  });

  /// Stream of new messages received from the server.
  Stream<MessageDto> get newMessages => _newMessageController!.stream;

  /// Stream of read receipts.
  Stream<ReadReceiptEvent> get readReceipts => _readReceiptController!.stream;

  /// Stream of typing indicators.
  Stream<TypingEvent> get typing => _typingController!.stream;

  /// Stream of member updates (added/removed).
  Stream<MemberUpdateEvent> get memberUpdates => _memberUpdateController!.stream;

  bool get isConnected => _isConnected;

  /// Connect to the WebSocket and start listening.
  void connect() {
    if (_disposed) return;

    _newMessageController = StreamController<MessageDto>.broadcast();
    _readReceiptController = StreamController<ReadReceiptEvent>.broadcast();
    _typingController = StreamController<TypingEvent>.broadcast();
    _memberUpdateController = StreamController<MemberUpdateEvent>.broadcast();

    _connectInternal();
  }

  void _connectInternal() {
    if (_disposed) return;

    try {
      print('[ChatWebSocketService] Connecting to: $wsUrl');
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isConnected = true;
      print('[ChatWebSocketService] WebSocket connected successfully');

      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
        cancelOnError: false,
      );
    } catch (e) {
      print('[ChatWebSocketService] Connection failed: $e');
      _isConnected = false;
      _scheduleReconnect();
    }
  }

  void _handleMessage(dynamic data) {
    if (_disposed) return;

    try {
      final json = jsonDecode(data as String) as Map<String, dynamic>;
      final type = json['type'] as String?;

      switch (type) {
        case 'new_message':
          final msgJson = json['message'] as Map<String, dynamic>;
          final msg = MessageDto.fromJson(msgJson);
          _newMessageController?.add(msg);
          break;

        case 'read_receipt':
          final event = ReadReceiptEvent(
            readerId: json['reader_id'] as int,
            lastReadId: json['last_read_id'] as int,
          );
          _readReceiptController?.add(event);
          break;

        case 'typing':
          final event = TypingEvent(
            userId: json['user_id'] as int,
            isTyping: json['is_typing'] as bool,
          );
          _typingController?.add(event);
          break;

        case 'member_update':
          final event = MemberUpdateEvent(
            action: json['action'] as String,
            userId: json['user_id'] as int,
            userName: json['user_name'] as String? ?? '',
          );
          _memberUpdateController?.add(event);
          break;
      }
    } catch (e) {
      // Ignore malformed messages
    }
  }

  void _handleError(dynamic error) {
    print('[ChatWebSocketService] WebSocket error: $error');
    _isConnected = false;
    if (!_disposed) {
      _scheduleReconnect();
    }
  }

  void _handleDone() {
    print('[ChatWebSocketService] WebSocket connection closed');
    _isConnected = false;
    if (!_disposed) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    print('[ChatWebSocketService] Scheduling reconnect in 3 seconds...');
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (!_disposed) {
        print('[ChatWebSocketService] Attempting to reconnect...');
        _connectInternal();
      }
    });
  }

  /// Send a message via WebSocket.
  void sendMessage(String contenu) {
    if (_isConnected && _channel != null) {
      final payload = jsonEncode({'type': 'send_message', 'contenu': contenu});
      _channel!.sink.add(payload);
    }
  }

  /// Mark conversation as read.
  void sendMarkRead() {
    if (_isConnected && _channel != null) {
      final payload = jsonEncode({'type': 'mark_read'});
      _channel!.sink.add(payload);
    }
  }

  /// Send typing start indicator.
  void sendTypingStart() {
    if (_isConnected && _channel != null) {
      final payload = jsonEncode({'type': 'typing_start'});
      _channel!.sink.add(payload);
    }
  }

  /// Send typing stop indicator.
  void sendTypingStop() {
    if (_isConnected && _channel != null) {
      final payload = jsonEncode({'type': 'typing_stop'});
      _channel!.sink.add(payload);
    }
  }

  /// Dispose the service and close all connections.
  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _newMessageController?.close();
    _readReceiptController?.close();
    _typingController?.close();
    _memberUpdateController?.close();
  }
}

/// Event models for typed streams.
class ReadReceiptEvent {
  final int readerId;
  final int lastReadId;

  const ReadReceiptEvent({
    required this.readerId,
    required this.lastReadId,
  });
}

class TypingEvent {
  final int userId;
  final bool isTyping;

  const TypingEvent({
    required this.userId,
    required this.isTyping,
  });
}

class MemberUpdateEvent {
  final String action; // "added" or "removed"
  final int userId;
  final String userName;

  const MemberUpdateEvent({
    required this.action,
    required this.userId,
    required this.userName,
  });
}

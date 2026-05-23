import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:job_app/core/storage/web_storage_impl.dart'
    if (dart.library.io) 'package:job_app/core/storage/storage_stub.dart';
import 'package:job_app/features/notifications/domain/notification_entity.dart';

const _kKey = 'jobiha_cross_notifs';

/// Stocke et lit des notifs cross-user via localStorage (même navigateur).
class CrossUserNotifService {
  /// Pousse une notif destinée à un rôle cible ('candidat' ou 'recruteur')
  static void push({
    required String title,
    required String targetRole,
    required NotificationType type,
    String? jobTitle,
    String? senderName,
  }) {
    if (!kIsWeb) return;
    final all = _read();
    all.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'targetRole': targetRole,
      'type': type.name,
      'jobTitle': jobTitle,
      'senderName': senderName,
      'dateCreation': DateTime.now().toIso8601String(),
    });
    platformWrite(_kKey, jsonEncode(all));
  }

  /// Consomme et retourne les notifs destinées à ce rôle
  static List<NotificationEntity> pop(String role) {
    if (!kIsWeb) return [];
    final all = _read();
    final mine = all.where((n) => n['targetRole'] == role).toList();
    final rest = all.where((n) => n['targetRole'] != role).toList();
    platformWrite(_kKey, jsonEncode(rest));

    return mine.map((n) {
      final typeStr = n['type'] as String? ?? 'newMessage';
      final type = NotificationType.values.firstWhere(
        (t) => t.name == typeStr,
        orElse: () => NotificationType.newMessage,
      );
      return NotificationEntity(
        id: n['id'] as String,
        title: n['title'] as String,
        type: type,
        dateCreation: DateTime.parse(n['dateCreation'] as String),
        isRead: false,
        jobTitle: n['jobTitle'] as String?,
        senderName: n['senderName'] as String?,
      );
    }).toList();
  }

  static List<Map<String, dynamic>> _read() {
    try {
      final raw = platformRead(_kKey);
      if (raw == null || raw.isEmpty) return [];
      return List<Map<String, dynamic>>.from(jsonDecode(raw));
    } catch (_) {
      return [];
    }
  }
}

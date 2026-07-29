import 'package:job_app/features/notifications/domain/notification_entity.dart';

// TODO(API): Adapter les champs fromJson à la réponse de GET /api/notifications
//            Ajouter la pagination (cursor/offset) quand le backend le supporte.

class NotificationModel {
  final String id;
  final String title;
  final String? message;
  final String type; // maps to NotificationType enum
  final String timestamp; // ISO 8601
  final bool isRead;
  final String? jobTitle;
  final String? senderName;
  final String? avatarUrl;
  final int? count;

  const NotificationModel({
    required this.id,
    required this.title,
    this.message,
    required this.type,
    required this.timestamp,
    required this.isRead,
    this.jobTitle,
    this.senderName,
    this.avatarUrl,
    this.count,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'] as String,
        title: json['title'] as String,
        message: json['message'] as String?,
        type: json['type'] as String? ?? 'system',
        timestamp: json['timestamp'] as String,
        isRead: json['is_read'] as bool? ?? false,
        jobTitle: json['job_title'] as String?,
        senderName: json['sender_name'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        count: json['count'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'type': type,
        'timestamp': timestamp,
        'is_read': isRead,
        'job_title': jobTitle,
        'sender_name': senderName,
        'avatar_url': avatarUrl,
        'count': count,
      };

  NotificationEntity toEntity() => NotificationEntity(
        id: id,
        title: title,
        message: message,
        type: _parseType(type),
        timestamp: DateTime.parse(timestamp),
        isRead: isRead,
        jobTitle: jobTitle,
        senderName: senderName,
        avatarUrl: avatarUrl,
        count: count,
      );

  factory NotificationModel.fromEntity(NotificationEntity e) =>
      NotificationModel(
        id: e.id,
        title: e.title,
        message: e.message,
        type: e.type.name,
        timestamp: e.timestamp.toIso8601String(),
        isRead: e.isRead,
        jobTitle: e.jobTitle,
        senderName: e.senderName,
        avatarUrl: e.avatarUrl,
        count: e.count,
      );

  static NotificationType _parseType(String value) {
    return NotificationType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => NotificationType.system,
    );
  }
}

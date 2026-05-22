import 'package:dio/dio.dart';
import 'package:job_app/core/api/api_client.dart';
import 'package:job_app/core/api/api_endpoints.dart';
import 'package:job_app/features/notifications/data/models/notification_model.dart';
import 'package:job_app/features/notifications/data/repositories/notifications_repository.dart';
import 'package:job_app/features/notifications/domain/notification_entity.dart';

class NotificationsRepositoryHttp implements NotificationsRepository {
  final Dio _dio = ApiClient.instance;

  List<dynamic> _results(dynamic data) {
    if (data is Map && data.containsKey('results')) return data['results'] as List;
    if (data is List) return data;
    return [];
  }

  // Backend returns integer IDs — normalize to String for the entity.
  static String _id(dynamic raw) => raw.toString();

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    final resp = await _dio.get(ApiEndpoints.notifications);
    return _results(resp.data)
        .map((j) {
          final map = j as Map<String, dynamic>;
          return NotificationModel.fromJson({
            ...map,
            'id': _id(map['id']),
            'date_creation': map['date_creation'] ?? DateTime.now().toIso8601String(),
          }).toEntity();
        })
        .toList();
  }

  @override
  Future<void> markAsRead(String id) async {
    await _dio.put(ApiEndpoints.notificationRead(int.parse(id)));
  }

  @override
  Future<void> deleteNotification(String id) async {
    await _dio.delete(ApiEndpoints.notificationDelete(int.parse(id)));
  }
}

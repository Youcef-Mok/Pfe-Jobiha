import 'package:dio/dio.dart';
import 'package:job_app/core/api/api_client.dart';
import 'package:job_app/core/api/api_endpoints.dart';
import '../../domain/notification_entity.dart';
import 'notifications_repository.dart';

/// Real API implementation of [NotificationsRepository].
/// Calls the Django REST backend via Dio.
class NotificationsRepositoryApi implements NotificationsRepository {
  final Dio _dio = ApiClient.instance;

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    final response = await _dio.get(ApiEndpoints.notifications);
    final List<dynamic> data = response.data is List
        ? response.data as List<dynamic>
        : (response.data['results'] as List<dynamic>?) ?? [];
    return data.map((json) => _fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> markAsRead(String id) async {
    final intId = int.tryParse(id) ?? 0;
    await _dio.post(ApiEndpoints.marquerNotifLue(intId));
  }

  @override
  Future<void> deleteNotification(String id) async {
    // The backend may not have a dedicated delete endpoint;
    // use mark-as-read as the closest action available.
    final intId = int.tryParse(id) ?? 0;
    await _dio.post(ApiEndpoints.marquerNotifLue(intId));
  }

  /// Parse a notification JSON object from the backend into a [NotificationEntity].
  NotificationEntity _fromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: json['id'].toString(),
      title: json['titre'] as String? ?? json['title'] as String? ?? '',
      message: json['message'] as String?,
      type: _parseType(json['type'] as String? ?? ''),
      timestamp: DateTime.tryParse(json['date_creation'] as String? ?? '') ?? DateTime.now(),
      isRead: json['est_lue'] as bool? ?? json['is_read'] as bool? ?? false,
      jobTitle: json['job_title'] as String?,
      senderName: json['sender_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      contextImageUrl: json['context_image_url'] as String?,
      count: json['count'] as int?,
    );
  }

  NotificationType _parseType(String type) {
    switch (type) {
      case 'new_applicants':
      case 'nouvelle_candidature':
        return NotificationType.newApplicants;
      case 'new_message':
      case 'nouveau_message':
        return NotificationType.newMessage;
      case 'job_question':
      case 'question_offre':
        return NotificationType.jobQuestion;
      case 'mission_expiring':
      case 'mission_expire':
        return NotificationType.missionExpiring;
      case 'interview_accepted':
      case 'entretien_accepte':
        return NotificationType.interviewAccepted;
      case 'mission_completed':
      case 'mission_terminee':
        return NotificationType.missionCompleted;
      case 'announcement_created':
      case 'annonce_creee':
        return NotificationType.announcementCreated;
      default:
        return NotificationType.system;
    }
  }
}

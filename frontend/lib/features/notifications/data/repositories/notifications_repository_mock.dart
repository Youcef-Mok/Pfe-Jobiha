import 'package:dio/dio.dart';
import 'package:job_app/core/api/api_client.dart';
import 'package:job_app/core/api/api_endpoints.dart';
import '../../domain/notification_entity.dart';
import 'notifications_repository.dart';

/// Implémentation API réelle du repository.
/// Appelle le backend Django REST via Dio.
// ─── Recruiter implementation ─────────────────────────────────────────────────
class NotificationsRepositoryMock implements NotificationsRepository {
  final Dio _dio = ApiClient.instance;

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    final response = await _dio.get(ApiEndpoints.notifications);
    final List<dynamic> data = response.data is List
        ? response.data as List<dynamic>
        : (response.data['results'] as List<dynamic>?) ?? [];
    return data
        .map((json) => _notificationFromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> markAsRead(String id) async {
    final intId = int.tryParse(id) ?? 0;
    await _dio.put(ApiEndpoints.notificationRead(intId));
  }

  @override
  Future<void> deleteNotification(String id) async {
    final intId = int.tryParse(id) ?? 0;
    await _dio.delete(ApiEndpoints.notificationDelete(intId));
  }

  /// Helper pour convertir JSON en NotificationEntity
  NotificationEntity _notificationFromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String?,
      type: _parseNotificationType(json['type'] as String?),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      isRead: json['is_read'] as bool? ?? false,
      jobTitle: json['job_title'] as String?,
      senderName: json['sender_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      contextImageUrl: json['context_image_url'] as String?,
      count: json['count'] as int?,
    );
  }

  /// Helper pour parser le type de notification
  NotificationType _parseNotificationType(String? type) {
    switch (type) {
      case 'new_applicants':
        return NotificationType.newApplicants;
      case 'new_message':
        return NotificationType.newMessage;
      case 'job_question':
        return NotificationType.jobQuestion;
      case 'mission_expiring':
        return NotificationType.missionExpiring;
      case 'interview_accepted':
        return NotificationType.interviewAccepted;
      case 'mission_completed':
        return NotificationType.missionCompleted;
      case 'announcement_created':
        return NotificationType.announcementCreated;
      case 'application_accepted':
        return NotificationType.applicationAccepted;
      case 'application_rejected':
        return NotificationType.applicationRejected;
      case 'application_viewed':
        return NotificationType.applicationViewed;
      case 'new_nearby_offer':
        return NotificationType.newNearbyOffer;
      case 'job_matching_preferences':
        return NotificationType.jobMatchingPreferences;
      case 'saved_job_expiring':
        return NotificationType.savedJobExpiring;
      case 'new_job_in_category':
        return NotificationType.newJobInCategory;
      case 'profile_viewed':
        return NotificationType.profileViewed;
      case 'profile_incomplete':
        return NotificationType.profileIncomplete;
      default:
        return NotificationType.system;
    }
  }
}

// ─── Candidate implementation ─────────────────────────────────────────────────
class CandidateNotificationsRepositoryMock implements NotificationsRepository {
  final Dio _dio = ApiClient.instance;

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    final response = await _dio.get(ApiEndpoints.notifications);
    final List<dynamic> data = response.data is List
        ? response.data as List<dynamic>
        : (response.data['results'] as List<dynamic>?) ?? [];
    return data
        .map((json) => _notificationFromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> markAsRead(String id) async {
    final intId = int.tryParse(id) ?? 0;
    await _dio.put(ApiEndpoints.notificationRead(intId));
  }

  @override
  Future<void> deleteNotification(String id) async {
    final intId = int.tryParse(id) ?? 0;
    await _dio.delete(ApiEndpoints.notificationDelete(intId));
  }

  /// Helper pour convertir JSON en NotificationEntity
  NotificationEntity _notificationFromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String?,
      type: _parseNotificationType(json['type'] as String?),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      isRead: json['is_read'] as bool? ?? false,
      jobTitle: json['job_title'] as String?,
      senderName: json['sender_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      contextImageUrl: json['context_image_url'] as String?,
      count: json['count'] as int?,
    );
  }

  /// Helper pour parser le type de notification
  NotificationType _parseNotificationType(String? type) {
    switch (type) {
      case 'new_applicants':
        return NotificationType.newApplicants;
      case 'new_message':
        return NotificationType.newMessage;
      case 'job_question':
        return NotificationType.jobQuestion;
      case 'mission_expiring':
        return NotificationType.missionExpiring;
      case 'interview_accepted':
        return NotificationType.interviewAccepted;
      case 'mission_completed':
        return NotificationType.missionCompleted;
      case 'announcement_created':
        return NotificationType.announcementCreated;
      case 'application_accepted':
        return NotificationType.applicationAccepted;
      case 'application_rejected':
        return NotificationType.applicationRejected;
      case 'application_viewed':
        return NotificationType.applicationViewed;
      case 'new_nearby_offer':
        return NotificationType.newNearbyOffer;
      case 'job_matching_preferences':
        return NotificationType.jobMatchingPreferences;
      case 'saved_job_expiring':
        return NotificationType.savedJobExpiring;
      case 'new_job_in_category':
        return NotificationType.newJobInCategory;
      case 'profile_viewed':
        return NotificationType.profileViewed;
      case 'profile_incomplete':
        return NotificationType.profileIncomplete;
      default:
        return NotificationType.system;
    }
  }
}

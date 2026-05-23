import '../../domain/notification_entity.dart';
import 'notifications_repository.dart';

// TODO(API): Remplacer par NotificationsRepositoryHttp dans notifications_provider.dart.
// ─── Recruiter mock ───────────────────────────────────────────────────────────
class NotificationsRepositoryMock implements NotificationsRepository {
  final List<NotificationEntity> _notifications = [];

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    // TODO(API): GET /api/v1/notifications
    await Future.delayed(const Duration(milliseconds: 400));
    return _notifications;
  }

  @override
  Future<void> markAsRead(String id) async {
    // TODO(API): PATCH /api/v1/notifications/:id/read
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    // TODO(API): DELETE /api/v1/notifications/:id
    _notifications.removeWhere((n) => n.id == id);
  }
}

// ─── Candidate mock — mêmes TODO(API) que NotificationsRepositoryMock ────────
class CandidateNotificationsRepositoryMock implements NotificationsRepository {
  final List<NotificationEntity> _notifications = [];

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _notifications;
  }

  @override
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
  }
}

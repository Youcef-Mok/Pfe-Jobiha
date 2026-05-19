import '../../domain/notification_entity.dart';
import 'notifications_repository.dart';

class NotificationsRepositoryMock implements NotificationsRepository {
  final List<NotificationEntity> _notifications = [
    NotificationEntity(
      id: '1',
      title: '3 nouveaux candidats\npour le poste de Serveur',
      type: NotificationType.newApplicants,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
      count: 3,
      jobTitle: 'Serveur',
    ),
    NotificationEntity(
      id: '2',
      title: 'Lucas Bernard vous a\nenvoyé un message',
      type: NotificationType.newMessage,
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      isRead: false,
      senderName: 'Lucas Bernard',
      avatarUrl: 'https://i.pravatar.cc/150?u=lucas',
    ),
    NotificationEntity(
      id: '3',
      title: 'Lucas Bernard vous a\nenvoyé un message\nconcernant "serveur en salle"',
      type: NotificationType.newMessage,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: false,
      senderName: 'Lucas Bernard',
      avatarUrl: 'https://i.pravatar.cc/150?u=lucas',
      contextImageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4', // Restaurant image
    ),
    NotificationEntity(
      id: '4',
      title: 'Nouvelle question sur\nvotre annonce',
      type: NotificationType.jobQuestion,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      isRead: false,
      jobTitle: 'serveur en salle',
    ),
    NotificationEntity(
      id: '5',
      title: 'Mission expire bientot',
      type: NotificationType.missionExpiring,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      isRead: false,
      jobTitle: 'Vendeur conseil',
    ),
    NotificationEntity(
      id: '6',
      title: 'Marie Durand a répondu à\nvotre offre',
      message: 'Marie a accepté votre proposition d\'entretien.',
      type: NotificationType.interviewAccepted,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
      isRead: false,
      senderName: 'Marie Durand',
      avatarUrl: 'https://i.pravatar.cc/150?u=marie',
    ),
    NotificationEntity(
      id: '7',
      title: 'Mission "Senior UX Designer"\nTerminee',
      type: NotificationType.missionCompleted,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
      isRead: false,
      jobTitle: 'Senior UX Designer',
    ),
    NotificationEntity(
      id: '8',
      title: 'Annonce "Commis de cuisine"\ncree',
      type: NotificationType.announcementCreated,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 10)),
      isRead: false,
      jobTitle: 'Commis de cuisine',
    ),
  ];

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 500));
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

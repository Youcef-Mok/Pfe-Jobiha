import '../../domain/notification_entity.dart';
import 'notifications_repository.dart';

// TODO(API): Remplacer par NotificationsRepositoryHttp dans notifications_provider.dart.
// ─── Recruiter mock ───────────────────────────────────────────────────────────
class NotificationsRepositoryMock implements NotificationsRepository {
  final List<NotificationEntity> _notifications = [
    NotificationEntity(
      id: '1',
      title: '3 nouveaux candidats\npour le poste de "serveur en salle"',
      type: NotificationType.newApplicants,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
      count: 3,
      jobTitle: 'serveur en salle',
    ),
    NotificationEntity(
      id: '2',
      title: 'Lucas Bernard vous a\nenvoyé un message',
      type: NotificationType.newMessage,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: false,
      senderName: 'Lucas Bernard',
      avatarUrl: 'assets/images/pdp_1.png',
    ),
    NotificationEntity(
      id: '3',
      title: 'Lucas Bernard vous a envoyé un message\nconcernant "serveur en salle"',
      type: NotificationType.newMessage,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: false,
      senderName: 'Lucas Bernard',
      avatarUrl: 'assets/images/pdp_1.png',
      contextImageUrl: 'assets/images/imageannonc(1).jpg',
    ),
    NotificationEntity(
      id: '4',
      title: 'Nouvelle question sur\nvotre annonce "serveur en salle"',
      type: NotificationType.jobQuestion,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      isRead: false,
      jobTitle: 'serveur en salle',
    ),
    NotificationEntity(
      id: '5',
      title: 'Mission "Senior UX Designer"\nTerminee',
      type: NotificationType.missionCompleted,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      isRead: false,
      jobTitle: 'Senior UX Designer',
    ),
    NotificationEntity(
      id: '6',
      title: 'Mission "Senior UX Designer"\nexspire bientot',
      type: NotificationType.missionExpiring,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
      isRead: false,
      jobTitle: 'Senior UX Designer',
    ),
    NotificationEntity(
      id: '7',
      title: 'Annonce "commis de cuisine"\nexspire bientot',
      type: NotificationType.announcementCreated,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
      isRead: false,
      jobTitle: 'commis de cuisine',
    ),
    NotificationEntity(
      id: '8',
      title: 'Marie Durand a validé sa candidature\npour le poste de "serveur en salle"',
      type: NotificationType.interviewAccepted,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 10)),
      isRead: false,
      senderName: 'Marie Durand',
      avatarUrl: 'assets/images/pdp_2.png',
      jobTitle: 'serveur en salle',
    ),
  ];

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
  final List<NotificationEntity> _notifications = [
    // Today — Candidatures
    NotificationEntity(
      id: 'c1',
      title: 'Votre candidature pour\n"Serveur en salle" a été acceptée',
      type: NotificationType.applicationAccepted,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
      jobTitle: 'Serveur en salle',
    ),
    NotificationEntity(
      id: 'c2',
      title: 'Lucas Bernard a consulté\nvotre candidature pour "Barista"',
      type: NotificationType.applicationViewed,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: false,
      senderName: 'Lucas Bernard',
      avatarUrl: 'assets/images/pdp_1.png',
      jobTitle: 'Barista',
    ),
    // Today — Messagerie
    NotificationEntity(
      id: 'c3',
      title: 'Lucas Bernard vous a\nenvoyé un message',
      type: NotificationType.newMessage,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: false,
      senderName: 'Lucas Bernard',
      avatarUrl: 'assets/images/pdp_1.png',
    ),
    // Hier — Candidatures
    NotificationEntity(
      id: 'c4',
      title: 'Votre candidature pour\n"Commis de cuisine" a été refusée',
      type: NotificationType.applicationRejected,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
      isRead: false,
      jobTitle: 'Commis de cuisine',
    ),
    // Hier — Jobs
    NotificationEntity(
      id: 'c5',
      title: 'Nouvelle offre proche\nde chez vous: Barman',
      type: NotificationType.newNearbyOffer,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      isRead: false,
      jobTitle: 'Barman',
    ),
    NotificationEntity(
      id: 'c6',
      title: 'Une offre correspond\nà vos préférences: Serveur',
      type: NotificationType.jobMatchingPreferences,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      isRead: true,
      jobTitle: 'Serveur',
    ),
    NotificationEntity(
      id: 'c7',
      title: "L'offre sauvegardée\n\"Cuisinier\" expire bientôt",
      type: NotificationType.savedJobExpiring,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 7)),
      isRead: false,
      jobTitle: 'Cuisinier',
    ),
    NotificationEntity(
      id: 'c8',
      title: 'Nouvelle offre dans\nla catégorie Restauration',
      type: NotificationType.newJobInCategory,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 9)),
      isRead: true,
      jobTitle: 'Restauration',
    ),
    // Système (shown only in "Toutes" tab, below other sections)
    NotificationEntity(
      id: 'c9',
      title: 'Quelqu\'un a consulté votre profil',
      type: NotificationType.profileViewed,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 11)),
      isRead: false,
    ),
    NotificationEntity(
      id: 'c10',
      title: 'Votre profil est incomplet',
      message: 'Ajoutez une photo et vos disponibilités pour attirer plus de recruteurs.',
      type: NotificationType.profileIncomplete,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: false,
    ),
  ];

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

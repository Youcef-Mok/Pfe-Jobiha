enum NotificationType {
  newApplicants,
  newMessage,
  jobQuestion,
  missionExpiring,
  interviewAccepted,
  missionCompleted,
  announcementCreated,
  system
}

class NotificationEntity {
  final String id;
  final String title;
  final String? message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? jobTitle;
  final String? senderName;
  final String? avatarUrl;
  final String? contextImageUrl; // Added for job icons or office pictures
  final int? count;

  NotificationEntity({
    required this.id,
    required this.title,
    this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.jobTitle,
    this.senderName,
    this.avatarUrl,
    this.contextImageUrl,
    this.count,
  });

  NotificationEntity copyWith({
    bool? isRead,
  }) {
    return NotificationEntity(
      id: id,
      title: title,
      message: message,
      type: type,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      jobTitle: jobTitle,
      senderName: senderName,
      avatarUrl: avatarUrl,
      contextImageUrl: contextImageUrl,
      count: count,
    );
  }
}

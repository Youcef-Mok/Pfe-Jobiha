enum NotificationType {
  newApplicants,
  newMessage,
  jobQuestion,
  missionExpiring,
  interviewAccepted,
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
      count: count,
    );
  }
}

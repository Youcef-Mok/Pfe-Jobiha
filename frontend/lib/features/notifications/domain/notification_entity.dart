import 'package:flutter/material.dart';

enum NotificationCategory {
  jobs,
  candidatures,
  messagerie,
  system,
}

extension NotificationCategoryX on NotificationCategory {
  Color get borderColor {
    switch (this) {
      case NotificationCategory.jobs:
        return const Color(0xFF545665);
      case NotificationCategory.candidatures:
        return const Color(0xFF233455);
      case NotificationCategory.messagerie:
        return const Color(0xFF401E66);
      case NotificationCategory.system:
        return const Color(0xFF545665);
    }
  }
}

enum NotificationType {
  // Recruiter
  newApplicants,
  newMessage,
  jobQuestion,
  missionExpiring,
  interviewAccepted,
  missionCompleted,
  announcementCreated,
  // Candidate
  applicationAccepted,
  applicationRejected,
  applicationViewed,
  newNearbyOffer,
  jobMatchingPreferences,
  savedJobExpiring,
  newJobInCategory,
  // System
  profileViewed,
  profileIncomplete,
  system,
}

extension NotificationTypeX on NotificationType {
  NotificationCategory get category {
    switch (this) {
      case NotificationType.newApplicants:
      case NotificationType.interviewAccepted:
      case NotificationType.applicationAccepted:
      case NotificationType.applicationRejected:
      case NotificationType.applicationViewed:
        return NotificationCategory.candidatures;
      case NotificationType.newMessage:
        return NotificationCategory.messagerie;
      case NotificationType.jobQuestion:
      case NotificationType.missionExpiring:
      case NotificationType.missionCompleted:
      case NotificationType.announcementCreated:
      case NotificationType.newNearbyOffer:
      case NotificationType.jobMatchingPreferences:
      case NotificationType.savedJobExpiring:
      case NotificationType.newJobInCategory:
        return NotificationCategory.jobs;
      case NotificationType.profileViewed:
      case NotificationType.profileIncomplete:
      case NotificationType.system:
        return NotificationCategory.system;
    }
  }
}

enum NotificationFilter {
  all('Toutes'),
  jobs('jobs'),
  messagerie('messagerie'),
  candidatures('candidatures');

  const NotificationFilter(this.label);
  final String label;
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
  final String? contextImageUrl;
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

  NotificationCategory get category => type.category;

  NotificationEntity copyWith({bool? isRead}) {
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

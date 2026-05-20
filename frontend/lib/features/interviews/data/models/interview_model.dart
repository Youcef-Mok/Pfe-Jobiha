import 'package:job_app/features/interviews/domain/interview_entity.dart';

/// Modèle de données pour un entretien (couche data)
class InterviewModel {
  final String id;
  final String candidateId;
  final String candidateName;
  final String? candidateAvatar;
  final String jobId;
  final String jobTitle;
  final String department;
  final String scheduledDate; // ISO 8601 string
  final String status;
  final String? notes;

  const InterviewModel({
    required this.id,
    required this.candidateId,
    required this.candidateName,
    this.candidateAvatar,
    required this.jobId,
    required this.jobTitle,
    this.department = 'IT',
    required this.scheduledDate,
    this.status = 'scheduled',
    this.notes,
  });

  /// Convertit le modèle en entité métier
  InterviewEntity toEntity() {
    return InterviewEntity(
      id: id,
      candidateId: candidateId,
      candidateName: candidateName,
      candidateAvatar: candidateAvatar,
      jobId: jobId,
      jobTitle: jobTitle,
      department: department,
      scheduledDate: DateTime.parse(scheduledDate),
      status: status,
      notes: notes,
    );
  }

  /// Crée un modèle depuis une entité métier
  factory InterviewModel.fromEntity(InterviewEntity entity) {
    return InterviewModel(
      id: entity.id,
      candidateId: entity.candidateId,
      candidateName: entity.candidateName,
      candidateAvatar: entity.candidateAvatar,
      jobId: entity.jobId,
      jobTitle: entity.jobTitle,
      department: entity.department,
      scheduledDate: entity.scheduledDate.toIso8601String(),
      status: entity.status,
      notes: entity.notes,
    );
  }

  /// Crée un modèle depuis JSON
  factory InterviewModel.fromJson(Map<String, dynamic> json) {
    return InterviewModel(
      id: json['id'] as String,
      candidateId: json['candidateId'] as String,
      candidateName: json['candidateName'] as String,
      candidateAvatar: json['candidateAvatar'] as String?,
      jobId: json['jobId'] as String,
      jobTitle: json['jobTitle'] as String,
      department: json['department'] as String? ?? 'IT',
      scheduledDate: json['scheduledDate'] as String,
      status: json['status'] as String? ?? 'scheduled',
      notes: json['notes'] as String?,
    );
  }

  /// Convertit le modèle en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'candidateId': candidateId,
      'candidateName': candidateName,
      'candidateAvatar': candidateAvatar,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'department': department,
      'scheduledDate': scheduledDate,
      'status': status,
      'notes': notes,
    };
  }
}

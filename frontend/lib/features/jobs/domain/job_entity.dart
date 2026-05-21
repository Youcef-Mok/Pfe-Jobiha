import 'package:flutter/material.dart' show TimeOfDay;

/// Entité métier pure — cette entité utilise maintenant TimeOfDay de Flutter.
enum JobStatus { draft, closed, searching }

enum ContractType { cdi, mission, freelance }

class JobEntity {
  final String id;
  final String title;
  final String? description;
  final String companyName;
  final String? recruiterId;
  final String? recruiterName;
  final String? recruiterRole;
  final String? recruiterAvatarAsset;
  final ContractType contractType; // Ajouté
  final String department;
  final DateTime postedAt;
  final JobStatus status;
  final int candidateCount;
  final int viewCount;
  final String? logoAsset;
  final bool isPublished;
  final List<JobCandidateEntity> candidates; // Ajout
  final List<JobCommentEntity> comments; // Ajout

  const JobEntity({
    required this.id,
    required this.title,
    this.description,
    required this.companyName,
    this.recruiterId,
    this.recruiterName,
    this.recruiterRole,
    this.recruiterAvatarAsset,
    required this.contractType, // Ajouté
    this.department = 'IT',
    required this.postedAt,
    required this.status,
    required this.candidateCount,
    required this.viewCount,
    this.logoAsset,
    required this.isPublished,
    this.candidates = const [], // Ajout
    this.comments = const [], // Ajout
  });

  bool get isActive => status == JobStatus.searching;
  bool get isDraft => status == JobStatus.draft;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is JobEntity && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class JobCandidateEntity {
  final String initials;
  final String name;
  final String role;
  final double rating;
  final String? avatarUrl;

  const JobCandidateEntity({
    required this.initials,
    required this.name,
    required this.role,
    required this.rating,
    this.avatarUrl,
  });
}

class JobCommentEntity {
  final String initials;
  final String authorName;
  final String date;
  final String question;
  final String recruitorLabel;
  final String recruitorDate;
  final String reply;

  const JobCommentEntity({
    required this.initials,
    required this.authorName,
    required this.date,
    required this.question,
    required this.recruitorLabel,
    required this.recruitorDate,
    required this.reply,
  });
}

class CreateJobForm {
  final String title;
  final ContractType contractType;
  final String description;
  final int? candidateCount;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final DateTime? startDate;
  final double? salary;
  final String? imageAsset;

  const CreateJobForm({
    this.title = '',
    this.contractType = ContractType.cdi,
    this.description = '',
    this.candidateCount,
    this.startTime,
    this.endTime,
    this.startDate,
    this.salary,
    this.imageAsset,
  });

  bool get isValid => title.trim().isNotEmpty;

  CreateJobForm copyWith({
    String? title,
    ContractType? contractType,
    String? description,
    int? candidateCount,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    DateTime? startDate,
    double? salary,
    String? imageAsset,
  }) =>
      CreateJobForm(
        title: title ?? this.title,
        contractType: contractType ?? this.contractType,
        description: description ?? this.description,
        candidateCount: candidateCount ?? this.candidateCount,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        startDate: startDate ?? this.startDate,
        salary: salary ?? this.salary,
        imageAsset: imageAsset ?? this.imageAsset,
      );
}

class EditJobForm {
  final String id;
  final String title;
  final ContractType contractType;
  final String description;
  final int? candidateCount;
  final double? salary;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final DateTime? startDate;
  final String? imageAsset;
  final bool isPrivate;

  const EditJobForm({
    required this.id,
    this.title = '',
    this.contractType = ContractType.cdi,
    this.description = '',
    this.candidateCount,
    this.salary,
    this.startTime,
    this.endTime,
    this.startDate,
    this.imageAsset,
    this.isPrivate = false,
  });

  bool get isValid => title.trim().isNotEmpty;

  /// Initialise depuis une entité existante
  factory EditJobForm.fromEntity(JobEntity entity) => EditJobForm(
        id: entity.id,
        title: entity.title,
        contractType: entity.contractType, // Maintenant valide
        description: entity.description ?? '',
        candidateCount: entity.candidateCount,
        salary: null,
        imageAsset: entity.logoAsset,
        isPrivate: !entity.isPublished,
      );

  EditJobForm copyWith({
    String? title,
    ContractType? contractType,
    String? description,
    int? candidateCount,
    double? salary,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    DateTime? startDate,
    String? imageAsset,
    bool? isPrivate,
  }) =>
      EditJobForm(
        id: id,
        title: title ?? this.title,
        contractType: contractType ?? this.contractType,
        description: description ?? this.description,
        candidateCount: candidateCount ?? this.candidateCount,
        salary: salary ?? this.salary,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        startDate: startDate ?? this.startDate,
        imageAsset: imageAsset ?? this.imageAsset,
        isPrivate: isPrivate ?? this.isPrivate,
      );
}

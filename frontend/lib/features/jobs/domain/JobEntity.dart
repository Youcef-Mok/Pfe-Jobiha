import 'package:flutter/material.dart' show TimeOfDay;

/// Entité métier pure — cette entité utilise maintenant TimeOfDay de Flutter.
enum JobStatus { active, draft, closed, searching }

class JobEntity {
  final String id;
  final String title;
  final String companyName;
  final DateTime postedAt;
  final JobStatus status;
  final int candidateCount;
  final int viewCount;
  final String? logoAsset;
  final bool isPublished;

  const JobEntity({
    required this.id,
    required this.title,
    required this.companyName,
    required this.postedAt,
    required this.status,
    required this.candidateCount,
    required this.viewCount,
    this.logoAsset,
    required this.isPublished,
  });
// Ajouter à job_entity.dart (en plus du contenu existant)

enum ContractType { cdi, mission, freelance }

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

// Note: TimeOfDay est de package:flutter/material.dart
// À importer dans job_entity.dart :
// import 'package:flutter/material.dart' show TimeOfDay;
  bool get isActive => status == JobStatus.active;
  bool get isDraft => status == JobStatus.draft;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is JobEntity && id == other.id;

  @override
  int get hashCode => id.hashCode;
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
        contractType: ContractType.cdi, // à enrichir quand le backend arrive
        description: '',
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
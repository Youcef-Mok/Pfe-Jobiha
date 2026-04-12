import 'package:flutter/material.dart';

import 'package:job_app/features/jobs/domain/job_entity.dart';

/// Modèle de données (DTO) — représente la forme brute venue de l'API/JSON.
/// Distinct de l'entité métier pour découpler la couche data du domaine.
class JobModel {
  final String id;
  final String title;
  final String companyName;
  final String contractType; // "cdi" | "mission" | "freelance"
  final String postedAt;     // ISO 8601 depuis l'API
  final String status;       // "active" | "draft" | "closed"
  final int candidateCount;
  final int viewCount;
  final String? logoAsset;
  final bool isPublished;

  const JobModel({
    required this.id,
    required this.title,
    required this.companyName,
    required this.contractType,
    required this.postedAt,
    required this.status,
    required this.candidateCount,
    required this.viewCount,
    this.logoAsset,
    required this.isPublished,
  });

  /// Désérialisation depuis JSON (API REST)
  factory JobModel.fromJson(Map<String, dynamic> json) => JobModel(
        id: json['id'] as String,
        title: json['title'] as String,
        companyName: json['company_name'] as String,
        contractType: json['contract_type'] as String? ?? 'cdi',
        postedAt: json['posted_at'] as String,
        status: json['status'] as String,
        candidateCount: json['candidate_count'] as int? ?? 0,
        viewCount: json['view_count'] as int? ?? 0,
        logoAsset: json['logo_asset'] as String?,
        isPublished: json['is_published'] as bool? ?? false,
      );

  /// Sérialisation vers JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'company_name': companyName,
        'contract_type': contractType,
        'posted_at': postedAt,
        'status': status,
        'candidate_count': candidateCount,
        'view_count': viewCount,
        'logo_asset': logoAsset,
        'is_published': isPublished,
      };

  /// Conversion vers l'entité métier
  JobEntity toEntity() => JobEntity(
        id: id,
        title: title,
        companyName: companyName,
        contractType: _parseContract(contractType),
        postedAt: DateTime.parse(postedAt),
        status: _parseStatus(status),
        candidateCount: candidateCount,
        viewCount: viewCount,
        logoAsset: logoAsset,
        isPublished: isPublished,
      );

  /// Conversion depuis l'entité métier (pour sauvegarder)
  factory JobModel.fromEntity(JobEntity entity) => JobModel(
        id: entity.id,
        title: entity.title,
        companyName: entity.companyName,
        contractType: entity.contractType.name,
        postedAt: entity.postedAt.toIso8601String(),
        status: entity.status.name,
        candidateCount: entity.candidateCount,
        viewCount: entity.viewCount,
        logoAsset: entity.logoAsset,
        isPublished: entity.isPublished,
      );

  static JobStatus _parseStatus(String value) => switch (value) {
        'active' => JobStatus.searching,
        'draft' => JobStatus.draft,
        'closed' => JobStatus.closed,
        'searching' => JobStatus.searching,
        _ => JobStatus.draft,
      };

  static ContractType _parseContract(String value) => switch (value) {
        'cdi' => ContractType.cdi,
        'mission' => ContractType.mission,
        'freelance' => ContractType.freelance,
        _ => ContractType.cdi,
      };
}
import 'package:job_app/features/applications/domain/application_entity.dart';
import 'package:job_app/features/jobs/domain/job_entity.dart';

class ApplicationModel {
  final String id;
  final String jobId;
  final String jobTitle;
  final String companyName;
  final String department;
  final String? logoAsset;
  final String status; // 'pending' | 'interview' | 'accepted' | 'rejected'
  final String appliedAt;
  final String location;
  final String contractType;
  final String? scheduleLabel;
  final String? interviewDate;
  final String? candidateName;
  final String? candidateAvatar;
  final String? candidateDomain;
  final double candidateRating;
  final String? motivationLetter;

  const ApplicationModel({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    this.department = 'IT',
    this.logoAsset,
    required this.status,
    required this.appliedAt,
    required this.location,
    required this.contractType,
    this.scheduleLabel,
    this.interviewDate,
    this.candidateName,
    this.candidateAvatar,
    this.candidateDomain,
    this.candidateRating = 0.0,
    this.motivationLetter,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    final rawJob = (json['job'] is Map<String, dynamic>)
        ? json['job'] as Map<String, dynamic>
        : (json['offre'] is Map<String, dynamic>)
            ? json['offre'] as Map<String, dynamic>
            : const <String, dynamic>{};

    String pickString(List<dynamic> values, {String fallback = ''}) {
      for (final v in values) {
        if (v == null) continue;
        final s = v.toString().trim();
        if (s.isNotEmpty) return s;
      }
      return fallback;
    }

    String? pickNullable(List<dynamic> values) {
      final v = pickString(values);
      return v.isEmpty ? null : v;
    }

    return ApplicationModel(
      id: pickString([json['id']]),
      jobId: pickString([json['job_id'], json['offre_id'], rawJob['id']]),
      jobTitle: pickString([json['job_title'], rawJob['title']]),
      companyName: pickString([json['company_name'], rawJob['company_name']]),
      department: pickString([json['department'], rawJob['category']], fallback: 'IT'),
      logoAsset: pickNullable([json['logo_asset'], rawJob['image'], rawJob['logo_asset']]),
      status: pickString([json['status']], fallback: 'pending'),
      appliedAt: pickString(
        [json['applied_at'], json['created_at'], json['date_creation']],
        fallback: DateTime.now().toIso8601String(),
      ),
      location: pickString([json['location'], rawJob['location']]),
      contractType: pickString([json['contract_type'], rawJob['contract_type']], fallback: 'cdi'),
      scheduleLabel: pickNullable([json['schedule_label'], rawJob['schedule_label']]),
      interviewDate: pickNullable([json['interview_date']]),
      candidateName: pickNullable([json['candidate_name']]),
      candidateAvatar: pickNullable([json['candidate_avatar']]),
      candidateDomain: pickNullable([json['candidate_domain']]),
      candidateRating: (json['candidate_rating'] as num?)?.toDouble() ?? 0.0,
      motivationLetter: pickNullable([json['motivation_letter']]),
    );
  }

  ApplicationEntity toEntity() => ApplicationEntity(
        id: id,
        jobId: jobId,
        jobTitle: jobTitle,
        companyName: companyName,
        department: department,
        logoAsset: logoAsset,
        status: _parseStatus(status),
        appliedAt: DateTime.parse(appliedAt),
        location: location,
        contractType: _parseContract(contractType),
        scheduleLabel: scheduleLabel,
        interviewDate: interviewDate,
        candidateName: candidateName,
        candidateAvatar: candidateAvatar,
        candidateDomain: candidateDomain,
        candidateRating: candidateRating,
        motivationLetter: motivationLetter,
      );

  static ApplicationStatus _parseStatus(String v) => switch (v) {
        'accepted' => ApplicationStatus.accepted,
        'interview' => ApplicationStatus.accepted,
        'rejected' => ApplicationStatus.rejected,
        _ => ApplicationStatus.pending,
      };

  static ContractType _parseContract(String v) => switch (v) {
        'mission' => ContractType.mission,
        'freelance' => ContractType.freelance,
        _ => ContractType.cdi,
      };
}

import 'package:job_app/features/applications/domain/application_entity.dart';
import 'package:job_app/features/jobs/domain/job_entity.dart';

class ApplicationModel {
  final String id;
  final String jobId;
  final String jobTitle;
  final String companyName;
  final String? logoAsset;
  final String status; // 'pending' | 'interview' | 'accepted' | 'rejected'
  final String appliedAt;
  final String location;
  final String contractType;
  final String? scheduleLabel;
  final String? interviewDate;

  const ApplicationModel({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    this.logoAsset,
    required this.status,
    required this.appliedAt,
    required this.location,
    required this.contractType,
    this.scheduleLabel,
    this.interviewDate,
  });

  ApplicationEntity toEntity() => ApplicationEntity(
        id: id,
        jobId: jobId,
        jobTitle: jobTitle,
        companyName: companyName,
        logoAsset: logoAsset,
        status: _parseStatus(status),
        appliedAt: DateTime.parse(appliedAt),
        location: location,
        contractType: _parseContract(contractType),
        scheduleLabel: scheduleLabel,
        interviewDate: interviewDate,
      );

  static ApplicationStatus _parseStatus(String v) => switch (v) {
        'accepted' => ApplicationStatus.accepted,
        'rejected' => ApplicationStatus.rejected,
        _ => ApplicationStatus.pending,
      };

  static ContractType _parseContract(String v) => switch (v) {
        'mission' => ContractType.mission,
        'freelance' => ContractType.freelance,
        _ => ContractType.cdi,
      };
}

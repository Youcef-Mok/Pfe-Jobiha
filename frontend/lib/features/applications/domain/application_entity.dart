import 'package:job_app/features/jobs/domain/job_entity.dart';

enum ApplicationStatus { pending, accepted, rejected }

class ApplicationEntity {
  final String id;
  final String jobId;
  final String jobTitle;
  final String companyName;
  final String? logoAsset;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final String location;
  final ContractType contractType;
  final String? scheduleLabel; // e.g. "10h-17h"
  final String? interviewDate; // e.g. "Entretien prévu le 18 Oct."

  const ApplicationEntity({
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

  String get statusLabel => switch (status) {
        ApplicationStatus.pending => 'En attente',
        ApplicationStatus.accepted => 'Acceptée',
        ApplicationStatus.rejected => 'Refusée',
      };
}

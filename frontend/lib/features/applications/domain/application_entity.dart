import 'package:job_app/features/jobs/domain/job_entity.dart';

enum ApplicationStatus { pending, accepted, rejected }

class ApplicationEntity {
  final String id;
  final String jobId;
  final String jobTitle;
  final String companyName;
  final String department;
  final String? logoAsset;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final String location;
  final ContractType contractType;
  final String? scheduleLabel; // e.g. "10h-17h"
  final String? interviewDate; // e.g. "Entretien prévu le 18 Oct."
  // Informations du candidat
  final String? candidateId;
  final String? candidateName;
  final String? candidateAvatar;
  final String? candidateDomain; // e.g. "Développement Web"
  final double candidateRating; // e.g. 4.5
  final String? motivationLetter; // Lettre de motivation complète

  const ApplicationEntity({
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
    this.candidateId,
    this.candidateName,
    this.candidateAvatar,
    this.candidateDomain,
    this.candidateRating = 0.0,
    this.motivationLetter,
  });

  String get statusLabel => switch (status) {
        ApplicationStatus.pending => 'En attente',
        ApplicationStatus.accepted => 'Acceptée',
        ApplicationStatus.rejected => 'Refusée',
      };
  
  /// Formatte la date et l'heure de candidature
  String get formattedDate {
    final months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return '${appliedAt.day} ${months[appliedAt.month - 1]}';
  }

  String get formattedTime {
    final hour = appliedAt.hour.toString().padLeft(2, '0');
    final minute = appliedAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

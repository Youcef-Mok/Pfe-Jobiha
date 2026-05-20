/// Entité métier pour un entretien planifié
class InterviewEntity {
  final String id;
  final String candidateId;
  final String candidateName;
  final String? candidateAvatar;
  final String jobId;
  final String jobTitle;
  final String department;
  final DateTime scheduledDate;
  final String status; // 'scheduled', 'completed', 'cancelled'
  final String? notes;

  const InterviewEntity({
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

  bool get isScheduled => status == 'scheduled';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  /// Formatte la date et l'heure pour l'affichage
  String get formattedDate {
    final months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return '${scheduledDate.day} ${months[scheduledDate.month - 1]}';
  }

  String get formattedTime {
    final hour = scheduledDate.hour.toString().padLeft(2, '0');
    final minute = scheduledDate.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is InterviewEntity && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

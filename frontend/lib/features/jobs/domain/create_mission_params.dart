/// Paramètres pour créer une mission (statut initial : non confirmée).
class CreateMissionParams {
  final String jobId;
  final String jobTitle;
  final String companyName;
  final String department;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String candidateName;
  final String? candidateAvatar;
  final String? imageUrl;

  const CreateMissionParams({
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    this.department = 'IT',
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.candidateName,
    this.candidateAvatar,
    this.imageUrl,
  });
}

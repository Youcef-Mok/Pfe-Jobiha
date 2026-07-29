enum ProfileMissionStatus { termine, enCours, annule }

class ProfileMissionEntity {
  final String id;
  final String jobTitle;
  final String companyName;
  final String duration;
  final double rating;
  final ProfileMissionStatus status;

  const ProfileMissionEntity({
    required this.id,
    required this.jobTitle,
    required this.companyName,
    required this.duration,
    required this.rating,
    required this.status,
  });
}

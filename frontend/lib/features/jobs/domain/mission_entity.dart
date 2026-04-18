class MissionEntity {
  final String id;
  final String jobTitle;
  final String companyName;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String status; // 'in_progress', 'completed'
  final String recruiterName;
  final String candidateName;
  final double candidateRating;
  final double recruiterRating;
  final String candidateFeedback;
  final String recruiterFeedback;
  final String? summary;
  final String? imageUrl;
  final List<MissionMemberEntity> team;

  const MissionEntity({
    required this.id,
    required this.jobTitle,
    required this.companyName,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.status,
    required this.recruiterName,
    required this.candidateName,
    this.candidateRating = 0.0,
    this.recruiterRating = 0.0,
    this.candidateFeedback = '',
    this.recruiterFeedback = '',
    this.summary,
    this.imageUrl,
    this.team = const [],
  });

  bool get isCompleted => status == 'completed';
}

class MissionMemberEntity {
  final String name;
  final String role;
  final double rating;
  final String? avatarUrl;

  const MissionMemberEntity({
    required this.name,
    required this.role,
    required this.rating,
    this.avatarUrl,
  });
}

class MissionReview {
  final String missionId;
  final int rating;
  final String comment;

  const MissionReview({
    required this.missionId,
    required this.rating,
    required this.comment,
  });

  bool get isValid => rating > 0 && comment.length >= 10;
}

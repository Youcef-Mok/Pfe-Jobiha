

enum CandidateStatus {
  nouveau,
  examine,
  archive,
}

class CandidateEntity {
  final String id;
  final String name;
  final String title;
  final String photoUrl;
  final double rating;
  final int reviewsCount;
  final bool isTopRated;
  final String coverLetter;
  final CandidateStatus status;

  const CandidateEntity({
    required this.id,
    required this.name,
    required this.title,
    required this.photoUrl,
    required this.rating,
    required this.reviewsCount,
    this.isTopRated = false,
    required this.coverLetter,
    this.status = CandidateStatus.nouveau,
  });
}

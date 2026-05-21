import 'package:job_app/features/candidates/domain/candidate_entity.dart';

class CandidateModel extends CandidateEntity {
  const CandidateModel({
    required super.id,
    required super.name,
    required super.title,
    required super.photoUrl,
    required super.rating,
    required super.reviewsCount,
    super.isTopRated,
    required super.coverLetter,
    super.status,
  });

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    return CandidateModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      photoUrl: json['photo_url'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['reviews_count'] as int? ?? 0,
      isTopRated: json['is_top_rated'] as bool? ?? false,
      coverLetter: json['cover_letter'] as String? ?? '',
      status: CandidateStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CandidateStatus.nouveau,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'photo_url': photoUrl,
      'rating': rating,
      'reviews_count': reviewsCount,
      'is_top_rated': isTopRated,
      'cover_letter': coverLetter,
      'status': status.name,
    };
  }
}

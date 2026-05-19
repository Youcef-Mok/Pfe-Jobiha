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
      id: json['id'] as String,
      name: json['name'] as String,
      title: json['title'] as String,
      photoUrl: json['photoUrl'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewsCount: json['reviewsCount'] as int,
      isTopRated: json['isTopRated'] as bool? ?? false,
      coverLetter: json['coverLetter'] as String,
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
      'photoUrl': photoUrl,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'isTopRated': isTopRated,
      'coverLetter': coverLetter,
      'status': status.name,
    };
  }
}

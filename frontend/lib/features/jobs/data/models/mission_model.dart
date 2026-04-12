import 'package:job_app/features/jobs/domain/mission_entity.dart';

class MissionModel {
  final String id;
  final String jobTitle;
  final String companyName;
  final String startDate;
  final String endDate;
  final String location;
  final String recruiterName;
  final String candidateName;
  final double candidateRating;
  final double recruiterRating;
  final String candidateFeedback;
  final String recruiterFeedback;
  final String status;
  final String? summary;
  final List<MissionMemberModel> team;

  const MissionModel({
    required this.id,
    required this.jobTitle,
    required this.companyName,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.recruiterName,
    required this.candidateName,
    required this.candidateRating,
    required this.recruiterRating,
    required this.candidateFeedback,
    required this.recruiterFeedback,
    required this.status,
    required this.team,
    this.summary,
  });

  factory MissionModel.fromJson(Map<String, dynamic> json) => MissionModel(
        id: json['id'] as String,
        jobTitle: json['job_title'] as String,
        companyName: json['company_name'] as String,
        startDate: json['start_date'] as String,
        endDate: json['end_date'] as String,
        location: json['location'] as String,
        recruiterName: json['recruiter_name'] as String,
        candidateName: json['candidate_name'] as String,
        candidateRating: (json['candidate_rating'] as num).toDouble(),
        recruiterRating: (json['recruiter_rating'] as num).toDouble(),
        candidateFeedback: json['candidate_feedback'] as String,
        recruiterFeedback: json['recruiter_feedback'] as String,
        status: json['status'] as String,
        summary: json['summary'] as String?,
        team: (json['team'] as List<dynamic>?)
                ?.map((e) => MissionMemberModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'job_title': jobTitle,
        'company_name': companyName,
        'start_date': startDate,
        'end_date': endDate,
        'location': location,
        'recruiter_name': recruiterName,
        'candidate_name': candidateName,
        'candidate_rating': candidateRating,
        'recruiter_rating': recruiterRating,
        'candidate_feedback': candidateFeedback,
        'recruiter_feedback': recruiterFeedback,
        'status': status,
        'summary': summary,
        'team': team.map((e) => e.toJson()).toList(),
      };

  MissionEntity toEntity() => MissionEntity(
        id: id,
        jobTitle: jobTitle,
        companyName: companyName,
        startDate: DateTime.parse(startDate),
        endDate: DateTime.parse(endDate),
        location: location,
        recruiterName: recruiterName,
        candidateName: candidateName,
        candidateRating: candidateRating,
        recruiterRating: recruiterRating,
        candidateFeedback: candidateFeedback,
        recruiterFeedback: recruiterFeedback,
        status: status,
        summary: summary,
        team: team.map((e) => e.toEntity()).toList(),
      );

  factory MissionModel.fromEntity(MissionEntity entity) => MissionModel(
        id: entity.id,
        jobTitle: entity.jobTitle,
        companyName: entity.companyName,
        startDate: entity.startDate.toIso8601String(),
        endDate: entity.endDate.toIso8601String(),
        location: entity.location,
        recruiterName: entity.recruiterName,
        candidateName: entity.candidateName,
        candidateRating: entity.candidateRating,
        recruiterRating: entity.recruiterRating,
        candidateFeedback: entity.candidateFeedback,
        recruiterFeedback: entity.recruiterFeedback,
        status: entity.status,
        summary: entity.summary,
        team: entity.team.map((e) => MissionMemberModel.fromEntity(e)).toList(),
      );
}

class MissionMemberModel {
  final String name;
  final String role;
  final double rating;

  const MissionMemberModel({
    required this.name,
    required this.role,
    required this.rating,
  });

  factory MissionMemberModel.fromJson(Map<String, dynamic> json) =>
      MissionMemberModel(
        name: json['name'] as String,
        role: json['role'] as String,
        rating: (json['rating'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'role': role,
        'rating': rating,
      };

  MissionMemberEntity toEntity() => MissionMemberEntity(
        name: name,
        role: role,
        rating: rating,
      );

  factory MissionMemberModel.fromEntity(MissionMemberEntity entity) =>
      MissionMemberModel(
        name: entity.name,
        role: entity.role,
        rating: entity.rating,
      );
}

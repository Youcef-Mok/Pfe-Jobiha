import 'package:job_app/features/profile/domain/user_entity.dart';

/// Modèle de données (DTO) pour un utilisateur
class UserModel {
  final String id;
  final String name;
  final String role;
  final String company;
  final String location;
  final String bio;
  final String? avatarUrl;
  final int followersCount;
  final int missionsCount;
  final double rating;
  final String accountType;

  const UserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.company,
    required this.location,
    required this.bio,
    this.avatarUrl,
    required this.followersCount,
    required this.missionsCount,
    required this.rating,
    required this.accountType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        role: json['role'] as String,
        company: json['company'] as String,
        location: json['location'] as String,
        bio: json['bio'] as String,
        avatarUrl: json['avatar_url'] as String?,
        followersCount: json['followers_count'] as int? ?? 0,
        missionsCount: json['missions_count'] as int? ?? 0,
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        accountType: json['account_type'] as String? ?? 'recruiter',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        'company': company,
        'location': location,
        'bio': bio,
        'avatar_url': avatarUrl,
        'followers_count': followersCount,
        'missions_count': missionsCount,
        'rating': rating,
        'account_type': accountType,
      };

  UserEntity toEntity() => UserEntity(
        id: id,
        name: name,
        role: role,
        company: company,
        location: location,
        bio: bio,
        avatarUrl: avatarUrl,
        followersCount: followersCount,
        missionsCount: missionsCount,
        rating: rating,
        accountType: accountType,
      );

  factory UserModel.fromEntity(UserEntity entity) => UserModel(
        id: entity.id,
        name: entity.name,
        role: entity.role,
        company: entity.company,
        location: entity.location,
        bio: entity.bio,
        avatarUrl: entity.avatarUrl,
        followersCount: entity.followersCount,
        missionsCount: entity.missionsCount,
        rating: entity.rating,
        accountType: entity.accountType,
      );
}

/// Modèle pour un avis employé
class EmployeeReviewModel {
  final String id;
  final String authorName;
  final String authorRole;
  final String? authorAvatar;
  final double rating;
  final String comment;
  final String? recruiterReply;
  final String? recruiterName;
  final String? recruiterReplyDate;

  const EmployeeReviewModel({
    required this.id,
    required this.authorName,
    required this.authorRole,
    this.authorAvatar,
    required this.rating,
    required this.comment,
    this.recruiterReply,
    this.recruiterName,
    this.recruiterReplyDate,
  });

  factory EmployeeReviewModel.fromJson(Map<String, dynamic> json) =>
      EmployeeReviewModel(
        id: json['id'] as String,
        authorName: json['author_name'] as String,
        authorRole: json['author_role'] as String,
        authorAvatar: json['author_avatar'] as String?,
        rating: (json['rating'] as num).toDouble(),
        comment: json['comment'] as String,
        recruiterReply: json['recruiter_reply'] as String?,
        recruiterName: json['recruiter_name'] as String?,
        recruiterReplyDate: json['recruiter_reply_date'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'author_name': authorName,
        'author_role': authorRole,
        'author_avatar': authorAvatar,
        'rating': rating,
        'comment': comment,
        'recruiter_reply': recruiterReply,
        'recruiter_name': recruiterName,
        'recruiter_reply_date': recruiterReplyDate,
      };

  EmployeeReviewEntity toEntity() => EmployeeReviewEntity(
        id: id,
        authorName: authorName,
        authorRole: authorRole,
        authorAvatar: authorAvatar,
        rating: rating,
        comment: comment,
        recruiterReply: recruiterReply,
        recruiterName: recruiterName,
        recruiterReplyDate: recruiterReplyDate,
      );
}

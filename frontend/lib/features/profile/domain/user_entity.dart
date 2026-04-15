/// Entite metier pour un utilisateur/recruteur.
class UserEntity {
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
  final String accountType; // 'recruiter' | 'candidate'

  const UserEntity({
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

  /// Initiale du nom (pour l'avatar par defaut).
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

/// Entite pour un avis employe.
class EmployeeReviewEntity {
  final String id;
  final String authorName;
  final String authorRole;
  final String? authorAvatar;
  final double rating;
  final String comment;
  final String? recruiterReply;
  final String? recruiterName;
  final String? recruiterReplyDate;

  const EmployeeReviewEntity({
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
}

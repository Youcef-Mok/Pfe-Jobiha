import 'package:job_app/features/jobs/domain/job_entity.dart';

/// Modèle de données (DTO) — représente la forme brute venue de l'API/JSON.
/// Distinct de l'entité métier pour découpler la couche data du domaine.
class JobModel {
  final String id;
  final String title;
  final String description;
  final String companyName;
  final String recruiterId;
  final String recruiterName;
  final String recruiterRole;
  final String? recruiterAvatarAsset;
  final String department;
  final String contractType; // "cdi" | "mission" | "freelance"
  final String? city;
  final String? location;
  final String? scheduleLabel;
  final double? latitude;
  final double? longitude;
  final String postedAt; // ISO 8601 depuis l'API
  final String status; // "active" | "draft" | "closed"
  final int candidateCount;
  final int viewCount;
  final String? logoAsset;
  final bool isPublished;
  final List<JobCandidateModel> candidates;
  final List<JobCommentModel> comments;

  const JobModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.companyName,
    this.recruiterId = 'recruiter_1',
    this.recruiterName = 'Ahmed Bensalem',
    this.recruiterRole = 'Responsable RH',
    this.recruiterAvatarAsset = 'assets/images/pdp_1.png',
    this.department = 'IT',
    required this.contractType,
    this.city,
    this.location,
    this.scheduleLabel,
    this.latitude,
    this.longitude,
    required this.postedAt,
    required this.status,
    required this.candidateCount,
    required this.viewCount,
    this.logoAsset,
    required this.isPublished,
    this.candidates = const [],
    this.comments = const [],
  });

  /// Désérialisation depuis JSON (API REST)
  factory JobModel.fromJson(Map<String, dynamic> json) => JobModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        companyName: json['company_name'] as String,
        recruiterId: json['recruiter_id'] as String? ?? 'recruiter_1',
        recruiterName: json['recruiter_name'] as String? ?? 'Ahmed Bensalem',
        recruiterRole: json['recruiter_role'] as String? ?? 'Responsable RH',
        recruiterAvatarAsset: json['recruiter_avatar_asset'] as String?,
        department: json['department'] as String? ?? 'IT',
        contractType: json['contract_type'] as String? ?? 'cdi',
        city: json['city'] as String? ?? json['ville'] as String?,
        location: json['location'] as String?,
        scheduleLabel: json['schedule_label'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        postedAt: json['posted_at'] as String? ?? DateTime.now().toIso8601String(),
        status: json['status'] as String,
        candidateCount: json['candidate_count'] as int? ?? 0,
        viewCount: json['view_count'] as int? ?? 0,
        logoAsset: json['logo_asset'] as String?,
        isPublished: json['is_published'] as bool? ?? false,
        candidates: (json['candidates'] as List<dynamic>?)
                ?.map((e) =>
                    JobCandidateModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        comments: (json['comments'] as List<dynamic>?)
                ?.map(
                    (e) => JobCommentModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  /// Sérialisation vers JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'company_name': companyName,
        'recruiter_id': recruiterId,
        'recruiter_name': recruiterName,
        'recruiter_role': recruiterRole,
        'recruiter_avatar_asset': recruiterAvatarAsset,
        'department': department,
        'contract_type': contractType,
        'city': city,
        'location': location,
        'schedule_label': scheduleLabel,
        'latitude': latitude,
        'longitude': longitude,
        'posted_at': postedAt,
        'status': status,
        'candidate_count': candidateCount,
        'view_count': viewCount,
        'logo_asset': logoAsset,
        'is_published': isPublished,
        'candidates': candidates.map((e) => e.toJson()).toList(),
        'comments': comments.map((e) => e.toJson()).toList(),
      };

  /// Conversion vers l'entité métier
  JobEntity toEntity() => JobEntity(
        id: id,
        title: title,
        description: description,
        companyName: companyName,
        recruiterId: recruiterId,
        recruiterName: recruiterName,
        recruiterRole: recruiterRole,
        recruiterAvatarAsset: recruiterAvatarAsset,
        department: department,
        contractType: _parseContract(contractType),
        city: city,
        location: location,
        scheduleLabel: scheduleLabel,
        latitude: latitude,
        longitude: longitude,
        postedAt: DateTime.parse(postedAt),
        status: _parseStatus(status),
        candidateCount: candidateCount,
        viewCount: viewCount,
        logoAsset: logoAsset,
        isPublished: isPublished,
        candidates: candidates.map((e) => e.toEntity()).toList(),
        comments: comments.map((e) => e.toEntity()).toList(),
      );

  /// Conversion depuis l'entité métier (pour sauvegarder)
  factory JobModel.fromEntity(JobEntity entity) => JobModel(
        id: entity.id,
        title: entity.title,
        description: entity.description,
        companyName: entity.companyName,
        recruiterId: entity.recruiterId,
        recruiterName: entity.recruiterName,
        recruiterRole: entity.recruiterRole,
        recruiterAvatarAsset: entity.recruiterAvatarAsset,
        department: entity.department,
        contractType: entity.contractType.name,
        city: entity.city,
        location: entity.location,
        scheduleLabel: entity.scheduleLabel,
        latitude: entity.latitude,
        longitude: entity.longitude,
        postedAt: entity.postedAt.toIso8601String(),
        status: entity.status.name,
        candidateCount: entity.candidateCount,
        viewCount: entity.viewCount,
        logoAsset: entity.logoAsset,
        isPublished: entity.isPublished,
        candidates: entity.candidates
            .map((e) => JobCandidateModel.fromEntity(e))
            .toList(),
        comments:
            entity.comments.map((e) => JobCommentModel.fromEntity(e)).toList(),
      );

  static JobStatus _parseStatus(String value) {
    final v = value.trim().toLowerCase();
    return switch (v) {
      'active' => JobStatus.searching,
      'searching' => JobStatus.searching,
      'draft' => JobStatus.draft,
      'closed' => JobStatus.closed,
      _ => JobStatus.draft,
    };
  }

  static ContractType _parseContract(String value) {
    final v = value.trim().toLowerCase();
    return switch (v) {
      'cdi' => ContractType.cdi,
      'mission' => ContractType.mission,
      'freelance' => ContractType.freelance,
      _ => ContractType.cdi,
    };
  }

}

class JobCandidateModel {
  final String initials;
  final String name;
  final String role;
  final double rating;
  final String? avatarUrl;

  const JobCandidateModel({
    required this.initials,
    required this.name,
    required this.role,
    required this.rating,
    this.avatarUrl,
  });

  factory JobCandidateModel.fromJson(Map<String, dynamic> json) =>
      JobCandidateModel(
        initials: json['initials'] as String? ?? '',
        name: json['name'] as String? ?? '',
        role: json['role'] as String? ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        avatarUrl: json['avatar_url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'initials': initials,
        'name': name,
        'role': role,
        'rating': rating,
        'avatarUrl': avatarUrl,
      };

  JobCandidateEntity toEntity() => JobCandidateEntity(
        initials: initials,
        name: name,
        role: role,
        rating: rating,
        avatarUrl: avatarUrl,
      );

  factory JobCandidateModel.fromEntity(JobCandidateEntity entity) =>
      JobCandidateModel(
        initials: entity.initials,
        name: entity.name,
        role: entity.role,
        rating: entity.rating,
        avatarUrl: entity.avatarUrl,
      );
}

class JobCommentModel {
  final String initials;
  final String authorName;
  final String date;
  final String question;
  final String recruitorLabel;
  final String recruitorDate;
  final String reply;

  const JobCommentModel({
    required this.initials,
    required this.authorName,
    required this.date,
    required this.question,
    required this.recruitorLabel,
    required this.recruitorDate,
    required this.reply,
  });

  factory JobCommentModel.fromJson(Map<String, dynamic> json) =>
      JobCommentModel(
        initials: json['initials'] as String? ?? '',
        authorName: (json['author_name'] ?? json['authorName'] ?? '') as String,
        date: json['date'] as String? ?? '',
        question: json['question'] as String? ?? '',
        recruitorLabel: (json['recruitor_label'] ?? json['recruitorLabel'] ?? '') as String,
        recruitorDate: (json['recruitor_date'] ?? json['recruitorDate'] ?? '') as String,
        reply: json['reply'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'initials': initials,
        'authorName': authorName,
        'date': date,
        'question': question,
        'recruitorLabel': recruitorLabel,
        'recruitorDate': recruitorDate,
        'reply': reply,
      };

  JobCommentEntity toEntity() => JobCommentEntity(
        initials: initials,
        authorName: authorName,
        date: date,
        question: question,
        recruitorLabel: recruitorLabel,
        recruitorDate: recruitorDate,
        reply: reply,
      );

  factory JobCommentModel.fromEntity(JobCommentEntity entity) =>
      JobCommentModel(
        initials: entity.initials,
        authorName: entity.authorName,
        date: entity.date,
        question: entity.question,
        recruitorLabel: entity.recruitorLabel,
        recruitorDate: entity.recruitorDate,
        reply: entity.reply,
      );
}

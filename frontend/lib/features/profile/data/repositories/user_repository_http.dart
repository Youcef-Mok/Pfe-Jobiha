import 'package:dio/dio.dart';
import 'package:job_app/core/api/api_client.dart';
import 'package:job_app/core/api/api_endpoints.dart';
import 'package:job_app/features/profile/data/models/user_model.dart';
import 'package:job_app/features/profile/data/repositories/user_repository.dart';
import 'package:job_app/features/profile/domain/cv_entity.dart';
import 'package:job_app/features/profile/domain/user_entity.dart';

class UserRepositoryHttp implements UserRepository {
  final Dio _dio = ApiClient.instance;

  // Backend returns 'candidat'/'recruteur' — entity expects 'candidate'/'recruiter'
  static String _normalizeAccountType(String? raw) => switch (raw) {
        'candidat' => 'candidate',
        'recruteur' => 'recruiter',
        _ => raw ?? 'candidate',
      };

  UserEntity _parseUser(Map<String, dynamic> json) {
    return UserModel.fromJson({
      ...json,
      'company': json['company'] ?? '',
      'location': json['location'] ?? '',
      'bio': json['bio'] ?? '',
      'account_type': _normalizeAccountType(json['account_type'] as String?),
    }).toEntity();
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    final resp = await _dio.get(ApiEndpoints.me);
    return _parseUser(resp.data as Map<String, dynamic>);
  }

  @override
  Future<UserEntity> getUserById(String userId) async {
    final resp = await _dio.get(ApiEndpoints.me.replaceFirst('/users/me', '/users/$userId'));
    return _parseUser(resp.data as Map<String, dynamic>);
  }

  @override
  Future<List<EmployeeReviewEntity>> getEmployeeReviews(String userId) async {
    final resp = await _dio.get(ApiEndpoints.userReviews(int.parse(userId)));
    final list = resp.data as List<dynamic>;
    return list
        .map((j) => EmployeeReviewModel.fromJson(j as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<UserEntity> updateProfile(UserEntity user) async {
    final trimmed = user.name.trim();
    final parts = trimmed.isEmpty ? const <String>[] : trimmed.split(RegExp(r'\s+'));
    final prenom = parts.isNotEmpty ? parts.first : '';
    final nom = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    final resp = await _dio.patch(ApiEndpoints.me, data: {
      'prenom': prenom,
      'nom': nom,
      'avatar_url': user.avatarUrl,
      'location': user.location,
      'bio': user.bio,
      'role': user.role,
      'domain': user.domain,
      'company': user.company,
    });
    return _parseUser(resp.data as Map<String, dynamic>);
  }

  @override
  Future<CvEntity> getCvData(String userId) async {
    final resp = await _dio.get(ApiEndpoints.userCv(int.parse(userId)));
    final data = resp.data as Map<String, dynamic>;

    final formations = (data['formations'] as List<dynamic>? ?? [])
        .map((f) {
          final rawYear = f['year'];
          final year = rawYear is int
              ? rawYear
              : int.tryParse((rawYear ?? '').toString()) ?? 0;
          return CvFormationEntity(
            title: f['title'] as String? ?? '',
            institution: f['institution'] as String? ?? '',
            location: f['location'] as String? ?? '',
            year: year,
            isActive: f['is_active'] as bool? ?? false,
            fileName: f['file_name'] as String?,
            filePath: f['file_path'] as String?,
          );
        })
        .toList();

    final experiences = (data['experiences'] as List<dynamic>? ?? [])
        .map((e) => CvExperienceEntity(
              title: e['title'] as String? ?? '',
              company: e['company'] as String? ?? '',
              location: e['location'] as String? ?? '',
              period: e['period'] as String?,
              endDate: e['end_date'] as String?,
              isAppMission: e['is_app_mission'] as bool? ?? false,
              isActive: e['is_active'] as bool? ?? false,
              missionId: e['mission_id']?.toString(),
              status: e['status'] as String?,
              startDate: e['start_date'] as String?,
              candidateName: e['candidate_name'] as String?,
              recruiterName: e['recruiter_name'] as String?,
              recruiterRating: (e['recruiter_rating'] as num?)?.toDouble() ?? 0.0,
              candidateRating: (e['candidate_rating'] as num?)?.toDouble() ?? 0.0,
              recruiterFeedback: e['recruiter_feedback'] as String?,
              candidateFeedback: e['candidate_feedback'] as String?,
              description: e['description'] as String?,
              imageUrl: e['image_url'] as String?,
            ))
        .toList();

    final languages = (data['languages'] as List<dynamic>? ?? [])
        .map((l) => CvLanguageEntity(
              name: l['name'] as String? ?? '',
              level: l['proficiency'] as String? ?? l['level'] as String? ?? '',
            ))
        .toList();

    final skills = (data['skills'] as List<dynamic>? ?? [])
        .map((s) {
          final level = s['level'] as String? ?? '';
          return CvSkillEntity(
            name: s['name'] as String? ?? '',
            levelLabel: _levelLabel(level),
            progress: _levelProgress(level),
          );
        })
        .toList();

    return CvEntity(
      formations: formations,
      experiences: experiences,
      languages: languages,
      skills: skills,
    );
  }

  @override
  Future<CvExperienceEntity> addExperience(CvExperienceEntity exp) async {
    final resp = await _dio.post(ApiEndpoints.cvExperiences, data: {
      'title': exp.title,
      'company': exp.company,
      'location': exp.location,
      if (exp.period != null) 'period': exp.period,
      if (exp.endDate != null) 'end_date': exp.endDate,
    });
    final d = resp.data as Map<String, dynamic>;
    return CvExperienceEntity(
      title: d['title'] as String,
      company: d['company'] as String,
      location: d['location'] as String? ?? '',
      period: d['period'] as String?,
      endDate: d['end_date'] as String?,
      isAppMission: d['is_app_mission'] as bool? ?? false,
      isActive: d['is_active'] as bool? ?? false,
    );
  }

  @override
  Future<CvFormationEntity> addFormation(CvFormationEntity formation) async {
    final data = <String, dynamic>{
      'title': formation.title,
      'institution': formation.institution,
      'location': formation.location,
      'year': formation.year,
      'is_active': formation.isActive,
      if (formation.fileName != null) 'file_name': formation.fileName,
      if (formation.filePath != null) 'file_path': formation.filePath,
    };
    if (formation.fileBytes != null && formation.fileName != null) {
      data['file'] = MultipartFile.fromBytes(
        formation.fileBytes!,
        filename: formation.fileName!,
      );
    }
    final resp = await _dio.post(
      ApiEndpoints.cvFormations,
      data: FormData.fromMap(data),
    );
    final d = resp.data as Map<String, dynamic>;
    return CvFormationEntity(
      title: d['title'] as String,
      institution: d['institution'] as String,
      location: d['location'] as String? ?? '',
      year: d['year'] as int,
      isActive: d['is_active'] as bool? ?? false,
      fileName: d['file_name'] as String?,
      filePath: d['file_path'] as String?,
    );
  }

  @override
  Future<CvLanguageEntity> addLanguage(CvLanguageEntity language) async {
    final resp = await _dio.post(ApiEndpoints.cvLanguages, data: {
      'name': language.name,
      'proficiency': language.level,
    });
    final d = resp.data as Map<String, dynamic>;
    return CvLanguageEntity(
      name: d['name'] as String,
      level: d['proficiency'] as String? ?? language.level,
    );
  }

  @override
  Future<CvSkillEntity> addSkill(CvSkillEntity skill) async {
    final resp = await _dio.post(ApiEndpoints.cvSkills, data: {
      'name': skill.name,
      'level': _skillLevelToApi(skill.levelLabel),
    });
    final d = resp.data as Map<String, dynamic>;
    final level = d['level'] as String? ?? '';
    return CvSkillEntity(
      name: d['name'] as String,
      levelLabel: _levelLabel(level),
      progress: _levelProgress(level),
    );
  }

  static String _skillLevelToApi(String? displayLabel) =>
      switch (displayLabel?.toUpperCase()) {
        'DÉBUTANT' => 'debutant',
        'INTERMÉDIAIRE' => 'intermediaire',
        'AVANCÉ' => 'avance',
        'EXPERT' => 'expert',
        _ => 'debutant',
      };

  static String? _levelLabel(String level) => switch (level) {
        'debutant' => 'Débutant',
        'intermediaire' => 'Intermédiaire',
        'avance' => 'Avancé',
        'expert' => 'Expert',
        _ => level.isEmpty ? null : level,
      };

  static double _levelProgress(String level) => switch (level) {
        'debutant' => 0.25,
        'intermediaire' => 0.50,
        'avance' => 0.75,
        'expert' => 1.00,
        _ => 0.5,
      };
}

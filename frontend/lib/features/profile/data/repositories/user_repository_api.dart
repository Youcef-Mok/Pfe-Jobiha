import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:job_app/core/api/api_client.dart';
import 'package:job_app/core/api/api_endpoints.dart';
import 'package:job_app/features/profile/domain/user_entity.dart';
import 'package:job_app/features/profile/domain/cv_entity.dart';
import 'package:job_app/features/profile/data/models/user_model.dart';
import 'package:job_app/features/profile/data/repositories/user_repository.dart';

/// Real API implementation of [UserRepository].
/// Calls the Django REST backend via Dio.
class UserRepositoryApi implements UserRepository {
  final Dio _dio = ApiClient.instance;

  @override
  Future<UserEntity> getCurrentUser() async {
    final response = await _dio.get(ApiEndpoints.me);
    final json = response.data as Map<String, dynamic>;
    return UserModel.fromJson(json).toEntity();
  }

  @override
  Future<List<EmployeeReviewEntity>> getEmployeeReviews(String userId) async {
    final id = int.tryParse(userId) ?? 0;
    final response = await _dio.get(ApiEndpoints.userEvaluations(id));
    final List<dynamic> data = response.data is List
        ? response.data as List<dynamic>
        : (response.data['results'] as List<dynamic>?) ?? [];
    return data
        .map((json) => EmployeeReviewModel.fromJson(json as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<UserEntity> updateProfile(UserEntity user) async {
    final model = UserModel.fromEntity(user);
    final response = await _dio.patch(ApiEndpoints.me, data: model.toJson());
    return UserModel.fromJson(response.data as Map<String, dynamic>).toEntity();
  }

  @override
  Future<CvEntity> getCvData(String userId) async {
    // Use the /users/<id>/cv endpoint which is accessible to all authenticated
    // users (candidat AND recruteur). The old /candidats/me endpoint requires
    // the IsCandidat permission and returns a 403 for recruiters.
    final id = int.tryParse(userId) ?? 0;
    final url = ApiEndpoints.userCv(id);
    debugPrint('[getCvData] Calling: $url (userId=$userId, parsed id=$id)');

    try {
      final response = await _dio.get(url);
      final json = response.data as Map<String, dynamic>;
      return _parseCvFromProfile(json);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // The endpoint doesn't exist for this user (e.g. recruteur has no CV).
        // Gracefully return an empty CV so the UI shows an empty state.
        debugPrint('[getCvData] 404 — no CV found for user $id. Returning empty CvEntity.');
        return const CvEntity(
          formations: [],
          experiences: [],
          languages: [],
          skills: [],
        );
      }
      rethrow; // propagate other errors (401, 500, network…)
    }
  }

  /// Parses CV data from the candidat profile response.
  CvEntity _parseCvFromProfile(Map<String, dynamic> json) {
    final formations = (json['formations'] as List<dynamic>?)
            ?.map((f) => CvFormationEntity(
                  title: f['title'] as String? ?? '',
                  institution: f['institution'] as String? ?? '',
                  location: f['location'] as String? ?? '',
                  year: f['year'] as int? ?? 0,
                  isActive: f['is_active'] as bool? ?? false,
                ))
            .toList() ??
        [];

    final experiences = (json['experiences'] as List<dynamic>?)
            ?.map((e) => CvExperienceEntity(
                  title: e['title'] as String? ?? '',
                  company: e['company'] as String? ?? '',
                  location: e['location'] as String? ?? '',
                  period: e['period'] as String?,
                  endDate: e['end_date'] as String?,
                  isAppMission: e['is_app_mission'] as bool? ?? false,
                  isActive: e['is_active'] as bool? ?? false,
                ))
            .toList() ??
        [];

    final languages = (json['languages'] as List<dynamic>?)
            ?.map((l) => CvLanguageEntity(
                  name: l['name'] as String? ?? '',
                  level: l['level'] as String? ?? '',
                ))
            .toList() ??
        [];

    final skills = (json['skills'] as List<dynamic>?)
            ?.map((s) => CvSkillEntity(
                  name: s['name'] as String? ?? '',
                  levelLabel: s['level_label'] as String?,
                  progress: (s['progress'] as num?)?.toDouble() ?? 0.0,
                ))
            .toList() ??
        [];

    return CvEntity(
      formations: formations,
      experiences: experiences,
      languages: languages,
      skills: skills,
    );
  }
}

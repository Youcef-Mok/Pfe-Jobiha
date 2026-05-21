import 'package:dio/dio.dart';
import 'package:job_app/core/api/api_client.dart';
import 'package:job_app/core/api/api_endpoints.dart';
import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/features/jobs/domain/mission_entity.dart';
import 'package:job_app/features/jobs/domain/create_mission_params.dart';
import 'package:job_app/features/jobs/data/models/job_model.dart';
import 'package:job_app/features/jobs/data/models/mission_model.dart';
import 'package:job_app/features/jobs/data/repositories/jobs_repository.dart';

/// Implémentation API réelle du repository.
/// Appelle le backend Django REST via Dio.
class JobsRepositoryMock implements JobsRepository {
  final Dio _dio = ApiClient.instance;
  @override
  Future<List<JobEntity>> getMyJobs({
    String? status,
    String? postedWithin,
    String? department,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;
    if (postedWithin != null) queryParams['posted_within'] = postedWithin;
    if (department != null) queryParams['department'] = department;

    final response = await _dio.get(
      ApiEndpoints.jobsMine,
      queryParameters: queryParams,
    );
    final List<dynamic> data = response.data is List
        ? response.data as List<dynamic>
        : (response.data['results'] as List<dynamic>?) ?? [];
    return data
        .map((json) => JobModel.fromJson(json as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<JobEntity> saveJob(JobEntity job) async {
    final model = JobModel.fromEntity(job);
    final json = model.toJson();

    // Si l'ID ressemble à un timestamp généré côté client, créer; sinon mettre à jour
    final isNew = int.tryParse(job.id) != null && job.id.length > 10;

    if (isNew) {
      json.remove('id'); // Laisser le backend assigner un ID
      final response = await _dio.post(ApiEndpoints.jobs, data: json);
      return JobModel.fromJson(response.data as Map<String, dynamic>).toEntity();
    } else {
      final id = int.tryParse(job.id) ?? 0;
      final response = await _dio.put(ApiEndpoints.jobDetail(id), data: json);
      return JobModel.fromJson(response.data as Map<String, dynamic>).toEntity();
    }
  }

  @override
  Future<void> deleteJob(String jobId) async {
    final id = int.tryParse(jobId) ?? 0;
    await _dio.delete(ApiEndpoints.jobDetail(id));
  }

  @override
  Future<JobEntity?> getJobById(String jobId) async {
    try {
      final id = int.tryParse(jobId) ?? 0;
      final response = await _dio.get(ApiEndpoints.jobDetail(id));
      return JobModel.fromJson(response.data as Map<String, dynamic>).toEntity();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<List<MissionEntity>> getMissions() async {
    final response = await _dio.get(ApiEndpoints.missions);
    final List<dynamic> data = response.data is List
        ? response.data as List<dynamic>
        : (response.data['results'] as List<dynamic>?) ?? [];
    return data
        .map((json) => MissionModel.fromJson(json as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<MissionEntity> createMission(CreateMissionParams params) async {
    final response = await _dio.post(
      ApiEndpoints.missions,
      data: {
        'job_id': params.jobId,
        'candidate_name': params.candidateName,
        'start_date': params.startDate.toIso8601String(),
        'end_date': params.endDate.toIso8601String(),
        'location': params.location,
        if (params.imageUrl != null) 'image_url': params.imageUrl,
      },
    );
    return MissionModel.fromJson(response.data as Map<String, dynamic>).toEntity();
  }

  @override
  Future<MissionEntity> confirmMission(String missionId) async {
    final id = int.tryParse(missionId) ?? 0;
    final response = await _dio.patch(ApiEndpoints.missionConfirm(id));
    return MissionModel.fromJson(response.data as Map<String, dynamic>).toEntity();
  }

  @override
  Future<MissionEntity> updateMissionReview(String missionId, double rating, String feedback) async {
    final id = int.tryParse(missionId) ?? 0;
    final response = await _dio.put(
      ApiEndpoints.missionReview(id),
      data: {
        'rating': rating,
        'feedback': feedback,
      },
    );
    return MissionModel.fromJson(response.data as Map<String, dynamic>).toEntity();
  }
}


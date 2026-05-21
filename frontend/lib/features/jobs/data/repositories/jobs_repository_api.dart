import 'package:dio/dio.dart';
import 'package:job_app/core/api/api_client.dart';
import 'package:job_app/core/api/api_endpoints.dart';
import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/features/jobs/domain/mission_entity.dart';
import 'package:job_app/features/jobs/data/models/job_model.dart';
import 'package:job_app/features/jobs/data/models/mission_model.dart';
import 'package:job_app/features/jobs/data/repositories/jobs_repository.dart';

//added this
import 'package:job_app/features/jobs/domain/create_mission_params.dart';



/// Real API implementation of [JobsRepository].
/// Calls the Django REST backend via Dio.
class JobsRepositoryApi implements JobsRepository {
  final Dio _dio = ApiClient.instance;

  @override
  Future<List<JobEntity>> getMyJobs() async {
    final response = await _dio.get(ApiEndpoints.myOffres);
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

    // If the id looks like a client-generated timestamp, create; otherwise update.
    final isNew = int.tryParse(job.id) != null && job.id.length > 10;

    if (isNew) {
      json.remove('id'); // let the backend assign an id
      final response = await _dio.post(ApiEndpoints.offres, data: json);
      return JobModel.fromJson(response.data as Map<String, dynamic>).toEntity();
    } else {
      final id = int.tryParse(job.id) ?? 0;
      final response = await _dio.patch(ApiEndpoints.offreDetail(id), data: json);
      return JobModel.fromJson(response.data as Map<String, dynamic>).toEntity();
    }
  }

  @override
  Future<void> deleteJob(String jobId) async {
    final id = int.tryParse(jobId) ?? 0;
    await _dio.delete(ApiEndpoints.offreDetail(id));
  }

  @override
  Future<JobEntity?> getJobById(String jobId) async {
    try {
      final id = int.tryParse(jobId) ?? 0;
      final response = await _dio.get(ApiEndpoints.offreDetail(id));
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

  //added this to fix error

  @override
  Future<MissionEntity> createMission(CreateMissionParams params) {
    throw UnimplementedError('createMission not yet implemented');
  }

  @override
  Future<MissionEntity> confirmMission(String missionId) {
    throw UnimplementedError('confirmMission not yet implemented');
  }

  @override
  Future<MissionEntity> updateMissionReview(String missionId, double rating, String feedback) {
    throw UnimplementedError('updateMissionReview not yet implemented');
  }

}

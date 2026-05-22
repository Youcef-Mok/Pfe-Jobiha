import 'package:dio/dio.dart';
import 'package:job_app/core/api/api_client.dart';
import 'package:job_app/core/api/api_endpoints.dart';
import 'package:job_app/features/applications/data/models/application_model.dart';
import 'package:job_app/features/applications/data/repositories/applications_repository.dart';
import 'package:job_app/features/applications/domain/application_entity.dart';

class ApplicationsRepositoryHttp implements ApplicationsRepository {
  final Dio _dio = ApiClient.instance;

  List<dynamic> _results(dynamic data) {
    if (data is Map && data.containsKey('results')) return data['results'] as List;
    if (data is List) return data;
    return [];
  }

  @override
  Future<List<ApplicationEntity>> getMyApplications() async {
    final resp = await _dio.get(ApiEndpoints.appliedJobs);
    return _results(resp.data)
        .map((j) => ApplicationModel.fromJson(j as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<ApplicationEntity> applyToJob(
    String jobId, {
    String? motivationLetter,
  }) async {
    final resp = await _dio.post(
      ApiEndpoints.appliedJobs,
      data: {
        'job_id': jobId,
        if (motivationLetter != null && motivationLetter.trim().isNotEmpty)
          'motivation_letter': motivationLetter.trim(),
      },
    );
    return ApplicationModel.fromJson(resp.data as Map<String, dynamic>).toEntity();
  }

  @override
  Future<void> cancelApplication(String applicationId) async {
    await _dio.delete(ApiEndpoints.candidatureDetail(int.parse(applicationId)));
  }

  @override
  Future<void> acceptApplication(String applicationId) async {
    await _dio.put(ApiEndpoints.accepterCandidature(int.parse(applicationId)));
  }

  @override
  Future<void> rejectApplication(String applicationId) async {
    await _dio.put(ApiEndpoints.refuserCandidature(int.parse(applicationId)));
  }
}

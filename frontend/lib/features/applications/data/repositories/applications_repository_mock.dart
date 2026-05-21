import 'package:dio/dio.dart';
import 'package:job_app/core/api/api_client.dart';
import 'package:job_app/core/api/api_endpoints.dart';
import 'package:job_app/features/applications/data/models/application_model.dart';
import 'package:job_app/features/applications/data/repositories/applications_repository.dart';
import 'package:job_app/features/applications/domain/application_entity.dart';

/// Implémentation API réelle du repository.
/// Appelle le backend Django REST via Dio.
class ApplicationsRepositoryMock implements ApplicationsRepository {
  final Dio _dio = ApiClient.instance;

  @override
  Future<List<ApplicationEntity>> getMyApplications() async {
    final response = await _dio.get(ApiEndpoints.applications);
    final List<dynamic> data = response.data is List
        ? response.data as List<dynamic>
        : (response.data['results'] as List<dynamic>?) ?? [];
    return data
        .map((json) => ApplicationModel.fromJson(json as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<ApplicationEntity> applyToJob(String jobId) async {
    final response = await _dio.post(
      ApiEndpoints.applications,
      data: {'job_id': jobId},
    );
    return ApplicationModel.fromJson(response.data as Map<String, dynamic>).toEntity();
  }

  @override
  Future<void> cancelApplication(String applicationId) async {
    final id = int.tryParse(applicationId) ?? 0;
    await _dio.delete(ApiEndpoints.applicationDetail(id));
  }

  @override
  Future<void> acceptApplication(String applicationId) async {
    final id = int.tryParse(applicationId) ?? 0;
    await _dio.put(ApiEndpoints.acceptApplication(id));
  }

  @override
  Future<void> rejectApplication(String applicationId) async {
    final id = int.tryParse(applicationId) ?? 0;
    await _dio.put(ApiEndpoints.rejectApplication(id));
  }
}

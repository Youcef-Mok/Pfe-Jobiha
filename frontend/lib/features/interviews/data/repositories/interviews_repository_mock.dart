import 'package:dio/dio.dart';
import 'package:job_app/core/api/api_client.dart';
import 'package:job_app/core/api/api_endpoints.dart';
import 'package:job_app/features/interviews/domain/interview_entity.dart';
import 'package:job_app/features/interviews/data/models/interview_model.dart';
import 'package:job_app/features/interviews/data/repositories/interviews_repository.dart';

/// Implémentation API réelle du repository.
/// Appelle le backend Django REST via Dio.
class InterviewsRepositoryMock implements InterviewsRepository {
  final Dio _dio = ApiClient.instance;

  @override
  Future<List<InterviewEntity>> getInterviews() async {
    final response = await _dio.get(ApiEndpoints.interviews);
    final List<dynamic> data = response.data is List
        ? response.data as List<dynamic>
        : (response.data['results'] as List<dynamic>?) ?? [];
    return data
        .map((json) => InterviewModel.fromJson(json as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<List<InterviewEntity>> getUpcomingInterviews() async {
    final response = await _dio.get(
      ApiEndpoints.interviews,
      queryParameters: {'upcoming': 'true', 'status': 'scheduled'},
    );
    final List<dynamic> data = response.data is List
        ? response.data as List<dynamic>
        : (response.data['results'] as List<dynamic>?) ?? [];
    return data
        .map((json) => InterviewModel.fromJson(json as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<InterviewEntity?> getInterviewById(String id) async {
    try {
      final intId = int.tryParse(id) ?? 0;
      final response = await _dio.get(ApiEndpoints.interviewDetail(intId));
      return InterviewModel.fromJson(response.data as Map<String, dynamic>).toEntity();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<InterviewEntity> createInterview(InterviewEntity interview) async {
    final model = InterviewModel.fromEntity(interview);
    final json = model.toJson();
    json.remove('id'); // Laisser le backend assigner un ID
    
    final response = await _dio.post(ApiEndpoints.interviews, data: json);
    return InterviewModel.fromJson(response.data as Map<String, dynamic>).toEntity();
  }

  @override
  Future<InterviewEntity> updateInterview(InterviewEntity interview) async {
    final intId = int.tryParse(interview.id) ?? 0;
    final model = InterviewModel.fromEntity(interview);
    final response = await _dio.put(
      ApiEndpoints.interviewDetail(intId),
      data: model.toJson(),
    );
    return InterviewModel.fromJson(response.data as Map<String, dynamic>).toEntity();
  }

  @override
  Future<void> cancelInterview(String id) async {
    final intId = int.tryParse(id) ?? 0;
    await _dio.delete(ApiEndpoints.interviewDetail(intId));
  }

  @override
  Future<InterviewEntity> completeInterview(String id, String? notes) async {
    final intId = int.tryParse(id) ?? 0;
    final response = await _dio.put(
      ApiEndpoints.interviewComplete(intId),
      data: {'notes': notes},
    );
    return InterviewModel.fromJson(response.data as Map<String, dynamic>).toEntity();
  }
}

import 'package:dio/dio.dart';
import 'package:job_app/core/api/api_client.dart';
import 'package:job_app/core/api/api_endpoints.dart';
import 'package:job_app/features/interviews/data/models/interview_model.dart';
import 'package:job_app/features/interviews/data/repositories/interviews_repository.dart';
import 'package:job_app/features/interviews/domain/interview_entity.dart';

class InterviewsRepositoryHttp implements InterviewsRepository {
  final Dio _dio = ApiClient.instance;

  // Backend returns snake_case; InterviewModel.fromJson expects camelCase.
  static Map<String, dynamic> _normalize(Map<String, dynamic> j) => {
        'id': j['id']?.toString() ?? '',
        'candidateId': j['candidate_id']?.toString() ?? '',
        'candidateName': j['candidate_name'] as String? ?? '',
        'candidateAvatar': j['candidate_avatar'] as String?,
        'jobId': j['job_id']?.toString() ?? '',
        'jobTitle': j['job_title'] as String? ?? '',
        'department': j['department'] as String? ?? 'IT',
        'scheduledDate': j['scheduled_date'] as String? ?? DateTime.now().toIso8601String(),
        'status': j['status'] as String? ?? 'scheduled',
        'notes': j['notes'] as String?,
      };

  InterviewEntity _parse(Map<String, dynamic> j) =>
      InterviewModel.fromJson(_normalize(j)).toEntity();

  @override
  Future<List<InterviewEntity>> getInterviews() async {
    final resp = await _dio.get(ApiEndpoints.interviews);
    final list = resp.data is List ? resp.data as List : [];
    return list.map((j) => _parse(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<InterviewEntity>> getUpcomingInterviews() async {
    final resp = await _dio.get(ApiEndpoints.interviews, queryParameters: {'upcoming': 'true'});
    final list = resp.data is List ? resp.data as List : [];
    return list.map((j) => _parse(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<InterviewEntity?> getInterviewById(String id) async {
    try {
      final resp = await _dio.get(ApiEndpoints.interviewDetail(int.parse(id)));
      return _parse(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<InterviewEntity> createInterview(InterviewEntity interview) async {
    final resp = await _dio.post(ApiEndpoints.interviews, data: {
      'candidate_id': interview.candidateId,
      'job_id': interview.jobId,
      'scheduled_date': interview.scheduledDate.toIso8601String(),
      if (interview.notes != null) 'notes': interview.notes,
    });
    return _parse(resp.data as Map<String, dynamic>);
  }

  @override
  Future<InterviewEntity> updateInterview(InterviewEntity interview) async {
    final resp = await _dio.put(
      ApiEndpoints.interviewDetail(int.parse(interview.id)),
      data: {
        'scheduled_date': interview.scheduledDate.toIso8601String(),
        if (interview.notes != null) 'notes': interview.notes,
      },
    );
    return _parse(resp.data as Map<String, dynamic>);
  }

  @override
  Future<void> cancelInterview(String id) async {
    await _dio.delete(ApiEndpoints.interviewDetail(int.parse(id)));
  }

  @override
  Future<InterviewEntity> completeInterview(String id, String? notes) async {
    final resp = await _dio.put(
      ApiEndpoints.interviewComplete(int.parse(id)),
      data: {if (notes != null) 'notes': notes},
    );
    return _parse(resp.data as Map<String, dynamic>);
  }
}

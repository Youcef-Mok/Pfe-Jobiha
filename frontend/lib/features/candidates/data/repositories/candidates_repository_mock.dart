import 'package:dio/dio.dart';
import 'package:job_app/core/api/api_client.dart';
import 'package:job_app/core/api/api_endpoints.dart';
import 'package:job_app/features/candidates/data/models/candidate_model.dart';
import 'package:job_app/features/candidates/domain/candidate_entity.dart';
import 'candidates_repository.dart';

/// Implémentation API réelle du repository.
/// Appelle le backend Django REST via Dio.
class CandidatesRepositoryMock implements CandidatesRepository {
  final Dio _dio = ApiClient.instance;

  @override
  Future<List<CandidateModel>> getCandidates(String jobId) async {
    final id = int.tryParse(jobId) ?? 0;
    final response = await _dio.get(ApiEndpoints.jobCandidates(id));
    final List<dynamic> data = response.data is List
        ? response.data as List<dynamic>
        : (response.data['results'] as List<dynamic>?) ?? [];
    return data
        .map((json) => CandidateModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updateCandidateStatus(String candidateId, String status) async {
    final id = int.tryParse(candidateId) ?? 0;
    await _dio.put(
      ApiEndpoints.candidateStatus(id),
      data: {'status': status},
    );
  }

  @override
  Future<void> scheduleInterview(
    String candidateId,
    DateTime date,
    String timeSlot,
  ) async {
    await _dio.post(
      ApiEndpoints.interviews,
      data: {
        'candidate_id': candidateId,
        'scheduled_date': date.toIso8601String(),
        'time_slot': timeSlot,
      },
    );
  }
}

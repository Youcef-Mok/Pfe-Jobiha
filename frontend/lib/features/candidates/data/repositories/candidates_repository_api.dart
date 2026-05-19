import 'package:dio/dio.dart';
import 'package:job_app/core/api/api_client.dart';
import 'package:job_app/core/api/api_endpoints.dart';
import 'package:job_app/features/candidates/data/models/candidate_model.dart';
import 'package:job_app/features/candidates/data/repositories/candidates_repository.dart';

/// Real API implementation of [CandidatesRepository].
/// Calls the Django REST backend via Dio.
class CandidatesRepositoryApi implements CandidatesRepository {
  final Dio _dio = ApiClient.instance;

  @override
  Future<List<CandidateModel>> getCandidates(String jobId) async {
    final id = int.tryParse(jobId) ?? 0;
    final response = await _dio.get(ApiEndpoints.offreCandidatures(id));
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
    // Use the appropriate accept/refuse endpoint based on the status
    if (status == 'accepte' || status == 'accepted') {
      await _dio.post(ApiEndpoints.accepterCandidature(id));
    } else if (status == 'refuse' || status == 'rejected') {
      await _dio.post(ApiEndpoints.refuserCandidature(id));
    } else {
      // For other status changes, use PATCH on the candidature detail
      await _dio.patch(
        ApiEndpoints.candidatureDetail(id),
        data: {'status': status},
      );
    }
  }

  @override
  Future<void> scheduleInterview(
    String candidateId,
    DateTime date,
    String timeSlot,
  ) async {
    final id = int.tryParse(candidateId) ?? 0;
    await _dio.patch(
      ApiEndpoints.candidatureDetail(id),
      data: {
        'interview_date': date.toIso8601String(),
        'interview_time_slot': timeSlot,
      },
    );
  }
}

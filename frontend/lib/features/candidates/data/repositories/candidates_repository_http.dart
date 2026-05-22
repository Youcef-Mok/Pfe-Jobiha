import 'package:dio/dio.dart';
import 'package:job_app/core/api/api_client.dart';
import 'package:job_app/core/api/api_endpoints.dart';
import 'package:job_app/features/candidates/data/models/candidate_model.dart';
import 'package:job_app/features/candidates/domain/candidate_entity.dart';
import 'candidates_repository.dart';

class CandidatesRepositoryHttp implements CandidatesRepository {
  final Dio _dio = ApiClient.instance;

  List<dynamic> _results(dynamic data) {
    if (data is Map && data.containsKey('results')) return data['results'] as List;
    if (data is List) return data;
    return [];
  }

  // Maps ApplicationResponse → CandidateModel.
  // The application id is used as candidate id for accept/reject actions.
  static CandidateModel _fromApplication(Map<String, dynamic> j) {
    final appStatus = j['status'] as String? ?? 'pending';
    return CandidateModel(
      id: j['id']?.toString() ?? '',
      name: j['candidate_name'] as String? ?? '',
      title: j['candidate_domain'] as String? ?? '',
      photoUrl: j['candidate_avatar'] as String? ?? '',
      rating: (j['candidate_rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: 0,
      isTopRated: false,
      coverLetter: j['motivation_letter'] as String? ?? '',
      status: _parseStatus(appStatus),
    );
  }

  static CandidateStatus _parseStatus(String s) => switch (s) {
        'accepted' => CandidateStatus.examine,
        'rejected' => CandidateStatus.archive,
        _ => CandidateStatus.nouveau,
      };

  @override
  Future<List<CandidateModel>> getCandidates(String jobId) async {
    final resp = await _dio.get(ApiEndpoints.offreCandidatures(int.parse(jobId)));
    return _results(resp.data)
        .map((j) => _fromApplication(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updateCandidateStatus(String applicationId, String status) async {
    if (status == 'examine') {
      await _dio.put(ApiEndpoints.accepterCandidature(int.parse(applicationId)));
    } else if (status == 'archive') {
      await _dio.put(ApiEndpoints.refuserCandidature(int.parse(applicationId)));
    }
    // 'nouveau' → no server action needed
  }

  @override
  Future<void> scheduleInterview(
    String candidateId,
    DateTime date,
    String timeSlot,
  ) async {
    // timeSlot is "HH:mm-HH:mm" — use start time for scheduled_date
    final startTime = timeSlot.split('-').first.trim();
    final parts = startTime.split(':');
    final scheduledDate = DateTime(
      date.year,
      date.month,
      date.day,
      parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0,
      parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
    await _dio.post(ApiEndpoints.interviews, data: {
      'candidate_id': candidateId,
      'scheduled_date': scheduledDate.toIso8601String(),
    });
  }
}

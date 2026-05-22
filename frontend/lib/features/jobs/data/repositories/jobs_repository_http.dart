import 'package:dio/dio.dart';
import 'package:job_app/core/api/api_client.dart';
import 'package:job_app/core/api/api_endpoints.dart';
import 'package:job_app/features/jobs/data/models/job_model.dart';
import 'package:job_app/features/jobs/data/models/mission_model.dart';
import 'package:job_app/features/jobs/data/repositories/jobs_repository.dart';
import 'package:job_app/features/jobs/domain/create_mission_params.dart';
import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/features/jobs/domain/mission_entity.dart';

class JobsRepositoryHttp implements JobsRepository {
  final Dio _dio = ApiClient.instance;

  // ── Helpers ──────────────────────────────────────────────────────────────────

  /// Extracts list from paginated or plain array response.
  List<dynamic> _results(dynamic data) {
    if (data is Map && data.containsKey('results')) return data['results'] as List;
    if (data is List) return data;
    return [];
  }

  /// True when [id] is a locally-generated temp ID (not a real server ID).
  /// Temp IDs are `DateTime.now().millisecondsSinceEpoch.toString()` — 13 digits.
  bool _isTempId(String id) {
    final n = int.tryParse(id);
    return n == null || n > 999999999;
  }

  String _contractTypeToApi(ContractType t) => switch (t) {
        ContractType.cdi => 'cdi',
        ContractType.mission => 'mission',
        ContractType.freelance => 'freelance',
      };

  // ── Jobs ─────────────────────────────────────────────────────────────────────

  @override
  Future<List<JobEntity>> getMyJobs({
    String? status,
    String? postedWithin,
    String? department,
  }) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;
    if (postedWithin != null) params['posted_within'] = postedWithin;
    if (department != null) params['department'] = department;
    final resp = await _dio.get(
      ApiEndpoints.myOffres,
      queryParameters: params.isEmpty ? null : params,
    );
    return _results(resp.data)
        .map((j) => JobModel.fromJson(j as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<List<JobEntity>> getAllJobs({
    double? lat,
    double? lng,
    double? maxDistanceKm,
    String? location,
    String? category,
    String? contractType,
  }) async {
    final params = <String, dynamic>{};
    if (lat != null) params['lat'] = lat;
    if (lng != null) params['lng'] = lng;
    if (maxDistanceKm != null) params['max_distance_km'] = maxDistanceKm;
    if (location != null) params['location'] = location;
    if (category != null) params['category'] = category;
    if (contractType != null) params['contract_type'] = contractType;
    final resp = await _dio.get(ApiEndpoints.offres, queryParameters: params.isEmpty ? null : params);
    return _results(resp.data)
        .map((j) => JobModel.fromJson(j as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<JobEntity?> getJobById(String jobId) async {
    try {
      final resp = await _dio.get(ApiEndpoints.offreDetail(int.parse(jobId)));
      return JobModel.fromJson(resp.data as Map<String, dynamic>).toEntity();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<JobEntity> saveJob(JobEntity job) async {
    if (_isTempId(job.id)) {
      final today = DateTime.now().toIso8601String().split('T').first;
      final safeDescription =
          (job.title.trim().isEmpty ? 'Annonce' : 'Annonce: ${job.title}');
      // Create
      final resp = await _dio.post(ApiEndpoints.offres, data: {
        'title': job.title,
        'contract_type': _contractTypeToApi(job.contractType),
        'description': safeDescription,
        'category': job.department,
        'start_date': today,
        'status': job.isPublished ? 'searching' : 'draft',
      });
      return JobModel.fromJson(resp.data as Map<String, dynamic>).toEntity();
    } else {
      // Update
      final resp = await _dio.patch(
        ApiEndpoints.offreDetail(int.parse(job.id)),
        data: {
          'title': job.title,
          'contract_type': _contractTypeToApi(job.contractType),
          'status': job.isPublished ? 'searching' : 'draft',
          'category': job.department,
        },
      );
      return JobModel.fromJson(resp.data as Map<String, dynamic>).toEntity();
    }
  }

  @override
  Future<void> deleteJob(String jobId) async {
    await _dio.delete(ApiEndpoints.offreDetail(int.parse(jobId)));
  }

  // ── Missions ─────────────────────────────────────────────────────────────────

  @override
  Future<List<MissionEntity>> getMissions() async {
    final resp = await _dio.get(ApiEndpoints.missions);
    return _results(resp.data)
        .map((m) => _parseMission(m as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MissionEntity> createMission(CreateMissionParams params) async {
    final resp = await _dio.post(ApiEndpoints.missions, data: {
      'job_id': params.jobId,
      'start_date': params.startDate.toIso8601String(),
      'end_date': params.endDate.toIso8601String(),
      'location': params.location,
      if (params.imageUrl != null) 'image_url': params.imageUrl,
    });
    return _parseMission(resp.data as Map<String, dynamic>);
  }

  @override
  Future<MissionEntity> confirmMission(String missionId) async {
    final resp = await _dio.patch(
      '${ApiEndpoints.missions}/$missionId/confirm',
    );
    return _parseMission(resp.data as Map<String, dynamic>);
  }

  @override
  Future<MissionEntity> updateMissionReview(
      String missionId, double rating, String feedback) async {
    await _dio.put(
      '${ApiEndpoints.missions}/$missionId/review',
      data: {'rating': rating.round(), 'feedback': feedback},
    );
    // Backend returns {detail: "Review submitted."} — re-fetch the mission
    final resp = await _dio.get('${ApiEndpoints.missions}/$missionId');
    return _parseMission(resp.data as Map<String, dynamic>);
  }

  // ── Search & Recent Searches ─────────────────────────────────────────────────

  @override
  Future<List<JobEntity>> searchJobs(
    String query, {
    String? category,
    List<String>? contractTypes,
  }) async {
    final params = <String, dynamic>{};
    if (query.trim().isNotEmpty) params['q'] = query.trim();
    if (category != null) params['category'] = category;
    if (contractTypes != null && contractTypes.isNotEmpty) {
      final mapped = contractTypes
          .map(_contractLabelToApi)
          .whereType<String>()
          .toList();
      if (mapped.isNotEmpty) params['contract_type'] = mapped.first;
    }
    final resp = await _dio.get(ApiEndpoints.offres, queryParameters: params);
    return _results(resp.data)
        .map((j) => JobModel.fromJson(j as Map<String, dynamic>).toEntity())
        .toList();
  }

  @override
  Future<List<String>> getRecentSearches() async {
    final resp = await _dio.get(ApiEndpoints.recentSearches);
    final data = resp.data;
    if (data is Map && data.containsKey('searches')) {
      return List<String>.from(data['searches'] as List);
    }
    return [];
  }

  @override
  Future<void> addRecentSearch(String query) async {
    await _dio.post(ApiEndpoints.recentSearchCreate, data: {'query': query});
  }

  @override
  Future<void> clearRecentSearches() async {
    await _dio.delete(ApiEndpoints.recentSearchClear);
  }

  @override
  Future<Set<String>> getSavedJobIds() async {
    final resp = await _dio.get(ApiEndpoints.savedJobIds);
    final data = resp.data;
    if (data is Map && data['saved_job_ids'] is List) {
      final ids = List<dynamic>.from(data['saved_job_ids']);
      return ids.map((e) => e.toString()).toSet();
    }
    return <String>{};
  }

  @override
  Future<List<JobEntity>> getSavedJobs() async {
    final resp = await _dio.get(ApiEndpoints.savedJobs);
    return _results(resp.data)
        .map((savedJob) {
          // Backend returns: { id, offre: {...}, saved_at }
          // We need to extract the 'offre' field
          final savedJobMap = savedJob as Map<String, dynamic>;
          final offreData = savedJobMap['offre'] as Map<String, dynamic>;
          return JobModel.fromJson(offreData).toEntity();
        })
        .toList();
  }

  @override
  Future<void> saveJobById(String jobId) async {
    await _dio.post(ApiEndpoints.savedJobs, data: {'offre_id': jobId});
  }

  @override
  Future<void> unsaveJobById(String jobId) async {
    await _dio.delete(
      ApiEndpoints.savedJobs,
      queryParameters: {'offre_id': jobId},
    );
  }

  String? _contractLabelToApi(String label) => switch (label.toLowerCase()) {
        'cdi' => 'cdi',
        'cdd' || 'mission' => 'mission',
        'freelance' => 'freelance',
        _ => null,
      };

  // ── Parsing ───────────────────────────────────────────────────────────────────

  MissionEntity _parseMission(Map<String, dynamic> json) {
    final now = DateTime.now().toIso8601String();
    return MissionModel.fromJson({
      ...json,
      'start_date': json['start_date'] ?? now,
      'end_date': json['end_date'] ?? now,
      'candidate_feedback': json['candidate_feedback'] ?? '',
      'recruiter_feedback': json['recruiter_feedback'] ?? '',
      'candidate_rating': json['candidate_rating'] ?? 0.0,
      'recruiter_rating': json['recruiter_rating'] ?? 0.0,
    }).toEntity();
  }
}

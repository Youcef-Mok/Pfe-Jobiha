import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:job_app/core/api/api_client.dart';
import 'package:job_app/core/api/api_endpoints.dart';
import 'package:job_app/features/map/domain/map_job_entity.dart';
import 'package:job_app/features/map/data/repositories/map_repository.dart';

class MapRepositoryHttp implements MapRepository {
  final Dio _dio = ApiClient.instance;

  @override
  Future<List<MapJobEntity>> getAllMapJobs({
    double? lat,
    double? lng,
    String? query,
    String? location,
    String? category,
    String? contractType,
    double? maxDistanceKm,
  }) async {
    final params = <String, dynamic>{};
    if (lat != null) params['lat'] = lat;
    if (lng != null) params['lng'] = lng;
    if (query != null && query.trim().isNotEmpty) params['q'] = query.trim();
    if (location != null && location.trim().isNotEmpty) {
      params['location'] = location.trim();
    }
    if (category != null) params['category'] = category;
    if (contractType != null) params['contract_type'] = contractType;
    if (maxDistanceKm != null) params['max_distance_km'] = maxDistanceKm;
    final resp =
        await _dio.get(ApiEndpoints.mapJobs, queryParameters: params.isEmpty ? null : params);
    final list = _results(resp.data);
    return list
        .whereType<Map<String, dynamic>>()
        .map(_parseMapJob)
        .whereType<MapJobEntity>()
        .toList();
  }

  List<dynamic> _results(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic> && data['results'] is List) {
      return data['results'] as List<dynamic>;
    }
    return const [];
  }

  @override
  Future<List<String>> getRecentSearches() async {
    final resp = await _dio.get(ApiEndpoints.recentSearches);
    final data = resp.data as Map<String, dynamic>;
    final searches = data['searches'] as List<dynamic>? ?? [];
    return searches.cast<String>();
  }

  @override
  Future<void> saveRecentSearch(String query) async {
    if (query.isEmpty) return;
    await _dio.post(ApiEndpoints.recentSearchCreate, data: {'query': query});
  }

  @override
  Future<void> clearRecentSearches() async {
    await _dio.delete(ApiEndpoints.recentSearches);
  }

  MapJobEntity? _parseMapJob(Map<String, dynamic> j) {
    final lat = _asDouble(j['lat'] ?? j['latitude']);
    final lng = _asDouble(j['lng'] ?? j['longitude']);
    if (lat == null || lng == null) return null;

    final category = (j['category'] ?? j['department'] ?? '') as String;
    final rawDistance = j['distance'];
    final distanceStr = rawDistance == null || rawDistance == 'N/A'
        ? ''
        : '${rawDistance.toString()} km';

    return MapJobEntity(
      id: (j['id'] ?? '').toString(),
      title: (j['title'] ?? '') as String,
      company: (j['company'] ?? j['company_name'] ?? '') as String,
      category: category,
      distance: distanceStr,
      city: (j['city'] ?? j['wilaya'] ?? '') as String,
      hours: (j['hours'] ?? j['schedule_label'] ?? '') as String,
      salary: _asDouble(j['salary']) ?? 0.0,
      contractType: (j['contract_type'] ?? '') as String,
      status: (j['status'] ?? 'searching').toString(),
      postedAt: _asDateTime(j['posted_at']),
      candidateCount: _asInt(j['candidate_count']),
      viewCount: _asInt(j['view_count']),
      rating: _asDouble(j['rating']) ?? 0.0,
      imageAsset: (j['image_asset'] ?? j['logo_asset']) as String?,
      recruiterAvatar:
          (j['recruiter_avatar'] ?? j['recruiter_avatar_asset']) as String?,
      recruiterName: (j['recruiter_name'] ?? j['recruiter']) as String?,
      recruiterRole: (j['recruiter_role'] ?? j['recruiter_title']) as String?,
      description: (j['description'] ?? j['summary']) as String?,
      lat: lat,
      lng: lng,
      categoryIcon: _iconForCategory(category),
    );
  }

  double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  DateTime? _asDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static IconData _iconForCategory(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('restaur') || lower.contains('food')) {
      return Icons.restaurant_outlined;
    }
    if (lower.contains('tech') || lower.contains('dev') || lower.contains('it')) {
      return Icons.code_outlined;
    }
    if (lower.contains('design')) return Icons.design_services_outlined;
    if (lower.contains('transport') || lower.contains('livr')) {
      return Icons.directions_car_outlined;
    }
    if (lower.contains('santé') || lower.contains('sante') || lower.contains('médical')) {
      return Icons.local_hospital_outlined;
    }
    if (lower.contains('éducation') || lower.contains('education') || lower.contains('forma')) {
      return Icons.school_outlined;
    }
    if (lower.contains('commerce') || lower.contains('vente')) {
      return Icons.store_outlined;
    }
    if (lower.contains('maintenance') || lower.contains('technique')) {
      return Icons.build_outlined;
    }
    return Icons.work_outline;
  }
}

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
    final resp = await _dio.get(ApiEndpoints.mapJobs, queryParameters: params.isEmpty ? null : params);
    final list = resp.data as List<dynamic>;
    return list.map((j) => _parseMapJob(j as Map<String, dynamic>)).toList();
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
    await _dio.post(ApiEndpoints.recentSearches, data: {'query': query});
  }

  @override
  Future<void> clearRecentSearches() async {
    await _dio.delete(ApiEndpoints.recentSearches);
  }

  MapJobEntity _parseMapJob(Map<String, dynamic> j) {
    final category = j['category'] as String? ?? '';
    final raw = j['distance'];
    final distanceStr = raw == null || raw == 'N/A'
        ? ''
        : '${raw.toString()} km';
    return MapJobEntity(
      id: j['id'] as String,
      title: j['title'] as String? ?? '',
      company: j['company'] as String? ?? '',
      category: category,
      distance: distanceStr,
      hours: j['hours'] as String? ?? '',
      salary: (j['salary'] as num?)?.toDouble() ?? 0.0,
      contractType: j['contract_type'] as String? ?? '',
      rating: (j['rating'] as num?)?.toDouble() ?? 0.0,
      imageAsset: j['image_asset'] as String?,
      recruiterAvatar: j['recruiter_avatar'] as String?,
      lat: (j['lat'] as num).toDouble(),
      lng: (j['lng'] as num).toDouble(),
      categoryIcon: _iconForCategory(category),
    );
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

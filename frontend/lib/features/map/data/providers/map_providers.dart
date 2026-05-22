import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/features/map/domain/map_job_entity.dart';
import 'package:job_app/features/map/domain/map_controller.dart';
import 'package:job_app/features/map/data/repositories/map_repository.dart';
import 'package:job_app/features/map/data/repositories/map_repository_http.dart';
import 'package:job_app/features/applications/data/providers/applications_provider.dart';
import 'package:job_app/features/profile/data/providers/profile_provider.dart';

// ─────────────────────────────────────────────
// 1. Repository Provider
// ─────────────────────────────────────────────
// TODO(API): Remplacer MapRepositoryMock par MapRepositoryHttp ici.
final mapRepositoryProvider = Provider<MapRepository>(
  (ref) => MapRepositoryHttp(),
);

// ─────────────────────────────────────────────
// 2. Controller Provider
// ─────────────────────────────────────────────
final mapControllerProvider = Provider<MapController>(
  (ref) => MapController(ref.watch(mapRepositoryProvider)),
);

// ─────────────────────────────────────────────
// 3. Map Jobs State — reactive to GPS, user profile, and active filters
// ─────────────────────────────────────────────
final allMapJobsProvider = FutureProvider<List<MapJobEntity>>((ref) async {
  final gps = ref.watch(userGpsPositionProvider);
  final user = ref.watch(candidateCurrentUserProvider).valueOrNull;
  final mapFilters = ref.watch(mapFiltersProvider);
  final query = ref.watch(mapSearchQueryProvider);
  final candidateFilters = ref.watch(candidateFiltersProvider);

  final lat = gps?.lat ?? user?.latitude;
  final lng = gps?.lng ?? user?.longitude;
  final location = user?.location;
  double? maxDistanceKm;
  String? category;
  String? contractType;
  if (mapFilters.containsKey('Emplacement')) {
    final raw = mapFilters['Emplacement']!;
    maxDistanceKm = double.tryParse(
      raw.replaceAll('<', '').replaceAll('km', '').trim(),
    );
  }
  if (mapFilters.containsKey('Domaine')) {
    category = mapFilters['Domaine'];
  } else if (candidateFilters.category != null &&
      candidateFilters.category!.trim().isNotEmpty) {
    category = candidateFilters.category;
  }
  if (mapFilters.containsKey('Categorie')) {
    contractType = _contractFilterToApi(mapFilters['Categorie']!);
  } else if (candidateFilters.contractTypes.isNotEmpty) {
    contractType = _contractFilterToApi(candidateFilters.contractTypes.first);
  }

  return ref.read(mapControllerProvider).fetchMapJobs(
    lat: lat,
    lng: lng,
    query: query,
    location: location,
    category: category,
    contractType: contractType,
    maxDistanceKm: maxDistanceKm,
  );
});

String? _contractFilterToApi(String label) => switch (label.toLowerCase()) {
      'cdi' => 'cdi',
      'cdd' || 'mission' => 'mission',
      'freelance' => 'freelance',
      _ => null,
    };

// ─────────────────────────────────────────────
// 4. Search & Filter State
// ─────────────────────────────────────────────
final mapSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredMapJobsProvider = Provider<List<MapJobEntity>>((ref) {
  final jobsAsync = ref.watch(allMapJobsProvider);
  final gps = ref.watch(userGpsPositionProvider);
  final user = ref.watch(candidateCurrentUserProvider).valueOrNull;
  final refLat = gps?.lat ?? user?.latitude;
  final refLng = gps?.lng ?? user?.longitude;

  return jobsAsync.when(
    data: (jobs) {
      final filtered = jobs;
      if (refLat == null || refLng == null) return filtered;
      final sorted = List<MapJobEntity>.from(filtered);
      sorted.sort((a, b) {
        final da = _distanceKm(refLat, refLng, a.lat, a.lng);
        final db = _distanceKm(refLat, refLng, b.lat, b.lng);
        return da.compareTo(db);
      });
      return sorted;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

double _distanceKm(double lat1, double lng1, double lat2, double lng2) {
  const double r = 6371.0;
  final dLat = _degToRad(lat2 - lat1);
  final dLng = _degToRad(lng2 - lng1);
  final a = (math.sin(dLat / 2) * math.sin(dLat / 2)) +
      math.cos(_degToRad(lat1)) *
          math.cos(_degToRad(lat2)) *
          (math.sin(dLng / 2) * math.sin(dLng / 2));
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return r * c;
}

double _degToRad(double deg) => deg * (3.141592653589793 / 180.0);

// ─────────────────────────────────────────────
// 5. Recent Searches State
// ─────────────────────────────────────────────
class RecentSearchesNotifier extends StateNotifier<List<String>> {
  final MapController _controller;

  RecentSearchesNotifier(this._controller) : super([]) {
    _init();
  }

  Future<void> _init() async {
    state = await _controller.fetchRecentSearches();
  }

  Future<void> addSearch(String query) async {
    await _controller.addRecentSearch(query);
    state = await _controller.fetchRecentSearches();
  }

  Future<void> clearAll() async {
    await _controller.clearHistory();
    state = [];
  }
}

final recentSearchesProvider =
    StateNotifierProvider<RecentSearchesNotifier, List<String>>((ref) {
  return RecentSearchesNotifier(ref.watch(mapControllerProvider));
});

// ─────────────────────────────────────────────
// 6. UI Selection State
// ─────────────────────────────────────────────
final selectedMapJobProvider = StateProvider<MapJobEntity?>((ref) => null);

// ─────────────────────────────────────────────
// 7. Map Filters State
// ─────────────────────────────────────────────
final mapFiltersProvider = StateProvider<Map<String, String>>((ref) => {});

final mapFilterOptions = {
  'Domaine': [
    ('Restauration', Icons.restaurant_outlined),
    ('Technologie', Icons.computer_outlined),
    ('Commerce', Icons.store_outlined),
    ('Santé', Icons.local_hospital_outlined),
    ('Éducation', Icons.school_outlined),
    ('Transport', Icons.directions_car_outlined),
  ],
  'Horaires': [
    ('Matin (6h-12h)', Icons.wb_sunny_outlined),
    ('Après-midi (12h-18h)', Icons.wb_cloudy_outlined),
    ('Soir (18h-23h)', Icons.nights_stay_outlined),
    ('Week-end', Icons.weekend_outlined),
    ('Temps partiel', Icons.access_time_outlined),
    ('Temps plein', Icons.work_outline),
  ],
  'Categorie': [
    ('CDI', Icons.article_outlined),
    ('CDD', Icons.description_outlined),
    ('Stage', Icons.school_outlined),
    ('Mission', Icons.assignment_outlined),
    ('Freelance', Icons.laptop_outlined),
  ],
  'Emplacement': [
    ('< 1 km', Icons.location_on_outlined),
    ('< 5 km', Icons.location_on_outlined),
    ('< 10 km', Icons.location_on_outlined),
    ('< 20 km', Icons.location_on_outlined),
    ('< 50 km', Icons.location_on_outlined),
  ],
};

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/features/map/domain/map_job_entity.dart';
import 'package:job_app/features/map/domain/map_controller.dart';
import 'package:job_app/features/map/data/repositories/map_repository.dart';
import 'package:job_app/features/map/data/repositories/map_repository_http.dart';
import 'package:job_app/features/applications/data/providers/applications_provider.dart';
import 'package:job_app/features/profile/data/providers/profile_provider.dart';
import 'package:job_app/features/jobs/data/repositories/jobs_repository_http.dart';
import 'package:job_app/features/jobs/domain/job_entity.dart';

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
final allMapJobsProvider = AutoDisposeFutureProvider<List<MapJobEntity>>((ref) async {
  final gps = ref.watch(userGpsPositionProvider);
  final user = ref.watch(candidateCurrentUserProvider).valueOrNull;
  final mapFilters = ref.watch(mapFiltersProvider);
  final query = ref.watch(mapSearchQueryProvider);
  final candidateFilters = ref.watch(candidateFiltersProvider);

  final lat = gps?.lat ?? user?.latitude;
  final lng = gps?.lng ?? user?.longitude;
  String? category;
  String? contractType;
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

  final jobs = await ref.read(mapControllerProvider).fetchMapJobs(
    lat: lat,
    lng: lng,
    query: query,
    category: category,
    contractType: contractType,
  );
  return _applyMapClientFilters(
    jobs,
    mapFilters: mapFilters,
    candidateFilters: candidateFilters,
    refLat: lat,
    refLng: lng,
  );
});

String? _contractFilterToApi(String label) => switch (_normalize(label)) {
      'cdi' => 'cdi',
      'cdd' || 'mission' => 'mission',
      'freelance' => 'freelance',
      _ => null,
    };

String _normalize(String value) {
  final lower = value.trim().toLowerCase();
  return lower
      .replaceAll('é', 'e')
      .replaceAll('è', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('ë', 'e')
      .replaceAll('à', 'a')
      .replaceAll('â', 'a')
      .replaceAll('ä', 'a')
      .replaceAll('î', 'i')
      .replaceAll('ï', 'i')
      .replaceAll('ô', 'o')
      .replaceAll('ö', 'o')
      .replaceAll('ù', 'u')
      .replaceAll('û', 'u')
      .replaceAll('ü', 'u')
      .replaceAll(RegExp(r'\s+'), ' ');
}

List<MapJobEntity> _applyMapClientFilters(
  List<MapJobEntity> jobs, {
  required Map<String, String> mapFilters,
  required CandidateFilters candidateFilters,
  required double? refLat,
  required double? refLng,
}) {
  var result = List<MapJobEntity>.from(jobs);

  final domain = (mapFilters['Domaine'] ?? candidateFilters.category ?? '').trim();
  if (domain.isNotEmpty) {
    final d = _normalize(domain);
    result = result.where((j) {
      final hay = _normalize('${j.category} ${j.title} ${j.company}');
      return hay.contains(d) || (d == 'technologie' && hay.contains('tech'));
    }).toList();
  }

  final contract = mapFilters['Categorie'];
  if (contract != null && contract.trim().isNotEmpty) {
    final c = _normalize(contract);
    result = result.where((j) {
      final jc = _normalize(j.contractType);
      if (c == 'cdi') return jc == 'cdi';
      if (c == 'mission' || c == 'cdd') return jc == 'mission' || jc == 'cdd';
      if (c == 'freelance') return jc == 'freelance';
      return true;
    }).toList();
  }

  final horaires = mapFilters['Horaires'];
  if (horaires != null && horaires.trim().isNotEmpty) {
    final h = _normalize(horaires);
    result = result.where((j) => _normalize(j.hours).contains(h)).toList();
  }

  final emplacement = mapFilters['Emplacement'];
  final radiusFromLabel = _radiusFromEmplacement(emplacement);
  final radius = radiusFromLabel ?? candidateFilters.locationRadiusKm;
  final centerLat = candidateFilters.locationLat ?? refLat;
  final centerLng = candidateFilters.locationLng ?? refLng;
  if (radius != null && centerLat != null && centerLng != null) {
    result = result.where((j) {
      final d = _distanceKm(centerLat, centerLng, j.lat, j.lng);
      return d <= radius;
    }).toList();
  }

  return result;
}

double? _radiusFromEmplacement(String? value) {
  if (value == null) return null;
  final n = RegExp(r'(\d+)').firstMatch(value);
  if (n == null) return null;
  return double.tryParse(n.group(1)!);
}

// ─────────────────────────────────────────────
// 4. Nearby Jobs (bottom sheet, 30 km cap)
// ─────────────────────────────────────────────
/// Dedicated provider for the "Emplois à proximité" bottom-sheet section.
/// Completely independent — queries GET /api/v1/jobs/map?max_distance_km=30.
final mapNearbyJobsProvider = AutoDisposeFutureProvider<List<MapJobEntity>>((ref) async {
  final gps = ref.watch(userGpsPositionProvider);
  final user = ref.watch(candidateCurrentUserProvider).valueOrNull;

  final lat = gps?.lat ?? user?.latitude;
  final lng = gps?.lng ?? user?.longitude;
  if (lat == null || lng == null) return [];

  final jobs = await ref.read(mapControllerProvider).fetchMapJobs(
    lat: lat,
    lng: lng,
    maxDistanceKm: 30.0,
  );

  // Sort client-side closest first
  final sorted = List<MapJobEntity>.from(jobs);
  sorted.sort((a, b) {
    final da = _distanceKm(lat, lng, a.lat, a.lng);
    final db = _distanceKm(lat, lng, b.lat, b.lng);
    return da.compareTo(db);
  });
  return sorted;
});

// ─────────────────────────────────────────────
// 5. Search & Filter State
// ─────────────────────────────────────────────
final mapSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredMapJobsProvider = Provider<List<MapJobEntity>>((ref) {
  final jobsAsync = ref.watch(allMapJobsProvider);
  final gps = ref.watch(userGpsPositionProvider);
  final user = ref.watch(candidateCurrentUserProvider).valueOrNull;
  final refLat = gps?.lat ?? user?.latitude;
  final refLng = gps?.lng ?? user?.longitude;

  return _sortByProximity(jobsAsync, refLat: refLat, refLng: refLng);
});

List<MapJobEntity> _sortByProximity(
  AsyncValue<List<MapJobEntity>> jobsAsync, {
  double? refLat,
  double? refLng,
}) {
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
}

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
// 6. Map Search Results (all published jobs, not GPS-restricted)
// ─────────────────────────────────────────────
/// Uses GET /api/v1/jobs?q=... so results are NOT limited to GPS-enabled jobs.
final mapSearchResultsProvider = AutoDisposeFutureProvider<List<JobEntity>>((ref) async {
  final query = ref.watch(mapSearchQueryProvider);
  final candidateFilters = ref.watch(candidateFiltersProvider);
  final mapFilters = ref.watch(mapFiltersProvider);

  String? category = mapFilters['Domaine'];
  category ??= candidateFilters.category;

  List<String>? contractTypes;
  final mapContract = mapFilters['Categorie'];
  if (mapContract != null && mapContract.trim().isNotEmpty) {
    contractTypes = [mapContract];
  } else if (candidateFilters.contractTypes.isNotEmpty) {
    contractTypes = candidateFilters.contractTypes;
  }

  final results = await JobsRepositoryHttp().searchJobs(
    query,
    category: category,
    contractTypes: contractTypes,
  );

  final selectedLocation = (candidateFilters.location ?? '').trim().toLowerCase();
  if (selectedLocation.isEmpty) return results;

  return results.where((job) {
    final city = (job.city ?? '').trim().toLowerCase();
    final location = (job.location ?? '').trim().toLowerCase();
    return city.contains(selectedLocation) || location.contains(selectedLocation);
  }).toList();
});

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
    AutoDisposeStateNotifierProvider<RecentSearchesNotifier, List<String>>((ref) {
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
    ('Sante', Icons.local_hospital_outlined),
    ('Education', Icons.school_outlined),
    ('Transport', Icons.directions_car_outlined),
  ],
  'Horaires': [
    ('Temps plein', Icons.work_outline),
    ('Temps partiel', Icons.access_time_outlined),
    ('Flexible', Icons.schedule_outlined),
  ],
  'Categorie': [
    ('CDI', Icons.article_outlined),
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


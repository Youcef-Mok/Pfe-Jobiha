import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/features/map/domain/map_job_entity.dart';
import 'package:job_app/features/map/domain/map_controller.dart';
import 'package:job_app/features/map/data/repositories/map_repository.dart';
import 'package:job_app/features/map/data/repositories/map_repository_mock.dart';
import 'package:job_app/features/applications/data/providers/applications_provider.dart';

// ─────────────────────────────────────────────
// 1. Repository Provider
// ─────────────────────────────────────────────
final mapRepositoryProvider = Provider<MapRepository>(
  (ref) => MapRepositoryMock(),
);

// ─────────────────────────────────────────────
// 2. Controller Provider
// ─────────────────────────────────────────────
final mapControllerProvider = Provider<MapController>(
  (ref) => MapController(ref.watch(mapRepositoryProvider)),
);

// ─────────────────────────────────────────────
// 3. Map Jobs State (AsyncNotifier or similar)
// ─────────────────────────────────────────────
final allMapJobsProvider = FutureProvider<List<MapJobEntity>>((ref) async {
  return ref.watch(mapControllerProvider).fetchMapJobs();
});

// ─────────────────────────────────────────────
// 4. Search & Filter State
// ─────────────────────────────────────────────
final mapSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredMapJobsProvider = Provider<List<MapJobEntity>>((ref) {
  final jobsAsync = ref.watch(allMapJobsProvider);
  final query = ref.watch(mapSearchQueryProvider);
  final mapFilters = ref.watch(mapFiltersProvider);
  final candidateFilters = ref.watch(candidateFiltersProvider);
  final controller = ref.watch(mapControllerProvider);

  return jobsAsync.when(
    data: (jobs) {
      var result = controller.filterJobs(jobs, query);

      // --- FILTRES GLOBAUX (CandidateFilters) ---

      // Catégorie (Domaine)
      if (candidateFilters.category != null) {
        final cat = candidateFilters.category!.toLowerCase();
        result = result
            .where((j) => j.category.toLowerCase().contains(cat))
            .toList();
      }

      // Types de contrat
      if (candidateFilters.contractTypes.isNotEmpty) {
        result = result
            .where((j) => candidateFilters.contractTypes.contains(j.contractType))
            .toList();
      }

      // Localisation (recherche textuelle simple sur la ville/commune si disponible)
      if (candidateFilters.location != null) {
        // Pour la démo, on considère que si la localisation est fixée, on peut filtrer (si l'entité avait un champ ville)
        // Ici on n'a pas de champ ville explicite dans MapJobEntity, mais on peut imaginer une logique
      }

      // --- FILTRES SPÉCIFIQUES CARTE ---

      // Filtre Categorie → contractType
      if (mapFilters.containsKey('Categorie')) {
        final cat = mapFilters['Categorie']!;
        result = result.where((j) => j.contractType == cat).toList();
      }

      // Filtre Domaine → category
      if (mapFilters.containsKey('Domaine')) {
        final dom = mapFilters['Domaine']!;
        result = result
            .where(
              (j) => j.category.toLowerCase().contains(dom.toLowerCase()),
            )
            .toList();
      }

      // Filtre Horraires → hours
      if (mapFilters.containsKey('Horaires')) {
        final hours = mapFilters['Horaires']!;
        result = result.where((j) => j.hours.contains(hours)).toList();
      }

      // Filtre Emplacement → distance
      if (mapFilters.containsKey('Emplacement')) {
        final limitStr = mapFilters['Emplacement']!; // e.g. "< 10 km"
        final limit = double.tryParse(
          limitStr.replaceAll('<', '').replaceAll('km', '').trim(),
        );
        if (limit != null) {
          result = result.where((j) {
            final dist = double.tryParse(
              j.distance.replaceAll('km', '').trim(),
            );
            return dist != null && dist <= limit;
          }).toList();
        }
      }

      return result;
    },
    loading: () => [],
    error: (_, __) => [],
  );
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

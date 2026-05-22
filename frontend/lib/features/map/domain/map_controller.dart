import 'package:job_app/features/map/domain/map_job_entity.dart';
import 'package:job_app/features/map/data/repositories/map_repository.dart';

class MapController {
  final MapRepository _repository;

  MapController(this._repository);

  Future<List<MapJobEntity>> fetchMapJobs({
    double? lat,
    double? lng,
    String? query,
    String? location,
    String? category,
    String? contractType,
    double? maxDistanceKm,
  }) {
    return _repository.getAllMapJobs(
      lat: lat,
      lng: lng,
      query: query,
      location: location,
      category: category,
      contractType: contractType,
      maxDistanceKm: maxDistanceKm,
    );
  }

  Future<List<String>> fetchRecentSearches() {
    return _repository.getRecentSearches();
  }

  Future<void> addRecentSearch(String query) {
    return _repository.saveRecentSearch(query);
  }

  Future<void> clearHistory() {
    return _repository.clearRecentSearches();
  }

  List<MapJobEntity> filterJobs(List<MapJobEntity> jobs, String query) {
    if (query.isEmpty) return jobs;
    final q = _normalize(query);
    return jobs.where((j) => 
      _normalize(j.title).contains(q) || 
      _normalize(j.company).contains(q)
    ).toList();
  }

  /// Applique recherche + filtres carte + filtres candidat globaux.
  /// TODO(API): GET /api/v1/map/jobs?q=&category=&contract_type=&...
  List<MapJobEntity> applyMapFilters({
    required List<MapJobEntity> jobs,
    required String searchQuery,
    required Map<String, String> mapFilters,
    String? candidateCategory,
    List<String> candidateContractTypes = const [],
  }) {
    var result = filterJobs(jobs, searchQuery);

    if (candidateCategory != null) {
      final cat = _normalize(candidateCategory);
      result = result
          .where((j) => _normalize(j.category).contains(cat))
          .toList();
    }

    if (candidateContractTypes.isNotEmpty) {
      final selectedContracts = candidateContractTypes
          .map(_contractLabelToApi)
          .whereType<String>()
          .toSet();
      result = result
          .where((j) => selectedContracts.contains(_normalize(j.contractType)))
          .toList();
    }

    if (mapFilters.containsKey('Categorie')) {
      final cat = _contractLabelToApi(mapFilters['Categorie']!);
      if (cat != null) {
        result = result
            .where((j) => _normalize(j.contractType) == cat)
            .toList();
      }
    }

    if (mapFilters.containsKey('Domaine')) {
      final dom = _normalize(mapFilters['Domaine']!);
      result = result
          .where((j) => _normalize(j.category).contains(dom))
          .toList();
    }

    if (mapFilters.containsKey('Horaires')) {
      final hours = _normalize(mapFilters['Horaires']!);
      result = result
          .where((j) => _normalize(j.hours).contains(hours))
          .toList();
    }

    if (mapFilters.containsKey('Emplacement')) {
      final limitStr = mapFilters['Emplacement']!;
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
  }

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

  String? _contractLabelToApi(String label) {
    final v = _normalize(label);
    return switch (v) {
      'cdi' => 'cdi',
      'cdd' || 'mission' => 'mission',
      'freelance' => 'freelance',
      _ => null,
    };
  }
}

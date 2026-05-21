import 'package:job_app/features/map/domain/map_job_entity.dart';
import 'package:job_app/features/map/data/repositories/map_repository.dart';

class MapController {
  final MapRepository _repository;

  MapController(this._repository);

  Future<List<MapJobEntity>> fetchMapJobs() {
    return _repository.getAllMapJobs();
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
    final q = query.toLowerCase();
    return jobs.where((j) => 
      j.title.toLowerCase().contains(q) || 
      j.company.toLowerCase().contains(q)
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
      final cat = candidateCategory.toLowerCase();
      result = result
          .where((j) => j.category.toLowerCase().contains(cat))
          .toList();
    }

    if (candidateContractTypes.isNotEmpty) {
      result = result
          .where((j) => candidateContractTypes.contains(j.contractType))
          .toList();
    }

    if (mapFilters.containsKey('Categorie')) {
      final cat = mapFilters['Categorie']!;
      result = result.where((j) => j.contractType == cat).toList();
    }

    if (mapFilters.containsKey('Domaine')) {
      final dom = mapFilters['Domaine']!;
      result = result
          .where((j) => j.category.toLowerCase().contains(dom.toLowerCase()))
          .toList();
    }

    if (mapFilters.containsKey('Horaires')) {
      final hours = mapFilters['Horaires']!;
      result = result.where((j) => j.hours.contains(hours)).toList();
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
}

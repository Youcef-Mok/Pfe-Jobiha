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
}

import 'package:job_app/features/map/domain/map_job_entity.dart';

abstract class MapRepository {
  Future<List<MapJobEntity>> getAllMapJobs();
  Future<List<String>> getRecentSearches();
  Future<void> saveRecentSearch(String query);
  Future<void> clearRecentSearches();
}

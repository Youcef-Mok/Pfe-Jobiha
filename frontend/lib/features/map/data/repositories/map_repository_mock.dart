import 'package:flutter/material.dart';
import 'package:job_app/features/map/domain/map_job_entity.dart';
import 'package:job_app/features/map/data/repositories/map_repository.dart';

// TODO(API): Remplacer par MapRepositoryHttp dans map_providers.dart.
class MapRepositoryMock implements MapRepository {
  final List<MapJobEntity> _mockJobs = [
    const MapJobEntity(
      id: '1',
      title: 'UI/UX Designer',
      company: 'Tech Studio',
      category: 'Design',
      distance: '2.5 km',
      hours: '9h - 17h',
      salary: 45,
      contractType: 'CDI',
      rating: 4.8,
      imageAsset: 'assets/images/imageannonc(1).jpg',
      recruiterAvatar: 'assets/images/pdp_1.png',
      lat: 36.765,
      lng: 3.048,
      categoryIcon: Icons.design_services_outlined,
    ),
    const MapJobEntity(
      id: '2',
      title: 'Serveur(se)',
      company: 'Le Petit Bistro',
      category: 'Restauration',
      distance: '1.2 km',
      hours: '18h - 23h',
      salary: 28,
      contractType: 'CDD',
      rating: 4.9,
      imageAsset: 'assets/images/imageannonc(2).jpg',
      recruiterAvatar: 'assets/images/pdp_4.png',
      lat: 36.758,
      lng: 3.031,
      categoryIcon: Icons.restaurant_outlined,
    ),
    const MapJobEntity(
      id: '3',
      title: 'Maintenance',
      company: 'Quick Fix',
      category: 'Technique',
      distance: '3.1 km',
      hours: '8h - 16h',
      salary: 35,
      contractType: 'Mission',
      rating: 4.5,
      imageAsset: 'assets/images/imageannonc(3).jpg',
      recruiterAvatar: 'assets/images/pdp_new.png',
      lat: 36.762,
      lng: 3.055,
      categoryIcon: Icons.build_outlined,
    ),
    const MapJobEntity(
      id: '4',
      title: 'Développeur Flutter',
      company: 'TechCorp',
      category: 'Tech',
      distance: '4.0 km',
      hours: '9h - 18h',
      salary: 60,
      contractType: 'Freelance',
      rating: 5.0,
      imageAsset: 'assets/images/imageannonc(4).jpg',
      recruiterAvatar: 'assets/images/pdp_2.png',
      lat: 36.770,
      lng: 3.042,
      categoryIcon: Icons.code_outlined,
    ),
  ];

  final List<String> _recentSearches = [
    'Développeur Fullstack',
    'serveur en salle',
    'Developper frontend',
  ];

  @override
  Future<List<MapJobEntity>> getAllMapJobs() async {
    // TODO(API): GET /api/v1/jobs/map?lat=&lng=&radius=  (retourne les offres géolocalisées)
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockJobs;
  }

  @override
  Future<List<String>> getRecentSearches() async {
    // TODO(API): GET /api/v1/users/me/recent-searches  (ou stockage local SharedPreferences)
    return _recentSearches;
  }

  @override
  Future<void> saveRecentSearch(String query) async {
    // TODO(API): POST /api/v1/users/me/recent-searches  body: { query }
    if (query.isEmpty) return;
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 10) _recentSearches.removeLast();
  }

  @override
  Future<void> clearRecentSearches() async {
    // TODO(API): DELETE /api/v1/users/me/recent-searches
    _recentSearches.clear();
  }
}

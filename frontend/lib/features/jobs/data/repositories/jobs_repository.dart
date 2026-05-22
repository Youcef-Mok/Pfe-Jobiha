import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/features/jobs/domain/mission_entity.dart';
import 'package:job_app/features/jobs/domain/create_mission_params.dart';
// features/candidates/data/repositories/candidates_repository.dart

/// Interface abstraite du repository.
/// Permet de swapper facilement mock → vraie API sans toucher au reste.
abstract class JobsRepository {
  /// Retourne tous les jobs de l'employeur authentifié
  Future<List<JobEntity>> getMyJobs();

  /// Retourne toutes les offres publiées (feed candidat), avec filtres optionnels
  Future<List<JobEntity>> getAllJobs({
    double? lat,
    double? lng,
    double? maxDistanceKm,
    String? location,
    String? category,
    String? contractType,
  });

  /// Sauvegarde (création ou mise à jour) d'un job
  Future<JobEntity> saveJob(JobEntity job);

  /// Supprime un job par son ID
  Future<void> deleteJob(String jobId);

  /// Récupère un job par son ID
  Future<JobEntity?> getJobById(String jobId);

  /// Retourne les missions de l'utilisateur
  Future<List<MissionEntity>> getMissions();

  /// Crée une mission (statut non confirmée).
  Future<MissionEntity> createMission(CreateMissionParams params);

  /// Confirme une mission non confirmée → en cours.
  Future<MissionEntity> confirmMission(String missionId);

  /// Met à jour une mission avec le review du candidat
  Future<MissionEntity> updateMissionReview(String missionId, double rating, String feedback);

  /// Recherche serveur d'offres publiées (feed candidat)
  Future<List<JobEntity>> searchJobs(String query, {String? category, List<String>? contractTypes});

  /// Récupère les recherches récentes de l'utilisateur connecté
  Future<List<String>> getRecentSearches();

  /// Enregistre une nouvelle recherche récente
  Future<void> addRecentSearch(String query);

  /// Efface toutes les recherches récentes
  Future<void> clearRecentSearches();

  /// IDs des offres sauvegardées pour l'utilisateur connecté.
  Future<Set<String>> getSavedJobIds();

  /// Liste complète des offres sauvegardées pour l'utilisateur connecté.
  Future<List<JobEntity>> getSavedJobs();

  /// Sauvegarde une offre.
  Future<void> saveJobById(String jobId);

  /// Retire une offre des sauvegardes.
  Future<void> unsaveJobById(String jobId);
}


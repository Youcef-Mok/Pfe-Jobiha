import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/features/jobs/domain/mission_entity.dart';
import 'package:job_app/features/jobs/domain/create_mission_params.dart';
// features/candidates/data/repositories/candidates_repository.dart

/// Interface abstraite du repository.
/// Permet de swapper facilement mock → vraie API sans toucher au reste.
abstract class JobsRepository {
  /// Retourne tous les jobs de l'employeur authentifié
  Future<List<JobEntity>> getMyJobs();

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
}


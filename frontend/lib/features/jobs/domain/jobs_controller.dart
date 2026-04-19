import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/features/jobs/domain/mission_entity.dart';
import 'package:job_app/features/jobs/data/repositories/jobs_repository.dart';

/// Couche domaine : contient TOUTE la logique métier.
/// Ne connaît ni Flutter ni Riverpod — uniquement des entités et un repository.
class JobsController {
  final JobsRepository _repository;

  JobsController(this._repository);

  /// Récupère tous les jobs de l'employeur courant
  Future<List<JobEntity>> fetchMyJobs() async {
    return _repository.getMyJobs();
  }

  /// Récupère toutes les missions de l'utilisateur courant
  Future<List<MissionEntity>> fetchMissions() async {
    return _repository.getMissions();
  }

  /// Filtre les jobs actifs
  List<JobEntity> filterActive(List<JobEntity> jobs) =>
      jobs.where((j) => j.status == JobStatus.searching).toList();

  /// Filtre les brouillons
  List<JobEntity> filterDrafts(List<JobEntity> jobs) =>
      jobs.where((j) => j.status == JobStatus.draft).toList();

  /// Sauvegarde un job (brouillon → actif, ou création)
  Future<JobEntity> saveJob(JobEntity job) async {
    return _repository.saveJob(job);
  }

  /// Supprime un job
  Future<void> deleteJob(String jobId) async {
    return _repository.deleteJob(jobId);
  }

  /// Crée un job à partir du formulaire (statut brouillon par défaut)
  Future<JobEntity> createJob(CreateJobForm form) async {
    final job = JobEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // ID temporaire
      title: form.title,
      companyName:
          'Ma Super Entreprise', // TODO: Récupérer depuis le user profile
      contractType: form.contractType, // Ajouté
      postedAt: DateTime.now(),
      status: JobStatus.draft,
      candidateCount: 0,
      viewCount: 0,
      isPublished: false,
    );
    return _repository.saveJob(job);
  }

  /// Publie un job
  Future<JobEntity> publishJob(JobEntity draft) async {
    final published = JobEntity(
      id: draft.id,
      title: draft.title,
      companyName: draft.companyName,
      contractType: draft.contractType, // Ajouté
      postedAt: DateTime.now(),
      status: JobStatus.searching,
      candidateCount: draft.candidateCount,
      viewCount: draft.viewCount,
      isPublished: true,
      logoAsset: draft.logoAsset,
    );
    return _repository.saveJob(published);
  }

  /// Met à jour un job existant depuis le formulaire d'édition
  Future<JobEntity> updateJob(EditJobForm form) async {
    // On récupère l'entité existante pour ne pas écraser ses champs non édités
    final existing = await _repository.getJobById(form.id);
    final updated = JobEntity(
      id: form.id,
      title: form.title.trim(),
      companyName: existing?.companyName ?? '',
      contractType: form.contractType, // Ajouté
      postedAt: existing?.postedAt ?? DateTime.now(),
      status: existing?.status ?? JobStatus.searching,
      candidateCount: form.candidateCount ?? existing?.candidateCount ?? 0,
      viewCount: existing?.viewCount ?? 0,
      logoAsset: form.imageAsset ?? existing?.logoAsset,
      isPublished: !form.isPrivate,
    );
    return _repository.saveJob(updated);
  }

  /// Calcule le total de candidatures
  int totalCandidates(List<JobEntity> jobs) =>
      jobs.fold(0, (sum, j) => sum + j.candidateCount);
}

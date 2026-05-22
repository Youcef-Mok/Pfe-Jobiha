import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/features/jobs/domain/mission_entity.dart';
import 'package:job_app/features/jobs/domain/create_mission_params.dart';
import 'package:job_app/features/jobs/domain/recruiter_filters.dart';
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

  /// Récupère toutes les offres publiées (feed candidat)
  Future<List<JobEntity>> fetchAllJobs() async {
    return _repository.getAllJobs();
  }

  /// Récupère les offres proches de l'utilisateur (par GPS ou wilaya)
  Future<List<JobEntity>> fetchNearbyJobs({
    double? lat,
    double? lng,
    String? location,
    String? category,
    String? contractType,
  }) {
    final hasGps = lat != null && lng != null;
    return _repository.getAllJobs(
      lat: hasGps ? lat : null,
      lng: hasGps ? lng : null,
      maxDistanceKm: hasGps ? 30.0 : null,
      location: hasGps ? null : location,
      category: category,
      contractType: contractType,
    );
  }

  /// Récupère toutes les missions de l'utilisateur courant (purge auto des non confirmées expirées).
  Future<List<MissionEntity>> fetchMissions() async {
    return _repository.getMissions();
  }

  Future<MissionEntity> createMission(CreateMissionParams params) =>
      _repository.createMission(params);

  Future<MissionEntity> confirmMission(String missionId) =>
      _repository.confirmMission(missionId);

  /// Filtre les jobs actifs
  List<JobEntity> filterActive(List<JobEntity> jobs) =>
      jobs.where((j) => j.status == JobStatus.searching).toList();

  /// Filtre les brouillons
  List<JobEntity> filterDrafts(List<JobEntity> jobs) =>
      jobs.where((j) => j.status == JobStatus.draft).toList();

  /// Filtre les annonces recruteur (statut, date de publication, département).
  List<JobEntity> filterJobs(List<JobEntity> jobs, RecruiterFilters filters) {
    if (filters.isEmpty) return jobs;
    return jobs.where((j) {
      if (filters.department != null && j.department != filters.department) {
        return false;
      }
      if (filters.status != null &&
          _jobStatusLabel(j.status) != filters.status) {
        return false;
      }
      if (!RecruiterFilterDates.matchesPostedWithin(
          j.postedAt, filters.dateFilter)) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Filtre les missions (statut, durée, département).
  List<MissionEntity> filterMissions(
    List<MissionEntity> missions,
    RecruiterFilters filters,
  ) {
    if (filters.isEmpty) return missions;
    return missions.where((m) {
      if (filters.jobId != null && m.jobId != filters.jobId) {
        return false;
      }
      if (filters.department != null && m.department != filters.department) {
        return false;
      }
      if (filters.status != null &&
          _missionStatusLabel(m) != filters.status) {
        return false;
      }
      if (!RecruiterFilterDates.matchesMissionDuration(
          m.startDate, m.endDate, filters.dateFilter)) {
        return false;
      }
      return true;
    }).toList();
  }

  String _jobStatusLabel(JobStatus status) => switch (status) {
        JobStatus.draft => 'Brouillon',
        JobStatus.searching => 'Publié',
        JobStatus.closed => 'Terminé',
      };

  String _missionStatusLabel(MissionEntity mission) => switch (mission.status) {
        'unconfirmed' => 'Non confirmée',
        'completed' => 'Terminé',
        'in_progress' => 'En cours',
        _ => 'En cours',
      };

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
      companyName: 'Le Petit Bistro', // TODO(API): injecter depuis /users/me
      recruiterId: 'recruiter_1',
      recruiterName: 'Ahmed Bensalem',
      recruiterRole: 'Responsable RH',
      recruiterAvatarAsset: 'assets/images/pdp_1.png',
      contractType: form.contractType, // Ajouté
      postedAt: DateTime.now(),
      status: JobStatus.draft,
      candidateCount: 0,
      viewCount: 0,
      isPublished: false,
    );
    return _repository.saveJob(
      job,
      imageBytes: form.imageBytes,
      imageFileName: form.imageFileName,
    );
  }

  /// Publie un job
  Future<JobEntity> publishJob(JobEntity draft) async {
    final published = JobEntity(
      id: draft.id,
      title: draft.title,
      companyName: draft.companyName,
      recruiterId: draft.recruiterId,
      recruiterName: draft.recruiterName,
      recruiterRole: draft.recruiterRole,
      recruiterAvatarAsset: draft.recruiterAvatarAsset,
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
      recruiterId: existing?.recruiterId ?? 'recruiter_1',
      recruiterName: existing?.recruiterName ?? 'Ahmed Bensalem',
      recruiterRole: existing?.recruiterRole ?? 'Responsable RH',
      recruiterAvatarAsset: existing?.recruiterAvatarAsset,
      department: existing?.department ?? 'IT',
      contractType: form.contractType, // Ajouté
      postedAt: existing?.postedAt ?? DateTime.now(),
      status: existing?.status ?? JobStatus.searching,
      candidateCount: form.candidateCount ?? existing?.candidateCount ?? 0,
      viewCount: existing?.viewCount ?? 0,
      logoAsset: form.imageAsset ?? existing?.logoAsset,
      isPublished: !form.isPrivate,
    );
    return _repository.saveJob(
      updated,
      imageBytes: form.imageBytes,
      imageFileName: form.imageFileName,
    );
  }

  /// Annonces publiées (feed candidat).
  /// TODO(API): GET /api/v1/jobs?published=true
  List<JobEntity> filterPublished(List<JobEntity> jobs) =>
      jobs.where((j) => j.isPublished).toList();

  /// Recherche texte sur annonces publiées.
  /// TODO(API): GET /api/v1/jobs?published=true&q=
  List<JobEntity> searchPublished(List<JobEntity> jobs, String query) {
    final published = filterPublished(jobs);
    if (query.trim().isEmpty) return published;
    final q = query.toLowerCase();
    return published
        .where((j) => j.title.toLowerCase().contains(q))
        .toList();
  }

  /// Filtres chips — jobs enregistrés (candidat).
  /// TODO(API): GET /api/v1/users/me/saved-jobs + query params filtres
  List<JobEntity> filterSavedJobs(
    List<JobEntity> jobs,
    Map<String, List<String>> selectedValues,
  ) {
    return jobs.where((job) {
      final contracts = selectedValues['contrat'] ?? [];
      if (contracts.isNotEmpty) {
        final matchesContract = contracts.any((contract) {
          return switch (contract.toLowerCase()) {
            'cdi' => job.contractType == ContractType.cdi,
            'cdd' => job.contractType == ContractType.mission,
            'freelance' => job.contractType == ContractType.freelance,
            _ => true,
          };
        });
        if (!matchesContract) return false;
      }

      for (final cat in ['horraires', 'categorie', 'localisation', 'domaine']) {
        final options = selectedValues[cat] ?? [];
        if (options.isNotEmpty) {
          final haystack = '${job.title} ${job.companyName}'.toLowerCase();
          final matchesCat =
              options.any((opt) => haystack.contains(opt.toLowerCase()));
          if (!matchesCat) return false;
        }
      }
      return true;
    }).toList();
  }

  /// Tri jobs enregistrés selon chip actif.
  List<JobEntity> sortSavedJobs(
    List<JobEntity> jobs,
    String chip,
  ) {
    final sorted = [...jobs];
    switch (chip) {
      case 'categorie':
        sorted.sort((a, b) => a.title.compareTo(b.title));
        return sorted;
      case 'contrat':
        sorted.sort(
            (a, b) => a.contractType.index.compareTo(b.contractType.index));
        return sorted;
      case 'localisation':
        sorted.sort((a, b) => a.companyName.compareTo(b.companyName));
        return sorted;
      case 'domaine':
        sorted.sort((a, b) => b.viewCount.compareTo(a.viewCount));
        return sorted;
      case 'horraires':
      default:
        sorted.sort((a, b) => b.postedAt.compareTo(a.postedAt));
        return sorted;
    }
  }

  /// Calcule le total de candidatures
  int totalCandidates(List<JobEntity> jobs) =>
      jobs.fold(0, (sum, j) => sum + j.candidateCount);

  /// Met à jour une mission avec le review du candidat
  Future<MissionEntity> updateMissionReview(String missionId, double rating, String feedback) async {
    return _repository.updateMissionReview(missionId, rating, feedback);
  }
  Future<JobCommentEntity> addJobComment(String jobId, String question) async {
    return _repository.addJobComment(jobId, question);
  }
}

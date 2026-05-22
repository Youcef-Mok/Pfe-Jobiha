import 'package:job_app/features/applications/domain/application_entity.dart';
import 'package:job_app/features/applications/data/repositories/applications_repository.dart';
import 'package:job_app/features/jobs/domain/recruiter_filters.dart';

enum ApplicationsTabFilter { all, pending, accepted, rejected }

// TODO(API): Toutes les méthodes de ce contrôleur passent par ApplicationsRepository.
//            Pour brancher le backend, remplace ApplicationsRepositoryMock par
//            ApplicationsRepositoryHttp dans applications_provider.dart.
//            Endpoints attendus :
//              GET    /api/applications          → getMyApplications()
//              POST   /api/applications          → applyToJob()
//              DELETE /api/applications/:id      → cancelApplication()
//              PUT    /api/applications/:id/accept → acceptApplication()
//              PUT    /api/applications/:id/reject → rejectApplication()

class ApplicationsController {
  final ApplicationsRepository _repository;

  ApplicationsController(this._repository);

  Future<List<ApplicationEntity>> fetchApplications() =>
      _repository.getMyApplications();

  Future<ApplicationEntity> apply(
    String jobId, {
    String? motivationLetter,
  }) =>
      _repository.applyToJob(jobId, motivationLetter: motivationLetter);

  Future<void> cancel(String applicationId) =>
      _repository.cancelApplication(applicationId);

  Future<void> accept(String applicationId) =>
      _repository.acceptApplication(applicationId);

  Future<void> reject(String applicationId) =>
      _repository.rejectApplication(applicationId);

  List<ApplicationEntity> filterByStatus(
    List<ApplicationEntity> apps,
    ApplicationStatus status,
  ) =>
      apps.where((a) => a.status == status).toList();

  /// Filtre par onglet (écran candidat « Mes candidatures »).
  /// TODO(API): mapper vers `?status=` sur GET /api/v1/applications
  List<ApplicationEntity> filterByTab(
    List<ApplicationEntity> apps,
    ApplicationsTabFilter tab,
  ) =>
      switch (tab) {
        ApplicationsTabFilter.all => apps,
        ApplicationsTabFilter.pending => filterByStatus(apps, ApplicationStatus.pending),
        ApplicationsTabFilter.accepted =>
          filterByStatus(apps, ApplicationStatus.accepted),
        ApplicationsTabFilter.rejected =>
          filterByStatus(apps, ApplicationStatus.rejected),
      };

  /// Tri overlay candidat (recent | proche | mieux_paye).
  /// TODO(API): mapper vers `?sort=` sur GET /api/v1/applications
  List<ApplicationEntity> sortByOverlay(
    List<ApplicationEntity> apps,
    String overlayFilter,
  ) {
    final sorted = [...apps];
    switch (overlayFilter) {
      case 'proche':
        sorted.sort((a, b) => a.location.compareTo(b.location));
        return sorted;
      case 'mieux_paye':
        sorted.sort((a, b) {
          final byStatus =
              _statusPriority(a.status) - _statusPriority(b.status);
          if (byStatus != 0) return byStatus;
          return b.appliedAt.compareTo(a.appliedAt);
        });
        return sorted;
      case 'recent':
      default:
        sorted.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
        return sorted;
    }
  }

  /// Chaîne filtre onglet + tri (provider `candidateApplicationsListProvider`).
  List<ApplicationEntity> applyCandidateListFilters({
    required List<ApplicationEntity> apps,
    required ApplicationsTabFilter tab,
    required String overlayFilter,
  }) =>
      sortByOverlay(filterByTab(apps, tab), overlayFilter);

  int _statusPriority(ApplicationStatus status) => switch (status) {
        ApplicationStatus.accepted => 0,
        ApplicationStatus.pending => 1,
        ApplicationStatus.rejected => 2,
      };

  List<ApplicationEntity> forJob(
    List<ApplicationEntity> apps,
    String jobId,
  ) {
    final list = apps.where((a) => a.jobId == jobId).toList()
      ..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
    return list;
  }

  List<ApplicationEntity> filterByRecruiterFilters(
    List<ApplicationEntity> apps,
    RecruiterFilters filters, {
    Set<String> savedIds = const {},
  }) {
    if (filters.isEmpty) return apps;
    return apps.where((a) {
      if (filters.savedOnly && !savedIds.contains(a.id)) {
        return false;
      }
      if (filters.jobId != null && a.jobId != filters.jobId) {
        return false;
      }
      if (filters.department != null && a.department != filters.department) {
        return false;
      }
      if (filters.status != null && a.statusLabel != filters.status) {
        return false;
      }
      if (!RecruiterFilterDates.matchesAppliedAt(
          a.appliedAt, filters.dateFilter)) {
        return false;
      }
      return true;
    }).toList();
  }

  List<ApplicationEntity> filterRecent(List<ApplicationEntity> apps) {
    return apps
        .where((a) => 
          a.status == ApplicationStatus.pending || 
          a.status == ApplicationStatus.accepted
        )
        .toList()
      ..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
  }
}

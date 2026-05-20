import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/features/applications/domain/application_entity.dart';
import 'package:job_app/features/applications/domain/applications_controller.dart';
import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/features/applications/data/repositories/applications_repository.dart';
import 'package:job_app/features/applications/data/repositories/applications_repository_mock.dart';
import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';

// ─────────────────────────────────────────────
// 1. Repository Provider
// ─────────────────────────────────────────────
// TODO(API): Remplacer ApplicationsRepositoryMock par ApplicationsRepositoryHttp ici.
final applicationsRepositoryProvider = Provider<ApplicationsRepository>(
  (ref) => ApplicationsRepositoryMock(),
);

// ─────────────────────────────────────────────
// 2. Controller Provider
// ─────────────────────────────────────────────
final applicationsControllerProvider = Provider<ApplicationsController>(
  (ref) => ApplicationsController(ref.watch(applicationsRepositoryProvider)),
);

// ─────────────────────────────────────────────
// 3. Applications Notifier
// ─────────────────────────────────────────────
class ApplicationsNotifier
    extends StateNotifier<AsyncValue<List<ApplicationEntity>>> {
  final ApplicationsController _controller;

  ApplicationsNotifier(this._controller) : super(const AsyncValue.loading()) {
    Future.microtask(() => fetch());
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final apps = await _controller.fetchApplications();
      state = AsyncValue.data(apps);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> apply(String jobId) async {
    try {
      await _controller.apply(jobId);
      await fetch();
    } catch (_) {}
  }

  Future<void> cancel(String applicationId) async {
    try {
      await _controller.cancel(applicationId);
      await fetch();
    } catch (_) {}
  }

  Future<void> accept(String applicationId) async {
    try {
      await _controller.accept(applicationId);
      await fetch();
    } catch (_) {}
  }

  Future<void> reject(String applicationId) async {
    try {
      await _controller.reject(applicationId);
      await fetch();
    } catch (_) {}
  }
}

final applicationsNotifierProvider = StateNotifierProvider<ApplicationsNotifier,
    AsyncValue<List<ApplicationEntity>>>(
  (ref) => ApplicationsNotifier(ref.watch(applicationsControllerProvider)),
);

class SavedApplicationsNotifier extends StateNotifier<Set<String>> {
  SavedApplicationsNotifier() : super({});

  void toggle(String applicationId) {
    if (state.contains(applicationId)) {
      state = {...state}..remove(applicationId);
    } else {
      state = {...state, applicationId};
    }
  }

  bool isSaved(String applicationId) => state.contains(applicationId);
}

final savedApplicationsProvider =
    StateNotifierProvider<SavedApplicationsNotifier, Set<String>>(
  (ref) => SavedApplicationsNotifier(),
);

/// Candidatures filtrées — homepage recruteur (onglet Mes candidatures).
final recruiterFilteredApplicationsProvider =
    Provider<AsyncValue<List<ApplicationEntity>>>((ref) {
  final appsAsync = ref.watch(applicationsNotifierProvider);
  final filters = ref.watch(recruiterFiltersProvider);
  final controller = ref.watch(applicationsControllerProvider);
  final savedIds = ref.watch(savedApplicationsProvider);
  return appsAsync.whenData(
    (apps) => controller.filterByRecruiterFilters(
      apps,
      filters,
      savedIds: savedIds,
    ),
  );
});

/// Candidatures d'une offre — détail annonce (triées par date).
final jobDetailApplicationsProvider =
    Provider.family<AsyncValue<List<ApplicationEntity>>, String>((ref, jobId) {
  final appsAsync = ref.watch(applicationsNotifierProvider);
  final controller = ref.watch(applicationsControllerProvider);
  return appsAsync.whenData((apps) => controller.forJob(apps, jobId));
});

/// Liste candidat — onglet + tri overlay (écran Mes candidatures).
final candidateApplicationsListProvider =
    Provider<AsyncValue<List<ApplicationEntity>>>((ref) {
  final appsAsync = ref.watch(applicationsNotifierProvider);
  final tab = ref.watch(applicationsTabProvider);
  final overlay = ref.watch(applicationsOverlayFilterProvider);
  final controller = ref.watch(applicationsControllerProvider);
  return appsAsync.whenData(
    (apps) => controller.applyCandidateListFilters(
      apps: apps,
      tab: tab,
      overlayFilter: overlay,
    ),
  );
});

// ─────────────────────────────────────────────
// 3. Applications Tab Filter (état UI)
// ─────────────────────────────────────────────
final applicationsTabProvider =
    StateProvider<ApplicationsTabFilter>((ref) => ApplicationsTabFilter.all);
final applicationsOverlayFilterProvider =
    StateProvider<String>((ref) => 'recent');
final savedJobsOverlayFilterProvider = StateProvider<String>((ref) => 'recent');
final savedJobsActiveChipProvider = StateProvider<String>((ref) => 'horraires');
final savedJobsFilterValuesProvider = StateProvider<Map<String, List<String>>>(
  (ref) => {
    'horraires': [],
    'categorie': [],
    'contrat': [],
    'localisation': [],
    'domaine': [],
  },
);

// ─────────────────────────────────────────────
// 4. Saved Jobs Provider (list of jobIds)
// ─────────────────────────────────────────────
class SavedJobsNotifier extends StateNotifier<Set<String>> {
  // TODO(API): GET /api/v1/users/me/saved-jobs — remplacer les IDs hardcodés par un fetch au démarrage
  SavedJobsNotifier() : super({'4', '5'});

  void toggle(String jobId) {
    if (state.contains(jobId)) {
      state = {...state}..remove(jobId);
    } else {
      state = {...state, jobId};
    }
  }

  bool isSaved(String jobId) => state.contains(jobId);
}

final savedJobsProvider =
    StateNotifierProvider<SavedJobsNotifier, Set<String>>(
  (ref) => SavedJobsNotifier(),
);

// ─────────────────────────────────────────────
// 5. Candidate Filters Provider
// ─────────────────────────────────────────────
class CandidateFilters {
  final String? category;
  final List<String> availability;
  final String? location;
  final List<String> contractTypes;

  const CandidateFilters({
    this.category,
    this.availability = const [],
    this.location,
    this.contractTypes = const [],
  });

  CandidateFilters copyWith({
    String? category,
    List<String>? availability,
    String? location,
    List<String>? contractTypes,
  }) =>
      CandidateFilters(
        category: category ?? this.category,
        availability: availability ?? this.availability,
        location: location ?? this.location,
        contractTypes: contractTypes ?? this.contractTypes,
      );

  bool get isEmpty =>
      category == null &&
      availability.isEmpty &&
      location == null &&
      contractTypes.isEmpty;
}

class CandidateFiltersNotifier extends StateNotifier<CandidateFilters> {
  CandidateFiltersNotifier() : super(const CandidateFilters());

  void setCategory(String? v) => state = state.copyWith(category: v);
  void setLocation(String? v) => state = state.copyWith(location: v);
  void toggleAvailability(String v) {
    final list = List<String>.from(state.availability);
    if (list.contains(v)) {
      list.remove(v);
    } else {
      list.add(v);
    }
    state = state.copyWith(availability: list);
  }

  void toggleContractType(String v) {
    final list = List<String>.from(state.contractTypes);
    if (list.contains(v)) {
      list.remove(v);
    } else {
      list.add(v);
    }
    state = state.copyWith(contractTypes: list);
  }

  void reset() => state = const CandidateFilters();
}

final candidateFiltersProvider =
    StateNotifierProvider<CandidateFiltersNotifier, CandidateFilters>(
  (ref) => CandidateFiltersNotifier(),
);

final recentApplicationsProvider = Provider<AsyncValue<List<ApplicationEntity>>>((ref) {
  final applicationsAsync = ref.watch(applicationsNotifierProvider);
  final controller = ref.watch(applicationsControllerProvider);
  return applicationsAsync.whenData(controller.filterRecent);
});

/// Jobs enregistrés filtrés + triés (écran Jobs enregistrés).
final savedJobsDisplayProvider = Provider<AsyncValue<List<JobEntity>>>((ref) {
  final jobsAsync = ref.watch(jobsNotifierProvider);
  final savedIds = ref.watch(savedJobsProvider);
  final filterValues = ref.watch(savedJobsFilterValuesProvider);
  final chip = ref.watch(savedJobsActiveChipProvider);
  final controller = ref.watch(jobsControllerProvider);
  return jobsAsync.whenData((jobs) {
    final saved = jobs.where((j) => savedIds.contains(j.id)).toList();
    final filtered = controller.filterSavedJobs(saved, filterValues);
    return controller.sortSavedJobs(filtered, chip);
  });
});

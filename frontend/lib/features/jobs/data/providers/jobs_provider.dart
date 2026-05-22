import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/features/jobs/domain/mission_entity.dart';
import 'package:job_app/features/jobs/domain/jobs_controller.dart';
import 'package:job_app/features/jobs/domain/recruiter_filters.dart';
import 'package:job_app/features/jobs/data/repositories/jobs_repository.dart';
import 'package:job_app/features/jobs/data/repositories/jobs_repository_http.dart';
import 'package:job_app/features/applications/data/providers/applications_provider.dart';
import 'package:job_app/features/profile/data/providers/profile_provider.dart';

// ─────────────────────────────────────────────
// 1. Repository Provider
//    → Swapper mock par l'implémentation réelle ici
// ─────────────────────────────────────────────
final jobsRepositoryProvider = Provider<JobsRepository>(
  (ref) => JobsRepositoryHttp(),
);

// ─────────────────────────────────────────────
// 2. Controller Provider
// ─────────────────────────────────────────────
final jobsControllerProvider = Provider<JobsController>(
  (ref) => JobsController(ref.watch(jobsRepositoryProvider)),
);

// ─────────────────────────────────────────────
// 3. Jobs List State (StateNotifier)
//    → Gère loading / error / data + mutations
// ─────────────────────────────────────────────
class JobsNotifier extends StateNotifier<AsyncValue<List<JobEntity>>> {
  final JobsController _controller;

  JobsNotifier(this._controller) : super(const AsyncValue.loading()) {
    Future.microtask(() => fetch());
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final jobs = await _controller.fetchMyJobs();
      state = AsyncValue.data(jobs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteJob(String jobId) async {
    try {
      await _controller.deleteJob(jobId);
      await fetch();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final jobsNotifierProvider =
    StateNotifierProvider<JobsNotifier, AsyncValue<List<JobEntity>>>(
  (ref) => JobsNotifier(ref.watch(jobsControllerProvider)),
);

class MissionsNotifier extends StateNotifier<AsyncValue<List<MissionEntity>>> {
  final JobsController _controller;

  MissionsNotifier(this._controller) : super(const AsyncValue.loading()) {
    Future.microtask(() => fetch());
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final missions = await _controller.fetchMissions();
      state = AsyncValue.data(missions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final missionsNotifierProvider =
    StateNotifierProvider<MissionsNotifier, AsyncValue<List<MissionEntity>>>(
  (ref) => MissionsNotifier(ref.watch(jobsControllerProvider)),
);

// ── Feed candidat ─────────────────────────────────────────────────────────────
// Appelle GET /jobs (toutes les offres publiées) — distinct de jobsNotifierProvider
// qui appelle GET /jobs/mine (recruteur uniquement).
class _AllJobsNotifier extends StateNotifier<AsyncValue<List<JobEntity>>> {
  final JobsController _controller;

  _AllJobsNotifier(this._controller) : super(const AsyncValue.loading()) {
    Future.microtask(() => fetch());
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final jobs = await _controller.fetchAllJobs();
      state = AsyncValue.data(jobs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final allJobsNotifierProvider =
    StateNotifierProvider<_AllJobsNotifier, AsyncValue<List<JobEntity>>>(
  (ref) => _AllJobsNotifier(ref.watch(jobsControllerProvider)),
);

/// Toutes les offres publiées — pour le feed candidat (home + recherche).
final candidateAllPublishedJobsProvider = Provider<AsyncValue<List<JobEntity>>>((ref) {
  final jobsAsync = ref.watch(allJobsNotifierProvider);
  final controller = ref.watch(jobsControllerProvider);
  return jobsAsync.whenData(controller.filterPublished);
});

/// Offres proches du user — GPS live > coordonnées profil > wilaya.
/// Réactif aux filtres actifs du candidat.
final nearbyJobsProvider = FutureProvider<List<JobEntity>>((ref) async {
  final gps = ref.watch(userGpsPositionProvider);
  final user = ref.watch(candidateCurrentUserProvider).valueOrNull;
  final filters = ref.watch(candidateFiltersProvider);

  final lat = gps?.lat ?? user?.latitude;
  final lng = gps?.lng ?? user?.longitude;
  final hasGps = lat != null && lng != null;
  final hasLocation = user?.location != null && user!.location.isNotEmpty;
  final selectedLocation = (filters.location ?? '').trim();
  final locationParam = selectedLocation.isNotEmpty
      ? selectedLocation
      : ((!hasGps && hasLocation) ? user.location : null);
  final contractType = _mapContractTypeToApi(
    filters.contractTypes.isNotEmpty ? filters.contractTypes.first : null,
  );

  return ref.read(jobsControllerProvider).fetchNearbyJobs(
    lat: hasGps ? lat : null,
    lng: hasGps ? lng : null,
    location: locationParam,
    category: filters.category,
    contractType: contractType,
  );
});

String? _mapContractTypeToApi(String? label) {
  if (label == null) return null;
  return switch (label.toLowerCase()) {
    'cdi' => 'cdi',
    'cdd' || 'mission' => 'mission',
    'freelance' => 'freelance',
    _ => null,
  };
}

final filteredJobsProvider = Provider<AsyncValue<List<JobEntity>>>((ref) {
  final jobsAsync = ref.watch(jobsNotifierProvider);
  final filters = ref.watch(recruiterFiltersProvider);
  final controller = ref.watch(jobsControllerProvider);
  return jobsAsync.whenData((jobs) => controller.filterJobs(jobs, filters));
});

final filteredMissionsProvider =
    Provider<AsyncValue<List<MissionEntity>>>((ref) {
  final missionsAsync = ref.watch(missionsNotifierProvider);
  final filters = ref.watch(recruiterFiltersProvider);
  final controller = ref.watch(jobsControllerProvider);
  return missionsAsync.whenData(
    (missions) => controller.filterMissions(missions, filters),
  );
});

final publishedJobsProvider = Provider<AsyncValue<List<JobEntity>>>((ref) {
  final jobsAsync = ref.watch(jobsNotifierProvider);
  final controller = ref.watch(jobsControllerProvider);
  return jobsAsync.whenData(controller.filterPublished);
});

final recruiterPublishedJobsProvider =
    Provider.family<AsyncValue<List<JobEntity>>, String>((ref, recruiterId) {
  final publishedAsync = ref.watch(publishedJobsProvider);
  return publishedAsync.whenData(
    (jobs) => jobs.where((j) => j.recruiterId == recruiterId).toList(),
  );
});

final recruiterFilteredPublishedJobsProvider =
    Provider.family<AsyncValue<List<JobEntity>>, String>((ref, recruiterId) {
  final jobsAsync = ref.watch(recruiterPublishedJobsProvider(recruiterId));
  final filters = ref.watch(recruiterFiltersProvider);
  final controller = ref.watch(jobsControllerProvider);
  return jobsAsync.whenData((jobs) => controller.filterJobs(jobs, filters));
});

final recruiterFilteredMissionsByNameProvider =
    Provider.family<AsyncValue<List<MissionEntity>>, String>(
        (ref, recruiterName) {
  final missionsAsync = ref.watch(missionsNotifierProvider);
  final filters = ref.watch(recruiterFiltersProvider);
  final controller = ref.watch(jobsControllerProvider);
  return missionsAsync.whenData((missions) {
    final scoped = missions.where((m) => m.recruiterName == recruiterName).toList();
    return controller.filterMissions(scoped, filters);
  });
});

final candidateJobSearchQueryProvider = StateProvider<String>((ref) => '');

// Server-side search: fires GET /jobs?q=...&category=...&contract_type=...
final jobSearchProvider = FutureProvider<List<JobEntity>>((ref) async {
  final query = ref.watch(candidateJobSearchQueryProvider);
  if (query.trim().isEmpty) return [];
  final filters = ref.watch(candidateFiltersProvider);
  return ref.read(jobsRepositoryProvider).searchJobs(
    query,
    category: filters.category,
    contractTypes: filters.contractTypes.isEmpty ? null : filters.contractTypes,
  );
});

// Recent searches notifier
class RecentSearchNotifier extends StateNotifier<AsyncValue<List<String>>> {
  final JobsRepository _repository;

  RecentSearchNotifier(this._repository) : super(const AsyncValue.loading()) {
    Future.microtask(_load);
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final searches = await _repository.getRecentSearches();
      state = AsyncValue.data(searches);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addSearch(String query) async {
    if (query.trim().isEmpty) return;
    final current = state.valueOrNull ?? [];
    if (!current.contains(query)) {
      state = AsyncValue.data([query, ...current]);
    }
    try {
      await _repository.addRecentSearch(query);
    } catch (_) {}
  }

  void removeSearch(int index) {
    final current = List<String>.from(state.valueOrNull ?? []);
    if (index < current.length) {
      current.removeAt(index);
      state = AsyncValue.data(current);
    }
  }

  Future<void> clearSearches() async {
    state = const AsyncValue.data([]);
    try {
      await _repository.clearRecentSearches();
    } catch (_) {}
  }
}

final recentSearchesProvider =
    StateNotifierProvider<RecentSearchNotifier, AsyncValue<List<String>>>(
  (ref) => RecentSearchNotifier(ref.watch(jobsRepositoryProvider)),
);

final candidateJobSearchResultsProvider =
    Provider<AsyncValue<List<JobEntity>>>((ref) {
  final jobsAsync = ref.watch(jobsNotifierProvider);
  final query = ref.watch(candidateJobSearchQueryProvider);
  final controller = ref.watch(jobsControllerProvider);
  return jobsAsync.whenData((jobs) => controller.searchPublished(jobs, query));
});

// ─────────────────────────────────────────────
// 4. Filtered providers (computed, zéro logique UI)
// ─────────────────────────────────────────────
final activeJobsProvider = Provider<List<JobEntity>>((ref) {
  final jobs = ref.watch(jobsNotifierProvider);
  final controller = ref.watch(jobsControllerProvider);
  return jobs.whenOrNull(data: controller.filterActive) ?? [];
});

final draftJobsProvider = Provider<List<JobEntity>>((ref) {
  final jobs = ref.watch(jobsNotifierProvider);
  final controller = ref.watch(jobsControllerProvider);
  return jobs.whenOrNull(data: controller.filterDrafts) ?? [];
});

/// Combine Jobs and Missions for a unified view
final combinedJobsAndMissionsProvider =
    Provider<AsyncValue<List<Object>>>((ref) {
  final jobsAsync = ref.watch(jobsNotifierProvider);
  final missionsAsync = ref.watch(missionsNotifierProvider);

  // If both are data, merge them
  if (jobsAsync is AsyncData<List<JobEntity>> &&
      missionsAsync is AsyncData<List<MissionEntity>>) {
    final jobs = jobsAsync.value;
    final missions = missionsAsync.value;

    final combined = [...jobs, ...missions];

    // Sort by date (newest first)
    combined.sort((a, b) {
      final dateA =
          a is JobEntity ? a.postedAt : (a as MissionEntity).startDate;
      final dateB =
          b is JobEntity ? b.postedAt : (b as MissionEntity).startDate;
      return dateB.compareTo(dateA);
    });

    return AsyncValue.data(combined);
  }

  // Handle errors
  if (jobsAsync.hasError) {
    return AsyncValue.error(jobsAsync.error!, jobsAsync.stackTrace!);
  }
  if (missionsAsync.hasError) {
    return AsyncValue.error(missionsAsync.error!, missionsAsync.stackTrace!);
  }

  // Otherwise standard loading
  return const AsyncValue.loading();
});

// ─────────────────────────────────────────────
// 5. Tab selection provider
// ─────────────────────────────────────────────
enum JobsTab { myJobs, missions, activity, applications, interviews }

final jobsTabProvider = StateProvider<JobsTab>((ref) => JobsTab.activity);

// ─────────────────────────────────────────────
// 6. Create Job Form Provider
// ─────────────────────────────────────────────
enum SubmitStatus { idle, loading, success, error }

class CreateJobFormNotifier extends StateNotifier<CreateJobForm> {
  final JobsController _controller;
  final Ref _ref;

  CreateJobFormNotifier(this._controller, this._ref)
      : super(const CreateJobForm());

  void updateTitle(String v) => state = state.copyWith(title: v);
  void updateContractType(ContractType v) =>
      state = state.copyWith(contractType: v);
  void updateDescription(String v) => state = state.copyWith(description: v);
  void updateCandidateCount(int? v) =>
      state = state.copyWith(candidateCount: v);
  void updateStartTime(TimeOfDay v) => state = state.copyWith(startTime: v);
  void updateEndTime(TimeOfDay v) => state = state.copyWith(endTime: v);
  void updateStartDate(DateTime v) => state = state.copyWith(startDate: v);
  void updateSalary(double? v) => state = state.copyWith(salary: v);

  void reset() => state = const CreateJobForm();

  /// Sauvegarde en brouillon
  Future<JobEntity?> saveDraft() async {
    if (!state.isValid) return null;
    try {
      final job = await _controller.createJob(state);
      _ref.read(jobsNotifierProvider.notifier).fetch(); // ← refresh liste
      return job;
    } catch (_) {
      return null;
    }
  }

  /// Sauvegarde puis publie
  Future<JobEntity?> publish() async {
    if (!state.isValid) return null;
    try {
      final draft = await _controller.createJob(state);
      final published = await _controller.publishJob(draft);
      _ref.read(jobsNotifierProvider.notifier).fetch(); // ← refresh liste
      return published;
    } catch (_) {
      return null;
    }
  }
}

final createJobFormProvider =
    StateNotifierProvider.autoDispose<CreateJobFormNotifier, CreateJobForm>(
  (ref) => CreateJobFormNotifier(ref.watch(jobsControllerProvider), ref),
);

// ─────────────────────────────────────────────
// 7. Submit Status Provider
// ─────────────────────────────────────────────
final submitStatusProvider =
    StateProvider<SubmitStatus>((ref) => SubmitStatus.idle);

// ─────────────────────────────────────────────
// 8. Edit Job Form State
// ─────────────────────────────────────────────
class EditJobFormNotifier extends StateNotifier<EditJobForm> {
  final JobsController _controller;
  final Ref _ref;

  EditJobFormNotifier(this._controller, this._ref, JobEntity initial)
      : super(EditJobForm.fromEntity(initial));

  void updateTitle(String v) => state = state.copyWith(title: v);
  void updateContractType(ContractType v) =>
      state = state.copyWith(contractType: v);
  void updateDescription(String v) => state = state.copyWith(description: v);
  void updateCandidateCount(int? v) =>
      state = state.copyWith(candidateCount: v);
  void updateSalary(double? v) => state = state.copyWith(salary: v);
  void updateStartTime(TimeOfDay v) => state = state.copyWith(startTime: v);
  void updateEndTime(TimeOfDay v) => state = state.copyWith(endTime: v);
  void updateStartDate(DateTime v) => state = state.copyWith(startDate: v);
  void togglePrivate() => state = state.copyWith(isPrivate: !state.isPrivate);

  Future<JobEntity?> save() async {
    if (!state.isValid) return null;
    try {
      final job = await _controller.updateJob(state);
      _ref.read(jobsNotifierProvider.notifier).fetch();
      return job;
    } catch (_) {
      return null;
    }
  }

  Future<void> delete() async {
    try {
      await _controller.deleteJob(state.id);
      _ref.read(jobsNotifierProvider.notifier).fetch();
    } catch (_) {}
  }
}

// Provider paramétré par l'entité à éditer
final editJobFormProvider =
    StateNotifierProviderFamily<EditJobFormNotifier, EditJobForm, JobEntity>(
  (ref, job) => EditJobFormNotifier(
    ref.watch(jobsControllerProvider),
    ref,
    job,
  ),
);

// ─────────────────────────────────────────────
// 9. Mission Review State
// ─────────────────────────────────────────────
class MissionReviewNotifier extends StateNotifier<MissionReview> {
  final Ref _ref;

  MissionReviewNotifier(String missionId, this._ref)
      : super(MissionReview(missionId: missionId, rating: 0, comment: ''));

  void setRating(int r) => state = MissionReview(
      missionId: state.missionId, rating: r, comment: state.comment);

  void setComment(String c) => state = MissionReview(
      missionId: state.missionId, rating: state.rating, comment: c);

  /// Valide la fin de mission : soumet l'avis + met à jour le statut
  Future<bool> submit() async {
    if (!state.isValid) return false;
    try {
      // Appel au controller pour persister le review
      await _ref.read(jobsControllerProvider).updateMissionReview(
        state.missionId,
        state.rating.toDouble(),
        state.comment,
      );
      // Refresh la liste des missions (pour les recruteurs)
      _ref.read(missionsNotifierProvider.notifier).fetch();
      // Refresh aussi la liste des missions du candidat (pour le profil)
      _ref.read(candidateMissionsProvider.notifier).fetch();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final missionReviewProvider =
    StateNotifierProviderFamily<MissionReviewNotifier, MissionReview, String>(
  (ref, missionId) => MissionReviewNotifier(missionId, ref),
);

// État de soumission de l'avis
final reviewSubmitStatusProvider =
    StateProvider.autoDispose<SubmitStatus>((ref) => SubmitStatus.idle);

// ─────────────────────────────────────────────
// 10. Candidate Missions (profil candidat)
// ─────────────────────────────────────────────
class CandidateMissionsNotifier extends StateNotifier<AsyncValue<List<MissionEntity>>> {
  final Ref _ref;

  CandidateMissionsNotifier(this._ref) : super(const AsyncValue.loading()) {
    Future.microtask(() => fetch());
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      // Endpoint is scoped by JWT user.
      final missions = await _ref.read(jobsRepositoryProvider).getMissions();
      state = AsyncValue.data(missions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final candidateMissionsProvider =
    StateNotifierProvider<CandidateMissionsNotifier, AsyncValue<List<MissionEntity>>>((ref) {
  return CandidateMissionsNotifier(ref);
});

final candidateMissionsByNameProvider =
    Provider.family<AsyncValue<List<MissionEntity>>, String>((ref, candidateName) {
  final missionsAsync = ref.watch(missionsNotifierProvider);
  return missionsAsync.whenData(
    (missions) => missions.where((m) => m.candidateName == candidateName).toList(),
  );
});


// ─────────────────────────────────────────────
// 11. Recruiter Filters Provider (état UI — logique dans les controllers)
// ─────────────────────────────────────────────
class RecruiterFiltersNotifier extends StateNotifier<RecruiterFilters> {
  RecruiterFiltersNotifier() : super(const RecruiterFilters());

  void setStatus(String? v) =>
      state = state.copyWith(status: v, clearStatus: v == null);

  void setDateFilter(String? v) =>
      state = state.copyWith(dateFilter: v, clearDateFilter: v == null);

  void setDepartment(String? v) =>
      state = state.copyWith(department: v, clearDepartment: v == null);

  void setJobId(String? v) =>
      state = state.copyWith(jobId: v, clearJobId: v == null);

  void setSavedOnly(bool v) => state = state.copyWith(savedOnly: v);

  void toggleSavedOnly() => state = state.copyWith(savedOnly: !state.savedOnly);

  void reset() => state = const RecruiterFilters();

  void apply(RecruiterFilters filters) => state = filters;
}

final recruiterFiltersProvider =
    StateNotifierProvider<RecruiterFiltersNotifier, RecruiterFilters>(
  (ref) => RecruiterFiltersNotifier(),
);


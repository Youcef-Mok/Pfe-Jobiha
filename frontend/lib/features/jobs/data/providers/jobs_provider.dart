import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';

import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/features/jobs/domain/mission_entity.dart';
import 'package:job_app/features/jobs/domain/jobs_controller.dart';
import 'package:job_app/features/jobs/domain/recruiter_filters.dart';
import 'package:job_app/features/jobs/data/repositories/jobs_repository.dart';
import 'package:job_app/features/jobs/data/repositories/jobs_repository_http.dart';
import 'package:job_app/features/applications/data/providers/applications_provider.dart';
import 'package:job_app/features/profile/data/providers/profile_provider.dart';
import 'package:job_app/features/auth/providers/auth_providers.dart';
import 'package:job_app/features/auth/data/models/auth_state.dart';

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
  final Ref _ref;
  final JobsController _controller;

  JobsNotifier(this._ref, this._controller) : super(const AsyncValue.loading()) {
    Future.microtask(() => fetch());
    _ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated &&
          prev?.status != AuthStatus.authenticated) {
        fetch();
      }
    });
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
  (ref) => JobsNotifier(ref, ref.watch(jobsControllerProvider)),
);

class MissionsNotifier extends StateNotifier<AsyncValue<List<MissionEntity>>> {
  final Ref _ref;
  final JobsController _controller;

  MissionsNotifier(this._ref, this._controller) : super(const AsyncValue.loading()) {
    Future.microtask(() => fetch());
    _ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated &&
          prev?.status != AuthStatus.authenticated) {
        fetch();
      }
    });
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
  (ref) => MissionsNotifier(ref, ref.watch(jobsControllerProvider)),
);

// ── Feed candidat ─────────────────────────────────────────────────────────────
// Appelle GET /jobs (toutes les offres publiées) — distinct de jobsNotifierProvider
// qui appelle GET /jobs/mine (recruteur uniquement).
class _AllJobsNotifier extends StateNotifier<AsyncValue<List<JobEntity>>> {
  final Ref _ref;
  final JobsController _controller;

  _AllJobsNotifier(this._ref, this._controller) : super(const AsyncValue.loading()) {
    Future.microtask(() => fetch());
    _ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated &&
          prev?.status != AuthStatus.authenticated) {
        fetch();
      }
    });
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
  (ref) => _AllJobsNotifier(ref, ref.watch(jobsControllerProvider)),
);

/// Toutes les offres publiées — pour le feed candidat (home + recherche).
final candidateAllPublishedJobsProvider = Provider<AsyncValue<List<JobEntity>>>((ref) {
  final jobsAsync = ref.watch(allJobsNotifierProvider);
  final controller = ref.watch(jobsControllerProvider);
  return jobsAsync.whenData(controller.filterPublished);
});

final candidateFilteredPublishedJobsProvider =
    Provider<AsyncValue<List<JobEntity>>>((ref) {
  final jobsAsync = ref.watch(candidateAllPublishedJobsProvider);
  final filters = ref.watch(candidateFiltersProvider);
  return jobsAsync.whenData((jobs) => _applyCandidateFilters(jobs, filters));
});

/// Offres proches du user — GPS live > coordonnées profil > wilaya.
/// Réactif aux filtres actifs du candidat.
final nearbyJobsProvider = AutoDisposeFutureProvider<List<JobEntity>>((ref) async {
  final gps = ref.watch(userGpsPositionProvider);
  final user = ref.watch(candidateCurrentUserProvider).valueOrNull;
  final filters = ref.watch(candidateFiltersProvider);

  final hasLocationPoint =
      filters.locationLat != null && filters.locationLng != null;
  final lat = hasLocationPoint ? filters.locationLat : (gps?.lat ?? user?.latitude);
  final lng = hasLocationPoint ? filters.locationLng : (gps?.lng ?? user?.longitude);
  final hasGps = lat != null && lng != null;
  final hasLocation = user?.location != null && user!.location.isNotEmpty;
  final selectedLocation = (filters.location ?? '').trim();
  final locationParam = selectedLocation.isNotEmpty
      ? selectedLocation
      : ((!hasGps && hasLocation) ? user.location : null);
  final contractType = _mapContractTypeToApi(
    filters.contractTypes.isNotEmpty ? filters.contractTypes.first : null,
  );
  final jobs = await ref.read(jobsRepositoryProvider).getAllJobs(
        lat: hasGps ? lat : null,
        lng: hasGps ? lng : null,
        maxDistanceKm: hasLocationPoint ? (filters.locationRadiusKm ?? 10.0) : 30.0,
        location: hasLocationPoint ? null : locationParam,
        category: filters.category,
        contractType: contractType,
      );

  // Apply full filter set client-side so selected homepage filters always
  // have a visible effect, even if API supports only a subset.
  return _applyCandidateFilters(jobs, filters);
});

List<JobEntity> _applyCandidateFilters(
  List<JobEntity> jobs,
  CandidateFilters filters,
) {
  final hasLocationPoint =
      filters.locationLat != null && filters.locationLng != null;
  return jobs.where((job) {
    if (filters.category != null && filters.category!.trim().isNotEmpty) {
      if (!_matchesDomain(job, filters.category!)) return false;
    }

    if (filters.contractTypes.isNotEmpty) {
      final ok = filters.contractTypes.any((c) {
        final v = _normalizeFilterValue(c);
        if (v == 'cdi') return job.contractType == ContractType.cdi;
        if (v == 'cdd' || v == 'mission') {
          return job.contractType == ContractType.mission;
        }
        if (v == 'freelance') return job.contractType == ContractType.freelance;
        return false;
      });
      if (!ok) return false;
    }

    if (!hasLocationPoint &&
        filters.location != null &&
        filters.location!.trim().isNotEmpty) {
      final q = _normalizeFilterValue(filters.location!);
      final haystack =
          '${job.location ?? ''} ${job.companyName} ${job.department} ${job.title}'
              .trim();
      final normalizedHaystack = _normalizeFilterValue(haystack);
      if (!normalizedHaystack.contains(q)) return false;
    }

    if (filters.availability.isNotEmpty) {
      final haystack =
          '${job.scheduleLabel ?? ''} ${job.title} ${job.department}'
              .trim();
      final normalizedHaystack = _normalizeFilterValue(haystack);
      final matchesAnyAvailability =
          filters.availability
              .any((a) => normalizedHaystack.contains(_normalizeFilterValue(a)));
      if (!matchesAnyAvailability) return false;
    }
    return true;
  }).toList();
}

String? _mapContractTypeToApi(String? label) {
  if (label == null) return null;
  return switch (_normalizeFilterValue(label)) {
    'cdi' => 'cdi',
    'cdd' || 'mission' => 'mission',
    'freelance' => 'freelance',
    _ => null,
  };
}

String _categoryCanonical(String value) {
  final n = _normalizeFilterValue(value);
  if (n.contains('tech')) return 'technologie';
  if (n.contains('restaur')) return 'restauration';
  if (n.contains('commerc') || n.contains('vente')) return 'commerce';
  if (n.contains('sante') || n.contains('medical')) return 'sante';
  if (n.contains('educ') || n.contains('formation')) return 'education';
  if (n.contains('transport') || n.contains('livraison')) return 'transport';
  return n;
}

bool _matchesDomain(JobEntity job, String selectedDomain) {
  final selected = _categoryCanonical(selectedDomain);
  final haystack = _normalizeFilterValue(
    '${job.department} ${job.title} ${job.companyName} ${job.location ?? ''} ${job.city ?? ''}',
  );
  final aliases = switch (selected) {
    'technologie' => ['technologie', 'tech', 'it', 'informatique', 'dev'],
    'restauration' => ['restauration', 'restaurant', 'cuisine', 'food'],
    'commerce' => ['commerce', 'vente', 'seller', 'shop', 'retail'],
    'sante' => ['sante', 'medical', 'clinique', 'hopital'],
    'education' => ['education', 'formation', 'ecole', 'prof'],
    'transport' => ['transport', 'livraison', 'chauffeur', 'driver'],
    _ => [selected],
  };
  return aliases.any(haystack.contains);
}

String _normalizeFilterValue(String value) {
  final lower = value.trim().toLowerCase();
  return lower
      .replaceAll('é', 'e')
      .replaceAll('è', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('ë', 'e')
      .replaceAll('à', 'a')
      .replaceAll('â', 'a')
      .replaceAll('ä', 'a')
      .replaceAll('î', 'i')
      .replaceAll('ï', 'i')
      .replaceAll('ô', 'o')
      .replaceAll('ö', 'o')
      .replaceAll('ù', 'u')
      .replaceAll('û', 'u')
      .replaceAll('ü', 'u')
      .replaceAll(RegExp(r'\s+'), ' ');
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
  // Uses public feed (GET /jobs) so candidates can view a recruiter's public profile
  final allJobsAsync = ref.watch(candidateAllPublishedJobsProvider);
  return allJobsAsync.whenData(
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

/// Missions publiques d'un recruteur — pour le profil public (GET /missions?recruiter_id=X).
final publicRecruiterMissionsProvider =
    FutureProvider.family<List<MissionEntity>, String>((ref, recruiterId) async {
  final controller = ref.watch(jobsControllerProvider);
  return await controller.fetchMissionsByRecruiterId(recruiterId);
});

final candidateJobSearchQueryProvider = StateProvider<String>((ref) => '');

// Server-side search: fires GET /jobs?q=...&category=...&contract_type=...
final jobSearchProvider = AutoDisposeFutureProvider<List<JobEntity>>((ref) async {
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

  Future<void> removeSearch(int index) async {
    final current = List<String>.from(state.valueOrNull ?? []);
    if (index >= current.length) return;
    final query = current[index];
    current.removeAt(index);
    state = AsyncValue.data(current);
    try {
      await _repository.removeRecentSearch(query);
    } catch (_) {}
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
  void updateImage(Uint8List bytes, String fileName) =>
      state = state.copyWith(imageBytes: bytes, imageFileName: fileName);

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
  void updateImage(Uint8List bytes, String fileName) =>
      state = state.copyWith(imageBytes: bytes, imageFileName: fileName);

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
    _ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated &&
          prev?.status != AuthStatus.authenticated) {
        fetch();
      }
    });
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


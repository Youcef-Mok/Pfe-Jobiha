import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/features/applications/domain/application_entity.dart';
import 'package:job_app/features/applications/data/repositories/applications_repository.dart';
import 'package:job_app/features/applications/data/repositories/applications_repository_mock.dart';

// ─────────────────────────────────────────────
// 1. Repository Provider
// ─────────────────────────────────────────────
final applicationsRepositoryProvider = Provider<ApplicationsRepository>(
  (ref) => ApplicationsRepositoryMock(),
);

// ─────────────────────────────────────────────
// 2. Applications Notifier
// ─────────────────────────────────────────────
class ApplicationsNotifier
    extends StateNotifier<AsyncValue<List<ApplicationEntity>>> {
  final ApplicationsRepository _repo;

  ApplicationsNotifier(this._repo) : super(const AsyncValue.loading()) {
    Future.microtask(() => fetch());
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final apps = await _repo.getMyApplications();
      state = AsyncValue.data(apps);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> apply(String jobId) async {
    try {
      await _repo.applyToJob(jobId);
      await fetch();
    } catch (_) {}
  }

  Future<void> cancel(String applicationId) async {
    try {
      await _repo.cancelApplication(applicationId);
      await fetch();
    } catch (_) {}
  }
}

final applicationsNotifierProvider = StateNotifierProvider<ApplicationsNotifier,
    AsyncValue<List<ApplicationEntity>>>(
  (ref) => ApplicationsNotifier(ref.watch(applicationsRepositoryProvider)),
);

// ─────────────────────────────────────────────
// 3. Applications Tab Filter
// ─────────────────────────────────────────────
enum ApplicationsTabFilter { all, pending, accepted, rejected }

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
  SavedJobsNotifier() : super({'4', '5'}); // pre-saved for demo

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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';
import 'package:job_app/features/candidates/domain/candidate_entity.dart';
import 'package:job_app/features/candidates/domain/candidates_controller.dart';
import 'package:job_app/features/candidates/data/models/candidate_model.dart';
import 'package:job_app/features/candidates/data/repositories/candidates_repository.dart';
import 'package:job_app/features/candidates/data/repositories/candidates_repository_http.dart';

final candidatesRepositoryProvider = Provider<CandidatesRepository>((ref) {
  return CandidatesRepositoryHttp();
});

final candidatesTabProvider = StateProvider<CandidateStatus>((ref) {
  return CandidateStatus.nouveau;
});

final currentJobIdProvider = StateProvider<String>((ref) {
  return '2'; // Mock job ID correctly linked to mock data
});

class CandidatesNotifier
    extends StateNotifier<AsyncValue<List<CandidateModel>>> {
  final CandidatesRepository _repository;
  final String _jobId;

  CandidatesNotifier(this._repository, this._jobId)
      : super(const AsyncValue.loading()) {
    Future.microtask(() => fetch());
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getCandidates(_jobId));
  }

  Future<void> updateStatus(String candidateId, CandidateStatus status) async {
    // Modify local state immediately for a fast UI (optimistic update)
    if (state is AsyncData<List<CandidateModel>>) {
      final currentList = state.value!;
      final updatedList = currentList.map((c) {
        if (c.id == candidateId) {
          return CandidateModel(
            id: c.id,
            name: c.name,
            title: c.title,
            photoUrl: c.photoUrl,
            rating: c.rating,
            reviewsCount: c.reviewsCount,
            isTopRated: c.isTopRated,
            coverLetter: c.coverLetter,
            status: status,
          );
        }
        return c;
      }).toList();
      state = AsyncValue.data(updatedList);
    }

    // Perform remote action silently in the background
    await _repository.updateCandidateStatus(candidateId, status.name);
  }

  Future<void> scheduleInterview(
    String candidateId,
    DateTime date,
    String timeSlot,
  ) async {
    await _repository.scheduleInterview(candidateId, date, timeSlot);
  }
}

final candidatesNotifierProvider =
    StateNotifierProvider<CandidatesNotifier, AsyncValue<List<CandidateModel>>>(
        (ref) {
  final repository = ref.watch(candidatesRepositoryProvider);
  final jobId = ref.watch(currentJobIdProvider);
  return CandidatesNotifier(repository, jobId);
});

final selectedJobProvider = Provider<JobEntity?>((ref) {
  final jobId = ref.watch(currentJobIdProvider);
  final jobsAsync = ref.watch(jobsNotifierProvider);
  return jobsAsync.whenOrNull(
    data: (jobs) {
      try {
        return jobs.firstWhere((j) => j.id == jobId);
      } catch (_) {
        return jobs.isNotEmpty ? jobs.first : null;
      }
    },
  );
});

// Logique de filtrage déléguée au controller du domaine
final candidatesControllerProvider =
    Provider((ref) => const CandidatesController());

final candidatesSortModeProvider = StateProvider<String>((ref) => 'recent');

/// Candidats filtrés/triés — écran liste par offre.
final filteredCandidatesProvider =
    Provider<AsyncValue<List<CandidateEntity>>>((ref) {
  final candidatesAsync = ref.watch(candidatesNotifierProvider);
  final tab = ref.watch(candidatesTabProvider);
  final sortMode = ref.watch(candidatesSortModeProvider);
  final controller = ref.watch(candidatesControllerProvider);
  return candidatesAsync.whenData(
    (list) => controller.filterAndSort(
      candidates: list,
      tab: tab,
      sortMode: sortMode,
    ),
  );
});

/// Candidats statut « nouveau » — onglet candidatures (détail offre).
final jobNouveauCandidatesProvider =
    Provider<AsyncValue<List<CandidateEntity>>>((ref) {
  final candidatesAsync = ref.watch(candidatesNotifierProvider);
  final controller = ref.watch(candidatesControllerProvider);
  return candidatesAsync.whenData(
    (list) => controller.filterByStatus(list, CandidateStatus.nouveau),
  );
});
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/features/interviews/domain/interview_entity.dart';
import 'package:job_app/features/interviews/domain/interviews_controller.dart';
import 'package:job_app/features/interviews/data/repositories/interviews_repository.dart';
import 'package:job_app/features/interviews/data/repositories/interviews_repository_http.dart';
import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';

// TODO(API): Remplacer InterviewsRepositoryMock par InterviewsRepositoryHttp.
//            Voir API_SPEC.md section "INTERVIEWS".
final interviewsRepositoryProvider = Provider<InterviewsRepository>((ref) {
  return InterviewsRepositoryHttp();
});

final interviewsControllerProvider = Provider<InterviewsController>((ref) {
  return InterviewsController(ref.watch(interviewsRepositoryProvider));
});

/// Notifier — délègue toutes les opérations au contrôleur domaine.
class InterviewsNotifier extends StateNotifier<AsyncValue<List<InterviewEntity>>> {
  final InterviewsController _controller;

  InterviewsNotifier(this._controller) : super(const AsyncValue.loading()) {
    fetch();
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final interviews = await _controller.fetchAll();
      state = AsyncValue.data(interviews);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> cancelInterview(String id) async {
    try {
      await _controller.cancel(id);
      await fetch();
    } catch (_) {}
  }

  Future<void> completeInterview(String id, String? notes) async {
    try {
      await _controller.complete(id, notes);
      await fetch();
    } catch (_) {}
  }

  Future<void> createInterview(InterviewEntity interview) async {
    try {
      await _controller.create(interview);
      await fetch();
    } catch (_) {}
  }

  Future<InterviewEntity?> updateInterview(InterviewEntity interview) async {
    try {
      final updated = await _controller.update(interview);
      await fetch();
      return updated;
    } catch (_) {
      return null;
    }
  }
}

final interviewsNotifierProvider =
    StateNotifierProvider<InterviewsNotifier, AsyncValue<List<InterviewEntity>>>((ref) {
  return InterviewsNotifier(ref.watch(interviewsControllerProvider));
});

class SavedInterviewsNotifier extends StateNotifier<Set<String>> {
  SavedInterviewsNotifier() : super({});

  void toggle(String interviewId) {
    if (state.contains(interviewId)) {
      state = {...state}..remove(interviewId);
    } else {
      state = {...state, interviewId};
    }
  }

  bool isSaved(String interviewId) => state.contains(interviewId);
}

final savedInterviewsProvider =
    StateNotifierProvider<SavedInterviewsNotifier, Set<String>>(
  (ref) => SavedInterviewsNotifier(),
);

final filteredInterviewsProvider =
    Provider<AsyncValue<List<InterviewEntity>>>((ref) {
  final interviewsAsync = ref.watch(interviewsNotifierProvider);
  final filters = ref.watch(recruiterFiltersProvider);
  final controller = ref.watch(interviewsControllerProvider);
  final savedIds = ref.watch(savedInterviewsProvider);
  return interviewsAsync.whenData(
    (interviews) => controller.filterByRecruiterFilters(
      interviews,
      filters,
      savedIds: savedIds,
    ),
  );
});

/// Entretiens à venir pour une offre — détail annonce.
final jobDetailInterviewsProvider =
    Provider.family<AsyncValue<List<InterviewEntity>>, String>((ref, jobId) {
  final interviewsAsync = ref.watch(interviewsNotifierProvider);
  final controller = ref.watch(interviewsControllerProvider);
  return interviewsAsync.whenData(
    (interviews) => controller.forJobUpcoming(interviews, jobId),
  );
});

/// Entretiens à venir — le filtrage est délégué à InterviewsController.filterUpcoming().
final upcomingInterviewsProvider = Provider<AsyncValue<List<InterviewEntity>>>((ref) {
  final interviewsAsync = ref.watch(interviewsNotifierProvider);
  final controller = ref.watch(interviewsControllerProvider);
  return interviewsAsync.whenData(
    (interviews) => controller.filterUpcoming(interviews, limit: 3),
  );
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';
import 'package:job_app/features/candidates/domain/candidate_entity.dart';
import 'package:job_app/features/candidates/data/models/candidate_model.dart';
import 'package:job_app/features/candidates/data/repositories/candidates_repository.dart';
import 'package:job_app/features/candidates/data/repositories/candidates_repository_mock.dart';

final candidatesRepositoryProvider = Provider<CandidatesRepository>((ref) {
  return CandidatesRepositoryMock();
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

// Gère la logique de filtrage
final candidatesControllerProvider =
    Provider((ref) => const CandidatesController());

class CandidatesController {
  const CandidatesController();

  List<CandidateModel> filterAndSort({
    required List<CandidateModel> candidates,
    required CandidateStatus tab,
    required String sortMode,
  }) {
    // 1. Filtrage par tab
    var list = candidates.where((c) {
      if (tab == CandidateStatus.archive) {
        return c.status == CandidateStatus.archive;
      }
      // Pour Nouveaux et Examine, on garde les archivés s'ils étaient de ce type
      // Mais pour simplifier, on suit le souhait de l'utilisateur : "ne pas disparaître"
      // Donc si on est dans l'onglet Nouveaux, on montre les Nouveaux + les archivés qui étaient Nouveaux (mock logic)
      if (tab == CandidateStatus.nouveau) {
        return c.status == CandidateStatus.nouveau || c.status == CandidateStatus.archive;
      }
      return c.status == tab;
    }).toList();

    // 2. Tris
    if (sortMode == 'best') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (sortMode == 'recent') {
      // Pour le mock, on simule par ID décroissant
      list.sort((a, b) => b.id.compareTo(a.id));
    } else if (sortMode == 'unprocessed') {
      list = list.where((c) => c.status == CandidateStatus.nouveau).toList();
    }

    return list;
  }
}

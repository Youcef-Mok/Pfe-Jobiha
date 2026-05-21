import 'package:job_app/features/interviews/domain/interview_entity.dart';
import 'package:job_app/features/interviews/data/repositories/interviews_repository.dart';
import 'package:job_app/features/jobs/domain/recruiter_filters.dart';

// TODO(API): Remplacer InterviewsRepositoryMock par InterviewsRepositoryHttp
//            dans interviews_provider.dart.
//            Voir API_SPEC.md section "INTERVIEWS" pour les endpoints.

class InterviewsController {
  final InterviewsRepository _repository;

  InterviewsController(this._repository);

  Future<List<InterviewEntity>> fetchAll() => _repository.getInterviews();

  Future<InterviewEntity?> fetchById(String id) =>
      _repository.getInterviewById(id);

  Future<InterviewEntity> create(InterviewEntity interview) =>
      _repository.createInterview(interview);

  Future<InterviewEntity> update(InterviewEntity interview) =>
      _repository.updateInterview(interview);

  Future<void> cancel(String id) => _repository.cancelInterview(id);

  Future<InterviewEntity> complete(String id, String? notes) =>
      _repository.completeInterview(id, notes);

  List<InterviewEntity> forJobUpcoming(
    List<InterviewEntity> interviews,
    String jobId,
  ) {
    final now = DateTime.now();
    return interviews
        .where((i) =>
            i.jobId == jobId && i.isScheduled && i.scheduledDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  List<InterviewEntity> filterByRecruiterFilters(
    List<InterviewEntity> interviews,
    RecruiterFilters filters, {
    Set<String> savedIds = const {},
  }) {
    if (filters.isEmpty) return interviews;
    return interviews.where((i) {
      if (filters.savedOnly && !savedIds.contains(i.id)) {
        return false;
      }
      if (filters.jobId != null && i.jobId != filters.jobId) {
        return false;
      }
      if (filters.department != null && i.department != filters.department) {
        return false;
      }
      if (filters.status != null && _statusLabel(i) != filters.status) {
        return false;
      }
      if (!RecruiterFilterDates.matchesInterviewDate(
          i.scheduledDate, filters.dateFilter)) {
        return false;
      }
      return true;
    }).toList();
  }

  String _statusLabel(InterviewEntity interview) => switch (interview.status) {
        'completed' => 'Terminé',
        'cancelled' => 'Annulé',
        _ => 'Planifié',
      };

  /// Filtre les entretiens planifiés à venir, triés par date chronologique.
  List<InterviewEntity> filterUpcoming(
    List<InterviewEntity> interviews, {
    int limit = 3,
  }) {
    final now = DateTime.now();
    final upcoming = interviews
        .where((i) => i.isScheduled && i.scheduledDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    return upcoming.take(limit).toList();
  }
}

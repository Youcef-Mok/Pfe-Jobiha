import 'package:job_app/features/candidates/data/models/candidate_model.dart';

abstract class CandidatesRepository {
  Future<List<CandidateModel>> getCandidates(String jobId);
  Future<void> updateCandidateStatus(String candidateId, String status);
  Future<void> scheduleInterview(
    String candidateId,
    DateTime date,
    String timeSlot,
  );
}

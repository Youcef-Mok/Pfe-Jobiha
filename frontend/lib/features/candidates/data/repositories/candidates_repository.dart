import 'package:job_app/features/candidates/data/models/candidate_model.dart';

// TODO(API): Lors du branchement backend, changer le type de retour de
//            getCandidates() de List<CandidateModel> vers List<CandidateEntity>.
//            CandidateModel extends CandidateEntity donc la migration est non-destructive.
//            Mettre à jour CandidatesRepositoryMock (.toList() suffira) et
//            CandidatesNotifier (changer le state type).
abstract class CandidatesRepository {
  Future<List<CandidateModel>> getCandidates(String jobId);
  Future<void> updateCandidateStatus(String candidateId, String status);
  Future<void> scheduleInterview(
    String candidateId,
    DateTime date,
    String timeSlot,
  );
}

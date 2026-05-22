import 'package:job_app/features/applications/domain/application_entity.dart';

abstract class ApplicationsRepository {
  Future<List<ApplicationEntity>> getMyApplications();
  Future<ApplicationEntity> applyToJob(
    String jobId, {
    String? motivationLetter,
  });
  Future<void> cancelApplication(String applicationId);
  Future<void> acceptApplication(String applicationId);
  Future<void> rejectApplication(String applicationId);
}

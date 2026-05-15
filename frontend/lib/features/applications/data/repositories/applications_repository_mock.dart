import 'package:job_app/features/applications/data/models/application_model.dart';
import 'package:job_app/features/applications/data/repositories/applications_repository.dart';
import 'package:job_app/features/applications/domain/application_entity.dart';

class ApplicationsRepositoryMock implements ApplicationsRepository {
  static final List<ApplicationModel> _data = [
    ApplicationModel(
      id: 'app1',
      jobId: '2',
      jobTitle: 'Product Manager',
      companyName: 'TechCorp Solutions',
      logoAsset: 'assets/images/imageannonc(1).jpg',
      status: 'pending',
      appliedAt: DateTime(2024, 10, 10).toIso8601String(),
      location: 'Alger, Birkhadem',
      contractType: 'cdi',
      scheduleLabel: '9h-17h',
    ),
    ApplicationModel(
      id: 'app2',
      jobId: '4',
      jobTitle: 'Développeur Flutter',
      companyName: 'ServicePro',
      logoAsset: 'assets/images/imageannonc(3).jpg',
      status: 'pending',
      appliedAt: DateTime(2024, 10, 12).toIso8601String(),
      location: 'Alger, Birkhadem',
      contractType: 'cdi',
      scheduleLabel: '10h-17h',
      interviewDate: 'Entretien prévu le 18 Oct.',
    ),
    ApplicationModel(
      id: 'app3',
      jobId: '5',
      jobTitle: 'UX Designer',
      companyName: 'Creative Agency',
      logoAsset: 'assets/images/imageannonc(4).jpg',
      status: 'accepted',
      appliedAt: DateTime(2024, 10, 8).toIso8601String(),
      location: 'Alger, Birkhadem',
      contractType: 'mission',
      scheduleLabel: '8h-16h',
      interviewDate: 'Entretien prévu le 18 Oct.',
    ),
    ApplicationModel(
      id: 'app4',
      jobId: '6',
      jobTitle: 'Chef de projet',
      companyName: 'BuildCorp',
      logoAsset: 'assets/images/imageannonc(5).jpg',
      status: 'rejected',
      appliedAt: DateTime(2024, 10, 5).toIso8601String(),
      location: 'Alger, Birkhadem',
      contractType: 'cdi',
      scheduleLabel: '9h-18h',
    ),
  ];

  static final List<ApplicationModel> _applications = List.from(_data);

  @override
  Future<List<ApplicationEntity>> getMyApplications() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _applications.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ApplicationEntity> applyToJob(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final model = ApplicationModel(
      id: 'app_${DateTime.now().millisecondsSinceEpoch}',
      jobId: jobId,
      jobTitle: 'Nouveau poste',
      companyName: 'Entreprise',
      status: 'pending',
      appliedAt: DateTime.now().toIso8601String(),
      location: 'Alger',
      contractType: 'cdi',
    );
    _applications.add(model);
    return model.toEntity();
  }

  @override
  Future<void> cancelApplication(String applicationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _applications.removeWhere((a) => a.id == applicationId);
  }
}

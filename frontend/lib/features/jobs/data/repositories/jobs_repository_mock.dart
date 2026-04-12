import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/features/jobs/domain/mission_entity.dart';
import 'package:job_app/features/jobs/data/models/job_model.dart';
import 'package:job_app/features/jobs/data/models/mission_model.dart';
import 'package:job_app/features/jobs/data/repositories/jobs_repository.dart';

/// Implémentation mock du repository.
/// Simule des appels réseau avec des délais artificiels.
class JobsRepositoryMock implements JobsRepository {
  // Données simulées
  static final List<JobModel> _mockData = [
    JobModel(
      id: '2',
      title: 'Product Manager',
      companyName: 'TechCorp Solutions',
      contractType: 'cdi',
      postedAt: DateTime(2024, 10, 8).toIso8601String(),
      status: 'searching',
      candidateCount: 8,
      viewCount: 210,
      logoAsset: null,
      isPublished: true,
    ),
    JobModel(
      id: '3',
      title: 'Marketing Lead',
      companyName: 'TechCorp Solutions',
      contractType: 'freelance',
      postedAt: DateTime(2024, 10, 11).toIso8601String(),
      status: 'draft',
      candidateCount: 0,
      viewCount: 0,
      logoAsset: null,
      isPublished: false,
    ),
  ];

  static final List<JobModel> _jobs = List.from(_mockData);

  static final List<MissionModel> _missionsData = [
    MissionModel(
      id: 'm1',
      jobTitle: 'Senior UX Designer',
      companyName: 'TechCorp Solutions',
      startDate: DateTime(2024, 10, 12).toIso8601String(),
      endDate: DateTime(2024, 11, 12).toIso8601String(),
      location: 'Paris, FR',
      recruiterName: 'Jean Recruteur',
      candidateName: 'Alice Design',
      candidateRating: 4.5,
      recruiterRating: 4.8,
      candidateFeedback: 'Alice a fait un excellent travail sur le design system.',
      recruiterFeedback: 'Mission très enrichissante, équipe au top.',
      status: 'in_progress',
      team: [
        MissionMemberModel(name: 'Amélie Laurent', role: 'Chef de rang', rating: 4.9),
        MissionMemberModel(name: 'Marc Dubois', role: 'Barista Expert', rating: 4.7),
      ],
    ),
    MissionModel(
      id: 'm2',
      jobTitle: 'Manager',
      companyName: 'TechCorp Solutions',
      startDate: DateTime(2024, 9, 1).toIso8601String(),
      endDate: DateTime(2024, 9, 30).toIso8601String(),
      location: 'Lyon, FR',
      recruiterName: 'Marc Chef',
      candidateName: 'Bob Manager',
      candidateRating: 5.0,
      recruiterRating: 4.2,
      candidateFeedback: 'Bob a parfaitement géré la transition de l\'équipe.',
      recruiterFeedback: 'Bonne expérience globale.',
      status: 'completed',
      team: [
        MissionMemberModel(name: 'Amélie Laurent', role: 'Chef de rang', rating: 4.9),
        MissionMemberModel(name: 'Marc Dubois', role: 'Barista Expert', rating: 4.7),
      ],
    ),
  ];

  static final List<MissionModel> _missions = List.from(_missionsData);

  @override
  Future<List<JobEntity>> getMyJobs() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _jobs.map((m) => m.toEntity()).toList();
  }

  @override
  Future<JobEntity> saveJob(JobEntity job) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final model = JobModel.fromEntity(job);
    final index = _jobs.indexWhere((j) => j.id == job.id);
    if (index >= 0) {
      _jobs[index] = model;
    } else {
      _jobs.add(model);
    }
    return model.toEntity();
  }

  @override
  Future<void> deleteJob(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _jobs.removeWhere((j) => j.id == jobId);
  }

  @override
  Future<JobEntity?> getJobById(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _jobs.firstWhere((j) => j.id == jobId).toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<MissionEntity>> getMissions() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _missions.map((m) => m.toEntity()).toList();
  }
}

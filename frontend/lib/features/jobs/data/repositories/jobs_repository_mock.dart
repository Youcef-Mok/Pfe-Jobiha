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
      logoAsset:
          'assets/images/imageannonc(1).jpg', // Job announcement image
      isPublished: true,
      candidates: [
        JobCandidateModel(
          initials: 'AL',
          name: 'Amélie Laurent',
          role: 'Chef de rang',
          rating: 4.9,
          avatarUrl: 'assets/images/pdp_1.png',
        ),
        JobCandidateModel(
          initials: 'MD',
          name: 'Marc Dubois',
          role: 'Barista Expert',
          rating: 4.7,
          avatarUrl: 'assets/images/pdp_4.png',
        ),
        JobCandidateModel(
          initials: 'LP',
          name: 'Lucas Petit',
          role: 'Senior Product Manager',
          rating: 4.5,
          avatarUrl: 'assets/images/pdp_new.png',
        ),
      ],
      comments: [
        JobCommentModel(
          initials: 'SM',
          authorName: 'Sarah Miller',
          date: '14 Oct.',
          question:
              'Bonjour, est-ce que le télétravail est possible pour ce poste ? Merci !',
          recruitorLabel: 'Recrutor',
          recruitorDate: 'Il y a 10 min',
          reply:
              "Bonjour Sarah, oui nous autorisons 2 jours de télétravail par semaine après la période d'intégration.",
        ),
        JobCommentModel(
          initials: 'JD',
          authorName: 'Jean Dupont',
          date: '12 Oct.',
          question: 'Les horaires sont-ils flexibles en début de journée ?',
          recruitorLabel: 'Recrutor',
          recruitorDate: 'Il y a 2 jours',
          reply:
              'Absolument ! Les horaires de bureau sont flexibles entre 8h et 10h le matin.',
        ),
      ],
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
      logoAsset: 'assets/images/imageannonc(2).jpg', // Job announcement image
      isPublished: false,
    ),
    JobModel(
      id: '4',
      title: 'Développeur Flutter',
      companyName: 'ServicePro',
      contractType: 'cdi',
      postedAt: DateTime(2024, 10, 15).toIso8601String(),
      status: 'searching',
      candidateCount: 12,
      viewCount: 340,
      logoAsset: 'assets/images/imageannonc(3).jpg', // Job announcement image
      isPublished: true,
    ),
    JobModel(
      id: '5',
      title: 'UX Designer',
      companyName: 'Creative Agency',
      contractType: 'mission',
      postedAt: DateTime(2024, 10, 18).toIso8601String(),
      status: 'searching',
      candidateCount: 5,
      viewCount: 180,
      logoAsset: 'assets/images/imageannonc(4).jpg', // Job announcement image
      isPublished: true,
    ),
    JobModel(
      id: '6',
      title: 'Chef de projet',
      companyName: 'BuildCorp',
      contractType: 'cdi',
      postedAt: DateTime(2024, 10, 20).toIso8601String(),
      status: 'closed',
      candidateCount: 15,
      viewCount: 520,
      logoAsset: 'assets/images/imageannonc(5).jpg', // Job announcement image
      isPublished: true,
    ),
  ];

  static final List<JobModel> _jobs = List.from(_mockData);

  static final List<MissionModel> _missionsData = [
    MissionModel(
      id: 'm1',
      jobTitle: 'Senior UX Designer',
      companyName: 'TechCorp Solutions',
      startDate:
          DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      endDate: DateTime.now().add(const Duration(days: 14)).toIso8601String(),
      location: 'Paris, FR',
      recruiterName: 'Jean Recruteur',
      candidateName: 'Alice Design',
      candidateRating: 4.5,
      recruiterRating: 4.8,
      candidateFeedback:
          'Alice a fait un excellent travail sur le design system.',
      recruiterFeedback: 'Mission très enrichissante, équipe au top.',
      status: 'in_progress',
      imageUrl: 'assets/images/company_logo_tech.png',
      team: [
        MissionMemberModel(
            name: 'Amélie Laurent',
            role: 'Chef de rang',
            rating: 4.9,
            avatarUrl: 'assets/images/pdp_1.png'),
        MissionMemberModel(
            name: 'Marc Dubois',
            role: 'Barista Expert',
            rating: 4.7,
            avatarUrl: 'assets/images/pdp_4.png'),
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
      imageUrl: 'assets/images/company_logo_service.png',
      team: [
        MissionMemberModel(
            name: 'Amélie Laurent',
            role: 'Chef de rang',
            rating: 4.9,
            avatarUrl: 'assets/images/pdp_1.png'),
        MissionMemberModel(
            name: 'Marc Dubois',
            role: 'Barista Expert',
            rating: 4.7,
            avatarUrl: 'assets/images/pdp_4.png'),
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


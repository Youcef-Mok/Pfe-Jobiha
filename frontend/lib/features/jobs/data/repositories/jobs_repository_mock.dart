import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/features/jobs/domain/mission_entity.dart';
import 'package:job_app/features/jobs/domain/create_mission_params.dart';
import 'package:job_app/features/jobs/data/models/job_model.dart';
import 'package:job_app/features/jobs/data/models/mission_model.dart';
import 'package:job_app/features/jobs/data/repositories/jobs_repository.dart';
import 'dart:typed_data';

/// Implémentation mock du repository.
/// Simule des appels réseau avec des délais artificiels.
///
/// TODO(API): Remplacer par JobsRepositoryHttp dans jobs_provider.dart.
/// Endpoints attendus :
///   GET    /api/jobs/mine             → getMyJobs()
///   GET    /api/jobs/:id              → getJobById()
///   POST   /api/jobs                  → saveJob()  (création)
///   PUT    /api/jobs/:id              → saveJob()  (mise à jour)
///   DELETE /api/jobs/:id              → deleteJob()
///   GET    /api/missions              → getMissions()
///   PUT    /api/missions/:id/review   → updateMissionReview()
class JobsRepositoryMock implements JobsRepository {
  // Données simulées
  static final List<JobModel> _mockData = [
    JobModel(
      id: '2',
      title: 'Chef de Produit',
      companyName: 'TechCorp Solutions',
      recruiterId: 'recruiter_1',
      recruiterName: 'Ahmed Bensalem',
      recruiterRole: 'Responsable RH',
      recruiterAvatarAsset: 'assets/images/pdp_1.png',
      department: 'IT',
      contractType: 'cdi',
      postedAt: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
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
          role: 'Chef de Produit Senior',
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
        JobCommentModel(
          initials: 'NL',
          authorName: 'Nadia Larbi',
          date: '11 Oct.',
          question:
              'Est-ce que vous proposez une formation interne pendant la prise de poste ?',
          recruitorLabel: 'Recrutor',
          recruitorDate: '',
          reply: '',
        ),
      ],
    ),
    JobModel(
      id: '3',
      title: 'Responsable Marketing',
      companyName: 'TechCorp Solutions',
      recruiterId: 'recruiter_2',
      recruiterName: 'Amira Hadj',
      recruiterRole: 'DRH',
      recruiterAvatarAsset: 'assets/images/pdp_2.png',
      department: 'Marketing',
      contractType: 'freelance',
      postedAt: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
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
      recruiterId: 'recruiter_3',
      recruiterName: 'Sofiane Mebarki',
      recruiterRole: 'Talent Acquisition Lead',
      recruiterAvatarAsset: 'assets/images/pdp_4.png',
      department: 'IT',
      contractType: 'cdi',
      postedAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      status: 'searching',
      candidateCount: 12,
      viewCount: 340,
      logoAsset: 'assets/images/imageannonc(3).jpg', // Job announcement image
      isPublished: true,
    ),
    JobModel(
      id: '5',
      title: 'Designer UX',
      companyName: 'Creative Agency',
      recruiterId: 'recruiter_4',
      recruiterName: 'Sarah Jenkins',
      recruiterRole: 'Head of Design',
      recruiterAvatarAsset: 'assets/images/pdp_new.png',
      department: 'Design',
      contractType: 'mission',
      postedAt: DateTime.now().subtract(const Duration(days: 12)).toIso8601String(),
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
      recruiterId: 'recruiter_5',
      recruiterName: 'Karim Bensalem',
      recruiterRole: 'Responsable Recrutement',
      recruiterAvatarAsset: 'assets/images/pdp_1.png',
      department: 'Opérations',
      contractType: 'cdi',
      postedAt: DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
      status: 'closed',
      candidateCount: 15,
      viewCount: 520,
      logoAsset: 'assets/images/imageannonc(5).jpg', // Job announcement image
      isPublished: true,
    ),
  ];

  static final List<JobModel> _jobs = List.from(_mockData);

  static final List<MissionModel> _missionsData = [
    // Missions de Farouja (candidat)
    MissionModel(
      id: 'cm_1',
      jobTitle: 'Serveur Senior',
      companyName: 'Sonatrach',
      department: 'Opérations',
      startDate: DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
      endDate: DateTime.now().add(const Duration(days: 18)).toIso8601String(),
      location: 'Alger',
      recruiterName: 'Karim Bensalem',
      candidateName: 'Farouja',
      candidateRating: 0.0,
      recruiterRating: 0.0,
      candidateFeedback: '',
      recruiterFeedback: '',
      status: 'in_progress',
      imageUrl: 'assets/images/imageannonc(1).jpg',
      team: [
        MissionMemberModel(
          name: 'Karim Bensalem',
          role: 'Responsable Recrutement',
          rating: 4.8,
          avatarUrl: 'assets/images/pdp_4.png',
        ),
      ],
    ),
    MissionModel(
      id: 'cm_2',
      jobTitle: 'Responsable RH',
      companyName: 'Cevital',
      department: 'RH',
      startDate: DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
      endDate: DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      location: 'Béjaïa',
      recruiterName: 'Amira Hadj',
      candidateName: 'Farouja',
      candidateRating: 4.9,
      recruiterRating: 4.8,
      candidateFeedback: 'Excellente expérience chez Cevital. Équipe professionnelle et environnement de travail stimulant.',
      recruiterFeedback: 'Mission de Responsable RH accomplie avec brio. Une vraie expertise en recrutement et gestion d\'équipe.',
      status: 'completed',
      imageUrl: 'assets/images/imageannonc(2).jpg',
      team: [
        MissionMemberModel(
          name: 'Amira Hadj',
          role: 'DRH',
          rating: 4.9,
          avatarUrl: 'assets/images/pdp_2.png',
        ),
      ],
    ),
    MissionModel(
      id: 'cm_3',
      jobTitle: 'Chargée de Recrutement',
      companyName: 'Air Algérie',
      startDate: DateTime.now().subtract(const Duration(days: 200)).toIso8601String(),
      endDate: DateTime.now().subtract(const Duration(days: 110)).toIso8601String(),
      location: 'Alger',
      recruiterName: 'Sofiane Mebarki',
      candidateName: 'Farouja',
      candidateRating: 4.7,
      recruiterRating: 4.5,
      candidateFeedback: 'Mission enrichissante avec Air Algérie. Beaucoup appris sur le recrutement dans le secteur aérien.',
      recruiterFeedback: 'Très bon travail sur les campagnes de recrutement. Professionnalisme exemplaire.',
      status: 'completed',
      imageUrl: null,
      team: [
        MissionMemberModel(
          name: 'Sofiane Mebarki',
          role: 'Responsable RH',
          rating: 4.6,
          avatarUrl: 'assets/images/pdp_4.png',
        ),
      ],
    ),
    // Autres missions (autres candidats)
    MissionModel(
      id: 'm1',
      jobTitle: 'Designer UX Senior',
      companyName: 'TechCorp Solutions',
      department: 'Design',
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
      imageUrl: 'assets/images/imageannonc(1).jpg',
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
      jobTitle: 'Responsable',
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
      imageUrl: 'assets/images/imageannonc(2).jpg',
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
      id: 'm3',
      jobTitle: 'Développeur Full Stack',
      companyName: 'Digital Agency',
      startDate: DateTime(2024, 8, 1).toIso8601String(),
      endDate: DateTime(2024, 8, 31).toIso8601String(),
      location: 'Marseille, FR',
      recruiterName: 'Sophie Martin',
      candidateName: 'Claire Dev',
      candidateRating: 4.8,
      recruiterRating: 4.9,
      candidateFeedback: 'Excellente collaboration sur le projet.',
      recruiterFeedback: 'Mission réussie avec brio.',
      status: 'completed',
      imageUrl: 'assets/images/imageannonc(3).jpg',
      team: [
        MissionMemberModel(
            name: 'Lucas Petit',
            role: 'Responsable Technique',
            rating: 4.8,
            avatarUrl: 'assets/images/pdp_new.png'),
      ],
    ),
    MissionModel(
      id: 'm4',
      jobTitle: 'Chef de Projet Digital',
      companyName: 'Innovation Labs',
      startDate: DateTime(2024, 7, 1).toIso8601String(),
      endDate: DateTime(2024, 7, 31).toIso8601String(),
      location: 'Bordeaux, FR',
      recruiterName: 'Thomas Durand',
      candidateName: 'Emma Project',
      candidateRating: 0.0,
      recruiterRating: 0.0,
      candidateFeedback: '',
      recruiterFeedback: '',
      status: 'completed',
      imageUrl: 'assets/images/imageannonc(4).jpg',
      team: [
        MissionMemberModel(
            name: 'Amélie Laurent',
            role: 'Chef de rang',
            rating: 4.9,
            avatarUrl: 'assets/images/pdp_1.png'),
      ],
    ),
    // APP MISSIONS
    MissionModel(
      id: 'm5',
      jobTitle: 'Serveur Principal - Événement Gala',
      companyName: 'LuxCatering Services',
      startDate: DateTime(2026, 2, 5).toIso8601String(),
      endDate: DateTime(2026, 4, 6).toIso8601String(),
      location: 'Paris, FR',
      recruiterName: 'Sophie Laurent',
      candidateName: 'Farouja',
      candidateRating: 4.8,
      recruiterRating: 4.8,
      candidateFeedback: 'Excellente prestation lors du gala.',
      recruiterFeedback: 'Professionnalisme exemplaire.',
      status: 'completed',
      imageUrl: 'assets/images/imageannonc(1).jpg',
      team: [
        MissionMemberModel(
            name: 'Sophie Laurent',
            role: 'Responsable Événementiel',
            rating: 4.9,
            avatarUrl: 'assets/images/pdp_1.png'),
      ],
    ),
    MissionModel(
      id: 'm6',
      jobTitle: 'Chef de Cuisine - Restaurant Étoilé',
      companyName: 'Michelin Stars Group',
      startDate: DateTime(2025, 11, 1).toIso8601String(),
      endDate: DateTime(2025, 12, 31).toIso8601String(),
      location: 'Lyon, FR',
      recruiterName: 'Jean Dupont',
      candidateName: 'Farouja',
      candidateRating: 4.9,
      recruiterRating: 4.7,
      candidateFeedback: 'Créativité culinaire impressionnante.',
      recruiterFeedback: 'Très bon travail en équipe.',
      status: 'completed',
      imageUrl: 'assets/images/imageannonc(2).jpg',
      team: [
        MissionMemberModel(
            name: 'Jean Dupont',
            role: 'Chef Cuisinier',
            rating: 4.8,
            avatarUrl: 'assets/images/pdp_4.png'),
      ],
    ),
    MissionModel(
      id: 'm7',
      jobTitle: 'Sommelier - Dégustation de Vins',
      companyName: 'Prestige Wines',
      startDate: DateTime(2025, 9, 15).toIso8601String(),
      endDate: DateTime(2025, 10, 15).toIso8601String(),
      location: 'Bordeaux, FR',
      recruiterName: 'Marc Beaumont',
      candidateName: 'Farouja',
      candidateRating: 4.6,
      recruiterRating: 4.9,
      candidateFeedback: 'Expérience enrichissante.',
      recruiterFeedback: 'Connaissances exceptionnelles.',
      status: 'completed',
      imageUrl: 'assets/images/imageannonc(3).jpg',
      team: [
        MissionMemberModel(
            name: 'Marc Beaumont',
            role: 'Directeur des Vins',
            rating: 4.9,
            avatarUrl: 'assets/images/pdp_new.png'),
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
  Future<List<JobEntity>> getAllJobs() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _jobs.map((m) => m.toEntity()).toList();
  }

  @override
  Future<JobEntity> saveJob(
    JobEntity job, {
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
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

  static void _purgeExpiredUnconfirmedMissions(List<MissionModel> missions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    missions.removeWhere((m) {
      if (m.status != 'unconfirmed') return false;
      final start = DateTime.parse(m.startDate);
      final startDay = DateTime(start.year, start.month, start.day);
      return !today.isBefore(startDay);
    });
  }

  @override
  Future<List<MissionEntity>> getMissions() async {
    // TODO(API): GET /api/v1/missions — le backend purge les non confirmées expirées
    await Future.delayed(const Duration(milliseconds: 600));
    _purgeExpiredUnconfirmedMissions(_missions);
    return _missions.map((m) => m.toEntity()).toList();
  }

  @override
  Future<MissionEntity> createMission(CreateMissionParams params) async {
    // TODO(API): POST /api/v1/missions
    await Future.delayed(const Duration(milliseconds: 400));
    final model = MissionModel(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      jobId: params.jobId,
      jobTitle: params.jobTitle,
      companyName: params.companyName,
      department: params.department,
      startDate: params.startDate.toIso8601String(),
      endDate: params.endDate.toIso8601String(),
      location: params.location,
      recruiterName: 'Ahmed',
      candidateName: params.candidateName,
      status: 'unconfirmed',
      imageUrl: params.imageUrl,
      candidateRating: 0,
      recruiterRating: 0,
      candidateFeedback: '',
      recruiterFeedback: '',
      team: const [],
    );
    _missions.insert(0, model);
    return model.toEntity();
  }

  @override
  Future<MissionEntity> confirmMission(String missionId) async {
    // TODO(API): PATCH /api/v1/missions/:id/confirm
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _missions.indexWhere((m) => m.id == missionId);
    if (index < 0) throw StateError('Mission not found');
    final m = _missions[index];
    _missions[index] = MissionModel(
      id: m.id,
      jobId: m.jobId,
      jobTitle: m.jobTitle,
      companyName: m.companyName,
      department: m.department,
      startDate: m.startDate,
      endDate: m.endDate,
      location: m.location,
      recruiterName: m.recruiterName,
      candidateName: m.candidateName,
      candidateRating: m.candidateRating,
      recruiterRating: m.recruiterRating,
      candidateFeedback: m.candidateFeedback,
      recruiterFeedback: m.recruiterFeedback,
      status: 'in_progress',
      summary: m.summary,
      imageUrl: m.imageUrl,
      team: m.team,
    );
    return _missions[index].toEntity();
  }

  @override
  Future<MissionEntity> updateMissionReview(String missionId, double rating, String feedback) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _missions.indexWhere((m) => m.id == missionId);
    if (index >= 0) {
      final mission = _missions[index];
      _missions[index] = MissionModel(
        id: mission.id,
        jobId: mission.jobId,
        jobTitle: mission.jobTitle,
        companyName: mission.companyName,
        department: mission.department,
        startDate: mission.startDate,
        endDate: mission.endDate,
        location: mission.location,
        recruiterName: mission.recruiterName,
        candidateName: mission.candidateName,
        candidateRating: rating,
        candidateFeedback: feedback,
        recruiterRating: mission.recruiterRating,
        recruiterFeedback: mission.recruiterFeedback,
        status: 'completed',
        imageUrl: mission.imageUrl,
        team: mission.team,
      );
      return _missions[index].toEntity();
    }
    throw Exception('Mission not found');
  }

  final Set<String> _savedJobIds = {'4', '5'};

  @override
  Future<Set<String>> getSavedJobIds() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return Set<String>.from(_savedJobIds);
  }

  @override
  Future<List<JobEntity>> getSavedJobs() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _jobs
        .where((j) => _savedJobIds.contains(j.id))
        .map((j) => j.toEntity())
        .toList();
  }

  @override
  Future<void> saveJobById(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 120));
    _savedJobIds.add(jobId);
  }

  @override
  Future<void> unsaveJobById(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 120));
    _savedJobIds.remove(jobId);
  }
}


import 'package:job_app/features/profile/domain/user_entity.dart';
import 'package:job_app/features/profile/domain/cv_entity.dart';
import 'package:job_app/features/profile/data/models/user_model.dart';
import 'package:job_app/features/profile/data/repositories/user_repository.dart';

/// Implémentation mock du repository utilisateur
class UserRepositoryMock implements UserRepository {
  static final Map<String, UserModel> _recruiters = {
    'recruiter_1': UserModel(
      id: 'recruiter_1',
      name: 'Ahmed Bensalem',
      role: 'Responsable RH',
      domain: 'Restauration',
      company: 'Le Petit Bistro',
      location: 'Alger, DZ',
      bio:
          'Je recrute des profils cuisine et salle pour renforcer des equipes performantes et offrir une experience client de haut niveau.',
      avatarUrl: 'assets/images/pdp_1.png',
      followersCount: 860,
      missionsCount: 52,
      rating: 4.9,
      accountType: 'recruiter',
    ),
    'recruiter_2': UserModel(
      id: 'recruiter_2',
      name: 'Amira Hadj',
      role: 'DRH',
      domain: 'Industrie',
      company: 'Cevital',
      location: 'Bejaia, DZ',
      bio: 'DRH avec 10+ ans d experience en recrutement et structuration RH.',
      avatarUrl: 'assets/images/pdp_2.png',
      followersCount: 540,
      missionsCount: 38,
      rating: 4.8,
      accountType: 'recruiter',
    ),
    'recruiter_3': UserModel(
      id: 'recruiter_3',
      name: 'Sofiane Mebarki',
      role: 'Talent Acquisition Lead',
      domain: 'Aérien',
      company: 'Air Algerie',
      location: 'Alger, DZ',
      bio: 'J accompagne les equipes dans le recrutement de profils operationnels.',
      avatarUrl: 'assets/images/pdp_4.png',
      followersCount: 430,
      missionsCount: 44,
      rating: 4.7,
      accountType: 'recruiter',
    ),
    'recruiter_4': UserModel(
      id: 'recruiter_4',
      name: 'Sarah Jenkins',
      role: 'Head of Design',
      domain: 'Design',
      company: 'Creative Agency',
      location: 'Lyon, FR',
      bio: 'I build high-performing design teams and product design processes.',
      avatarUrl: 'assets/images/pdp_new.png',
      followersCount: 920,
      missionsCount: 61,
      rating: 4.9,
      accountType: 'recruiter',
    ),
    'recruiter_5': UserModel(
      id: 'recruiter_5',
      name: 'Karim Bensalem',
      role: 'Responsable Recrutement',
      domain: 'Operations',
      company: 'BuildCorp',
      location: 'Oran, DZ',
      bio: 'Specialise dans le recrutement terrain et la gestion de missions longues.',
      avatarUrl: 'assets/images/pdp_1.png',
      followersCount: 310,
      missionsCount: 29,
      rating: 4.6,
      accountType: 'recruiter',
    ),
  };
  static final Map<String, UserModel> _candidates = {
    'candidate_1': const UserModel(
      id: 'candidate_1',
      name: 'Farouja',
      role: 'Serveuse',
      domain: 'Restauration',
      company: 'Indépendant',
      location: 'Alger, DZ',
      bio:
          'Candidate experimentee en restauration, service en salle et coordination d equipe.',
      avatarUrl: 'assets/images/imageannonc(3).jpg',
      followersCount: 0,
      missionsCount: 120,
      rating: 4.9,
      accountType: 'candidate',
    ),
    'candidate_2': const UserModel(
      id: 'candidate_2',
      name: 'Lina Rahal',
      role: 'Chargee de recrutement',
      domain: 'RH',
      company: 'Freelance',
      location: 'Oran, DZ',
      bio: 'J accompagne les equipes RH sur le sourcing et la preselection.',
      avatarUrl: 'assets/images/pdp_2.png',
      followersCount: 0,
      missionsCount: 34,
      rating: 4.7,
      accountType: 'candidate',
    ),
  };

  // TODO(API): GET /api/v1/users/:userId/reviews
  //            En production, le backend filtre par userId côté serveur.
  //            Supprimer la branche candidate_1 ici et utiliser directement l'endpoint.

  // Avis reçus sur le profil recruteur
  static final List<EmployeeReviewModel> _reviews = [
    EmployeeReviewModel(
      id: 'review_1',
      authorName: 'Sarah Jenkins',
      authorRole: 'Chef de rang',
      authorAvatar: 'https://i.pravatar.cc/150?img=48',
      rating: 5.0,
      comment:
          'Une ambiance de travail incroyable et une gestion très humaine. C\'est l\'endroit idéal pour apprendre le métier de la restauration.',
      recruiterReply:
          'Merci Sarah ! Ce fut un plaisir de t\'avoir parmi nous en salle. Bonne continuation !',
      recruiterName: 'Marc-Antoine Lefebvre',
      recruiterReplyDate: 'Il y a 2 jours',
    ),
    EmployeeReviewModel(
      id: 'review_2',
      authorName: 'Marcus Chen',
      authorRole: 'Sous-chef',
      authorAvatar: 'https://i.pravatar.cc/150?img=12',
      rating: 5.0,
      comment:
          'Des défis techniques passionnants en cuisine et une équipe de chefs très soudée. Je recommande vivement !',
      recruiterReply:
          'Nous sommes ravis que la créativité en cuisine te plaise, Marcus. Merci pour ton engagement !',
      recruiterName: 'Marc-Antoine Lefebvre',
      recruiterReplyDate: 'Il y a 1 jour',
    ),
    EmployeeReviewModel(
      id: 'review_3',
      authorName: 'Nadia Benali',
      authorRole: 'Serveuse',
      authorAvatar: 'https://i.pravatar.cc/150?img=32',
      rating: 4.0,
      comment:
          'Bonne expérience globale, l\'équipe est respectueuse. J\'aurais aimé un planning un peu plus stable.',
      recruiterReply: null,
      recruiterName: null,
      recruiterReplyDate: null,
    ),
  ];

  // Avis reçus sur le profil candidat (Farouja — userId: 'candidate_1')
  static final List<EmployeeReviewModel> _candidateReviews = [
    EmployeeReviewModel(
      id: 'review_c1',
      authorName: 'Karim Bensalem',
      authorRole: 'Recruteur chez Sonatrach',
      authorAvatar: 'assets/images/pdp_1.png',
      rating: 5.0,
      comment:
          'Excellente collaboration sur la mission de Tech Recruiter. Farouja a su s\'adapter rapidement à nos besoins et a fait preuve d\'un grand professionnalisme.',
      recruiterReply: null,
      recruiterName: null,
      recruiterReplyDate: null,
    ),
    EmployeeReviewModel(
      id: 'review_c2',
      authorName: 'Amira Hadj',
      authorRole: 'DRH chez Cevital',
      authorAvatar: 'assets/images/pdp_2.png',
      rating: 5.0,
      comment:
          'Mission de Responsable RH accomplie avec brio. Une vraie expertise en recrutement et gestion d\'équipe. Je recommande vivement !',
      recruiterReply: null,
      recruiterName: null,
      recruiterReplyDate: null,
    ),
    EmployeeReviewModel(
      id: 'review_c3',
      authorName: 'Sofiane Mebarki',
      authorRole: 'Manager RH chez Air Algérie',
      authorAvatar: 'assets/images/pdp_4.png',
      rating: 4.0,
      comment:
          'Très bonne expérience sur la mission de Chargée de Recrutement. Farouja a su gérer efficacement le processus de recrutement.',
      recruiterReply: null,
      recruiterName: null,
      recruiterReplyDate: null,
    ),
  ];
  static final Map<String, List<EmployeeReviewModel>> _reviewsByUserId = {
    'candidate_1': _candidateReviews,
    'candidate_2': _candidateReviews,
    'recruiter_1': _reviews,
    'recruiter_2': _reviews,
    'recruiter_3': _reviews,
    'recruiter_4': _reviews,
    'recruiter_5': _reviews,
  };

  static const _cvData = CvEntity(
    formations: [
      CvFormationEntity(
        title: 'Master en Management de l\'Hôtellerie',
        institution: 'École Hôtelière de Lausanne',
        location: 'Lausanne, CH',
        year: 2021,
        isActive: true,
        fileName: 'master_management_hotellerie.pdf',
        filePath: null,
      ),
      CvFormationEntity(
        title: 'Licence Gestion Événementielle',
        institution: 'Université Paris Dauphine',
        location: 'Paris, FR',
        year: 2019,
        isActive: false,
        fileName: null,
        filePath: null,
      ),
      CvFormationEntity(
        title: 'BTS Hôtellerie-Restauration',
        institution: 'Lycée Hôtelier Paul Augier',
        location: 'Nice, FR',
        year: 2017,
        isActive: false,
        fileName: null,
        filePath: null,
      ),
    ],
    experiences: [
      CvExperienceEntity(
        title: 'Chef de Rang - Événement Grand Gala',
        company: 'LuxCatering Services',
        location: 'Paris, FR',
        isAppMission: true,
        isActive: true,
      ),
      CvExperienceEntity(
        title: 'Barista Junior',
        company: 'Morning Brew Café',
        location: 'Londres, UK',
        period: 'Sep 2021 - Août 2023',
        isAppMission: false,
        isActive: false,
      ),
      CvExperienceEntity(
        title: 'Assistant Chef Privé',
        company: 'Maison Traiteur Elite',
        location: 'Paris, FR',
        endDate: 'Août 2021',
        isAppMission: true,
        isActive: true,
      ),
      CvExperienceEntity(
        title: 'Serveuse Senior',
        company: 'Le Petit Bistro',
        location: 'Alger, DZ',
        period: 'Jan 2019 - Août 2021',
        isAppMission: false,
        isActive: false,
      ),
    ],
    languages: [
      CvLanguageEntity(name: 'Anglais', level: 'Courant (C1)'),
      CvLanguageEntity(name: 'Espagnol', level: 'Intermédiaire (B2)'),
      CvLanguageEntity(name: 'Français', level: 'Courant (C2)'),
      CvLanguageEntity(name: 'Arabe', level: 'Natif'),
    ],
    skills: [
      CvSkillEntity(name: 'Service en salle', levelLabel: 'EXPERT', progress: 0.90),
      CvSkillEntity(name: 'Management d\'équipe', levelLabel: 'AVANCÉ', progress: 0.70),
      CvSkillEntity(name: 'Gestion de caisse', progress: 0.85),
      CvSkillEntity(name: 'Accueil client', progress: 0.45),
    ],
  );

  @override
  Future<UserEntity> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _recruiters['recruiter_1']!.toEntity();
  }

  @override
  Future<UserEntity> getUserById(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final user = _recruiters[userId] ?? _candidates[userId] ?? _recruiters['recruiter_1']!;
    return user.toEntity();
  }

  @override
  Future<List<EmployeeReviewEntity>> getEmployeeReviews(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // TODO(API): GET /api/v1/users/:userId/reviews.
    final source = _reviewsByUserId[userId] ?? const <EmployeeReviewModel>[];
    return source.map((r) => r.toEntity()).toList();
  }

  @override
  Future<UserEntity> updateProfile(UserEntity user) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return user;
  }

  @override
  Future<CvEntity> getCvData(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _cvData;
  }

  @override
  Future<CvExperienceEntity> addExperience(CvExperienceEntity exp) async => exp;

  @override
  Future<CvFormationEntity> addFormation(CvFormationEntity formation) async => formation;

  @override
  Future<CvLanguageEntity> addLanguage(CvLanguageEntity language) async => language;

  @override
  Future<CvSkillEntity> addSkill(CvSkillEntity skill) async => skill;
}

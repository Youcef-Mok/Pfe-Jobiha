import 'package:job_app/features/profile/domain/user_entity.dart';
import 'package:job_app/features/profile/domain/cv_entity.dart';
import 'package:job_app/features/profile/data/models/user_model.dart';
import 'package:job_app/features/profile/data/repositories/user_repository.dart';

/// Implémentation mock du repository utilisateur
class UserRepositoryMock implements UserRepository {
  static final UserModel _currentUser = UserModel(
    id: 'recruiter_1',
    name: 'Ahmed Bensalem',
    role: 'Recruteur Senior',
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
  );

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
    return _currentUser.toEntity();
  }

  @override
  Future<List<EmployeeReviewEntity>> getEmployeeReviews(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // TODO(API): GET /api/v1/users/:userId/reviews — supprimer ce if/else,
    //            le backend retournera les avis du bon utilisateur.
    final source = userId == 'candidate_1' ? _candidateReviews : _reviews;
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
}

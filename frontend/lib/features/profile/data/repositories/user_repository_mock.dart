import 'package:job_app/features/profile/domain/user_entity.dart';
import 'package:job_app/features/profile/domain/cv_entity.dart';
import 'package:job_app/features/profile/data/models/user_model.dart';
import 'package:job_app/features/profile/data/repositories/user_repository.dart';

/// Implémentation mock du repository utilisateur
class UserRepositoryMock implements UserRepository {
  static final UserModel _currentUser = UserModel(
    id: 'user_1',
    name: 'Farouja',
    role: 'Gérante',
    domain: 'Restauration',
    company: 'Le petit bistro',
    location: 'Alger Birlmouta',
    bio:
        'Passionné par la gastronomie et le service d\'excellence, je recrute des talents pour dynamiser nos équipes en cuisine et en salle. Mon objectif est de créer une expérience client inoubliable au quotidien.',
    avatarUrl: 'https://i.pravatar.cc/150?img=47',
    followersCount: 1200,
    missionsCount: 45,
    rating: 4.8,
    accountType: 'recruiter',
  );

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
    return _reviews.map((r) => r.toEntity()).toList();
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

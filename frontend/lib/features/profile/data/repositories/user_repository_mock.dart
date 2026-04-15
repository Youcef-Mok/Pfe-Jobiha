import 'package:job_app/features/profile/domain/user_entity.dart';
import 'package:job_app/features/profile/data/models/user_model.dart';
import 'package:job_app/features/profile/data/repositories/user_repository.dart';

/// Implémentation mock du repository utilisateur
class UserRepositoryMock implements UserRepository {
  static final UserModel _currentUser = UserModel(
    id: 'user_1',
    name: 'Farouja',
    role: 'gerante, le petit bistro',
    company: 'Restauration',
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
          'Bonne expérience globale, l’équipe est respectueuse. J’aurais aimé un planning un peu plus stable.',
      recruiterReply: null,
      recruiterName: null,
      recruiterReplyDate: null,
    ),
  ];

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
}

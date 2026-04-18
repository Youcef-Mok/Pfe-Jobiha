import 'package:job_app/features/profile/domain/user_entity.dart';

/// Interface abstraite du repository utilisateur
abstract class UserRepository {
  /// Récupère le profil de l'utilisateur connecté
  Future<UserEntity> getCurrentUser();

  /// Récupère les avis des employés pour un recruteur
  Future<List<EmployeeReviewEntity>> getEmployeeReviews(String userId);

  /// Met à jour le profil utilisateur
  Future<UserEntity> updateProfile(UserEntity user);
}

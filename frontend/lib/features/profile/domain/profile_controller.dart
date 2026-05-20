import 'package:job_app/features/profile/data/repositories/user_repository.dart';
import 'package:job_app/features/profile/domain/cv_entity.dart';
import 'package:job_app/features/profile/domain/user_entity.dart';

// TODO(API): Toutes les méthodes passent par UserRepository.
//            Voir API_SPEC.md sections "USERS / PROFILE" et "MISSIONS".

class ProfileController {
  final UserRepository _repository;

  ProfileController(this._repository);

  Future<UserEntity> fetchCurrentUser() {
    // TODO(API): GET /api/v1/users/me
    return _repository.getCurrentUser();
  }

  Future<List<EmployeeReviewEntity>> fetchEmployeeReviews(String userId) {
    // TODO(API): GET /api/v1/users/:userId/reviews
    return _repository.getEmployeeReviews(userId);
  }

  Future<CvEntity> fetchCvData(String userId) {
    // TODO(API): GET /api/v1/users/:userId/cv
    return _repository.getCvData(userId);
  }

  Future<UserEntity> updateProfile(UserEntity user) {
    // TODO(API): PUT /api/v1/users/me
    return _repository.updateProfile(user);
  }
}

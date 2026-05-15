import 'package:job_app/features/profile/data/repositories/user_repository.dart';
import 'package:job_app/features/profile/domain/cv_entity.dart';
import 'package:job_app/features/profile/domain/user_entity.dart';

class ProfileController {
  final UserRepository _repository;

  ProfileController(this._repository);

  Future<UserEntity> fetchCurrentUser() {
    return _repository.getCurrentUser();
  }

  Future<List<EmployeeReviewEntity>> fetchEmployeeReviews(String userId) {
    return _repository.getEmployeeReviews(userId);
  }

  Future<CvEntity> fetchCvData(String userId) {
    return _repository.getCvData(userId);
  }

  Future<UserEntity> updateProfile(UserEntity user) {
    return _repository.updateProfile(user);
  }
}

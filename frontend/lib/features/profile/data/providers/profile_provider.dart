import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/features/profile/domain/user_entity.dart';
import 'package:job_app/features/profile/domain/cv_entity.dart';
import 'package:job_app/features/profile/data/repositories/user_repository.dart';
import 'package:job_app/features/profile/data/repositories/user_repository_mock.dart';

// ─────────────────────────────────────────────
// 1. Repository Provider
// ─────────────────────────────────────────────
final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepositoryMock(),
);

// ─────────────────────────────────────────────
// 2. Current User Provider
// ─────────────────────────────────────────────
final currentUserProvider = FutureProvider<UserEntity>((ref) async {
  final repo = ref.watch(userRepositoryProvider);
  return await repo.getCurrentUser();
});

// ─────────────────────────────────────────────
// 3. Employee Reviews Provider
// ─────────────────────────────────────────────
final employeeReviewsProvider =
    FutureProvider<List<EmployeeReviewEntity>>((ref) async {
  final repo = ref.watch(userRepositoryProvider);
  final user = await ref.watch(currentUserProvider.future);
  return await repo.getEmployeeReviews(user.id);
});

// ─────────────────────────────────────────────
// 4. CV Data Provider
// ─────────────────────────────────────────────
final cvDataProvider = FutureProvider<CvEntity>((ref) async {
  final repo = ref.watch(userRepositoryProvider);
  final user = await ref.watch(currentUserProvider.future);
  return await repo.getCvData(user.id);
});

// ─────────────────────────────────────────────
// 5. Profile Tab Selection
// ─────────────────────────────────────────────
enum ProfileTab { annonces, missions, competences, reviews }

final profileTabProvider =
    StateProvider<ProfileTab>((ref) => ProfileTab.annonces);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/features/profile/domain/user_entity.dart';
import 'package:job_app/features/profile/domain/cv_entity.dart';
import 'package:job_app/features/profile/domain/profile_controller.dart';
import 'package:job_app/features/profile/data/repositories/user_repository.dart';
import 'package:job_app/features/profile/data/repositories/user_repository_api.dart';

// ─────────────────────────────────────────────
// 1. Repository Provider
// ─────────────────────────────────────────────
final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepositoryApi(),
);

final profileControllerProvider = Provider<ProfileController>(
  (ref) => ProfileController(ref.watch(userRepositoryProvider)),
);

// ─────────────────────────────────────────────
// 2. Current User Provider (Real API - No Mock Data)
// ─────────────────────────────────────────────
final currentUserProvider = FutureProvider<UserEntity>((ref) async {
  ref.keepAlive();
  final controller = ref.watch(profileControllerProvider);
  return await controller.fetchCurrentUser();
});

final publicRecruiterProvider =
    FutureProvider.family<UserEntity, String>((ref, recruiterId) async {
  ref.keepAlive();
  final controller = ref.watch(profileControllerProvider);
  return await controller.fetchUserById(recruiterId);
});

final publicUserProvider = publicRecruiterProvider;

final publicRecruiterReviewsProvider =
    FutureProvider.family<List<EmployeeReviewEntity>, String>(
        (ref, recruiterId) async {
  ref.keepAlive();
  final controller = ref.watch(profileControllerProvider);
  return await controller.fetchEmployeeReviews(recruiterId);
});

final publicUserReviewsProvider = publicRecruiterReviewsProvider;

// ─────────────────────────────────────────────
// 3. Employee Reviews Provider
// ─────────────────────────────────────────────
final employeeReviewsProvider =
    FutureProvider<List<EmployeeReviewEntity>>((ref) async {
  ref.keepAlive();
  final controller = ref.watch(profileControllerProvider);
  final user = await ref.watch(currentUserProvider.future);
  return await controller.fetchEmployeeReviews(user.id);
});

// ─────────────────────────────────────────────
// 4. CV Data Provider (avec gestion d'état pour ajouts)
// ─────────────────────────────────────────────
class CvNotifier extends StateNotifier<AsyncValue<CvEntity>> {
  final ProfileController _controller;
  final String _userId;

  CvNotifier(this._controller, this._userId) : super(const AsyncValue.loading()) {
    _loadCv();
  }

  Future<void> _loadCv() async {
    try {
      final cv = await _controller.fetchCvData(_userId);
      state = AsyncValue.data(cv);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void addFormation(CvFormationEntity formation) {
    state.whenData((cv) {
      state = AsyncValue.data(CvEntity(
        formations: [...cv.formations, formation],
        experiences: cv.experiences,
        languages: cv.languages,
        skills: cv.skills,
      ));
    });
  }

  void addExperience(CvExperienceEntity experience) {
    state.whenData((cv) {
      state = AsyncValue.data(CvEntity(
        formations: cv.formations,
        experiences: [...cv.experiences, experience],
        languages: cv.languages,
        skills: cv.skills,
      ));
    });
  }

  void addLanguage(CvLanguageEntity language) {
    state.whenData((cv) {
      state = AsyncValue.data(CvEntity(
        formations: cv.formations,
        experiences: cv.experiences,
        languages: [...cv.languages, language],
        skills: cv.skills,
      ));
    });
  }

  void addSkill(CvSkillEntity skill) {
    state.whenData((cv) {
      state = AsyncValue.data(CvEntity(
        formations: cv.formations,
        experiences: cv.experiences,
        languages: cv.languages,
        skills: [...cv.skills, skill],
      ));
    });
  }

  Future<void> refresh() => _loadCv();
}

final cvDataProvider = FutureProvider<CvEntity>((ref) async {
  ref.keepAlive();
  final controller = ref.watch(profileControllerProvider);
  final user = await ref.watch(currentUserProvider.future);
  return await controller.fetchCvData(user.id);
});

final cvNotifierProvider = StateNotifierProvider<CvNotifier, AsyncValue<CvEntity>>((ref) {
  final controller = ref.watch(profileControllerProvider);
  return CvNotifier(controller, 'candidate_1');
});

// ─────────────────────────────────────────────
// 5. Profile Tab Selection
// ─────────────────────────────────────────────
enum ProfileTab { description, annonces, missions }

final profileTabProvider =
    StateProvider<ProfileTab>((ref) => ProfileTab.description);

// ─────────────────────────────────────────────────────────────────────────────
// Candidate profile (with update capabilities)
// ─────────────────────────────────────────────────────────────────────────────
enum CandidateProfileTab { description, competences, missions }

final candidateProfileTabProvider =
    StateProvider<CandidateProfileTab>((ref) => CandidateProfileTab.description);

class CandidateUserNotifier extends StateNotifier<AsyncValue<UserEntity>> {
  final ProfileController _controller;

  CandidateUserNotifier(this._controller) : super(const AsyncValue.loading()) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _controller.fetchCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void updateProfilePhoto(String newAvatarUrl) {
    state.whenData((user) {
      state = AsyncValue.data(user.copyWith(avatarUrl: newAvatarUrl));
    });
  }

  Future<void> updateProfileInfo({
    String? name,
    String? bio,
    String? location,
    String? domain,
  }) async {
    try {
      final currentUser = state.value;
      if (currentUser == null) return;

      // Update locally first for immediate UI feedback
      final updatedUser = currentUser.copyWith(
        name: name ?? currentUser.name,
        bio: bio ?? currentUser.bio,
        location: location ?? currentUser.location,
        domain: domain ?? currentUser.domain,
      );
      state = AsyncValue.data(updatedUser);

      // Then save to backend
      await _controller.updateProfile(updatedUser);
      
      // Reload to get server state
      await _loadUser();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => _loadUser();
}

final candidateCurrentUserProvider = StateNotifierProvider<CandidateUserNotifier, AsyncValue<UserEntity>>((ref) {
  final controller = ref.watch(profileControllerProvider);
  return CandidateUserNotifier(controller);
});

final candidateEmployeeReviewsProvider =
    FutureProvider<List<EmployeeReviewEntity>>((ref) async {
  ref.keepAlive();
  final controller = ref.watch(profileControllerProvider);
  // TODO(API): GET /api/v1/users/:userId/reviews — remplacer 'candidate_1' par l'ID de l'utilisateur authentifié
  return await controller.fetchEmployeeReviews('candidate_1');
});

final candidateCvDataProvider = FutureProvider<CvEntity>((ref) async {
  ref.keepAlive();
  final controller = ref.watch(profileControllerProvider);
  return await controller.fetchCvData('candidate_1');
});

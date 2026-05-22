import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/features/profile/domain/user_entity.dart';
import 'package:job_app/features/profile/domain/cv_entity.dart';
import 'package:job_app/features/profile/domain/profile_controller.dart';
import 'package:job_app/features/profile/data/repositories/user_repository.dart';
import 'package:job_app/features/profile/data/repositories/user_repository_http.dart';

// ─────────────────────────────────────────────
// 1. Repository Provider
// ─────────────────────────────────────────────

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepositoryHttp(),
);

final profileControllerProvider = Provider<ProfileController>(
  (ref) => ProfileController(ref.watch(userRepositoryProvider)),
);

// ─────────────────────────────────────────────
// 2. User Notifier (Main Profile State)
// ─────────────────────────────────────────────

class UserNotifier extends StateNotifier<AsyncValue<UserEntity>> {
  final ProfileController _controller;

  UserNotifier(this._controller) : super(const AsyncValue.loading()) {
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

  void updateUser(UserEntity updatedUser) {
    state = AsyncValue.data(updatedUser);
  }

  void updateProfilePhoto(String newAvatarUrl) {
    state.whenData((user) {
      state = AsyncValue.data(user.copyWith(avatarUrl: newAvatarUrl));
    });
  }

  void updateProfileInfo({
    String? name,
    String? bio,
    String? location,
    String? domain,
  }) {
    state.whenData((user) {
      state = AsyncValue.data(user.copyWith(
        name: name ?? user.name,
        bio: bio ?? user.bio,
        location: location ?? user.location,
        domain: domain ?? user.domain,
      ));
    });
  }

  Future<void> refresh() => _loadUser();
}

// ─────────────────────────────────────────────
// 3. Current User Provider (API)
// ─────────────────────────────────────────────

final currentUserProvider = FutureProvider<UserEntity>((ref) async {
  ref.keepAlive();
  final controller = ref.watch(profileControllerProvider);
  return await controller.fetchCurrentUser();
});

// ─────────────────────────────────────────────
// 4. Public Profiles
// ─────────────────────────────────────────────

final publicRecruiterProvider =
    FutureProvider.family<UserEntity, String>((ref, recruiterId) async {
  ref.keepAlive();
  final controller = ref.watch(profileControllerProvider);
  return await controller.fetchUserById(recruiterId);
});

final publicUserProvider = publicRecruiterProvider;

// ─────────────────────────────────────────────
// 5. Reviews
// ─────────────────────────────────────────────

final publicRecruiterReviewsProvider =
    FutureProvider.family<List<EmployeeReviewEntity>, String>(
        (ref, recruiterId) async {
  ref.keepAlive();
  final controller = ref.watch(profileControllerProvider);
  return await controller.fetchEmployeeReviews(recruiterId);
});

final publicUserReviewsProvider = publicRecruiterReviewsProvider;

final employeeReviewsProvider =
    FutureProvider<List<EmployeeReviewEntity>>((ref) async {
  ref.keepAlive();
  final controller = ref.watch(profileControllerProvider);
  final user = await ref.watch(currentUserProvider.future);
  return await controller.fetchEmployeeReviews(user.id);
});

// ─────────────────────────────────────────────
// 6. CV Notifier
// ─────────────────────────────────────────────

class CvNotifier extends StateNotifier<AsyncValue<CvEntity>> {
  final ProfileController _controller;

  CvNotifier(this._controller) : super(const AsyncValue.loading()) {
    _loadCv();
  }

  Future<void> _loadCv() async {
    try {
      final user = await _controller.fetchCurrentUser();
      final cv = await _controller.fetchCvData(user.id);
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

// Providers

final cvDataProvider = FutureProvider<CvEntity>((ref) async {
  ref.keepAlive();
  final controller = ref.watch(profileControllerProvider);
  final user = await ref.watch(currentUserProvider.future);
  return await controller.fetchCvData(user.id);
});

final cvNotifierProvider =
    StateNotifierProvider<CvNotifier, AsyncValue<CvEntity>>((ref) {
  return CvNotifier(ref.watch(profileControllerProvider));
});

// ─────────────────────────────────────────────
// 7. Profile Tabs
// ─────────────────────────────────────────────

enum ProfileTab { description, annonces, missions }

final profileTabProvider =
    StateProvider<ProfileTab>((ref) => ProfileTab.description);

enum CandidateProfileTab { description, competences, missions }

final candidateProfileTabProvider =
    StateProvider<CandidateProfileTab>(
        (ref) => CandidateProfileTab.description);

// ─────────────────────────────────────────────
// 8. Candidate User Notifier (UPDATED VERSION)
// ─────────────────────────────────────────────

class CandidateUserNotifier extends StateNotifier<AsyncValue<UserEntity>> {
  final ProfileController _controller;

  CandidateUserNotifier(this._controller)
      : super(const AsyncValue.loading()) {
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

  void updateUser(UserEntity updatedUser) {
    state = AsyncValue.data(updatedUser);
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

      final updatedUser = currentUser.copyWith(
        name: name ?? currentUser.name,
        bio: bio ?? currentUser.bio,
        location: location ?? currentUser.location,
        domain: domain ?? currentUser.domain,
      );

      // optimistic update
      state = AsyncValue.data(updatedUser);

      // persist to backend
      await _controller.updateProfile(updatedUser);

      // refresh from server
      await _loadUser();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => _loadUser();
}

final candidateCurrentUserProvider =
    StateNotifierProvider<CandidateUserNotifier, AsyncValue<UserEntity>>((ref) {
  return CandidateUserNotifier(ref.watch(profileControllerProvider));
});

// ─────────────────────────────────────────────
// 9. Candidate extra providers
// ─────────────────────────────────────────────

final candidateEmployeeReviewsProvider =
    FutureProvider<List<EmployeeReviewEntity>>((ref) async {
  ref.keepAlive();
  final controller = ref.watch(profileControllerProvider);
  final user = await ref.watch(currentUserProvider.future);
  return await controller.fetchEmployeeReviews(user.id);
});

final candidateCvDataProvider = FutureProvider<CvEntity>((ref) async {
  ref.keepAlive();
  final controller = ref.watch(profileControllerProvider);
  final user = await ref.watch(currentUserProvider.future);
  return await controller.fetchCvData(user.id);
});

// ─────────────────────────────────────────────
// 10. GPS Position (global live state)
// ─────────────────────────────────────────────

final userGpsPositionProvider =
    StateProvider<({double lat, double lng})?>((ref) => null);
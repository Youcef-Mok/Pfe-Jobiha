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
// 2. Current User Provider
// ─────────────────────────────────────────────
class UserNotifier extends StateNotifier<AsyncValue<UserEntity>> {
  UserNotifier() : super(const AsyncValue.loading()) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    // TODO(API): GET /api/v1/users/me (avec token candidat)
    //            Remplacer les données hardcodées ci-dessous par :
    //            final user = await ref.read(profileControllerProvider).fetchCurrentUser();
    //            Le backend retournera le bon profil selon le JWT (candidat ou recruteur).
    try {
      await Future.delayed(const Duration(milliseconds: 250));
      const user = UserEntity(
        id: 'candidate_1',
        name: 'Farouja',
        role: 'Serveur',
        domain: 'Restauration',
        company: 'Restauration',
        location: 'Alger Birlmouta',
        bio: 'Specializing in scaling Series A-C startups with high-performing engineering teams. 12+ years of experience in the EMEA and US',
        avatarUrl: 'assets/images/imageannonc(3).jpg',
        followersCount: 0,
        missionsCount: 120,
        rating: 4.9,
        accountType: 'candidate',
      );
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
// Candidate profile (only: Competences + Reviews)
// ─────────────────────────────────────────────────────────────────────────────
enum CandidateProfileTab { description, competences, missions }

final candidateProfileTabProvider =
    StateProvider<CandidateProfileTab>((ref) => CandidateProfileTab.description);

final candidateCurrentUserProvider = StateNotifierProvider<UserNotifier, AsyncValue<UserEntity>>((ref) {
  return UserNotifier();
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

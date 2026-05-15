import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/features/profile/domain/user_entity.dart';
import 'package:job_app/features/profile/domain/cv_entity.dart';
import 'package:job_app/features/profile/domain/profile_controller.dart';
import 'package:job_app/features/profile/data/repositories/user_repository.dart';
import 'package:job_app/features/profile/data/repositories/user_repository_mock.dart';
import 'package:job_app/features/jobs/domain/mission_entity.dart';
import 'package:job_app/features/jobs/data/repositories/jobs_repository.dart';
import 'package:job_app/features/jobs/data/repositories/jobs_repository_mock.dart';

// ─────────────────────────────────────────────
// 1. Repository Provider
// ─────────────────────────────────────────────
final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepositoryMock(),
);

final jobsRepositoryProvider = Provider<JobsRepository>(
  (ref) => JobsRepositoryMock(),
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
    try {
      // For candidate, use mock data
      await Future.delayed(const Duration(milliseconds: 250));
      const user = UserEntity(
        id: 'candidate_1',
        name: 'Farouja',
        role: 'Serveur', // Le poste occupé
        domain: 'Restauration', // Le domaine d'activité
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
enum ProfileTab { annonces, missions, competences, reviews }

final profileTabProvider =
    StateProvider<ProfileTab>((ref) => ProfileTab.annonces);

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
  await Future.delayed(const Duration(milliseconds: 400));
  return const [
    EmployeeReviewEntity(
      id: 'review_1',
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
    EmployeeReviewEntity(
      id: 'review_2',
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
    EmployeeReviewEntity(
      id: 'review_3',
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
});

final candidateCvDataProvider = FutureProvider<CvEntity>((ref) async {
  ref.keepAlive();
  final controller = ref.watch(profileControllerProvider);
  return await controller.fetchCvData('candidate_1');
});

// Utilise le même provider que les missions dans jobs_provider
// pour garantir la cohérence des données
class CandidateMissionsNotifier extends StateNotifier<AsyncValue<List<MissionEntity>>> {
  final Ref _ref;

  CandidateMissionsNotifier(this._ref) : super(const AsyncValue.loading()) {
    Future.microtask(() => fetch());
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      // Récupère les missions depuis le repository partagé
      final missions = await _ref.read(jobsRepositoryProvider).getMissions();
      // Filtre pour ne garder que les missions du candidat 'Farouja'
      final candidateMissions = missions.where((m) => m.candidateName == 'Farouja').toList();
      state = AsyncValue.data(candidateMissions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final candidateMissionsProvider =
    StateNotifierProvider<CandidateMissionsNotifier, AsyncValue<List<MissionEntity>>>((ref) {
  return CandidateMissionsNotifier(ref);
});

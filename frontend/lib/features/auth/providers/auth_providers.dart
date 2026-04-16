// lib/features/auth/providers/auth_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../data/profile_repository.dart';
import '../data/models/auth_state.dart';
import '../data/models/register_request.dart';

// ── Repository providers ───────────────────────────────────────────────────────
// These are simple providers that create a single instance of each repository.
// Any notifier or screen that needs them just reads these providers.

final authRepositoryProvider = Provider<AuthRepository>((_) => AuthRepository());

final profileRepositoryProvider = Provider<ProfileRepository>((_) => ProfileRepository());

// ── AuthNotifier ───────────────────────────────────────────────────────────────
// Owns the auth lifecycle: register, login, logout, session restore.
// Screens watch [authProvider] to react to state changes.

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState()) {
    _restoreSession();
  }

  // ── Session restore (called once on app start) ─────────────────────────────
  Future<void> _restoreSession() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final session = await _repo.restoreSession();
      if (session != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          role:   session.role,
          userId: session.userId,
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  // ── Register candidat ──────────────────────────────────────────────────────
  Future<void> registerCandidat(RegisterCandidatRequest req) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final auth = await _repo.registerCandidat(req);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        role:   auth.role,
        userId: auth.userId,
      );
    } catch (e) {
      state = state.copyWith(
        status:       AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Register recruteur ─────────────────────────────────────────────────────
  Future<void> registerRecruteur(RegisterRecruteurRequest req) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final auth = await _repo.registerRecruteur(req);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        role:   auth.role,
        userId: auth.userId,
      );
    } catch (e) {
      state = state.copyWith(
        status:       AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Login ──────────────────────────────────────────────────────────────────
  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final auth = await _repo.login(email, password);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        role:   auth.role,
        userId: auth.userId,
      );
    } catch (e) {
      state = state.copyWith(
        status:       AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _repo.logout();
    // Use the static constant — fully resets role, userId, errorMessage.
    state = AuthState.unauthenticated;
  }

  // ── Clear error (call after showing a SnackBar) ────────────────────────────
  void clearError() {
    if (state.status == AuthStatus.error) {
      state = AuthState.unauthenticated;
    }
  }
}

// ── The main provider screens will watch ──────────────────────────────────────
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.watch(authRepositoryProvider)),
);

// ── ProfileNotifier ────────────────────────────────────────────────────────────
// Handles the second onboarding step: saving profile data after registration.

class ProfileNotifier extends StateNotifier<AsyncValue<void>> {
  final ProfileRepository _repo;

  ProfileNotifier(this._repo) : super(const AsyncData(null));

  Future<bool> saveCandidatProfile({
    required List<String> competences,
    required String experience,
  }) async {
    state = const AsyncLoading();
    try {
      await _repo.updateCandidatProfile(
        competences: competences,
        experience:  experience,
      );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> saveRecruteurProfile({
    required String nomStructure,
    required String typeStructure,
    String? description,
  }) async {
    state = const AsyncLoading();
    try {
      await _repo.updateRecruteurProfile(
        nomStructure:  nomStructure,
        typeStructure: typeStructure,
        description:   description,
      );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<void>>(
  (ref) => ProfileNotifier(ref.watch(profileRepositoryProvider)),
);
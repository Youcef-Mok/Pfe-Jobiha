// lib/features/auth/providers/auth_providers.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/api/session_event_bus.dart';
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
  late final StreamSubscription<void> _sessionSub;

  AuthNotifier(this._repo) : super(const AuthState()) {
    _restoreSession();
    _sessionSub = SessionEventBus.stream.listen((_) => logout());
  }

  @override
  void dispose() {
    _sessionSub.cancel();
    super.dispose();
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
          isGoogleUser: session.isGoogleUser,
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
      final json = await _repo.registerCandidat(req);
      _handleRegisterResponse(json, req.email);
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
      final json = await _repo.registerRecruteur(req);
      _handleRegisterResponse(json, req.email);
    } catch (e) {
      state = state.copyWith(
        status:       AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Shared logic for both register responses.
  /// If backend says `verification_required`, park on OTP screen;
  /// otherwise save tokens and move to authenticated.
  void _handleRegisterResponse(Map<String, dynamic> json, String email) async {
    if (json['verification_required'] == true) {
      state = state.copyWith(
        status: AuthStatus.otpRequired,
        email:  email,
        role:   json['role'] as String?,
      );
    } else {
      // Backend returned tokens directly — no OTP needed.
      final auth = await _repo.saveRegisterResponse(json);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        role:   auth.role,
        userId: auth.userId,
      );
    }
  }

  // ── Verify email OTP ──────────────────────────────────────────────────────
  Future<void> verifyEmail(String email, String otp) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final auth = await _repo.verifyEmail(email, otp);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        role:   auth.role,
        userId: auth.userId,
      );
    } catch (e) {
      state = state.copyWith(
        status:       AuthStatus.error,
        errorMessage: e.toString(),
        email:        state.email, // preserve email for retry
      );
    }
  }

  // ── Resend OTP ────────────────────────────────────────────────────────────
  Future<void> resendOtp(String email) async {
    try {
      await _repo.resendOtp(email);
    } catch (e) {
      state = state.copyWith(
        status:       AuthStatus.error,
        errorMessage: e.toString(),
        email:        state.email,
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

  // ── Google login ───────────────────────────────────────────────────────────
  // FIX: removed forced googleSignIn.signOut() that was causing loading on every tap
  Future<void> loginWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(
        scopes: ['email'],
      );
 
      final account = await googleSignIn.signIn();
 
      if (account == null) {
        // User cancelled — stay unauthenticated silently, no loading flash
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }
 
      // Only set loading AFTER the user has picked an account
      state = state.copyWith(status: AuthStatus.loading);
 
      final googleAuth = await account.authentication;
      final idToken = googleAuth.idToken;
 
      if (idToken == null) {
        throw Exception('Impossible de récupérer le token Google.');
      }
 
      final json = await _repo.loginWithGoogleRaw(idToken);
 
      if (json['requires_role_selection'] == true) {
        state = state.copyWith(
          status: AuthStatus.pendingRoleSelection,
          pendingGoogleUser: {
            'email':  json['email']  as String,
            'nom':    json['nom']    as String,
            'prenom': json['prenom'] as String,
          },
        );
      } else {
        final auth = await _repo.saveRegisterResponse(json, isGoogleUser: true);
        state = state.copyWith(
          status: AuthStatus.authenticated,
          role:   auth.role,
          userId: auth.userId,
          isGoogleUser: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status:       AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Complete Google sign-up (after role selection) ──────────────────────────
  Future<void> completeGoogleSignUp({
    required String role,
    String? firstName,
    String? lastName,
    String? telephone,
    String? nomStructure,
    String? typeStructure,
  }) async {
    final pending = state.pendingGoogleUser;
    if (pending == null) {
      state = state.copyWith(
        status:       AuthStatus.error,
        errorMessage: 'Données Google manquantes.',
      );
      return;
    }

    state = state.copyWith(status: AuthStatus.loading);
    try {
      final auth = await _repo.completeGoogleSignUp(
        email:         pending['email']!,
        nom:           lastName ?? pending['nom']!,
        prenom:        firstName ?? pending['prenom']!,
        role:          role,
        telephone:     telephone,
        nomStructure:  nomStructure,
        typeStructure: typeStructure,
      );
      state = state.copyWith(
        status:            AuthStatus.authenticated,
        role:              auth.role,
        userId:            auth.userId,
        pendingGoogleUser: null,
        isGoogleUser:      true,
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
      // Go back to otpRequired if we have an email (mid-OTP flow),
      // otherwise go to unauthenticated.
      if (state.email != null) {
        state = state.copyWith(
          status: AuthStatus.otpRequired,
          email:  state.email,
          role:   state.role,
        );
      } else {
        state = AuthState.unauthenticated;
      }
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
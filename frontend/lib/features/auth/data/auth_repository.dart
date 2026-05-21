// lib/features/auth/data/auth_repository.dart

import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/storage/token_storage.dart';
import 'models/auth_response.dart';
import 'models/register_request.dart';

class AuthRepository {
  final Dio _dio = ApiClient.instance;

  // ── Register candidat ──────────────────────────────────────────────────────
  /// Returns raw JSON so the notifier can check for `verification_required`.
  Future<Map<String, dynamic>> registerCandidat(RegisterCandidatRequest req) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.registerCandidat,
        data: req.toJson(),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // ── Register recruteur ─────────────────────────────────────────────────────
  /// Returns raw JSON so the notifier can check for `verification_required`.
  Future<Map<String, dynamic>> registerRecruteur(RegisterRecruteurRequest req) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.registerRecruteur,
        data: req.toJson(),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // ── Verify email OTP ──────────────────────────────────────────────────────
  Future<AuthResponse> verifyEmail(String email, String otp) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.verifyEmail,
        data: {'email': email, 'otp': otp},
      );
      return _saveAndReturn(response.data);
    } on DioException catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // ── Resend OTP ────────────────────────────────────────────────────────────
  Future<void> resendOtp(String email) async {
    try {
      await _dio.post(
        ApiEndpoints.resendOtp,
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // ── Login ──────────────────────────────────────────────────────────────────
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'mot_de_passe': password},
      );
      print('🔵 Login response status: ${response.statusCode}');
      print('🔵 Login response body: ${response.data}');
      
      final auth = await _saveAndReturn(response.data);
      print('🔵 Parsed token (access): ${auth.access.substring(0, 20)}...');
      print('🔵 Parsed role: ${auth.role}');
      print('🔵 Parsed userId: ${auth.userId}');
      
      return auth;
    } on DioException catch (e) {
      print('🔴 Login error: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception(_friendlyError(e));
    }
  }

  // ── Google login (raw) ───────────────────────────────────────────────────────
  /// Returns raw JSON so the notifier can check for `requires_role_selection`.
  Future<Map<String, dynamic>> loginWithGoogleRaw(String idToken) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.googleLogin,
        data: {'token': idToken},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // ── Complete Google sign-up ─────────────────────────────────────────────────
  Future<AuthResponse> completeGoogleSignUp({
    required String email,
    required String nom,
    required String prenom,
    required String role,
    String? telephone,
    String? nomStructure,
    String? typeStructure,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.googleComplete,
        data: {
          'email': email,
          'nom': nom,
          'prenom': prenom,
          'role': role,
          if (telephone != null && telephone.isNotEmpty)  'telephone': telephone,
          if (nomStructure != null)  'nom_structure': nomStructure,
          if (typeStructure != null) 'type_structure': typeStructure,
        },
      );
      return _saveAndReturn(response.data, isGoogleUser: true);
    } on DioException catch (e) {
      throw Exception(_friendlyError(e));
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
    } catch (_) {
      // Ignore server errors on logout.
    } finally {
      await TokenStorage.clear();
    }
  }

  // ── Restore session on app start ───────────────────────────────────────────
  Future<({String role, int userId, bool isGoogleUser})?> restoreSession() async {
    final hasSession = await TokenStorage.hasSession();
    if (!hasSession) return null;

    final role   = await TokenStorage.getRole();
    final userId = await TokenStorage.getUserId();
    final isGoogleUser = await TokenStorage.getIsGoogleUser();
    if (role == null || userId == null) return null;

   await TokenStorage.saveIsGoogleUser(isGoogleUser);

    return (role: role, userId: userId, isGoogleUser: isGoogleUser);
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<AuthResponse> _saveAndReturn(Map<String, dynamic> json, {bool isGoogleUser = false}) async {
    final auth = AuthResponse.fromJson(json);
    await TokenStorage.saveSession(
      access:  auth.access,
      refresh: auth.refresh,
      role:    auth.role,
      userId:  auth.userId,
      isGoogleUser: isGoogleUser,
    );
    return auth;
  }

  /// Persist tokens from a raw register response (when backend returns them
  /// directly, i.e. no OTP required).
  Future<AuthResponse> saveRegisterResponse(Map<String, dynamic> json, {bool isGoogleUser = false}) =>
      _saveAndReturn(json, isGoogleUser: isGoogleUser);

  /// Convert a DioException into a user-facing French string.
  String _friendlyError(DioException e) {
    final status = e.response?.statusCode;
    final data   = e.response?.data;

    // Status-specific messages
    if (status == 409) return 'Un compte avec cet email existe déjà.';
    if (status == 401) return 'Email ou mot de passe incorrect.';
    if (status == 403) return 'Accès refusé.';
    if (status == 404) return 'Ressource introuvable.';

    // DRF field-level errors: { "field": ["msg", ...] } or { "detail": "..." }
    if (data is Map) {
      if (data.containsKey('detail')) return data['detail'] as String;
      final messages = <String>[];
      data.forEach((key, value) {
        if (value is List) messages.add(value.join(' '));
      });
      if (messages.isNotEmpty) return messages.join('\n');
    }

    // Network / timeout errors
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout    ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Délai d\'attente dépassé. Vérifiez votre connexion.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Impossible de joindre le serveur. Vérifiez votre connexion.';
    }

    return 'Erreur inattendue (${status ?? "réseau"}).';
  }
}


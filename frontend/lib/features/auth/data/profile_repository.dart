// lib/features/auth/data/profile_repository.dart

import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

class ProfileRepository {
  final Dio _dio = ApiClient.instance;

  // ── Candidat profile ───────────────────────────────────────────────────────
  /// Called after SignupProfileScreen — sends skills + experience.
  Future<void> updateCandidatProfile({
    required List<String> competences,
    required String experience,
  }) async {
    await _dio.patch(
      ApiEndpoints.candidatMe,
      data: {
        'competences': competences,
        'experience':  experience,
      },
    );
  }

  // ── Recruteur profile ──────────────────────────────────────────────────────
  /// Called after RecruiterProfileScreen — sends company info.
  Future<void> updateRecruteurProfile({
    required String nomStructure,
    required String typeStructure,
    String? description,
  }) async {
    await _dio.patch(
      ApiEndpoints.recruteurMe,
      data: {
        'nom_structure':  nomStructure,
        'type_structure': typeStructure,
        if (description != null && description.isNotEmpty)
          'description': description,
      },
    );
  }

  // ── Shared user info (name, phone) ─────────────────────────────────────────
  Future<void> updateBaseProfile({
    String? nom,
    String? prenom,
    String? telephone,
  }) async {
    await _dio.patch(
      ApiEndpoints.me,
      data: {
        if (nom       != null) 'nom':       nom,
        if (prenom    != null) 'prenom':    prenom,
        if (telephone != null) 'telephone': telephone,
      },
    );
  }
}
// lib/features/settings/data/repositories/settings_repository.dart

import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/settings_model.dart';

class SettingsRepository {
  final Dio _dio = ApiClient.instance;

  // ── Push notification preference ───────────────────────────────────────────

  Future<bool> getPushNotifPref() async {
    final response = await _dio.get(ApiEndpoints.pushNotifPref);
    return response.data['push_notif_enabled'] as bool;
  }

  Future<void> setPushNotifPref({required bool enabled}) async {
    await _dio.patch(
      ApiEndpoints.pushNotifPref,
      data: {'push_notif_enabled': enabled},
    );
  }

  // ── Blocked users ──────────────────────────────────────────────────────────

  Future<List<BlockedUserModel>> getBlockedUsers() async {
    final response = await _dio.get(ApiEndpoints.blockedUsers);
    final List data = response.data as List;
    return data
        .cast<Map<String, dynamic>>()
        .map(BlockedUserModel.fromJson)
        .toList();
  }

  Future<void> blockUser(int userId) async {
    await _dio.post(
      ApiEndpoints.blockedUsers,
      data: {'user_id': userId},
    );
  }

  Future<void> unblockUser(int userId) async {
    await _dio.delete('${ApiEndpoints.blockedUsers}/$userId');
  }

  // ── Deactivate account ─────────────────────────────────────────────────────

  Future<void> deactivateAccount() async {
    await _dio.post(ApiEndpoints.deactivateAccount);
  }



// TODO :
  // ── Delete account ─────────────────────────────────────────────────────────
  // Backend endpoint to be added when permanent deletion is implemented.
  //Future<void> deleteAccount() async {
   // await _dio.delete(ApiEndpoints.deleteAccount);
  //}


}
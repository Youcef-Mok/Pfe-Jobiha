import 'package:dio/dio.dart';
import 'package:job_app/core/api/api_client.dart';
import 'package:job_app/core/api/api_endpoints.dart';
import 'package:job_app/core/storage/token_storage.dart';
import 'package:job_app/features/settings/data/models/settings_model.dart';
import 'package:job_app/features/settings/data/repositories/settings_repository.dart';

class SettingsRepositoryHttp implements SettingsRepository {
  final Dio _dio = ApiClient.instance;

  @override
  Future<AppSettings> getSettings() async {
    final resp = await _dio.get(ApiEndpoints.settings);
    return AppSettings.fromJson(resp.data as Map<String, dynamic>);
  }

  @override
  Future<void> updateNotificationsEnabled(bool enabled) async {
    await _dio.put(ApiEndpoints.settingsNotifs, data: {'enabled': enabled});
  }

  @override
  Future<void> updateDarkMode(bool enabled) async {
    await _dio.put(ApiEndpoints.settingsTheme, data: {'dark_mode': enabled});
  }

  @override
  Future<void> updateLanguage(String languageCode) async {
    await _dio.put(ApiEndpoints.settingsLanguage, data: {'language_code': languageCode});
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
    } catch (_) {
      // Best-effort: clear local tokens even if server call fails
    } finally {
      await TokenStorage.clear();
    }
  }

  @override
  Future<void> deleteAccount() async {
    await _dio.delete(ApiEndpoints.deleteAccount);
    await TokenStorage.clear();
  }
}

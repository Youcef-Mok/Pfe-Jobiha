import 'package:job_app/features/settings/data/models/settings_model.dart';
import 'package:job_app/features/settings/data/repositories/settings_repository.dart';

// TODO(API): Remplacer cette classe par SettingsRepositoryHttp qui appellera
//            les vrais endpoints REST. Voir settings_repository.dart pour le contrat.

class SettingsRepositoryMock implements SettingsRepository {
  AppSettings _settings = const AppSettings();

  @override
  Future<AppSettings> getSettings() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _settings;
  }

  @override
  Future<void> updateNotificationsEnabled(bool enabled) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _settings = _settings.copyWith(notificationsEnabled: enabled);
  }

  @override
  Future<void> updateDarkMode(bool enabled) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _settings = _settings.copyWith(darkMode: enabled);
  }

  @override
  Future<void> updateLanguage(String languageCode) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _settings = _settings.copyWith(languageCode: languageCode);
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO(API): POST /api/auth/logout — invalider le token JWT côté serveur
  }

  @override
  Future<void> deleteAccount() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO(API): DELETE /api/account — supprimer le compte et ses données
  }
}

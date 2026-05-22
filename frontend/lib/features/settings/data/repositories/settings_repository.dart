import 'package:job_app/features/settings/data/models/settings_model.dart';

// TODO(API): Remplacer SettingsRepositoryMock par une implémentation HTTP.
//            Endpoints attendus:
//              GET  /api/settings        → getSettings()
//              PUT  /api/settings/notifs → updateNotificationsEnabled()
//              PUT  /api/settings/theme  → updateDarkMode()
//              PUT  /api/settings/lang   → updateLanguage()
//              POST /api/auth/logout     → logout()
//              DELETE /api/account       → deleteAccount()

abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> updateNotificationsEnabled(bool enabled);
  Future<void> updateDarkMode(bool enabled);
  Future<void> updateLanguage(String languageCode);
  Future<void> logout();
  Future<void> deleteAccount();
}

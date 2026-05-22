import 'package:job_app/features/settings/data/models/settings_model.dart';
import 'package:job_app/features/settings/data/repositories/settings_repository.dart';

class SettingsController {
  final SettingsRepository _repository;

  SettingsController(this._repository);

  // TODO(API): Brancher chaque méthode sur l'endpoint backend correspondant
  //            en remplaçant SettingsRepositoryMock par une implémentation HTTP.

  Future<AppSettings> loadSettings() => _repository.getSettings();

  Future<void> updateNotifications(bool enabled) =>
      _repository.updateNotificationsEnabled(enabled);

  Future<void> updateDarkMode(bool enabled) =>
      _repository.updateDarkMode(enabled);

  Future<void> updateLanguage(String languageCode) =>
      _repository.updateLanguage(languageCode);

  Future<void> deleteAccount() => _repository.deleteAccount();

  Future<void> logout() => _repository.logout();
}

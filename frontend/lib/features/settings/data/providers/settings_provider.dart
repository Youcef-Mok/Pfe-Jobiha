import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/features/settings/data/models/settings_model.dart';
import 'package:job_app/features/settings/data/repositories/settings_repository.dart';
import 'package:job_app/features/settings/data/repositories/settings_repository_mock.dart';
import 'package:job_app/features/settings/domain/settings_controller.dart';

// ─────────────────────────────────────────────
// 1. Repository Provider
//    TODO(API): Remplace SettingsRepositoryMock par SettingsRepositoryHttp
// ─────────────────────────────────────────────
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryMock(),
);

// ─────────────────────────────────────────────
// 2. Controller Provider
// ─────────────────────────────────────────────
final settingsControllerProvider = Provider<SettingsController>(
  (ref) => SettingsController(ref.watch(settingsRepositoryProvider)),
);

// ─────────────────────────────────────────────
// 3. Settings State (AsyncNotifier)
// ─────────────────────────────────────────────
class SettingsNotifier extends StateNotifier<AsyncValue<AppSettings>> {
  final SettingsController _controller;

  SettingsNotifier(this._controller) : super(const AsyncValue.loading()) {
    Future.microtask(() => _load());
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final settings = await _controller.loadSettings();
      state = AsyncValue.data(settings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleNotifications(bool enabled) async {
    await _controller.updateNotifications(enabled);
    await _load();
  }

  Future<void> toggleDarkMode(bool enabled) async {
    await _controller.updateDarkMode(enabled);
    await _load();
  }

  Future<void> setLanguage(String code) async {
    await _controller.updateLanguage(code);
    await _load();
  }

  Future<void> logout() => _controller.logout();

  Future<void> deleteAccount() => _controller.deleteAccount();
}

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<AppSettings>>(
  (ref) => SettingsNotifier(ref.watch(settingsControllerProvider)),
);

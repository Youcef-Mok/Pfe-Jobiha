// lib/features/settings/domain/settings_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/settings_model.dart';
import '../data/repositories/settings_repository.dart';

// ── State ──────────────────────────────────────────────────────────────────────

enum SettingsStatus { initial, loading, success, error }

class SettingsState {
  final SettingsStatus status;
  final SettingsModel settings;
  final String? errorMessage;

  const SettingsState({
    this.status   = SettingsStatus.initial,
    this.settings = const SettingsModel(),
    this.errorMessage,
  });

  bool get isLoading => status == SettingsStatus.loading;

  SettingsState copyWith({
    SettingsStatus? status,
    SettingsModel?  settings,
    String?         errorMessage,
  }) =>
      SettingsState(
        status:       status       ?? this.status,
        settings:     settings     ?? this.settings,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

// ── Notifier ───────────────────────────────────────────────────────────────────

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsRepository _repo;

  SettingsNotifier(this._repo) : super(const SettingsState()) {
    loadSettings();
  }

  // ── Load all settings on init ──────────────────────────────────────────────

  Future<void> loadSettings() async {
    state = state.copyWith(status: SettingsStatus.loading);
    try {
      final pushEnabled    = await _repo.getPushNotifPref();
      final blockedUsers   = await _repo.getBlockedUsers();
      state = state.copyWith(
        status:   SettingsStatus.success,
        settings: SettingsModel(
          pushNotifEnabled: pushEnabled,
          blockedUsers:     blockedUsers,
        ),
      );
    } catch (e) {
      // Non-fatal: keep defaults so the screen still renders.
      state = state.copyWith(
        status:       SettingsStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Push notification preference ───────────────────────────────────────────

  Future<void> setPushNotif(bool enabled) async {
    // Optimistic update — flip immediately, revert on failure.
    final previous = state.settings.pushNotifEnabled;
    state = state.copyWith(
      settings: state.settings.copyWith(pushNotifEnabled: enabled),
    );
    try {
      await _repo.setPushNotifPref(enabled: enabled);
    } catch (e) {
      state = state.copyWith(
        settings:     state.settings.copyWith(pushNotifEnabled: previous),
        errorMessage: e.toString(),
      );
    }
  }

  // ── Block a user ───────────────────────────────────────────────────────────

  Future<void> blockUser(int userId) async {
    try {
      await _repo.blockUser(userId);
      await _refreshBlockedUsers();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  // ── Unblock a user ─────────────────────────────────────────────────────────

  Future<void> unblockUser(int userId) async {
    // Optimistic removal — remove from list immediately.
    final previous = state.settings.blockedUsers;
    state = state.copyWith(
      settings: state.settings.copyWith(
        blockedUsers: previous.where((u) => u.id != userId).toList(),
      ),
    );
    try {
      await _repo.unblockUser(userId);
    } catch (e) {
      // Revert on failure.
      state = state.copyWith(
        settings:     state.settings.copyWith(blockedUsers: previous),
        errorMessage: e.toString(),
      );
    }
  }

  // ── Deactivate account ─────────────────────────────────────────────────────
  /// Returns true on success so the screen can trigger logout + navigation.

  Future<bool> deactivateAccount() async {
    state = state.copyWith(status: SettingsStatus.loading);
    try {
      await _repo.deactivateAccount();
      state = state.copyWith(status: SettingsStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status:       SettingsStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // ── Delete account ─────────────────────────────────────────────────────────
  /// Returns true on success so the screen can trigger logout + navigation.

  Future<bool> deleteAccount() async {
    state = state.copyWith(status: SettingsStatus.loading);
    try {
      await _repo.deleteAccount();
      state = state.copyWith(status: SettingsStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status:       SettingsStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // ── Clear error ────────────────────────────────────────────────────────────

  void clearError() {
    state = state.copyWith(
      status:       SettingsStatus.success,
      errorMessage: null,
    );
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _refreshBlockedUsers() async {
    final blockedUsers = await _repo.getBlockedUsers();
    state = state.copyWith(
      settings: state.settings.copyWith(blockedUsers: blockedUsers),
    );
  }
}
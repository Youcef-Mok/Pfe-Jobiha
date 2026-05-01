// lib/features/settings/data/providers/settings_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/settings_repository.dart';
import '../../domain/settings_controller.dart';

// ── Repository provider ────────────────────────────────────────────────────────

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (_) => SettingsRepository(),
);

// ── Main provider screens will watch ──────────────────────────────────────────

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(ref.watch(settingsRepositoryProvider)),
);
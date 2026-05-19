import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/notifications_repository.dart';
import '../repositories/notifications_repository_api.dart';
import '../../domain/notifications_controller.dart';

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) {
  return NotificationsRepositoryApi();
});

final notificationsControllerProvider =
    StateNotifierProvider<NotificationsController, NotificationsState>((ref) {
  final repository = ref.watch(notificationsRepositoryProvider);
  return NotificationsController(repository);
});
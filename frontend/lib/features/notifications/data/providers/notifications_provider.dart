import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/notifications_repository.dart';
import '../repositories/notifications_repository_http.dart';
import '../../domain/notifications_controller.dart';

// Both recruiter and candidate use the same HTTP impl — backend filters by JWT role.
final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepositoryHttp();
});

final notificationsControllerProvider =
    StateNotifierProvider<NotificationsController, NotificationsState>((ref) {
  return NotificationsController(ref.watch(notificationsRepositoryProvider));
});

final candidateNotificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepositoryHttp();
});

final candidateNotificationsControllerProvider =
    StateNotifierProvider<NotificationsController, NotificationsState>((ref) {
  return NotificationsController(ref.watch(candidateNotificationsRepositoryProvider));
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/notifications_repository.dart';
import '../repositories/notifications_repository_mock.dart';
import '../../domain/notifications_controller.dart';

// TODO(API): Remplacer par NotificationsRepositoryHttp quand le backend est prêt.
final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepositoryMock();
});

final notificationsControllerProvider =
    StateNotifierProvider<NotificationsController, NotificationsState>((ref) {
  return NotificationsController(ref.watch(notificationsRepositoryProvider));
});

final candidateNotificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return CandidateNotificationsRepositoryMock();
});

final candidateNotificationsControllerProvider =
    StateNotifierProvider<NotificationsController, NotificationsState>((ref) {
  return NotificationsController(ref.watch(candidateNotificationsRepositoryProvider));
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/messaging_repository.dart';
import '../repositories/messaging_repository_mock.dart';
import '../../domain/chat_controller.dart';

// TODO(API): Remplacer MessagingRepositoryMock par MessagingRepositoryHttp ici.
final messagingRepositoryProvider = Provider<MessagingRepository>((ref) {
  return MessagingRepositoryMock();
});

final messagingControllerProvider =
    StateNotifierProvider<MessagingController, MessagingState>((ref) {
  return MessagingController(ref.watch(messagingRepositoryProvider));
});


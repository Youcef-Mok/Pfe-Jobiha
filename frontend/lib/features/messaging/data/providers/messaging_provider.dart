import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/messaging_repository.dart';
import '../repositories/messaging_repository_api.dart';
import '../datasources/messaging_remote_datasource.dart';
import '../../domain/chat_controller.dart';

final messagingRepositoryProvider = Provider<MessagingRepository>((ref) {
  print('[messagingRepositoryProvider] Création de MessagingRepositoryApi');
  return MessagingRepositoryApi(MessagingRemoteDataSource());
});

final messagingControllerProvider =
    StateNotifierProvider<MessagingController, MessagingState>((ref) {
  print('[messagingControllerProvider] Création de MessagingController');
  return MessagingController(ref.watch(messagingRepositoryProvider));
});

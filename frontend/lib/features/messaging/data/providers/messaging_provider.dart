import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/messaging_remote_datasource.dart';
import '../repositories/messaging_repository.dart';
import '../repositories/messaging_repository_api.dart';
import '../../domain/chat_controller.dart';

final messagingRepositoryProvider = Provider<MessagingRepository>((ref) {
  return MessagingRepositoryApi(MessagingRemoteDataSource());
});

final messagingControllerProvider =
    StateNotifierProvider<MessagingController, MessagingState>((ref) {
  return MessagingController(ref.watch(messagingRepositoryProvider));
});

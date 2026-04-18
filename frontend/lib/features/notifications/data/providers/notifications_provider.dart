import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/notification_entity.dart';

class NotificationsState {
  final bool isLoading;
  const NotificationsState({this.isLoading = false});
}

class NotificationsController extends StateNotifier<NotificationsState> {
  NotificationsController() : super(const NotificationsState());

  String selectedFilter = 'all';
  Map<String, List<NotificationEntity>> get groupedNotifications => {};
  int get unreadCount => 0;

  void setFilter(String filter) => selectedFilter = filter;
  void markAsRead(String id) {}
}

final notificationsControllerProvider =
    StateNotifierProvider<NotificationsController, NotificationsState>(
  (ref) => NotificationsController(),
);

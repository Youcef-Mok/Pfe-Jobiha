import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/notifications_repository.dart';
import 'notification_entity.dart';

class NotificationsState {
  final List<NotificationEntity> notifications;
  final bool isLoading;
  final NotificationFilter activeFilter;

  NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.activeFilter = NotificationFilter.all,
  });

  NotificationsState copyWith({
    List<NotificationEntity>? notifications,
    bool? isLoading,
    NotificationFilter? activeFilter,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }
}

class NotificationsController extends StateNotifier<NotificationsState> {
  final NotificationsRepository _repository;

  NotificationsController(this._repository) : super(NotificationsState()) {
    fetchNotifications();
  }

  NotificationFilter get selectedFilter => state.activeFilter;

  Future<void> fetchNotifications() async {
    state = state.copyWith(isLoading: true);
    try {
      final notifications = await _repository.getNotifications();
      state = state.copyWith(notifications: notifications, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void setFilter(NotificationFilter filter) {
    state = state.copyWith(activeFilter: filter);
  }

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);
    final updated = state.notifications.map((n) {
      if (n.id == id) return n.copyWith(isRead: true);
      return n;
    }).toList();
    state = state.copyWith(notifications: updated);
  }

  Future<void> markAllAsRead() async {
    for (final n in state.notifications.where((n) => !n.isRead)) {
      await _repository.markAsRead(n.id);
    }
    final updated = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    state = state.copyWith(notifications: updated);
  }

  int get unreadCount => state.notifications.where((n) => !n.isRead).length;

  List<NotificationEntity> get filteredNotifications {
    final all = state.notifications;
    switch (state.activeFilter) {
      case NotificationFilter.all:
        return all;
      case NotificationFilter.jobs:
        return all.where((n) => n.category == NotificationCategory.jobs).toList();
      case NotificationFilter.messagerie:
        return all.where((n) => n.category == NotificationCategory.messagerie).toList();
      case NotificationFilter.candidatures:
        return all.where((n) => n.category == NotificationCategory.candidatures).toList();
    }
  }

  Map<String, List<NotificationEntity>> get groupedNotifications {
    final filtered = filteredNotifications;
    final Map<String, List<NotificationEntity>> grouped = {};
    final systemItems = <NotificationEntity>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var n in filtered) {
      if (n.category == NotificationCategory.system &&
          state.activeFilter == NotificationFilter.all) {
        systemItems.add(n);
        continue;
      }
      final msgDay = DateTime(n.timestamp.year, n.timestamp.month, n.timestamp.day);
      String key;
      if (msgDay == today) {
        key = 'Today';
      } else if (msgDay == yesterday) {
        key = 'Hier';
      } else {
        final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
        key = '${n.timestamp.day} ${months[n.timestamp.month - 1]}';
      }
      grouped.putIfAbsent(key, () => []).add(n);
    }

    if (systemItems.isNotEmpty) {
      grouped['Système'] = systemItems;
    }

    return grouped;
  }
}

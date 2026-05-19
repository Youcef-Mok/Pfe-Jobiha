import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/notifications_repository.dart';
import 'notification_entity.dart';
import 'package:intl/intl.dart';

class NotificationsState {
  final List<NotificationEntity> notifications;
  final bool isLoading;

  NotificationsState({this.notifications = const [], this.isLoading = false});

  NotificationsState copyWith({List<NotificationEntity>? notifications, bool? isLoading}) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationsController extends StateNotifier<NotificationsState> {
  final NotificationsRepository _repository;
  String _selectedFilter = 'all';

  NotificationsController(this._repository) : super(NotificationsState()) {
    fetchNotifications();
  }

  String get selectedFilter => _selectedFilter;

  Future<void> fetchNotifications() async {
    state = state.copyWith(isLoading: true);
    try {
      final notifications = await _repository.getNotifications();
      state = state.copyWith(notifications: notifications, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    state = state.copyWith(); // Trigger rebuild
  }

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);
    final updated = state.notifications.map((n) {
      if (n.id == id) return n.copyWith(isRead: true);
      return n;
    }).toList();
    state = state.copyWith(notifications: updated);
  }

  int get unreadCount => state.notifications.where((n) => !n.isRead).length;

  List<NotificationEntity> get filteredNotifications {
    if (_selectedFilter == 'all') return state.notifications;
    if (_selectedFilter == 'clients') {
      return state.notifications.where((n) => 
        n.type == NotificationType.newApplicants || 
        n.type == NotificationType.newMessage ||
        n.type == NotificationType.interviewAccepted
      ).toList();
    }
    if (_selectedFilter == 'system') {
      return state.notifications.where((n) => 
        n.type == NotificationType.jobQuestion || 
        n.type == NotificationType.missionExpiring ||
        n.type == NotificationType.missionCompleted ||
        n.type == NotificationType.announcementCreated ||
        n.type == NotificationType.system
      ).toList();
    }
    return state.notifications;
  }

  Map<String, List<NotificationEntity>> get groupedNotifications {
    final filtered = filteredNotifications;
    final Map<String, List<NotificationEntity>> grouped = {};

    final now = DateTime.now();
    final todayStr = 'Aujourd\'hui';
    final yesterdayStr = 'Yesterday'; // As per user CSS/Screenshot

    for (var n in filtered) {
      String key;
      if (DateFormat('yyyyMMdd').format(n.timestamp) == DateFormat('yyyyMMdd').format(now)) {
        key = todayStr;
      } else if (DateFormat('yyyyMMdd').format(n.timestamp) == DateFormat('yyyyMMdd').format(now.subtract(const Duration(days: 1)))) {
        key = yesterdayStr;
      } else {
        key = DateFormat('d MMMM', 'fr_FR').format(n.timestamp);
      }

      if (grouped[key] == null) grouped[key] = [];
      grouped[key]!.add(n);
    }

    return grouped;
  }
}

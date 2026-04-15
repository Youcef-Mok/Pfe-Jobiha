import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/providers/notifications_provider.dart';
import '../widgets/notification_card.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsControllerProvider);
    final controller = ref.read(notificationsControllerProvider.notifier);
    final groupedNotifications = controller.groupedNotifications;
    final unreadCount = controller.unreadCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1D1B1F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF1D1B1F)),
        ),
        actions: [
          if (unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF3A1B5E), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    '$unreadCount nouvelles',
                    style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _FilterTabs(
            selectedFilter: controller.selectedFilter,
            onFilterChanged: (filter) => controller.setFilter(filter),
          ),
          Expanded(
            child: state.isLoading 
                ? const Center(child: CircularProgressIndicator())
                : groupedNotifications.isEmpty
                    ? const _EmptyState()
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        children: groupedNotifications.entries.map((entry) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              NotificationSectionHeader(title: entry.key),
                              ...entry.value.map((notification) {
                                return NotificationCard(
                                  notification: notification,
                                  onTap: () => controller.markAsRead(notification.id),
                                );
                              }).toList(),
                            ],
                          );
                        }).toList(),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: const _BottomNavBar(),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const _FilterTabs({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      color: const Color(0xFFF7F6F8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _FilterChip(
            label: 'All',
            isSelected: selectedFilter == 'all',
            onTap: () => onFilterChanged('all'),
          ),
          _FilterChip(
            label: 'Clients',
            isSelected: selectedFilter == 'clients',
            onTap: () => onFilterChanged('clients'),
          ),
          _FilterChip(
            label: 'Système',
            isSelected: selectedFilter == 'system',
            onTap: () => onFilterChanged('system'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF401E66) : const Color(0xFFF6F3F8),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            height: 1.43,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Pas de notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 89,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_outlined, label: 'home', isActive: false, onTap: () => Navigator.pop(context)),
              const SizedBox(width: 56),
              _NavItem(icon: Icons.notifications, label: 'notif', isActive: true),
              _NavItem(icon: Icons.message_outlined, label: 'chat', isActive: false),
              _NavItem(icon: Icons.person_outline, label: 'profile', isActive: false),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            top: -20,
            child: Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF401E66),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF401E66).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, size: 30, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF401E66) : const Color(0xFF475569);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 10, color: color)),
        ],
      ),
    );
  }
}

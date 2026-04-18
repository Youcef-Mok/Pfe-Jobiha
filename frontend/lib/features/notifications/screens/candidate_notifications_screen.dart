import 'package:flutter/material.dart';

// ── Candidate Notification Types ─────────────────────────────────────────────
enum CandidateNotifType {
  applicationAccepted,
  applicationRejected,
  applicationViewed,
  newNearbyOffer,
  jobMatchingPreferences,
  savedJobExpiring,
  newJobInCategory,
  profileViewed,
  profileIncomplete,
}

// ── Candidate Notification Entity ─────────────────────────────────────────────
class CandidateNotification {
  final String id;
  final String title;
  final String? message;
  final CandidateNotifType type;
  final DateTime timestamp;
  final bool isRead;
  final String? jobTitle;
  final String? senderName;
  final String? avatarUrl;
  final double? distanceKm;

  CandidateNotification({
    required this.id,
    required this.title,
    this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.jobTitle,
    this.senderName,
    this.avatarUrl,
    this.distanceKm,
  });

  CandidateNotification copyWith({bool? isRead}) => CandidateNotification(
        id: id,
        title: title,
        message: message,
        type: type,
        timestamp: timestamp,
        isRead: isRead ?? this.isRead,
        jobTitle: jobTitle,
        senderName: senderName,
        avatarUrl: avatarUrl,
        distanceKm: distanceKm,
      );
}

// ── Mock Data ─────────────────────────────────────────────────────────────────
final List<CandidateNotification> _mockNotifications = [
  // ── TODAY ──
  CandidateNotification(
    id: '1',
    title: 'Candidature acceptée',
    message: 'Votre candidature pour le poste de Serveur a été acceptée.',
    type: CandidateNotifType.applicationAccepted,
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    isRead: false,
    jobTitle: 'Serveur en salle',
    senderName: 'Le Petit Bistro',
  ),
  CandidateNotification(
    id: '2',
    title: 'Nouvelle offre à proximité',
    message: 'Une offre de Barista est disponible à 1.2 km de vous.',
    type: CandidateNotifType.newNearbyOffer,
    timestamp: DateTime.now().subtract(const Duration(minutes: 43)),
    isRead: false,
    jobTitle: 'Barista',
    distanceKm: 1.2,
  ),
  CandidateNotification(
    id: '3',
    title: 'Offre correspondant à vos préférences',
    message: 'Un poste de Designer UX correspond à votre profil.',
    type: CandidateNotifType.jobMatchingPreferences,
    timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    isRead: false,
    jobTitle: 'Designer UX',
    senderName: 'Tech Studio',
  ),
  CandidateNotification(
    id: '4',
    title: 'Votre profil a été consulté',
    message: 'Un recruteur a consulté votre profil il y a peu.',
    type: CandidateNotifType.profileViewed,
    timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    isRead: false,
  ),

  // ── YESTERDAY ──
  CandidateNotification(
    id: '5',
    title: 'Candidature refusée',
    message: "Votre candidature pour Livreur n'a pas été retenue.",
    type: CandidateNotifType.applicationRejected,
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    isRead: true,
    jobTitle: 'Livreur',
    senderName: 'Express Delivery',
  ),
  CandidateNotification(
    id: '6',
    title: 'Candidature consultée',
    message: 'Un recruteur a consulté votre candidature pour Réceptionniste.',
    type: CandidateNotifType.applicationViewed,
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    isRead: true,
    jobTitle: 'Réceptionniste',
  ),
  CandidateNotification(
    id: '7',
    title: 'Offre sauvegardée bientôt expirée',
    message: "L'offre Réceptionniste expire dans 24h. Postulez vite !",
    type: CandidateNotifType.savedJobExpiring,
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
    isRead: true,
    jobTitle: 'Réceptionniste',
  ),
  CandidateNotification(
    id: '8',
    title: 'Nouveau poste dans votre catégorie',
    message: '3 nouvelles offres en Restauration ont été publiées.',
    type: CandidateNotifType.newJobInCategory,
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
    isRead: true,
    jobTitle: 'Restauration',
  ),

  // ── EARLIER ──
  CandidateNotification(
    id: '9',
    title: 'Nouvelle offre à proximité',
    message: 'Un poste de Gérant est disponible à 2.8 km de vous.',
    type: CandidateNotifType.newNearbyOffer,
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
    isRead: true,
    jobTitle: 'Gérant',
    distanceKm: 2.8,
  ),
  CandidateNotification(
    id: '10',
    title: 'Complétez votre profil',
    message: 'Ajoutez votre CV pour augmenter vos chances de 70%.',
    type: CandidateNotifType.profileIncomplete,
    timestamp: DateTime.now().subtract(const Duration(days: 3)),
    isRead: true,
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────
class CandidateNotificationsScreen extends StatefulWidget {
  const CandidateNotificationsScreen({super.key});

  @override
  State<CandidateNotificationsScreen> createState() =>
      _CandidateNotificationsScreenState();
}

class _CandidateNotificationsScreenState
    extends State<CandidateNotificationsScreen> {
  String _selectedFilter = 'all';
  late List<CandidateNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.from(_mockNotifications);
  }

  List<CandidateNotification> get _filtered {
    if (_selectedFilter == 'jobs') {
      return _notifications.where((n) =>
          n.type == CandidateNotifType.applicationAccepted ||
          n.type == CandidateNotifType.applicationRejected ||
          n.type == CandidateNotifType.applicationViewed ||
          n.type == CandidateNotifType.newNearbyOffer ||
          n.type == CandidateNotifType.jobMatchingPreferences ||
          n.type == CandidateNotifType.savedJobExpiring ||
          n.type == CandidateNotifType.newJobInCategory).toList();
    }
    if (_selectedFilter == 'system') {
      return _notifications.where((n) =>
          n.type == CandidateNotifType.profileViewed ||
          n.type == CandidateNotifType.profileIncomplete).toList();
    }
    return _notifications;
  }

  Map<String, List<CandidateNotification>> get _grouped {
    final now = DateTime.now();
    final today = <CandidateNotification>[];
    final yesterday = <CandidateNotification>[];
    final older = <CandidateNotification>[];

    for (final n in _filtered) {
      final diff = now.difference(n.timestamp);
      if (diff.inDays == 0) {
        today.add(n);
      } else if (diff.inDays == 1) {
        yesterday.add(n);
      } else {
        older.add(n);
      }
    }

    return {
      if (today.isNotEmpty) 'TODAY': today,
      if (yesterday.isNotEmpty) 'YESTERDAY': yesterday,
      if (older.isNotEmpty) 'EARLIER': older,
    };
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAsRead(String id) {
    setState(() {
      _notifications = _notifications.map((n) {
        if (n.id == id) return n.copyWith(isRead: true);
        return n;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
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
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Color(0xFF1D1B1F),
          ),
        ),
        actions: [
          if (_unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A1B5E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_unreadCount nouvelles',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _FilterTabs(
            selectedFilter: _selectedFilter,
            onFilterChanged: (f) => setState(() => _selectedFilter = f),
          ),
          Expanded(
            child: _grouped.isEmpty
                ? const _EmptyState()
                : ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    children: _grouped.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(title: entry.key),
                          ...entry.value.map((n) => _NotificationCard(
                                notification: n,
                                onTap: () => _markAsRead(n.id),
                              )),
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

// ── Filter Tabs ───────────────────────────────────────────────────────────────
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
          _FilterChip(label: 'All', value: 'all', selected: selectedFilter, onTap: onFilterChanged),
          _FilterChip(label: 'Jobs', value: 'jobs', selected: selectedFilter, onTap: onFilterChanged),
          _FilterChip(label: 'Système', value: 'system', selected: selectedFilter, onTap: onFilterChanged),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final Function(String) onTap;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
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
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 8, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: Color(0xFF475569),
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

// ── Notification Card ─────────────────────────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  final CandidateNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  IconData get _icon {
    switch (notification.type) {
      case CandidateNotifType.applicationAccepted:
        return Icons.check_circle_outline;
      case CandidateNotifType.applicationRejected:
        return Icons.cancel_outlined;
      case CandidateNotifType.applicationViewed:
        return Icons.remove_red_eye_outlined;
      case CandidateNotifType.newNearbyOffer:
        return Icons.location_on_outlined;
      case CandidateNotifType.jobMatchingPreferences:
        return Icons.tune_outlined;
      case CandidateNotifType.savedJobExpiring:
        return Icons.timer_outlined;
      case CandidateNotifType.newJobInCategory:
        return Icons.category_outlined;
      case CandidateNotifType.profileViewed:
        return Icons.visibility_outlined;
      case CandidateNotifType.profileIncomplete:
        return Icons.person_outline;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case CandidateNotifType.applicationAccepted:
        return const Color(0xFF16A34A);
      case CandidateNotifType.applicationRejected:
        return const Color(0xFFDC2626);
      case CandidateNotifType.applicationViewed:
        return const Color(0xFF2563EB);
      case CandidateNotifType.newNearbyOffer:
        return const Color(0xFF401E66);
      case CandidateNotifType.jobMatchingPreferences:
        return const Color(0xFF2563EB);
      case CandidateNotifType.savedJobExpiring:
        return const Color(0xFFD97706);
      case CandidateNotifType.newJobInCategory:
        return const Color(0xFF401E66);
      case CandidateNotifType.profileViewed:
        return const Color(0xFF0891B2);
      case CandidateNotifType.profileIncomplete:
        return const Color(0xFFD97706);
    }
  }

  Color get _iconBg {
    switch (notification.type) {
      case CandidateNotifType.applicationAccepted:
        return const Color(0xFFDCFCE7);
      case CandidateNotifType.applicationRejected:
        return const Color(0xFFFEE2E2);
      case CandidateNotifType.applicationViewed:
        return const Color(0xFFDBEAFE);
      case CandidateNotifType.newNearbyOffer:
        return const Color(0xFFEDE9FE);
      case CandidateNotifType.jobMatchingPreferences:
        return const Color(0xFFDBEAFE);
      case CandidateNotifType.savedJobExpiring:
        return const Color(0xFFFEF3C7);
      case CandidateNotifType.newJobInCategory:
        return const Color(0xFFEDE9FE);
      case CandidateNotifType.profileViewed:
        return const Color(0xFFE0F2FE);
      case CandidateNotifType.profileIncomplete:
        return const Color(0xFFFEF3C7);
    }
  }

  String _formatTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}j';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : const Color(0xFFF3EEFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead
                ? const Color(0xFFE2E8F0)
                : const Color(0xFFD4B8F0),
            width: 0.8,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, color: _iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: notification.isRead
                          ? FontWeight.w500
                          : FontWeight.w700,
                      fontSize: 14,
                      color: const Color(0xFF1D1B1F),
                    ),
                  ),
                  if (notification.message != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      notification.message!,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (notification.distanceKm != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 12, color: Color(0xFF401E66)),
                        const SizedBox(width: 3),
                        Text(
                          '${notification.distanceKm} km de vous',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: Color(0xFF401E66),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (notification.jobTitle != null ||
                      notification.senderName != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            notification.jobTitle != null
                                ? Icons.work_outline
                                : Icons.person_outline,
                            size: 11,
                            color: const Color(0xFF475569),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            notification.jobTitle ?? notification.senderName!,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(notification.timestamp),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                if (!notification.isRead) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF401E66),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
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

// ── Bottom Nav Bar ────────────────────────────────────────────────────────────
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
              _NavItem(icon: Icons.home_outlined, label: 'Home', isActive: false, onTap: () => Navigator.pop(context)),
              _NavItem(icon: Icons.notifications, label: 'Notif', isActive: true),
              const SizedBox(width: 56),
              _NavItem(icon: Icons.chat_bubble_outline, label: 'mess', isActive: false),
              _NavItem(icon: Icons.person_outline, label: 'Profil', isActive: false),
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
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
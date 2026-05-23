import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/features/notifications/domain/notification_entity.dart';
import 'package:job_app/features/notifications/data/providers/notifications_provider.dart';

// ─── Provider global ────────────────────────────────────────────────────────
final notificationToastServiceProvider = Provider<NotificationToastService>((ref) {
  return NotificationToastService(ref);
});

// ─── Service ────────────────────────────────────────────────────────────────
class NotificationToastService {
  final Ref _ref;
  OverlayEntry? _currentToast;

  NotificationToastService(this._ref);

  /// Affiche une bannière en haut ET ajoute la notif dans la liste
  void show({
    required BuildContext context,
    required String title,
    required NotificationType type,
    String? senderName,
    String? jobTitle,
    int? count,
  }) {
    // 1. Ajouter dans la liste de notifs (mock)
    _addToNotifications(
      title: title,
      type: type,
      senderName: senderName,
      jobTitle: jobTitle,
      count: count,
    );

    // 2. Afficher la bannière
    _showToast(context: context, title: title, type: type);
  }

  /// Ajoute uniquement dans la liste candidat (sans toast)
  void addCandidateNotification({
    required String title,
    required NotificationType type,
    String? senderName,
    String? jobTitle,
    int? count,
  }) {
    final notif = NotificationEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      type: type,
      dateCreation: DateTime.now(),
      isRead: false,
      senderName: senderName,
      jobTitle: jobTitle,
      count: count,
    );
    _ref.read(candidateNotificationsControllerProvider.notifier).addNotification(notif);
  }

  /// Affiche uniquement le toast (sans ajouter dans la liste)
  void showToastOnly({
    required BuildContext context,
    required String title,
    required NotificationType type,
  }) {
    _showToast(context: context, title: title, type: type);
  }

  void _addToNotifications({
    required String title,
    required NotificationType type,
    String? senderName,
    String? jobTitle,
    int? count,
  }) {
    final notif = NotificationEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      type: type,
      dateCreation: DateTime.now(),
      isRead: false,
      senderName: senderName,
      jobTitle: jobTitle,
      count: count,
    );

    // Détecter si c'est candidat ou recruteur selon le type
    final isCandidate = [
      NotificationType.applicationAccepted,
      NotificationType.applicationRejected,
      NotificationType.applicationViewed,
      NotificationType.newNearbyOffer,
      NotificationType.jobMatchingPreferences,
      NotificationType.savedJobExpiring,
      NotificationType.newJobInCategory,
      NotificationType.profileViewed,
      NotificationType.profileIncomplete,
    ].contains(type);

    if (isCandidate) {
      _ref.read(candidateNotificationsControllerProvider.notifier).addNotification(notif);
    } else {
      _ref.read(notificationsControllerProvider.notifier).addNotification(notif);
    }
  }

  void _showToast({
    required BuildContext context,
    required String title,
    required NotificationType type,
  }) {
    _currentToast?.remove();

    final overlay = Overlay.of(context);
    _currentToast = OverlayEntry(
      builder: (_) => _NotificationToastWidget(
        title: title,
        type: type,
        onDismiss: () {
          _currentToast?.remove();
          _currentToast = null;
        },
      ),
    );

    overlay.insert(_currentToast!);

    // Auto-dismiss après 4 secondes
    Future.delayed(const Duration(seconds: 4), () {
      _currentToast?.remove();
      _currentToast = null;
    });
  }
}

// ─── Widget bannière ─────────────────────────────────────────────────────────
class _NotificationToastWidget extends StatefulWidget {
  final String title;
  final NotificationType type;
  final VoidCallback onDismiss;

  const _NotificationToastWidget({
    required this.title,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_NotificationToastWidget> createState() => _NotificationToastWidgetState();
}

class _NotificationToastWidgetState extends State<_NotificationToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _slide = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  IconData get _icon {
    switch (widget.type) {
      case NotificationType.newMessage:
        return Icons.chat_bubble_outline;
      case NotificationType.newApplicants:
      case NotificationType.applicationAccepted:
      case NotificationType.applicationViewed:
      case NotificationType.interviewAccepted:
        return Icons.person_add_outlined;
      case NotificationType.applicationRejected:
        return Icons.cancel_outlined;
      case NotificationType.missionCompleted:
        return Icons.check_circle_outline;
      case NotificationType.missionExpiring:
      case NotificationType.savedJobExpiring:
      case NotificationType.announcementCreated:
        return Icons.timer_outlined;
      case NotificationType.newNearbyOffer:
      case NotificationType.jobMatchingPreferences:
      case NotificationType.newJobInCategory:
        return Icons.work_outline;
      case NotificationType.jobQuestion:
        return Icons.help_outline;
      case NotificationType.profileViewed:
        return Icons.visibility_outlined;
      case NotificationType.profileIncomplete:
        return Icons.warning_amber_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: GestureDetector(
            onTap: widget.onDismiss,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1B2E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF401E66),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_icon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Jobiha',
                            style: TextStyle(
                              color: Color(0xFFB39DDB),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.title.replaceAll('\n', ' '),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Inter',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onDismiss,
                      child: const Icon(Icons.close, color: Colors.white54, size: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

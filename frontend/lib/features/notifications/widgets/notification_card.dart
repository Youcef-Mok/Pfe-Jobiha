import 'package:flutter/material.dart';
import '../domain/notification_entity.dart';

class NotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final n = notification;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          if (!n.isRead && onTap != null) onTap!();
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEDEDED)),
            boxShadow: const [
              BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left border accent (4px)
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: n.category.borderColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                // Main content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
                    child: _buildContent(n),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(NotificationEntity n) {
    final time = _formatTime(n.dateCreation);
    final isUnread = !n.isRead;

    switch (n.type) {
      // â”€â”€ Recruiter â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
      case NotificationType.newApplicants:
        return _CardLayout(
          leading: _IconCircle(
            icon: Icons.people,
            iconColor: const Color(0xFF233455),
            bgColor: const Color(0xFFE7EDFF),
          ),
          title: '${n.count ?? 0} nouveaux candidats\npour le poste de "${n.jobTitle ?? ''}"',
          time: time,
          isUnread: isUnread,
          senderName: n.senderName,
          jobTitle: n.jobTitle,
          button: _NotifBtn(
            label: 'Voir les profils',
            bgColor: const Color(0xFFE7EDFF),
            textColor: const Color(0xFF233455),
          ),
        );

      case NotificationType.newMessage:
        return _CardLayout(
          leading: n.contextImageUrl != null
              ? _ImgWithBadge(asset: n.contextImageUrl!, badgeColor: const Color(0xFF513376))
              : _AvatarWithBadge(
                  asset: n.avatarUrl,
                  badgeColor: const Color(0xFF513376),
                  badgeIconColor: Colors.white,
                ),
          title: n.title,
          time: time,
          isUnread: isUnread,
          senderName: n.senderName,
          jobTitle: n.jobTitle,
          button: n.contextImageUrl == null
              ? _NotifBtn(
                  label: 'Répondre',
                  bgColor: const Color(0xFF3B1D5E),
                  textColor: Colors.white,
                )
              : null,
        );

      case NotificationType.jobQuestion:
        return _CardLayout(
          leading: _IconCircle(
            icon: Icons.help_outline,
            iconColor: const Color(0xFF6A6C76),
            bgColor: const Color(0xFFEFEDF2),
          ),
          title: n.jobTitle != null
              ? 'Nouvelle question sur\nvotre annonce "${n.jobTitle}"'
              : 'Nouvelle question sur\nvotre annonce',
          time: time,
          isUnread: isUnread,
          senderName: n.senderName,
          jobTitle: n.jobTitle,
          button: _NotifBtn(
            label: 'Répondre',
            bgColor: const Color(0xFFEFEDF2),
            textColor: const Color(0xFF505050),
          ),
        );

      case NotificationType.missionExpiring:
        return _CardLayout(
          leading: _IconCircle(
            icon: Icons.assignment_outlined,
            iconColor: const Color(0xFF6A6C76),
            bgColor: const Color(0xFFEFEDF2),
          ),
          title: n.jobTitle != null
              ? 'Mission "${n.jobTitle}"\nexpire bientot'
              : 'Mission expire bientot',
          time: time,
          isUnread: isUnread,
          senderName: n.senderName,
          jobTitle: n.jobTitle,
          button: _NotifBtn(
            label: 'Prolonger',
            icon: Icons.history,
            bgColor: const Color(0xFFEFEDF2),
            textColor: const Color(0xFF505050),
          ),
        );

      case NotificationType.interviewAccepted:
        return _CardLayout(
          leading: _AvatarWithBadge(
            asset: n.avatarUrl,
            badgeColor: const Color(0xFFE9EEFE),
            badgeIconColor: const Color(0xFF394866),
            badgeIcon: Icons.assignment_outlined,
          ),
          title: n.title,
          time: time,
          isUnread: isUnread,
          senderName: n.senderName,
          jobTitle: n.jobTitle,
          button: _NotifBtn(
            label: 'Voir les profils',
            bgColor: const Color(0xFFE7EDFF),
            textColor: const Color(0xFF233455),
          ),
        );

      case NotificationType.missionCompleted:
        return _CardLayout(
          leading: _IconCircle(
            icon: Icons.assignment_turned_in_outlined,
            iconColor: const Color(0xFF6A6C76),
            bgColor: const Color(0xFFEFEDF2),
          ),
          title: n.title,
          time: time,
          isUnread: isUnread,
          senderName: n.senderName,
          jobTitle: n.jobTitle,
          button: _NotifBtn(
            label: 'Noter',
            icon: Icons.star_outline,
            bgColor: const Color(0xFFEFEDF2),
            textColor: const Color(0xFF505050),
          ),
        );

      case NotificationType.announcementCreated:
        return _CardLayout(
          leading: _IconCircle(
            icon: Icons.event_note_outlined,
            iconColor: const Color(0xFF6A6C76),
            bgColor: const Color(0xFFEFEDF2),
          ),
          title: n.title,
          time: time,
          isUnread: isUnread,
          senderName: n.senderName,
          jobTitle: n.jobTitle,
          button: _NotifBtn(
            label: 'Prolonger',
            icon: Icons.history,
            bgColor: const Color(0xFFEFEDF2),
            textColor: const Color(0xFF505050),
          ),
        );

      // â”€â”€ Candidate â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
      case NotificationType.applicationAccepted:
        return _CardLayout(
          leading: _IconCircle(
            icon: Icons.check_circle_outline,
            iconColor: const Color(0xFF233455),
            bgColor: const Color(0xFFE7EDFF),
          ),
          title: n.title,
          time: time,
          isUnread: isUnread,
          senderName: n.senderName,
          jobTitle: n.jobTitle,
          button: _NotifBtn(
            label: "Voir l'offre",
            bgColor: const Color(0xFFE7EDFF),
            textColor: const Color(0xFF233455),
          ),
        );

      case NotificationType.applicationRejected:
        return _CardLayout(
          leading: _IconCircle(
            icon: Icons.cancel_outlined,
            iconColor: const Color(0xFF233455),
            bgColor: const Color(0xFFE7EDFF),
          ),
          title: n.title,
          time: time,
          isUnread: isUnread,
          senderName: n.senderName,
          jobTitle: n.jobTitle,
        );

      case NotificationType.applicationViewed:
        return _CardLayout(
          leading: _IconCircle(
            icon: Icons.visibility_outlined,
            iconColor: const Color(0xFF233455),
            bgColor: const Color(0xFFE7EDFF),
          ),
          title: n.title,
          time: time,
          isUnread: isUnread,
          senderName: n.senderName,
          jobTitle: n.jobTitle,
          button: _NotifBtn(
            label: "Voir l'offre",
            bgColor: const Color(0xFFE7EDFF),
            textColor: const Color(0xFF233455),
          ),
        );

      case NotificationType.newNearbyOffer:
        return _CardLayout(
          leading: _IconCircle(
            icon: Icons.location_on_outlined,
            iconColor: const Color(0xFF6A6C76),
            bgColor: const Color(0xFFEFEDF2),
          ),
          title: n.title,
          time: time,
          isUnread: isUnread,
          senderName: n.senderName,
          jobTitle: n.jobTitle,
          button: _NotifBtn(
            label: "Voir l'offre",
            bgColor: const Color(0xFFEFEDF2),
            textColor: const Color(0xFF505050),
          ),
        );

      case NotificationType.jobMatchingPreferences:
        return _CardLayout(
          leading: _IconCircle(
            icon: Icons.star_outline,
            iconColor: const Color(0xFF6A6C76),
            bgColor: const Color(0xFFEFEDF2),
          ),
          title: n.title,
          time: time,
          isUnread: isUnread,
          senderName: n.senderName,
          jobTitle: n.jobTitle,
          button: _NotifBtn(
            label: "Voir l'offre",
            bgColor: const Color(0xFFEFEDF2),
            textColor: const Color(0xFF505050),
          ),
        );

      case NotificationType.savedJobExpiring:
        return _CardLayout(
          leading: _IconCircle(
            icon: Icons.bookmark_outline,
            iconColor: const Color(0xFF6A6C76),
            bgColor: const Color(0xFFEFEDF2),
          ),
          title: n.title,
          time: time,
          isUnread: isUnread,
          senderName: n.senderName,
          jobTitle: n.jobTitle,
          button: _NotifBtn(
            label: "Voir l'offre",
            icon: Icons.history,
            bgColor: const Color(0xFFEFEDF2),
            textColor: const Color(0xFF505050),
          ),
        );

      case NotificationType.newJobInCategory:
        return _CardLayout(
          leading: _IconCircle(
            icon: Icons.work_outline,
            iconColor: const Color(0xFF6A6C76),
            bgColor: const Color(0xFFEFEDF2),
          ),
          title: n.title,
          time: time,
          isUnread: isUnread,
          senderName: n.senderName,
          jobTitle: n.jobTitle,
          button: _NotifBtn(
            label: 'Voir',
            bgColor: const Color(0xFFEFEDF2),
            textColor: const Color(0xFF505050),
          ),
        );

      case NotificationType.profileViewed:
        return _CardLayout(
          leading: _IconCircle(
            icon: Icons.visibility_outlined,
            iconColor: const Color(0xFF6A6C76),
            bgColor: const Color(0xFFF3ECF2),
          ),
          title: n.title,
          time: time,
          isUnread: isUnread,
          senderName: n.senderName,
          jobTitle: n.jobTitle,
        );

      case NotificationType.profileIncomplete:
        return _CardLayout(
          leading: _IconCircle(
            icon: Icons.person_outline,
            iconColor: const Color(0xFF401E66),
            bgColor: const Color(0xFFF5F1F9),
          ),
          title: n.title,
          time: time,
          isUnread: isUnread,
          senderName: n.senderName,
          jobTitle: n.jobTitle,
          button: _NotifBtn(
            label: 'Compléter',
            icon: Icons.edit_outlined,
            bgColor: const Color(0xFF401E66),
            textColor: Colors.white,
          ),
        );

      default:
        return _CardLayout(
          leading: _IconCircle(
            icon: Icons.notifications_outlined,
            iconColor: const Color(0xFF6A6C76),
            bgColor: const Color(0xFFF3ECF2),
          ),
          title: n.title,
          time: time,
          isUnread: isUnread,
          senderName: n.senderName,
          jobTitle: n.jobTitle,
        );
    }
  }

  String _formatTime(DateTime ts) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(ts.year, ts.month, ts.day);
    final h = ts.hour.toString().padLeft(2, '0');
    final m = ts.minute.toString().padLeft(2, '0');
    if (day == today) return '$h:$m';
    if (day == today.subtract(const Duration(days: 1))) return 'Hier, $h:${m}h';
    return '${ts.day}/${ts.month}';
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// _CardLayout "” [leading] [title (flex)] [time+dot / button]
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _CardLayout extends StatelessWidget {
  final Widget leading;
  final String title;
  final String time;
  final bool isUnread;
  final _NotifBtn? button;
  final String? senderName;
  final String? jobTitle;

  const _CardLayout({
    required this.leading,
    required this.title,
    required this.time,
    required this.isUnread,
    this.button,
    this.senderName,
    this.jobTitle,
  });

  // Bold senderName and text in “...” within the title
  List<TextSpan> _buildSpans(Color baseColor) {
    final bold = TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w800,
      fontSize: 15,
      height: 20 / 15,
      letterSpacing: 0.2,
      color: baseColor,
    );
    final normal = TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w700,
      fontSize: 15,
      height: 20 / 15,
      letterSpacing: 0.2,
      color: baseColor,
    );

    // Collect bold patterns: senderName + any text within “...”
    final boldPatterns = <String>[];
    if (senderName != null && senderName!.isNotEmpty) boldPatterns.add(RegExp.escape(senderName!));
    boldPatterns.add('”[^”]+”'); // quoted job titles

    if (boldPatterns.isEmpty) return [TextSpan(text: title, style: normal)];

    final pattern = RegExp(boldPatterns.join('|'));
    final spans = <TextSpan>[];
    int cursor = 0;
    for (final m in pattern.allMatches(title)) {
      if (m.start > cursor) spans.add(TextSpan(text: title.substring(cursor, m.start), style: normal));
      spans.add(TextSpan(text: m.group(0), style: bold));
      cursor = m.end;
    }
    if (cursor < title.length) spans.add(TextSpan(text: title.substring(cursor), style: normal));
    return spans.isEmpty ? [TextSpan(text: title, style: normal)] : spans;
  }

  @override
  Widget build(BuildContext context) {
    final titleColor = isUnread ? const Color(0xFF000000) : const Color(0xFF1C1C1C);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon / avatar
        leading,
        const SizedBox(width: 10),

        // Title — fills remaining width
        Expanded(
          child: RichText(
            text: TextSpan(children: _buildSpans(titleColor)),
          ),
        ),
        const SizedBox(width: 8),

        // Right column: time [+dot] on top, button below
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Time + unread dot
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    color: Color(0xFF7C7580),
                  ),
                ),
                if (isUnread) ...[
                  const SizedBox(width: 4),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3A1B5E),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),

            // Action button
            if (button != null) ...[
              const SizedBox(height: 8),
              button!,
            ],
          ],
        ),
      ],
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Action button (fixed width, right-aligned)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _NotifBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color bgColor;
  final Color textColor;

  const _NotifBtn({
    required this.label,
    this.icon,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor, size: 12),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Icon circle avatar
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _IconCircle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _IconCircle({required this.icon, required this.iconColor, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Icon(icon, color: iconColor, size: 22),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Photo avatar with small badge circle
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _AvatarWithBadge extends StatelessWidget {
  final String? asset;
  final Color badgeColor;
  final Color badgeIconColor;
  final IconData badgeIcon;

  const _AvatarWithBadge({
    this.asset,
    required this.badgeColor,
    this.badgeIconColor = Colors.white,
    this.badgeIcon = Icons.chat_bubble_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFE2E8F0),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))],
            image: asset != null
                ? DecorationImage(image: AssetImage(asset!), fit: BoxFit.cover)
                : null,
          ),
          child: asset == null ? const Icon(Icons.person, color: Colors.grey, size: 24) : null,
        ),
        Positioned(
          right: -4,
          bottom: -4,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(badgeIcon, color: badgeIconColor, size: 10),
          ),
        ),
      ],
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Rectangular image (job photo) with badge
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _ImgWithBadge extends StatelessWidget {
  final String asset;
  final Color badgeColor;

  const _ImgWithBadge({required this.asset, required this.badgeColor});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 50,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: const Color(0xFFE2E8F0),
            image: DecorationImage(image: AssetImage(asset), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          right: -4,
          bottom: -4,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 10),
          ),
        ),
      ],
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Section header
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class NotificationSectionHeader extends StatelessWidget {
  final String title;
  const NotificationSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 0.6,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }
}

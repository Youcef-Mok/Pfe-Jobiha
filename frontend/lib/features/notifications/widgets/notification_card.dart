import 'package:flutter/material.dart';
import '../domain/notification_entity.dart';
import 'package:intl/intl.dart';

class NotificationCard extends StatefulWidget {
  final NotificationEntity notification;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final n = widget.notification;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          setState(() => _isExpanded = !_isExpanded);
          if (widget.onTap != null) widget.onTap!();
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF8FAFC)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Vertical unread indicator
              if (!n.isRead)
                Positioned(
                  left: 0,
                  top: 3,
                  bottom: 3,
                  child: Container(
                    width: 5,
                    decoration: const BoxDecoration(
                      color: Color(0xFF401E66),
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
                    ),
                  ),
                ),

              // Main content
              Padding(
                padding: const EdgeInsets.all(16),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: _buildLayout(n),
                ),
              ),
              
              // Unread Dot (top right)
              if (!n.isRead)
                const Positioned(
                  right: 17,
                  top: 17,
                  child: _UnreadDot(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLayout(NotificationEntity n) {
    final timeStr = DateFormat('HH:mm').format(n.timestamp);

    switch (n.type) {
      case NotificationType.newApplicants:
        return _ApplicantsLayout(
          count: n.count ?? 0,
          position: n.jobTitle ?? '',
          time: timeStr,
          isExpanded: _isExpanded,
        );
      case NotificationType.newMessage:
        return _MessageLayout(
          senderName: n.senderName ?? 'Inconnu',
          title: n.title,
          time: timeStr,
          avatarUrl: n.avatarUrl,
          contextImageUrl: n.contextImageUrl,
          isExpanded: _isExpanded,
        );
      case NotificationType.jobQuestion:
        return _QuestionLayout(
          jobTitle: n.jobTitle ?? '',
          time: 'Hier, $timeStr',
          isExpanded: _isExpanded,
        );
      case NotificationType.missionExpiring:
        return _ExpiringLayout(
          jobTitle: n.jobTitle ?? '',
          time: 'Hier, $timeStr',
          isExpanded: _isExpanded,
        );
      case NotificationType.interviewAccepted:
        return _ActionLayout(
          senderName: n.senderName ?? '',
          title: n.title,
          message: n.message ?? '',
          time: 'Hier, $timeStr',
          avatarUrl: n.avatarUrl,
          isExpanded: _isExpanded,
          label: 'Valider',
          bgColor: const Color(0xFFE1F5EA),
          textColor: const Color(0xFF79B282),
          icon: Icons.check_circle_outline,
        );
      case NotificationType.missionCompleted:
        return _ActionLayout(
          title: n.title,
          time: 'Hier, $timeStr',
          isExpanded: _isExpanded,
          label: 'Noter employe',
          bgColor: const Color(0x33D9B9FF),
          textColor: const Color(0xFF3A1B5E),
          icon: Icons.star_border,
          leadingIcon: Icons.assignment_turned_in_outlined,
          leadingColor: const Color(0xFF7C7580),
          leadingBg: const Color(0xFFF3ECF2),
        );
      case NotificationType.announcementCreated:
        return _AnnouncementLayout(
          title: n.title,
          time: 'Hier, $timeStr',
          isExpanded: _isExpanded,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─────────────────────────────────────────────
// SUB-LAYOUTS
// ─────────────────────────────────────────────

class _ApplicantsLayout extends StatelessWidget {
  final int count;
  final String position;
  final String time;
  final bool isExpanded;

  const _ApplicantsLayout({required this.count, required this.position, required this.time, required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CardLeading(icon: Icons.people, color: const Color(0xFF3A1B5E), bgColor: const Color(0xFFEBD9FC)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '$count nouveaux candidats\npour le poste de $position',
                      style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 16, height: 1.25, color: Color(0xFF1D1B1F)),
                    ),
                  ),
                  Text(time, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 10, color: Color(0xFF7C7580))),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 12),
                _ActionButton(
                  label: 'Voir les profils',
                  icon: Icons.person,
                  bgColor: const Color(0x33D9B9FF),
                  textColor: const Color(0xFF3A1B5E),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageLayout extends StatelessWidget {
  final String senderName;
  final String title;
  final String time;
  final String? avatarUrl;
  final String? contextImageUrl;
  final bool isExpanded;

  const _MessageLayout({required this.senderName, required this.title, required this.time, this.avatarUrl, this.contextImageUrl, required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AvatarBadge(avatarUrl: avatarUrl, icon: contextImageUrl != null ? Icons.work : Icons.chat_bubble),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 16, height: 1.25, color: Color(0xFF1D1B1F)),
                    ),
                  ),
                  Text(time, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 10, color: Color(0xFF7C7580))),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 12),
                if (contextImageUrl != null)
                  _ContextImage(imageUrl: contextImageUrl!),
                const SizedBox(height: 8),
                _ActionButton(
                  label: 'Répondre',
                  icon: Icons.reply,
                  bgColor: const Color(0xFF401E66),
                  textColor: Colors.white,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _QuestionLayout extends StatelessWidget {
  final String jobTitle;
  final String time;
  final bool isExpanded;

  const _QuestionLayout({required this.jobTitle, required this.time, required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CardLeading(icon: Icons.help_outline, color: const Color(0xFF6F5D1D), bgColor: const Color(0x4DC1AA62)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Nouvelle question sur\nvotre annonce',
                      style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 16, height: 1.25, color: Color(0xFF1D1B1F)),
                    ),
                  ),
                  Text(time, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 10, color: Color(0xFF7C7580))),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 12),
                _ActionButton(
                  label: 'Répondre',
                  icon: Icons.reply,
                  bgColor: const Color(0xFF401E66),
                  textColor: Colors.white,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ExpiringLayout extends StatelessWidget {
  final String jobTitle;
  final String time;
  final bool isExpanded;

  const _ExpiringLayout({required this.jobTitle, required this.time, required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CardLeading(icon: Icons.access_time, color: const Color(0xFF7C7580), bgColor: const Color(0xFFF3ECF2)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Mission expire bientot',
                      style: TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: -0.5, color: Color(0xFF0F172A)),
                    ),
                  ),
                  Text(time, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 10, color: Color(0xFF7C7580))),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 12),
                _ActionButton(
                  label: 'Prolonger',
                  icon: Icons.history,
                  bgColor: const Color(0xFFE3E7C3),
                  textColor: const Color(0xFF8B8752),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionLayout extends StatelessWidget {
  final String? senderName;
  final String title;
  final String? message;
  final String time;
  final String? avatarUrl;
  final bool isExpanded;
  final String label;
  final Color bgColor;
  final Color textColor;
  final IconData icon;
  final IconData? leadingIcon;
  final Color? leadingColor;
  final Color? leadingBg;

  const _ActionLayout({
    this.senderName, required this.title, this.message, required this.time, 
    this.avatarUrl, required this.isExpanded, required this.label, required this.bgColor, 
    required this.textColor, required this.icon, this.leadingIcon, this.leadingColor, this.leadingBg,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leadingIcon != null)
           _CardLeading(icon: leadingIcon!, color: leadingColor!, bgColor: leadingBg!)
        else
          _AvatarBadge(avatarUrl: avatarUrl, icon: Icons.check),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 16, height: 1.25, color: Color(0xFF1D1B1F)),
                    ),
                  ),
                  Text(time, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 10, color: Color(0xFF7C7580))),
                ],
              ),
              if (isExpanded) ...[
                if (message != null && message!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(message!, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w400, fontSize: 14, color: Color(0xFF4A454F))),
                ],
                const SizedBox(height: 12),
                _ActionButton(
                  label: label,
                  icon: icon,
                  bgColor: bgColor,
                  textColor: textColor,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AnnouncementLayout extends StatelessWidget {
  final String title;
  final String time;
  final bool isExpanded;

  const _AnnouncementLayout({required this.title, required this.time, required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CardLeading(icon: Icons.event_note, color: const Color(0xFF7C7580), bgColor: const Color(0xFFF3ECF2)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 15, letterSpacing: -0.5, color: Color(0xFF0F172A)),
                    ),
                  ),
                  Text(time, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 10, color: Color(0xFF7C7580))),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    _ActionButton(
                      label: 'Modifier',
                      icon: Icons.edit_outlined,
                      bgColor: const Color(0x33D9B9FF),
                      textColor: const Color(0xFF505050),
                    ),
                    const SizedBox(width: 10),
                    _ActionButton(
                      label: 'Mettre en brouillon',
                      icon: Icons.drafts_outlined,
                      bgColor: const Color(0x33D9B9FF),
                      textColor: const Color(0xFF3A1B5E),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// COMPONENTS
// ─────────────────────────────────────────────

class _CardLeading extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _CardLeading({required this.icon, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Center(child: Icon(icon, color: color, size: 22)),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  final String? avatarUrl;
  final IconData icon;

  const _AvatarBadge({this.avatarUrl, required this.icon});

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
            image: avatarUrl != null 
              ? DecorationImage(image: AssetImage(avatarUrl!), fit: BoxFit.cover)
              : null,
            color: avatarUrl == null ? Colors.grey[200] : null,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        Positioned(
          right: -4,
          bottom: -4,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF513376),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(child: Icon(icon, color: Colors.white, size: 12)),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color textColor;

  const _ActionButton({required this.label, required this.icon, required this.bgColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 12, color: textColor),
          ),
        ],
      ),
    );
  }
}

class _ContextImage extends StatelessWidget {
  final String imageUrl;

  const _ContextImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(image: AssetImage(imageUrl), fit: BoxFit.cover),
      ),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(color: Color(0xFF3A1B5E), shape: BoxShape.circle),
    );
  }
}

class NotificationSectionHeader extends StatelessWidget {
  final String title;

  const NotificationSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 16, 16, 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.6,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }
}

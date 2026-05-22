import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:job_app/features/profile/domain/user_entity.dart';

class ShareProfileOverlay extends StatelessWidget {
  final UserEntity user;

  const ShareProfileOverlay({super.key, required this.user});

  String get _profileLink => 'https://jobapp.dz/candidat/${user.id}';

  Future<void> _copyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _profileLink));
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lien copié dans le presse-papiers'),
          backgroundColor: Color(0xFF401E66),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _shareVia(BuildContext context, String scheme) async {
    final text = Uri.encodeComponent('Découvrez mon profil JobApp : $_profileLink');
    final Uri uri;
    switch (scheme) {
      case 'whatsapp':
        uri = Uri.parse('whatsapp://send?text=$text');
      case 'telegram':
        uri = Uri.parse('tg://msg?text=$text');
      case 'email':
        uri = Uri.parse('mailto:?subject=Mon profil JobApp&body=$text');
      case 'sms':
        uri = Uri.parse('sms:?body=$text');
      default:
        return;
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application non disponible')),
        );
      }
    }
  }

  void _exportPdf(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export PDF — à venir'),
        backgroundColor: Color(0xFF401E66),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 16, 24, 24 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          const Text(
            'Partager le profil',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _profileLink,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Color(0xFF94A3B8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),

          // Social icons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SocialButton(
                icon: FontAwesomeIcons.whatsapp,
                label: 'WhatsApp',
                color: const Color(0xFF25D366),
                onTap: () => _shareVia(context, 'whatsapp'),
              ),
              _SocialButton(
                icon: FontAwesomeIcons.telegram,
                label: 'Telegram',
                color: const Color(0xFF229ED9),
                onTap: () => _shareVia(context, 'telegram'),
              ),
              _SocialButton(
                icon: FontAwesomeIcons.envelope,
                label: 'Email',
                color: const Color(0xFF6B7280),
                onTap: () => _shareVia(context, 'email'),
              ),
              _SocialButton(
                icon: FontAwesomeIcons.commentSms,
                label: 'SMS',
                color: const Color(0xFF401E66),
                onTap: () => _shareVia(context, 'sms'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Copy link button
          _ActionButton(
            icon: Icons.link,
            label: 'Copier le lien',
            onTap: () => _copyLink(context),
          ),
          const SizedBox(height: 10),

          // Export PDF button
          _ActionButton(
            icon: Icons.picture_as_pdf_outlined,
            label: 'Exporter en PDF',
            onTap: () => _exportPdf(context),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: FaIcon(icon, color: color, size: 22),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F7FC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF401E66)),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

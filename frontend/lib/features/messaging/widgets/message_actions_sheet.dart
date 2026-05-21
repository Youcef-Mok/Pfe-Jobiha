import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:job_app/features/messaging/domain/message_entity.dart';

class messageActionsSheet extends StatelessWidget {
  final MessageEntity message;
  final VoidCallback? onReply;

  const messageActionsSheet({super.key, required this.message, this.onReply});

  static const List<String> _emojis = ['❤️', '🔥', '🙌', '👍', '🙏'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // message preview
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  message.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
            ),

            // react row
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'react',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ..._emojis.map(
                        (e) => _EmojiButton(
                          emoji: e,
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                      _EmojiButton(
                        isPlus: true,
                        onTap: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Container(height: 1, color: const Color(0xFFF1EEF6)),

            _ActionTile(
              label: 'copy',
              icon: Icons.copy_outlined,
              onTap: () {
                Clipboard.setData(ClipboardData(text: message.content));
                Navigator.pop(context);
              },
            ),
            Container(
                height: 1,
                margin: const EdgeInsets.only(left: 14),
                color: const Color(0xFFF1EEF6)),
            _ActionTile(
              label: 'reply',
              icon: Icons.reply_outlined,
              onTap: () {
                Navigator.pop(context);
                onReply?.call();
              },
            ),
            Container(
                height: 1,
                margin: const EdgeInsets.only(left: 14),
                color: const Color(0xFFF1EEF6)),
            _ActionTile(
              label: 'forward',
              icon: Icons.shortcut_outlined,
              onTap: () => Navigator.pop(context),
            ),
            Container(
                height: 1,
                margin: const EdgeInsets.only(left: 14),
                color: const Color(0xFFF1EEF6)),
            _ActionTile(
              label: 'report',
              icon: Icons.flag_outlined,
              onTap: () => Navigator.pop(context),
            ),
            Container(
                height: 1,
                margin: const EdgeInsets.only(left: 14),
                color: const Color(0xFFF1EEF6)),
            _ActionTile(
              label: 'delete',
              icon: Icons.delete_outline,
              isDestructive: true,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _EmojiButton extends StatelessWidget {
  final String? emoji;
  final bool isPlus;
  final VoidCallback onTap;

  const _EmojiButton({
    this.emoji,
    this.isPlus = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isPlus ? const Color(0xFFF1F5F9) : const Color(0xFFF8F6FF),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: isPlus
            ? const Icon(Icons.add, size: 18, color: Color(0xFF64748B))
            : Text(emoji!, style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDestructive;
  final VoidCallback onTap;

  const _ActionTile({
    required this.label,
    required this.icon,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isDestructive ? const Color(0xFFEF4444) : const Color(0xFF0F172A);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: color,
              ),
            ),
            Icon(icon, size: 20, color: color),
          ],
        ),
      ),
    );
  }
}

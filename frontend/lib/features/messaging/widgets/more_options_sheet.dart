import 'package:flutter/material.dart';

class MoreOptionsSheet extends StatelessWidget {
  final bool isRecruiter;
  final VoidCallback? onBlock;
  final VoidCallback? onRestrict;
  final VoidCallback? onReport;

  const MoreOptionsSheet({
    super.key,
    this.isRecruiter = false,
    this.onBlock,
    this.onRestrict,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F3FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _OptionTile(
              icon: Icons.shield_outlined,
              title: 'restreindre',
              subtitle: "moins d'interactions visibles",
              onTap: () {
                Navigator.pop(context);
                onRestrict?.call();
              },
            ),
            const _Divider(),
            _OptionTile(
              icon: Icons.block,
              title: 'bloquer',
              subtitle: 'supprimer tout contact',
              onTap: () {
                Navigator.pop(context);
                onBlock?.call();
              },
            ),
            const _Divider(),
            _OptionTile(
              icon: Icons.flag_outlined,
              title: 'signaler',
              subtitle: 'signaler un comportement',
              onTap: () {
                Navigator.pop(context);
                onReport?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: const Color(0xFFE8E0F0),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFEDE9F7),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 22, color: const Color(0xFF401E66)),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


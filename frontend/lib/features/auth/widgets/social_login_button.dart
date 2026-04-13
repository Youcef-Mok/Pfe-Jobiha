import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final IconData fallbackIcon;
  final Color color;
  final VoidCallback onTap;

  const SocialLoginButton({
    super.key,
    required this.fallbackIcon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withValues(alpha: 0.4),
            width: 1.5,
          ),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(fallbackIcon, color: color, size: 24),
        ),
      ),
    );
  }
}
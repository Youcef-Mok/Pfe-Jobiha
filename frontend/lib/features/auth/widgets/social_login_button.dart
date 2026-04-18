import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final IconData fallbackIcon;
  final Color color;
  final VoidCallback? onTap; // nullable so disabled state works
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    required this.fallbackIcon,
    required this.color,
    required this.onTap,
    this.isLoading = false,
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
            color: color.withValues(alpha: onTap == null ? 0.2 : 0.4),
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
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              : Icon(
                  fallbackIcon,
                  color: color.withValues(alpha: onTap == null ? 0.3 : 1.0),
                  size: 24,
                ),
        ),
      ),
    );
  }
}
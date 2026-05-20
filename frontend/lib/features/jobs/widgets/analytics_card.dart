import 'package:flutter/material.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/core/widgets/svg_icon.dart';

/// Carte analytics avec compteur et icône
class AnalyticsCard extends StatelessWidget {
  final IconData? icon;
  final String? svgIcon;
  final String label;
  final int count;
  final Color? iconColor;
  final Color? dotColor;

  const AnalyticsCard({
    super.key,
    this.icon,
    this.svgIcon,
    required this.label,
    required this.count,
    this.iconColor,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 195,
        maxHeight: 84,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3A1B5E).withValues(alpha: 0.05),
            blurRadius: 4,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icône SVG, icône Material ou point coloré
          if (svgIcon != null)
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.violet).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: SvgIcon(
                  assetPath: svgIcon!,
                  size: 17,
                  color: iconColor ?? AppColors.violet,
                ),
              ),
            )
          else if (icon != null)
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.violet).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                size: 17,
                color: iconColor ?? AppColors.violet,
              ),
            )
          else if (dotColor != null)
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 15),
          // Compteur et Label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Compteur
                Text(
                  count.toString(),
                  style: AppTextStyles.heading1.copyWith(
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate900,
                  ),
                ),
                const SizedBox(height: 2),
                // Label
                Text(
                  label,
                  style: AppTextStyles.captionLight.copyWith(
                    fontSize: 11,
                    color: AppColors.slate600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

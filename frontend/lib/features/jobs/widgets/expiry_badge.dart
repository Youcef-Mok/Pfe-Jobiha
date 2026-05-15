import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ExpiryBadge extends StatelessWidget {
  final String label;

  const ExpiryBadge({super.key, this.label = '2weeks'});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 265,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Partie gauche — "Expire dans"
          Container(
            width: 125,
            height: 29,
            decoration: BoxDecoration(
              color: AppColors.violet,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.timer_outlined,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 5),
                const Text(
                  'se termine dans',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Partie droite — valeur
          Container(
            width: 74,
            height: 29,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x15000000), // Ombre plus douce
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppColors.violet,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

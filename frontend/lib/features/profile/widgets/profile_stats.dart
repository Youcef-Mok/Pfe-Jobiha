import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_app/features/profile/domain/user_entity.dart';

/// Section statistiques (Missions, Annonces, Reviews) avec style IG #38145B
class ProfileStats extends StatelessWidget {
  final UserEntity user;

  const ProfileStats({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 344),
        height: 41,
        decoration: BoxDecoration(
          color: const Color(0xFF38145B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x4DCCC3D0)), // rgba(204, 195, 208, 0.3)
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000), // 0.15 opacity
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(child: _StatSegment(value: '128', label: 'MISSIONS')),
            Container(width: 1, height: 32, color: const Color(0x66CCC3D0)), // divider
            Expanded(child: _StatSegment(value: '45', label: 'ANNONCE')),
            Container(width: 1, height: 32, color: const Color(0x66CCC3D0)), // divider
            Expanded(child: _StatSegment(value: '45', label: 'REVIEWS')),
          ],
        ),
      ),
    );
  }
}

class _StatSegment extends StatelessWidget {
  final String value;
  final String label;

  const _StatSegment({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            height: 1.1,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 8,
            letterSpacing: 0.55,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

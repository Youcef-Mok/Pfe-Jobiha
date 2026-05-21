import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_app/features/profile/domain/user_entity.dart';

/// Stats du candidat (badge missions + rating/reviews)
class CandidateProfileStats extends StatelessWidget {
  final UserEntity user;
  final int reviewsCount;

  const CandidateProfileStats({
    super.key,
    required this.user,
    this.reviewsCount = 124,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF401E66),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.workspace_premium,
                    size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  '${user.missionsCount} missions',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 16, color: Color(0xFFFACC15)),
                const SizedBox(width: 4),
                Text(
                  user.rating.toStringAsFixed(1),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '($reviewsCount reviews)',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


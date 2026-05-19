import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_app/features/profile/domain/user_entity.dart';

/// Header du profil avec dimensions CSS Figma
class ProfileHeader extends StatelessWidget {
  final UserEntity user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12), // Léger padding naturel au lieu de la barre Actions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 84.56,
                height: 84.56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE2E8F0),
                  image: user.avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(user
                              .avatarUrl!), // ou NetworkImage(user.avatarUrl!)
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: user.avatarUrl == null
                    ? Center(
                        child: Text(
                          user.initials,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 32,
                            color: const Color(0xFF401E66),
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            user.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                              height: 1.33,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        // Badge RECRUTOR
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0x1A7F19E6),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            'RECRUTOR',
                            style: GoogleFonts.splineSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              letterSpacing: 1,
                              color: const Color(0xFF401E66),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.role,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 1.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 12, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${user.company} • ${user.location}',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              height: 1.5,
                              color: const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Row of Buttons aligned with text start
          Row(
            children: [
              const SizedBox(width: 84.56 + 16), // Match avatar width + spacing
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 34.29,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF401E66),
                            foregroundColor: const Color(0xFFFAFAFA),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            'Modifier',
                            style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      width: 59,
                      height: 32.28,
                      decoration: BoxDecoration(
                        color: const Color(0x1A7F13EC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.mail_outline,
                        color: Color(0xFF401E66),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Bio Text
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              user.bio,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 1.64, // corresponds to 23px
                color: const Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

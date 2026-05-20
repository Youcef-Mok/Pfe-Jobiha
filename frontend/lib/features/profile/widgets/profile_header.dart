import 'package:flutter/material.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/profile/domain/user_entity.dart';

/// Header du profil avec avatar, nom, rôle, localisation et boutons
class ProfileHeader extends StatelessWidget {
  final UserEntity user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
   return Padding(
  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔻 Avatar réduit
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9999),
              color: AppColors.slate100,
            ),
            child: user.avatarUrl != null
                ? ClipOval(
                    child: Image.network(
                      user.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          user.initials,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 28, // 🔻 un peu réduit
                            color: AppColors.violet,
                          ),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      user.initials,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                        color: AppColors.violet,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12), // 🔻 espace réduit

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
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          height: 1.2, // 🔻 plus compact
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2), // 🔻 réduit
                      decoration: BoxDecoration(
                        color: const Color(0x1A7F19E6),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'RECRUTOR',
                        style: TextStyle(
                          fontFamily: 'Spline Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 9, // 🔻 plus petit
                          letterSpacing: 1,
                          color: AppColors.violet,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 2), // 🔻 moins d’espace

                // 🔻 Statut réduit
                Text(
                  user.role,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w500,
                    fontSize: 14, // 🔻 réduit
                    height: 1.3,
                    color: AppColors.slate600,
                  ),
                ),

                const SizedBox(height: 2), // 🔻 moins d’espace

                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 11, color: AppColors.slate600), // 🔻 réduit
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${user.company} • ${user.location}',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w500,
                          fontSize: 14, // 🔻 réduit
                          height: 1.3,
                          color: AppColors.slate600,
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

      const SizedBox(height: 8),

      Row(
        children: [
          SizedBox(
            width: 116,
            height: 42,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.violet,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: const Text(
                'Follow',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 59,
            height: 40,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0x1A7F19E6),
                foregroundColor: AppColors.violet,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.zero,
              ),
              child: const Icon(Icons.mail_outline, size: 20),
            ),
          ),
        ],
      ),

      const SizedBox(height: 14),

      // 🔺 Bio agrandie
      Text(
        user.bio,
        style: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w400,
          fontSize: 15, // 🔺 plus grand
          height: 1.8,
          color: Color(0xFF475569),
        ),
      ),
    ],
  ),
);
  }
}
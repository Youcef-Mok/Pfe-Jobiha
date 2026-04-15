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
          // Avatar + infos principales
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 84.56,
                height: 84.56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9999),
                  color: AppColors.slate100,
                ),
                child: user.avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          user.avatarUrl!,
                          width: 84.56,
                          height: 84.56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              user.initials,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontSize: 32,
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
                            fontSize: 32,
                            color: AppColors.violet,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            user.name,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                              height: 1.33,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0x1A7F19E6),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            'RECRUTOR',
                            style: TextStyle(
                              fontFamily: 'Spline Sans',
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              letterSpacing: 1,
                              color: AppColors.violet,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.role,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 1.5,
                        color: AppColors.slate600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 12, color: AppColors.slate600),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${user.company} • ${user.location}',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              height: 1.5,
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
          const SizedBox(height: 16),
          Text(
            user.bio,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
              fontSize: 13,
              height: 2,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}

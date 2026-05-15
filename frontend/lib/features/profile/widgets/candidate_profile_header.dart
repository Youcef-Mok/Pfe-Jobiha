import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/profile/domain/user_entity.dart';
import 'package:job_app/features/profile/data/providers/profile_provider.dart';
import 'package:job_app/core/utils/color_utils.dart';
import 'dart:io';

class CandidateProfileHeader extends ConsumerWidget {
  final UserEntity user;
  final VoidCallback? onEdit;

  const CandidateProfileHeader({
    super.key,
    required this.user,
    this.onEdit,
  });

  Widget _buildProfileImage() {
    final avatarUrl = user.avatarUrl;
    
    // Check if it's a local file path
    if (avatarUrl != null && !avatarUrl.startsWith('assets/') && File(avatarUrl).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Image.file(
          File(avatarUrl),
          fit: BoxFit.cover,
          width: 108,
          height: 108,
        ),
      );
    }
    
    // Use asset image
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Image.asset(
        avatarUrl ?? 'assets/images/imageannonc(3).jpg',
        fit: BoxFit.cover,
        width: 108,
        height: 108,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 108,
            height: 108,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
            ),
            child: const Icon(Icons.person, size: 54, color: Colors.white),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Récupérer les missions du candidat pour détecter une mission active
    final missionsAsync = ref.watch(candidateMissionsProvider);
    
    // Chercher une mission active (status: 'in_progress')
    String? activeMissionTitle;
    bool hasActiveMission = false;
    
    missionsAsync.whenData((missions) {
      final activeMission = missions.where((m) => m.status == 'in_progress').firstOrNull;
      if (activeMission != null) {
        activeMissionTitle = activeMission.jobTitle;
        hasActiveMission = true;
      }
    });
    
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.only(top: 10, bottom: 13),
      child: Column(
        children: [
          // Ligne avec boutons et photo de profil au même niveau
          SizedBox(
            height: 88,
            child: Stack(
              children: [
                // Bouton Modifier (à gauche)
                Positioned(
                  left: 16,
                  top: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/edit-profile');
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF401E66),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Bouton Partager (à côté du modifier)
                Positioned(
                  left: 63,
                  top: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFEDF2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.share_outlined,
                      size: 18,
                      color: Color(0xFF401E66),
                    ),
                  ),
                ),
                // Bouton Settings (à droite)
                Positioned(
                  right: 16,
                  top: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
                // Photo de profil centrée au même niveau
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 108,
                        height: 108,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlphaValue(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _buildProfileImage(),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1D7FEA),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.check, size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      color: Color(0xFF0B1C30),
                    ),
                  ),
                  if (hasActiveMission) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF401E66),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'en poste',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 0),
          Center(
            child: Text(
              // Afficher le titre de la mission active ou le rôle par défaut
              activeMissionTitle ?? user.role,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF401E66),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

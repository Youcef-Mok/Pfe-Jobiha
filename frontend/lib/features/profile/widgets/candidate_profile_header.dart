import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/core/utils/color_utils.dart';
import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';
import 'package:job_app/features/profile/domain/user_entity.dart';
import 'package:job_app/features/profile/widgets/share_profile_overlay.dart';

class CandidateProfileHeader extends ConsumerWidget {
  final UserEntity user;
  final bool isRecruiterView;
  final bool isPublicRecruiterView;
  final bool isPublicCandidateView;
  final VoidCallback? onMessageTap;
  final VoidCallback? onMoreTap;

  const CandidateProfileHeader({
    super.key,
    required this.user,
    this.isRecruiterView = false,
    this.isPublicRecruiterView = false,
    this.isPublicCandidateView = false,
    this.onMessageTap,
    this.onMoreTap,
  });

  Widget _buildProfileImage() {
    final avatarUrl = user.avatarUrl;

    // Local file picked from gallery
    if (!kIsWeb &&
        avatarUrl != null &&
        !avatarUrl.startsWith('http') &&
        !avatarUrl.startsWith('assets/') &&
        File(avatarUrl).existsSync()) {
      return ClipOval(
        child: Image.file(
          File(avatarUrl),
          fit: BoxFit.cover,
          width: 108,
          height: 108,
        ),
      );
    }

    // Network image from server
    if (avatarUrl != null && avatarUrl.startsWith('http')) {
      return ClipOval(
        child: Image.network(
          avatarUrl,
          fit: BoxFit.cover,
          width: 108,
          height: 108,
          errorBuilder: (_, __, ___) => _buildInitialsAvatar(108),
        ),
      );
    }

    // Initials fallback
    return _buildInitialsAvatar(108);
  }

  Widget _buildInitialsAvatar(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF401E66),
      ),
      child: Center(
        child: Text(
          user.initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPublicView = isPublicRecruiterView || isPublicCandidateView;
    final missionsAsync = ref.watch(candidateMissionsProvider);

    String? activeMissionTitle;
    bool hasActiveMission = false;

    missionsAsync.whenData((missions) {
      final activeMission =
          missions.where((m) => m.status == 'in_progress').firstOrNull;
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
          SizedBox(
            height: 88,
            child: Stack(
              children: [
                Positioned(
                  left: 16,
                  top: 0,
                  child: GestureDetector(
                    onTap: isPublicRecruiterView
                        || isPublicCandidateView
                        ? onMessageTap
                        : () => Navigator.pushNamed(
                              context,
                              isRecruiterView
                                  ? '/edit-profile-recruiter'
                                  : '/edit-profile',
                            ),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF401E66),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isPublicRecruiterView
                            || isPublicCandidateView
                            ? Icons.chat_bubble_outline
                            : Icons.edit_outlined,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (!isPublicView)
                  Positioned(
                    left: 63,
                    top: 0,
                    child: GestureDetector(
                      onTap: () => showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (_) => ShareProfileOverlay(user: user),
                      ),
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
                  ),
                Positioned(
                  right: 16,
                  top: 0,
                  child: GestureDetector(
                    onTap: isPublicView ? onMoreTap : null,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isPublicRecruiterView
                            || isPublicCandidateView
                            ? Icons.more_horiz
                            : Icons.settings_outlined,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 108,
                        height: 108,
                        clipBehavior: Clip.antiAlias,
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
                          child:
                              const Icon(Icons.check, size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
              if (isRecruiterView) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF401E66),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Recruteur',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ] else if (hasActiveMission) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
          const SizedBox(height: 0),
          Center(
            child: Text(
              isRecruiterView
                  ? '${user.role} - ${user.company}'
                  : (activeMissionTitle ?? user.role),
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

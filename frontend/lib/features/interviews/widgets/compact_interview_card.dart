import 'package:flutter/material.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/interviews/domain/interview_entity.dart';
import 'package:job_app/features/interviews/widgets/edit_interview_sheet.dart';
import 'package:job_app/features/profile/screens/candidate_public_profile_screen.dart';

/// Carte entretien compacte horizontale
class CompactInterviewCard extends StatelessWidget {
  final InterviewEntity interview;
  final VoidCallback? onTap;
  final VoidCallback? onJobTap;

  const CompactInterviewCard({
    super.key,
    required this.interview,
    this.onTap,
    this.onJobTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Photo de profil + nom candidat (tappable → profil public)
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CandidatePublicProfileScreen(
                    candidateId: interview.candidateId,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 12),
                ],
              ),
            ),
            // Informations
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom du candidat (tappable → profil public)
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CandidatePublicProfileScreen(
                          candidateId: interview.candidateId,
                        ),
                      ),
                    ),
                    child: Text(
                      interview.candidateName,
                      style: AppTextStyles.labelBold.copyWith(
                        fontSize: 15,
                        color: AppColors.slate900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Poste (cliquable, en violet)
                  GestureDetector(
                    onTap: onJobTap,
                    child: Text(
                      interview.jobTitle,
                      style: AppTextStyles.labelBold.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.violet,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => showEditInterviewSheet(context, interview),
              child: Stack(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F0F8),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: const Color(0xFFD7CCE6), width: 1.6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icône calendrier
                        const Icon(
                          Icons.calendar_month,
                          size: 17,
                          color: AppColors.violet,
                        ),
                        const SizedBox(height: 4),
                        // Date
                        Text(
                          interview.formattedDate,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12,
                            color: AppColors.slate900,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Heure
                        Text(
                          interview.formattedTime,
                          style: AppTextStyles.captionLight.copyWith(
                            fontSize: 12,
                            color: AppColors.violet,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Icône crayon en haut à droite
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.violet,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final avatar = interview.candidateAvatar;
    if (avatar != null) {
      final image = avatar.startsWith('http')
          ? NetworkImage(avatar) as ImageProvider
          : AssetImage(avatar);
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: image, fit: BoxFit.cover),
        ),
      );
    }

    // Avatar par défaut avec initiales
    final initials = interview.candidateName.split(' ').map((n) => n[0]).take(2).join().toUpperCase();

    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: AppColors.violetLight,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.labelBold.copyWith(
            color: AppColors.violet,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

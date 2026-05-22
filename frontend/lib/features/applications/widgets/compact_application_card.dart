import 'package:flutter/material.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/applications/domain/application_entity.dart';

/// Carte candidature compacte avec swipe pour refuser
class CompactApplicationCard extends StatelessWidget {
  final ApplicationEntity application;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onSave;
  final VoidCallback? onTap;
  final VoidCallback? onJobTap;
  final bool isSaved;
  final bool dense;

  const CompactApplicationCard({
    super.key,
    required this.application,
    this.onAccept,
    this.onReject,
    this.onSave,
    this.onTap,
    this.onJobTap,
    this.isSaved = false,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final padding = dense ? 8.0 : 11.0;
    final avatarSize = dense ? 40.0 : 48.0;
    final nameSize = dense ? 14.0 : 16.0;
    final titleSize = dense ? 12.0 : 14.0;
    final excerptMaxLines = dense ? 1 : 1;
    final excerptFontSize = dense ? 11.0 : 11.0;
    final motivation = (application.motivationLetter ?? '').trim();
    final excerpt = motivation.isNotEmpty
        ? motivation
        : (application.candidateDomain?.trim().isNotEmpty == true
            ? application.candidateDomain!.trim()
            : 'Aucune motivation fournie');

    return Dismissible(
      key: Key(application.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFDC2626),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        if (onReject != null) {
          onReject!();
        }
        return false;
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(padding),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildAvatar(avatarSize),
                  SizedBox(width: dense ? 8 : 12),
                  // Nom du candidat
                  Expanded(
                    child: Text(
                      application.candidateName ?? 'Candidat',
                      style: AppTextStyles.labelBold.copyWith(
                        fontSize: nameSize,
                        color: AppColors.slate900,
                      ),
                    ),
                  ),
                  // Bouton Accepter
                  GestureDetector(
                    onTap: application.status == ApplicationStatus.accepted
                        ? null
                        : onAccept,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: dense ? 10 : 14,
                          vertical: dense ? 5 : 7),
                      decoration: BoxDecoration(
                        color: application.status ==
                                ApplicationStatus.accepted
                            ? AppColors.slate200
                            : AppColors.violet,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        application.status == ApplicationStatus.accepted
                            ? 'Acceptée'
                            : 'Accepter',
                        style: AppTextStyles.labelBold.copyWith(
                          fontSize: dense ? 11 : 12,
                          color: application.status ==
                                  ApplicationStatus.accepted
                              ? AppColors.slate400
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (!dense && onSave != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                    onTap: onSave,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.violet, width: 1.5),
                      ),
                      child: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_outline,
                        size: 16,
                        color: AppColors.violet,
                      ),
                    ),
                  ),
                  ],
                ],
              ),
              SizedBox(height: dense ? 4 : 6),
              if (onJobTap != null)
                GestureDetector(
                  onTap: onJobTap,
                  child: Text(
                    application.jobTitle,
                    style: AppTextStyles.labelBold.copyWith(
                      fontSize: titleSize,
                      color: AppColors.violet,
                    ),
                  ),
                )
              else
                Text(
                  application.jobTitle,
                  style: AppTextStyles.labelBold.copyWith(
                    fontSize: titleSize,
                    color: AppColors.violet,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                excerpt,
                style: AppTextStyles.captionLight.copyWith(
                  fontSize: excerptFontSize,
                  color: AppColors.slate600,
                  height: 1.25,
                ),
                maxLines: excerptMaxLines,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: dense ? 4 : 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${application.formattedDate} à ${application.formattedTime}',
                  style: AppTextStyles.captionLight.copyWith(
                    fontSize: 10,
                    color: AppColors.slate600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(double size) {
    if (application.candidateAvatar != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage(application.candidateAvatar!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // Avatar par défaut avec initiales
    final name = application.candidateName ?? 'C';
    final initials = name.split(' ').map((n) => n[0]).take(2).join().toUpperCase();

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.violetLight,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.labelBold.copyWith(
            color: AppColors.violet,
            fontSize: size * 0.35,
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/applications/domain/application_entity.dart';

// Carte candidature complète (vue candidat).
// Pour la vue recruteur compacte avec swipe, voir compact_application_card.dart.
//
// TODO(API): Les données viennent de ApplicationsRepositoryMock.
//            Brancher sur GET /api/applications lors de l'intégration backend.

class ApplicationCard extends StatelessWidget {
  final ApplicationEntity application;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  const ApplicationCard({
    super.key,
    required this.application,
    this.onTap,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _buildLogo(),
              const SizedBox(width: 12),
              Expanded(child: _buildInfo()),
              _buildStatusBadge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.draftBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: application.logoAsset != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                application.logoAsset!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.business_outlined,
                  color: AppColors.slate400,
                  size: 22,
                ),
              ),
            )
          : const Icon(Icons.business_outlined,
              color: AppColors.slate400, size: 22),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          application.jobTitle,
          style: AppTextStyles.labelBold.copyWith(fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          '${application.companyName} • ${application.location}',
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 12,
            color: AppColors.slate600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          application.formattedDate,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 11,
            color: AppColors.slate400,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final (bg, textColor) = switch (application.status) {
      ApplicationStatus.pending => (AppColors.draftBg, AppColors.draftText),
      ApplicationStatus.accepted => (AppColors.activeBg, AppColors.activeText),
      ApplicationStatus.rejected =>
        (const Color(0xFFFFE4E4), const Color(0xFFDC2626)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        application.statusLabel,
        style: AppTextStyles.badge.copyWith(color: textColor, fontSize: 10),
      ),
    );
  }
}

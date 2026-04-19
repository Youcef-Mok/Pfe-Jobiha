import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:job_app/features/jobs/domain/mission_entity.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/jobs/widgets/expiry_badge.dart';

class MissionCard extends StatelessWidget {
  final MissionEntity mission;
  final VoidCallback? onTap;

  const MissionCard({
    super.key,
    required this.mission,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (mission.isCompleted) {
      return _buildCompletedCard();
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.violetBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTopSection(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Carte TERMINÉE ──────────────────────────────────────────────────────────
  Widget _buildCompletedCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.violetBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo 64x64
                Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D000000),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: mission.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              mission.imageUrl!,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.business,
                                size: 28,
                                color: AppColors.slate400,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.business,
                            size: 28,
                            color: AppColors.slate400,
                          ),
                ),
                const SizedBox(width: 16),

                // Contenu principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre + Badge TERMINÉE
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              mission.jobTitle,
                              style: AppTextStyles.heading3,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.activeBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'TERMINÉE',
                              style: AppTextStyles.badge.copyWith(
                                color: AppColors.activeText,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 0),

                      // Entreprise + dates
                      Text(
                        '${mission.companyName} • ${_formatDateRange()}',
                        style: AppTextStyles.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 0),

                      // Évaluation reçue + note
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC1AA62),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.star_rounded,
                              size: 12,
                              color: Color(0xFF4E3E00),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Évaluation reçue',
                            style: AppTextStyles.bodyMedium,
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.star_rounded,
                            size: 13,
                            color: Color(0xFF6E14C7),
                          ),
                          const SizedBox(width: 1),
                          Text(
                            mission.recruiterRating.toStringAsFixed(1),
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateRange() {
    final start = DateFormat('d MMM', 'fr_FR').format(mission.startDate);
    final end = DateFormat('d MMM yyyy', 'fr_FR').format(mission.endDate);
    return '$start – $end';
  }

  Widget _buildTopSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildLogo(),
          const SizedBox(width: 16),
          Expanded(child: _buildInfo()),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.draftBg,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: mission.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                mission.imageUrl!,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.business, color: AppColors.slate400, size: 28),
              ),
            )
          : const Icon(Icons.business, color: AppColors.slate400, size: 28),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                mission.jobTitle,
                style: AppTextStyles.heading3,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _StatusBadge(status: mission.status),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '${mission.companyName} • ${_formatPeriod()}',
          style: AppTextStyles.bodyMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (mission.status == 'in_progress')
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: ExpiryBadge(label: _getExpiryLabel(mission.endDate)),
          ),
      ],
    );
  }

  String _formatPeriod() {
    final start = DateFormat('d MMM', 'fr_FR').format(mission.startDate);
    final end = DateFormat('d MMM', 'fr_FR').format(mission.endDate);
    return 'Du $start au $end';
  }

  String _getExpiryLabel(DateTime endDate) {
    final diff = endDate.difference(DateTime.now());
    if (diff.isNegative) return 'Expiré';
    if (diff.inDays > 7) return '${diff.inDays ~/ 7} sem.';
    if (diff.inDays > 0) return '${diff.inDays} jours';
    return '${diff.inHours} h';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, textColor, label) = switch (status) {
      'in_progress' => (AppColors.searchingBg, AppColors.searchingText, 'EN COURS'),
      'completed' => (AppColors.activeBg, AppColors.activeText, 'TERMINÉ'),
      _ => (AppColors.draftBg, AppColors.draftText, status.toUpperCase()),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.badge.copyWith(color: textColor, fontSize: 8),
      ),
    );
  }
}


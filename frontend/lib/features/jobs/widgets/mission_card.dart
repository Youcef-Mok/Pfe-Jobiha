import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:job_app/features/jobs/domain/mission_entity.dart';
import 'package:job_app/core/theme/app_theme.dart';

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
              // Pas d'actions de bas de carte pour les missions (enlevé Modifier / Candidats)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
      child: const Icon(Icons.business, color: AppColors.slate400, size: 28),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(mission.jobTitle, style: AppTextStyles.heading3),
            ),
            const SizedBox(width: 8),
            _StatusBadge(status: mission.status),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${mission.companyName} • ${_formatPeriod()}',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  String _formatPeriod() {
    final start = DateFormat('d MMM', 'fr_FR').format(mission.startDate);
    final end = DateFormat('d MMM', 'fr_FR').format(mission.endDate);
    return 'Du $start au $end';
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.badge.copyWith(color: textColor),
      ),
    );
  }
}


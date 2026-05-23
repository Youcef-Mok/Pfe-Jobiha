import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:job_app/features/jobs/domain/mission_entity.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/jobs/widgets/expiry_badge.dart';
import 'package:job_app/features/jobs/widgets/completed_mission_card.dart';

class MissionCard extends StatelessWidget {
  final MissionEntity mission;
  final VoidCallback? onTap;
  final Color? cardColor;

  const MissionCard({
    super.key,
    required this.mission,
    this.onTap,
    this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    if (mission.isCompleted) {
      return CompletedMissionCard(
        mission: mission,
        onTap: onTap,
      );
    }

    final bool emphasized = mission.isInProgress || mission.isUnconfirmed;
    final double logoSize = emphasized ? 64 : 52;
    final double padding = emphasized ? 12 : 8;
    final double titleSize = emphasized ? 16 : 15;
    final double subtitleSize = emphasized ? 13 : 12;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: cardColor ?? Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLogo(logoSize),
            const SizedBox(width: 10),
            Expanded(
              child: _buildInfo(
                titleSize: titleSize,
                subtitleSize: subtitleSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(double size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: mission.imageUrl != null
          ? (mission.imageUrl!.startsWith('http')
              ? Image.network(
                  mission.imageUrl!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _logoPlaceholder(size),
                )
              : Image.asset(
                  mission.imageUrl!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _logoPlaceholder(size),
                ))
          : _logoPlaceholder(size),
    );
  }

  Widget _logoPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      color: AppColors.draftBg,
      child: const Icon(Icons.description_outlined,
          color: AppColors.slate400, size: 22),
    );
  }

  Widget _buildInfo({
    required double titleSize,
    required double subtitleSize,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                mission.jobTitle,
                style: AppTextStyles.plusJakarta.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: titleSize,
                  color: const Color(0xFF2A292B),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _StatusBadge(status: mission.status),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${mission.companyName} • ${_formatPeriod()}',
          style: AppTextStyles.plusJakarta.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: subtitleSize,
            color: const Color(0xFF5B5B5C),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (mission.isInProgress || mission.isUnconfirmed)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: mission.isUnconfirmed
                ? Text(
                    'À confirmer avant le ${DateFormat('d MMM', 'fr_FR').format(mission.startDate)}',
                    style: AppTextStyles.captionLight.copyWith(
                      fontSize: 11,
                      color: AppColors.slate600,
                    ),
                  )
                : ExpiryBadge(label: _getExpiryLabel(mission.endDate)),
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
      'unconfirmed' => (
          const Color(0xFFFFF7ED),
          const Color(0xFFC2410C),
          'NON CONFIRMÉE'
        ),
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

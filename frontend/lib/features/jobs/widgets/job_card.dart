import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/core/theme/app_theme.dart';


/// Widget purement présentationnel — reçoit des données, émet des callbacks.
/// Aucune logique métier, aucun accès à Riverpod.
class JobCard extends StatelessWidget {
  final JobEntity job;
  final VoidCallback? onEdit;
  final VoidCallback? onViewCandidates;
  final VoidCallback? onComplete;
  final VoidCallback? onTap;

  const JobCard({
    super.key,
    required this.job,
    this.onEdit,
    this.onViewCandidates,
    this.onComplete,
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
          child: Opacity(
            opacity: job.isDraft ? 0.71 : 1.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTopSection(),
                _buildBottomActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
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
    final hasImage = job.logoAsset != null;
    final isNetwork = hasImage && job.logoAsset!.startsWith('http');

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
      child: hasImage
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: isNetwork
                  ? Image.asset(
                      job.logoAsset!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.business, color: AppColors.slate400, size: 28),
                    )
                  : Image.asset(
                      job.logoAsset!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
            )
          : const Icon(Icons.business, color: AppColors.slate400, size: 28),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          job.title,
          style: AppTextStyles.heading3,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          '${job.companyName} • ${_formatDate(job.postedAt, job.status)}',
          style: AppTextStyles.bodyMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        if (!job.isDraft) _buildMetrics(),
        if (job.isDraft) _buildDraftInfo(),
      ],
    );
  }

  Widget _buildMetrics() {
    return Row(
      children: [
        _MetricChip(
          icon: Icons.people_outline,
          value: '${job.candidateCount} candidats',
          isBold: true,
          iconColor: AppColors.violet,
        ),
        const SizedBox(width: 16),
        _MetricChip(
          icon: Icons.remove_red_eye_outlined,
          value: '${job.viewCount} vues',
          isBold: false,
          iconColor: AppColors.slate400,
        ),
      ],
    );
  }

  Widget _buildDraftInfo() {
    return Row(
      children: [
        const Icon(Icons.lock_outline, size: 12, color: AppColors.slate400),
        const SizedBox(width: 4),
        Text('Non publiée', style: AppTextStyles.captionLight),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.violetBorder),
        ),
      ),
      child: job.isDraft ? _buildDraftAction() : _buildActiveActions(),
    );
  }

  Widget _buildActiveActions() {
    return IntrinsicHeight(
      child: Row(
        children: [
          // Modifier
          Expanded(
            child: _ActionButton(
              icon: Icons.edit_outlined,
              label: 'Modifier',
              color: AppColors.slate600,
              fontWeight: FontWeight.w600,
              onTap: onEdit,
            ),
          ),
          const VerticalDivider(
            width: 1,
            color: AppColors.violetBorder,
          ),
          // Voir les candidats
          Expanded(
            child: _ActionButton(
              icon: Icons.group_outlined,
              label: 'Voir les candidats',
              color: AppColors.violet,
              fontWeight: FontWeight.w700,
              onTap: onViewCandidates,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraftAction() {
    return SizedBox(
      width: double.infinity,
      child: _ActionButton(
        icon: Icons.edit_note_outlined,
        label: "Compléter l'annonce",
        color: AppColors.violet,
        fontWeight: FontWeight.w700,
        onTap: onComplete,
      ),
    );
  }

  String _formatDate(DateTime date, JobStatus status) {
    final formatted = DateFormat('d MMM.', 'fr_FR').format(date);
    return status == JobStatus.draft
        ? 'Modifié hier'
        : 'Posté le $formatted';
  }
}

// ─────────────────────────────────────────────
// Widgets internes (private)
// ─────────────────────────────────────────────

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final bool isBold;
  final Color iconColor;

  const _MetricChip({
    required this.icon,
    required this.value,
    required this.isBold,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 4),
        Text(
          value,
          style: isBold ? AppTextStyles.caption : AppTextStyles.captionLight,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final FontWeight fontWeight;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.fontWeight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: fontWeight,
                fontSize: 14,
                height: 1.43,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
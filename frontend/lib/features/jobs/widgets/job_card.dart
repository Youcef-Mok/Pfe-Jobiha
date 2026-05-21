import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/core/theme/app_theme.dart';

class JobCard extends StatelessWidget {
  final JobEntity job;
  final VoidCallback? onEdit;
  final VoidCallback? onViewCandidates;
  final VoidCallback? onComplete;
  final VoidCallback? onTap;
  final Color? cardColor;
  final bool showActions;
  final int? plannedInterviewsCount;

  const JobCard({
    super.key,
    required this.job,
    this.onEdit,
    this.onViewCandidates,
    this.onComplete,
    this.onTap,
    this.cardColor,
    this.showActions = true,
    this.plannedInterviewsCount,
  });

  String _contractLabel(ContractType t) => switch (t) {
        ContractType.cdi => 'CDI',
        ContractType.mission => 'MISSION',
        ContractType.freelance => 'FREELANCE',
      };

  @override
  Widget build(BuildContext context) {
    final contractLabel = _contractLabel(job.contractType);

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: job.isDraft ? 0.75 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: cardColor ?? (job.isDraft ? const Color(0xFFEFEDF2) : Colors.white),
            border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Top section — identique CandidateJobCard ──
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: job.logoAsset != null
                          ? Image.asset(
                              job.logoAsset!,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              cacheWidth: 112,
                              errorBuilder: (_, __, ___) => _logoFallback(),
                            )
                          : _logoFallback(),
                    ),
                    const SizedBox(width: 12),
                    // Infos
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            job.title,
                            style: AppTextStyles.plusJakarta.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              height: 1.25,
                              color: const Color(0xFF2A292B),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            job.companyName,
                            style: AppTextStyles.plusJakarta.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              height: 1.3,
                              color: const Color(0xFF5B5B5C),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Wrap(
                            spacing: 10,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              // Badge contrat
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.violet,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  contractLabel,
                                  style: AppTextStyles.badge.copyWith(
                                    color: Colors.white,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                              // Badge candidats (si publié) ou "Non publiée" (si brouillon)
                              if (!job.isDraft)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE1DDEC),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${job.candidateCount} candidats',
                                    style: AppTextStyles.badge.copyWith(
                                      color: const Color(0xFF401E66),
                                      fontSize: 9,
                                    ),
                                  ),
                                )
                              else
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.lock_outline,
                                        size: 12, color: AppColors.slate400),
                                    const SizedBox(width: 4),
                                    Text('Non publiée',
                                        style: AppTextStyles.captionLight),
                                  ],
                                ),
                              // Entretiens prévus
                              if (!job.isDraft)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFEDF2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${plannedInterviewsCount ?? 0} entretiens',
                                    style: AppTextStyles.badge.copyWith(
                                      color: const Color(0xFF401E66),
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (showActions)
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFFEEEBF4), width: 1),
                    ),
                  ),
                  child: job.isDraft
                      ? _buildDraftAction()
                      : _buildActiveActions(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoFallback() {
    return Container(
      width: 64,
      height: 64,
      color: AppColors.violetLight,
      alignment: Alignment.center,
      child: Text(
        job.title.isNotEmpty ? job.title[0] : '?',
        style: const TextStyle(
          color: AppColors.violet,
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),
      ),
    );
  }

  Widget _buildActiveActions() {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              icon: Icons.edit_outlined,
              label: 'Modifier',
              color: AppColors.slate600,
              fontWeight: FontWeight.w600,
              onTap: onEdit,
            ),
          ),
          const VerticalDivider(width: 1, color: Color(0xFFEEEBF4)),
          Expanded(
            child: _ActionButton(
              icon: null,
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
}

class _ActionButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color color;
  final FontWeight fontWeight;
  final VoidCallback? onTap;

  const _ActionButton({
    this.icon,
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
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: fontWeight,
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

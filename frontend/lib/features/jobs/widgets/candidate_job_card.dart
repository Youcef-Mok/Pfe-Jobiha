import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/applications/domain/application_entity.dart';
import 'package:job_app/features/applications/data/providers/applications_provider.dart';
import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/features/jobs/screens/candidate_job_details_screen.dart';

class CandidateJobCard extends ConsumerWidget {
  final JobEntity job;
  final ApplicationStatus? applicationStatus;
  final String? interviewDate;
  final VoidCallback? onTap;
  final bool showSaveButton;

  const CandidateJobCard({
    super.key,
    required this.job,
    this.applicationStatus,
    this.interviewDate,
    this.onTap,
    this.showSaveButton = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(
      savedJobsProvider.select((saved) => saved.contains(job.id)),
    );
    final contractLabel = _contractLabel(job.contractType);

    return GestureDetector(
      onTap: onTap ??
          () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CandidateJobDetailsScreen(job: job)),
              ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFEFEDF2),
          border: Border.all(
            color: const Color(0xFFEEEBF4),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: job.logoAsset != null
                        ? Image.asset(
                            job.logoAsset!,
                            width: 68,
                            height: 68,
                            fit: BoxFit.cover,
                            cacheWidth: 136,
                          )
                        : Container(
                            width: 68,
                            height: 68,
                            color: AppColors.violetLight,
                            alignment: Alignment.center,
                            child: Text(
                              job.title[0],
                              style: const TextStyle(
                                color: AppColors.violet,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                job.title,
                                style: AppTextStyles.plusJakarta.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  height: 28 / 18,
                                  color: const Color(0xFF2A292B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (applicationStatus != null && applicationStatus != ApplicationStatus.pending) ...[
                              const SizedBox(width: 8),
                              _StatusBadge(status: applicationStatus!),
                            ],
                          ],
                        ),
                        Text(
                          job.companyName,
                          style: AppTextStyles.plusJakarta.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            height: 20 / 14,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 10,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.violet,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                contractLabel,
                                style: AppTextStyles.badge.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE1DDEC),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '10H-17H',
                                style: AppTextStyles.badge.copyWith(
                                  color: const Color(0xFF401E66),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 13,
                                  color: AppColors.violet,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Alger, Birkhadem',
                                  style: AppTextStyles.badge.copyWith(
                                    color: AppColors.violet,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (interviewDate != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 12,
                                color: Color(0xFF059669),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  interviewDate!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.plusJakarta.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: const Color(0xFF059669),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (showSaveButton)
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () =>
                      ref.read(savedJobsProvider.notifier).toggle(job.id),
                  child: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    size: 22,
                    color: isSaved ? AppColors.violet : Colors.black,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _contractLabel(ContractType t) => switch (t) {
        ContractType.cdi => 'CDI',
        ContractType.mission => 'MISSION',
        ContractType.freelance => 'FREELANCE',
      };
}


class _StatusBadge extends StatelessWidget {
  final ApplicationStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status) {
      ApplicationStatus.pending => (
          const Color(0xFFFEF9C3),
          const Color(0xFF92400E),
          'EN ATTENTE',
        ),
      ApplicationStatus.accepted => (
          const Color(0xFFD1FAE5),
          const Color(0xFF1D8869),
          'ACCEPTEE',
        ),
      ApplicationStatus.rejected => (
          const Color(0xFFFFE4E6),
          const Color(0xFFBE123C),
          'REFUSEE',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.plusJakarta.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 9,
          letterSpacing: 0.55,
          color: fg,
        ),
      ),
    );
  }
}

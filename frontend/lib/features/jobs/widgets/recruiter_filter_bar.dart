import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';
import 'package:job_app/features/jobs/widgets/recruiter_filter_sheets.dart';

/// Barre de filtres sous les onglets (annonces, missions, candidatures, entretiens).
class RecruiterFilterBar extends ConsumerWidget {
  final JobsTab? forcedTab;

  const RecruiterFilterBar({super.key, this.forcedTab});

  String? _jobLabel(WidgetRef ref) {
    final jobId = ref.watch(recruiterFiltersProvider).jobId;
    if (jobId == null) return null;
    final jobs = ref.watch(jobsNotifierProvider).valueOrNull;
    if (jobs == null) return null;
    try {
      return jobs.firstWhere((j) => j.id == jobId).title;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final JobsTab tab = forcedTab ?? ref.watch(jobsTabProvider);
    final filters = ref.watch(recruiterFiltersProvider);
    final showJobFilter =
        tab == JobsTab.applications || tab == JobsTab.interviews;
    final jobLabel = _jobLabel(ref);

    final dateLabel = switch (tab) {
      JobsTab.myJobs => 'Publié il y a',
      JobsTab.missions => 'Durée',
      JobsTab.applications => 'Date de dépôt',
      JobsTab.interviews => 'Date de l\'entretien',
      JobsTab.activity => '',
    };

    final chips = <Widget>[
      _FilterChip(
        label: filters.status ?? 'Statut',
        isActive: filters.status != null,
        onTap: () => showRecruiterStatusSheet(context, tab),
        onClear: filters.status != null
            ? () => ref.read(recruiterFiltersProvider.notifier).setStatus(null)
            : null,
      ),
      _FilterChip(
        label: filters.dateFilter ?? dateLabel,
        isActive: filters.dateFilter != null,
        onTap: () => showRecruiterDateSheet(context, tab),
        onClear: filters.dateFilter != null
            ? () =>
                ref.read(recruiterFiltersProvider.notifier).setDateFilter(null)
            : null,
      ),
      _FilterChip(
        label: filters.department ?? 'Département',
        isActive: filters.department != null,
        onTap: () => showRecruiterDepartmentSheet(context),
        onClear: filters.department != null
            ? () =>
                ref.read(recruiterFiltersProvider.notifier).setDepartment(null)
            : null,
      ),
    ];

    if (showJobFilter) {
      chips.addAll([
        _FilterChip(
          label: jobLabel ?? 'Annonce',
          isActive: filters.jobId != null,
          onTap: () => showRecruiterJobOfferSheet(context),
          onClear: filters.jobId != null
              ? () => ref.read(recruiterFiltersProvider.notifier).setJobId(null)
              : null,
        ),
        _FilterChip(
          label: 'Enregistrés',
          isActive: filters.savedOnly,
          showDropdownIcon: false,
          onTap: () =>
              ref.read(recruiterFiltersProvider.notifier).toggleSavedOnly(),
          onClear: filters.savedOnly
              ? () => ref.read(recruiterFiltersProvider.notifier).setSavedOnly(false)
              : null,
        ),
      ]);
    }

    return Container(
      height: 41,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.violetBorder),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: chips.length,
        itemBuilder: (_, i) => chips[i],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final bool showDropdownIcon;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.onClear,
    this.showDropdownIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isActive ? Colors.white : AppColors.violet;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(
          left: 10,
          right: onClear != null ? 6 : 10,
        ),
        height: 32,
        decoration: BoxDecoration(
          color: isActive ? AppColors.violet : const Color(0xFFEFEDF2),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.poppinsSemiBold14.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            if (showDropdownIcon) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: textColor,
              ),
            ],
            if (isActive && onClear != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onClear,
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

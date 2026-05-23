import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/applications/data/providers/applications_provider.dart';
import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/features/jobs/widgets/candidate_filter_sheets.dart';
import 'package:job_app/features/jobs/widgets/candidate_job_card.dart';

class SavedJobsScreen extends ConsumerWidget {
  const SavedJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(savedJobsDisplayProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildHeader(context),
            const SizedBox(height: 16),
            const _SavedFilterChips(),
            const SizedBox(height: 14),
            Expanded(
              child: jobsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.violet),
                ),
                error: (_, __) =>
                    const Center(child: Text('Erreur de chargement')),
                data: (jobs) => _buildList(jobs),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE4E4E7))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const SizedBox(
              width: 32,
              height: 32,
              child: Icon(Icons.arrow_back, size: 30, color: Color(0xFF18181B)),
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'Saved jobs',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Color(0xFF18181B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<JobEntity> jobs) {
    if (jobs.isEmpty) {
      return const Center(
        child: Text(
          'Aucun job enregistré',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppColors.slate600,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 16, bottom: 14),
          child: Text(
            '${jobs.length} Job${jobs.length > 1 ? 's' : ''} enregistré${jobs.length > 1 ? 's' : ''}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 17,
              color: Color(0xFF060527),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Column(
                  children: [
                    for (final job in jobs) CandidateJobCard(job: job),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SavedFilterChips extends ConsumerWidget {
  const _SavedFilterChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(candidateFiltersProvider);
    final chips = <Widget>[];

    if (filters.category != null) {
      chips.add(_FilterChip(
        label: filters.category!,
        icon: Icons.category_outlined,
        isActive: true,
        onTap: () => ref.read(candidateFiltersProvider.notifier).setCategory(null),
      ));
    }
    for (final c in filters.contractTypes) {
      chips.add(_FilterChip(
        label: c,
        icon: Icons.assignment_outlined,
        isActive: true,
        onTap: () => ref.read(candidateFiltersProvider.notifier).toggleContractType(c),
      ));
    }
    if (filters.location != null) {
      chips.add(_FilterChip(
        label: filters.location!,
        icon: Icons.location_on_outlined,
        isActive: true,
        onTap: () => ref.read(candidateFiltersProvider.notifier).setLocation(null),
      ));
    }

    chips.add(_FilterChip(
      label: 'Horaires',
      showArrow: true,
      onTap: () => showAvailabilitySheet(context),
    ));
    chips.add(_FilterChip(
      label: 'Contrat',
      showArrow: true,
      onTap: () => showContractTypeSheet(context),
    ));
    chips.add(_FilterChip(
      label: 'Localisation',
      showArrow: true,
      onTap: () => showLocationSheet(context),
    ));

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => chips[i],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final bool showArrow;
  final IconData? icon;

  const _FilterChip({
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.showArrow = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF3A1B5E) : const Color(0xFFEFEDF2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: isActive ? Colors.white : const Color(0xFF401E66)),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isActive ? Colors.white : const Color(0xFF401E66),
              ),
            ),
            if (showArrow) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: isActive ? Colors.white : const Color(0xFF401E66),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

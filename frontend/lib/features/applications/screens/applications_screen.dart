import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/applications/domain/application_entity.dart';
import 'package:job_app/features/applications/data/providers/applications_provider.dart';
import 'package:job_app/core/widgets/candidate_nav_bar.dart';
import 'package:job_app/core/widgets/candidate_filter_overlay.dart';
import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';
import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/features/jobs/screens/candidate_job_details_screen.dart';
import 'package:job_app/features/jobs/widgets/candidate_job_card.dart';

class ApplicationsScreen extends ConsumerWidget {
  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(applicationsNotifierProvider);
    final tabFilter = ref.watch(applicationsTabProvider);
    final overlayFilter = ref.watch(applicationsOverlayFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, ref),
            const SizedBox(height: 15),

            // "”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"” Tab filter segments "”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _TabFilter(current: tabFilter),
            ),
            const SizedBox(height: 12),

            // "”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"” Content "”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”
            Expanded(
              child: appsAsync.when(
                loading: () => const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.violet)),
                error: (_, __) =>
                    const Center(child: Text('Erreur de chargement')),
                data: (apps) {
                  final filtered = _filterApps(apps, tabFilter);
                  final sorted = _sortApps(filtered, overlayFilter);
                  return _buildList(context, ref, sorted, overlayFilter);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CandidateNavBar(currentIndex: -1),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE4E4E7))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back,
                size: 22, color: Color(0xFF18181B)),
          ),
          const SizedBox(width: 10),
          const Text(
            'Mes candidatures',
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

  List<ApplicationEntity> _filterApps(
      List<ApplicationEntity> apps, ApplicationsTabFilter filter) {
    return switch (filter) {
      ApplicationsTabFilter.all => apps,
      ApplicationsTabFilter.pending =>
        apps.where((a) => a.status == ApplicationStatus.pending).toList(),
      ApplicationsTabFilter.accepted =>
        apps.where((a) => a.status == ApplicationStatus.accepted).toList(),
      ApplicationsTabFilter.rejected =>
        apps.where((a) => a.status == ApplicationStatus.rejected).toList(),
    };
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<ApplicationEntity> apps,
    String overlayFilter,
  ) {
    if (apps.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.inbox_outlined, size: 48, color: AppColors.slate400),
            SizedBox(height: 16),
            Text(
              'Aucune candidature',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.slate600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 25, right: 16, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${apps.length} Candidature${apps.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600, // Reverted to w600
                    fontSize: 17,
                    color: Color(0xFF060527),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final selected = await showDialog<String>(
                    context: context,
                    barrierColor: Colors.transparent,
                    builder: (context) => CandidateFilterOverlay(
                      initialFilter: overlayFilter,
                      topOffset: 126,
                    ),
                  );
                  if (selected != null && context.mounted) {
                    ref.read(applicationsOverlayFilterProvider.notifier).state =
                        selected;
                  }
                },
                child: const Icon(Icons.filter_list, color: Color(0xFF18181B)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Column(
                  children: [
                    for (final app in apps)
                      CandidateJobCard(
                        job: _fallbackJob(app),
                        applicationStatus: app.status,
                        interviewDate: app.status == ApplicationStatus.accepted
                            ? app.interviewDate
                            : null,
                        showSaveButton: false,
                        onTap: () => _openApplicationDetails(context, ref, app),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<ApplicationEntity> _sortApps(List<ApplicationEntity> apps, String filter) {
    final sorted = [...apps];
    switch (filter) {
      case 'proche':
        sorted.sort((a, b) => a.location.compareTo(b.location));
        return sorted;
      case 'mieux_paye':
        sorted.sort((a, b) {
          final byStatus = _statusPriority(a.status) - _statusPriority(b.status);
          if (byStatus != 0) return byStatus;
          return b.appliedAt.compareTo(a.appliedAt);
        });
        return sorted;
      case 'recent':
      default:
        sorted.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
        return sorted;
    }
  }

  int _statusPriority(ApplicationStatus status) => switch (status) {
        ApplicationStatus.accepted => 0,
        ApplicationStatus.pending => 1,
        ApplicationStatus.rejected => 2,
      };

  Future<void> _openApplicationDetails(
    BuildContext context,
    WidgetRef ref,
    ApplicationEntity app,
  ) async {
    final repository = ref.read(jobsRepositoryProvider);
    final job = await repository.getJobById(app.jobId) ?? _fallbackJob(app);
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CandidateJobDetailsScreen(
          job: job,
          application: app,
        ),
      ),
    );
  }

  JobEntity _fallbackJob(ApplicationEntity app) {
    return JobEntity(
      id: app.jobId,
      title: app.jobTitle,
      companyName: app.companyName,
      contractType: app.contractType,
      postedAt: app.appliedAt,
      status: JobStatus.searching,
      candidateCount: 0,
      viewCount: 0,
      logoAsset: app.logoAsset,
      isPublished: true,
    );
  }

  IconData _iconForOverlayFilter(String filter) {
    switch (filter) {
      case 'proche':
        return Icons.navigation_outlined;
      case 'mieux_paye':
        return Icons.savings_outlined;
      case 'recent':
      default:
        return Icons.history;
    }
  }

  String _labelForOverlayFilter(String filter) {
    switch (filter) {
      case 'proche':
        return 'plus proche';
      case 'mieux_paye':
        return 'Mieux payé';
      case 'recent':
      default:
        return 'plus recent';
    }
  }
}

// "”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”
// Tab Filter Segments
// "”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”"”
class _TabFilter extends ConsumerWidget {
  final ApplicationsTabFilter current;
  const _TabFilter({required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 35,
      decoration: BoxDecoration(
        color: const Color(0xFFEFEDF2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _Pill('Toutes', ApplicationsTabFilter.all, current, ref),
          _Pill('Acceptees', ApplicationsTabFilter.accepted, current, ref),
          _Pill('Refusees', ApplicationsTabFilter.rejected, current, ref),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final ApplicationsTabFilter value;
  final ApplicationsTabFilter current;
  final WidgetRef ref;

  const _Pill(this.label, this.value, this.current, this.ref);

  @override
  Widget build(BuildContext context) {
    final isActive = current == value;
    return Expanded(
      child: GestureDetector(
        onTap: () =>
            ref.read(applicationsTabProvider.notifier).state = value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    const BoxShadow(
                      color: Color(0x1A7F13EC),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Plus Jakarta',
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: AppColors.violet,
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedAppliedChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onRemove;

  const _SelectedAppliedChip({
    required this.label,
    required this.icon,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF3A1B5E), // Violet background
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2), // Light translucent background for icon
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 12, color: Colors.white), // White icon
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: Colors.white, // White text
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 14,
              color: Colors.white, // White close icon
            ),
          ),
        ],
      ),
    );
  }
}

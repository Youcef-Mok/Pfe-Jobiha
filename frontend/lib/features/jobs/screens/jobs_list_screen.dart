import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';
import 'package:job_app/features/jobs/domain/job_entity.dart';

import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/jobs/widgets/job_card.dart';
import 'package:job_app/features/jobs/widgets/mission_card.dart';
import 'package:job_app/features/jobs/screens/create_job_screen.dart';
import 'package:job_app/features/jobs/screens/edit_job_screen.dart';
import 'package:job_app/features/jobs/screens/job_details_screen.dart';
import 'package:job_app/features/jobs/widgets/mission_in_progress_sheet.dart';
import 'package:job_app/features/notifications/screens/notifications_screen.dart';
import 'package:job_app/features/candidates/screens/candidates_screen.dart';
import 'package:job_app/features/candidates/data/providers/candidates_provider.dart';
import 'package:job_app/core/widgets/app_bottom_nav_bar.dart';

/// ────────────────
/// ENTRY POINT
/// ────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);

  runApp(
    const ProviderScope(
      child: JobsListApp(),
    ),
  );
}

class JobsListApp extends StatelessWidget {
  const JobsListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JobApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.violet),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'PlusJakartaSans',
      ),
      home: const JobsListScreen(),
    );
  }
}

/// ────────────────
/// JobsListScreen
/// ────────────────
class JobsListScreen extends ConsumerWidget {
  const JobsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            SizedBox(
              height: 56,
              child: _TabBar(),
            ),
            Expanded(child: _JobsBody()),
          ],
        ),
      ),
      floatingActionButton: _AddJobFAB(),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }
}

// ─────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────
class _Header extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Text('Mes annonces', style: AppTextStyles.heading1),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_outlined,
                  color: AppColors.slate700,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.violet,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.violetLight,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x337F13EC)),
            ),
            child: const Icon(
              Icons.person_outline,
              color: AppColors.violet,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tab Bar
// ─────────────────────────────────────────────
class _TabBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(jobsTabProvider);
    final missionsAsync = ref.watch(missionsNotifierProvider);
    final missionCount = missionsAsync.whenOrNull(
          data: (missions) => missions.length,
        ) ??
        0;

    final tabs = [
      (JobsTab.myJobs, 'Mes annonces'),
      (JobsTab.missions, 'Mes missions ($missionCount)'),
      (JobsTab.drafts, 'Brouillons'),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.violetBorder),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: tabs.map((tab) {
                final (value, label) = tab;
                final isActive = currentTab == value;
                return _TabItem(
                  label: label,
                  isActive: isActive,
                  onTap: () => ref.read(jobsTabProvider.notifier).state = value,
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        margin: const EdgeInsets.only(right: 24),
        decoration: isActive
            ? const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.violet,
                    width: 3,
                  ),
                ),
              )
            : null,
        child: Center(
          child: Text(
            label,
            style:
                isActive ? AppTextStyles.tabActive : AppTextStyles.tabInactive,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Body principal
// ─────────────────────────────────────────────
class _JobsBody extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(jobsTabProvider);

    if (currentTab == JobsTab.missions) {
      return _buildMissionsList(ref);
    }

    // Use jobsNotifierProvider for myJobs (only jobs), otherwise standard jobsNotifierProvider
    final dataAsync = ref.watch(jobsNotifierProvider);

    final controller = ref.watch(jobsControllerProvider);

    return dataAsync.when(
      loading: () => const _LoadingState(),
      error: (e, _) => _ErrorState(
        message: e.toString(),
        onRetry: () {
          ref.read(jobsNotifierProvider.notifier).fetch();
          ref.read(missionsNotifierProvider.notifier).fetch();
        },
      ),
      data: (items) {
        final List<JobEntity> filtered = switch (currentTab) {
          JobsTab.drafts => controller.filterDrafts(items),
          JobsTab.myJobs => items,
          _ => [],
        };

        if (filtered.isEmpty) return const _EmptyState();

        return RefreshIndicator(
          color: AppColors.violet,
          onRefresh: () async {
            await ref.read(jobsNotifierProvider.notifier).fetch();
            await ref.read(missionsNotifierProvider.notifier).fetch();
          },
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = filtered[index];

              return JobCard(
                job: item,
                onEdit: () => _handleEdit(context, item),
                onViewCandidates: () => _handleViewCandidates(context, item, ref),
                onComplete: () => _handleComplete(context, item),
                onTap: item.status == JobStatus.searching
                    ? () => _handleViewDetails(context, item)
                    : null,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMissionsList(WidgetRef ref) {
    final missionsAsync = ref.watch(missionsNotifierProvider);

    return missionsAsync.when(
      loading: () => const _LoadingState(),
      error: (e, _) => _ErrorState(
        message: e.toString(),
        onRetry: () => ref.read(missionsNotifierProvider.notifier).fetch(),
      ),
      data: (missions) {
        if (missions.isEmpty) return const _EmptyState();

        return RefreshIndicator(
          color: AppColors.violet,
          onRefresh: () => ref.read(missionsNotifierProvider.notifier).fetch(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: missions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final mission = missions[index];
              return MissionCard(
                mission: mission,
                onTap: () {
                  if (mission.isCompleted) {
                    showCompletedMissionSheet(context, mission);
                  } else {
                    showMissionInProgressSheet(context, mission);
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  void _handleEdit(BuildContext context, JobEntity job) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditJobScreen(job: job)),
    );
  }

  void _handleViewDetails(BuildContext context, JobEntity job) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => JobDetailsScreen(job: job)),
    );
  }

  void _handleViewCandidates(BuildContext context, JobEntity job, WidgetRef ref) {
    // 1. Définir le job courant dans le provider
    ref.read(currentJobIdProvider.notifier).state = job.id;

    // 2. Naviguer vers l'écran des candidats
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CandidatesScreen()),
    );
  }

  void _handleComplete(BuildContext context, JobEntity job) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditJobScreen(job: job)),
    );
  }
}

// ─────────────────────────────────────────────
// États : loading / error / empty
// ─────────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, __) => const _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 155,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.violetBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.draftBg,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _shimmer(height: 20, width: double.infinity),
                  const SizedBox(height: 8),
                  _shimmer(height: 14, width: 180),
                  const SizedBox(height: 12),
                  _shimmer(height: 12, width: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmer({required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.draftBg,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppColors.slate400),
            const SizedBox(height: 16),
            Text(
              'Une erreur est survenue',
              style: AppTextStyles.heading3.copyWith(color: AppColors.slate600),
            ),
            const SizedBox(height: 8),
            Text(message,
                style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.violet,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.work_outline, size: 48, color: AppColors.slate400),
          const SizedBox(height: 16),
          Text(
            'Aucune annonce',
            style: AppTextStyles.heading3.copyWith(color: AppColors.slate600),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre première offre d\'emploi',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FAB
// ─────────────────────────────────────────────
class _AddJobFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9999),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7F13EC).withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 8),
            spreadRadius: -6,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateJobScreen()),
          );
        },
        backgroundColor: AppColors.violet,
        foregroundColor: Colors.white,
        elevation: 0,
        child: const Icon(Icons.add, size: 24),
      ),
    );
  }
}



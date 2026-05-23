import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';
import 'package:job_app/features/jobs/domain/job_entity.dart';

import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/jobs/widgets/job_card.dart';
import 'package:job_app/features/jobs/widgets/mission_card.dart';
import 'package:job_app/features/jobs/widgets/analytics_card.dart';
import 'package:job_app/features/jobs/screens/create_job_screen.dart';
import 'package:job_app/features/jobs/screens/edit_job_screen.dart';
import 'package:job_app/features/jobs/screens/job_details_screen.dart';
import 'package:job_app/features/jobs/widgets/mission_in_progress_sheet.dart';
import 'package:job_app/core/widgets/app_bottom_nav_bar.dart';
import 'package:job_app/features/jobs/data/providers/analytics_provider.dart';
import 'package:job_app/features/applications/data/providers/applications_provider.dart';
import 'package:job_app/features/applications/widgets/compact_application_card.dart';
import 'package:job_app/features/applications/widgets/application_details_sheet.dart';
import 'package:job_app/features/interviews/data/providers/interviews_provider.dart';
import 'package:job_app/features/interviews/widgets/compact_interview_card.dart';
import 'package:job_app/core/widgets/svg_icon.dart';
import 'package:job_app/features/jobs/widgets/recruiter_filter_bar.dart';
import 'package:job_app/features/profile/data/providers/profile_provider.dart';

/// ────────────────
/// JobsListScreen
/// ────────────────
class JobsListScreen extends ConsumerWidget {
  const JobsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(jobsTabProvider);
    final showFilters = currentTab != JobsTab.activity;

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
            if (showFilters) const RecruiterFilterBar(),
            Expanded(child: _JobsBody()),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }
}

// ─────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────
class _Header extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final userName = userAsync.whenOrNull(data: (u) => u.name) ?? '';
    final avatarUrl = userAsync.whenOrNull(data: (u) => u.avatarUrl);
    final initials = userName.isNotEmpty
        ? userName.split(' ').map((n) => n[0]).take(2).join().toUpperCase()
        : '';

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          // Avatar du recruteur
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.violet,
              image: avatarUrl != null && avatarUrl.startsWith('http')
                  ? DecorationImage(
                      image: NetworkImage(avatarUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: avatarUrl == null || !avatarUrl.startsWith('http')
                ? Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),
          // Texte
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName.isNotEmpty ? 'Bonjour $userName' : 'Bonjour',
                  style: AppTextStyles.heading1.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'Voici l\'activité de vos recrutements aujourd\'hui.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    color: AppColors.slate600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Bouton Ajouter une offre
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateJobScreen()),
              );
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.violet,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tab Bar (style boutons comme candidat)
// ─────────────────────────────────────────────
class _TabBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(jobsTabProvider);

    final tabs = [
      (JobsTab.activity, 'Activité'),
      (JobsTab.myJobs, 'Mes annonces'),
      (JobsTab.missions, 'Mes missions'),
      (JobsTab.applications, 'Mes candidatures'),
      (JobsTab.interviews, 'Mes entretiens'),
    ];

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.violetBorder),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final (value, label) = tabs[index];
          final isActive = currentTab == value;
          return _TabButton(
            label: label,
            isActive: isActive,
            onTap: () {
              ref.read(recruiterFiltersProvider.notifier).reset();
              ref.read(jobsTabProvider.notifier).state = value;
            },
          );
        },
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.violet : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.violet : const Color(0xFFEEEBF4),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelBold.copyWith(
              fontSize: 14,
              color: isActive ? Colors.white : AppColors.slate600,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Body principal
// ─────────────────────────────────────────────
class _JobsBody extends ConsumerStatefulWidget {
  @override
  ConsumerState<_JobsBody> createState() => _JobsBodyState();
}

class _JobsBodyState extends ConsumerState<_JobsBody> {
  bool _showAllApplications = false;

  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(jobsTabProvider);
    final interviewsAsync = ref.watch(interviewsNotifierProvider);
    final now = DateTime.now();
    final interviewsByJob = interviewsAsync.valueOrNull
            ?.where((i) => i.isScheduled && i.scheduledDate.isAfter(now))
            .fold<Map<String, int>>(
              <String, int>{},
              (acc, i) {
                acc[i.jobId] = (acc[i.jobId] ?? 0) + 1;
                return acc;
              },
            ) ??
        const <String, int>{};

    if (currentTab == JobsTab.missions) {
      return _buildMissionsList(ref);
    }

    if (currentTab == JobsTab.activity) {
      return _buildActivitySection(ref);
    }

    if (currentTab == JobsTab.applications) {
      return _buildApplicationsList(ref);
    }

    if (currentTab == JobsTab.interviews) {
      return _buildInterviewsList(ref);
    }

    // Use jobsNotifierProvider for myJobs (only jobs), otherwise standard jobsNotifierProvider
    final dataAsync = ref.watch(filteredJobsProvider);

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
        if (items.isEmpty) return const _EmptyState();

        return RefreshIndicator(
          color: AppColors.violet,
          onRefresh: () async {
            await ref.read(jobsNotifierProvider.notifier).fetch();
            await ref.read(missionsNotifierProvider.notifier).fetch();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Column(
                children: items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: JobCard(
                    job: item,
                    plannedInterviewsCount: interviewsByJob[item.id] ?? 0,
                    onEdit: () => _handleEdit(context, item),
                    onViewCandidates: () => _handleViewCandidates(context, item, ref),
                    onComplete: () => _handleComplete(context, item),
                    onTap: item.status == JobStatus.searching
                        ? () => _handleViewDetails(context, item)
                        : null,
                  ),
                )).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivitySection(WidgetRef ref) {
    final analyticsAsync = ref.watch(recruiterAnalyticsProvider);
    final recentApplicationsAsync = ref.watch(recentApplicationsProvider);
    final upcomingInterviewsAsync = ref.watch(upcomingInterviewsProvider);

    return RefreshIndicator(
      color: AppColors.violet,
      onRefresh: () async {
        await ref.read(jobsNotifierProvider.notifier).fetch();
        await ref.read(missionsNotifierProvider.notifier).fetch();
        await ref.read(applicationsNotifierProvider.notifier).fetch();
        await ref.read(interviewsNotifierProvider.notifier).fetch();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Analytics Cards - 3 cartes sur une ligne
            analyticsAsync.when(
              data: (analytics) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: AnalyticsCard(
                        icon: Icons.engineering_outlined,
                        label: 'Missions actives',
                        count: analytics.activeMissions,
                        iconColor: const Color(0xFF7F13EC),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AnalyticsCard(
                        svgIcon: SvgIcons.fileText,
                        label: 'Candidatures',
                        count: analytics.pendingApplications,
                        iconColor: const Color(0xFF15803D),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AnalyticsCard(
                        svgIcon: SvgIcons.calendar,
                        label: 'Entretiens',
                        count: analytics.upcomingInterviews,
                        iconColor: const Color(0xFFEA580C),
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
              error: (_, __) => const SizedBox(),
            ),

            const SizedBox(height: 24),

            // Candidatures récentes avec bouton "Voir plus"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Candidatures récentes',
                    style: AppTextStyles.heading2.copyWith(fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11),
              child: recentApplicationsAsync.when(
                data: (applications) {
                  if (applications.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          'Aucune candidature récente',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.slate600),
                        ),
                      ),
                    );
                  }
                  
                  // Limiter à 3 candidatures si pas étendu
                  final displayedApplications = _showAllApplications 
                      ? applications 
                      : applications.take(3).toList();
                  
                  return Column(
                    children: [
                      ...displayedApplications.map((app) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Builder(
                          builder: (context) {
                            final savedIds =
                                ref.watch(savedApplicationsProvider);
                            return CompactApplicationCard(
                            application: app,
                            isSaved: savedIds.contains(app.id),
                            onAccept: () async {
                              setState(() {});
                              await ref.read(applicationsNotifierProvider.notifier).accept(app.id);
                            },
                            onReject: () async {
                              await ref.read(applicationsNotifierProvider.notifier).reject(app.id);
                            },
                            onSave: () => ref
                                .read(savedApplicationsProvider.notifier)
                                .toggle(app.id),
                            onTap: () {
                              // Ouvrir l'overlay des détails de candidature
                              showApplicationDetailsSheet(context, app);
                            },
                            onJobTap: () {
                              _navigateToJobDetails(context, app.jobId, ref);
                            },
                          );
                          },
                        ),
                      )),
                      // Bouton Voir plus/moins en bas à droite
                      if (applications.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showAllApplications = !_showAllApplications;
                                });
                              },
                              child: Text(
                                _showAllApplications ? 'Voir moins' : 'Voir plus',
                                style: AppTextStyles.labelBold.copyWith(
                                  fontSize: 14,
                                  color: AppColors.violet,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox(),
              ),
            ),

            const SizedBox(height: 6),

            // Entretiens à venir
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11),
              child: Text(
                'Entretiens à venir',
                style: AppTextStyles.heading2.copyWith(fontSize: 18),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11),
              child: upcomingInterviewsAsync.when(
                data: (interviews) {
                  if (interviews.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          'Aucun entretien planifié',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.slate600),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: interviews.map((interview) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CompactInterviewCard(
                        interview: interview,
                        onTap: () {
                          // TODO: Naviguer vers détails entretien
                        },
                        onJobTap: () {
                          // Naviguer vers les détails de l'offre
                          _navigateToJobDetails(context, interview.jobId, ref);
                        },
                      ),
                    )).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationsList(WidgetRef ref) {
    final applicationsAsync = ref.watch(recruiterFilteredApplicationsProvider);

    return applicationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorState(
        message: e.toString(),
        onRetry: () => ref.read(applicationsNotifierProvider.notifier).fetch(),
      ),
      data: (applications) {
        if (applications.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.work_outline, size: 48, color: AppColors.slate400),
                  SizedBox(height: 16),
                  Text(
                    'Aucune candidature',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Les candidatures apparaîtront ici',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.slate600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.violet,
          onRefresh: () => ref.read(applicationsNotifierProvider.notifier).fetch(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: applications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final app = applications[index];
              final savedIds = ref.watch(savedApplicationsProvider);
              return CompactApplicationCard(
                application: app,
                isSaved: savedIds.contains(app.id),
                onAccept: () async {
                  await ref.read(applicationsNotifierProvider.notifier).accept(app.id);
                },
                onReject: () async {
                  await ref.read(applicationsNotifierProvider.notifier).reject(app.id);
                },
                onSave: () => ref
                    .read(savedApplicationsProvider.notifier)
                    .toggle(app.id),
                onTap: () {
                  showApplicationDetailsSheet(context, app);
                },
                onJobTap: () {
                  _navigateToJobDetails(context, app.jobId, ref);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInterviewsList(WidgetRef ref) {
    final interviewsAsync = ref.watch(filteredInterviewsProvider);

    return interviewsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorState(
        message: e.toString(),
        onRetry: () => ref.read(interviewsNotifierProvider.notifier).fetch(),
      ),
      data: (interviews) {
        if (interviews.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, size: 48, color: AppColors.slate400),
                  SizedBox(height: 16),
                  Text(
                    'Aucun entretien',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Les entretiens planifiés apparaîtront ici',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.slate600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.violet,
          onRefresh: () => ref.read(interviewsNotifierProvider.notifier).fetch(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: interviews.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final interview = interviews[index];
              return CompactInterviewCard(
                interview: interview,
                onTap: () {},
                onJobTap: () {
                  _navigateToJobDetails(context, interview.jobId, ref);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMissionsList(WidgetRef ref) {
    final missionsAsync = ref.watch(filteredMissionsProvider);

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
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Column(
                  children: [
                    for (var i = 0; i < missions.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      MissionCard(
                        mission: missions[i],
                        onTap: () {
                          final mission = missions[i];
                          if (mission.isCompleted) {
                            showCompletedMissionSheet(context, mission,
                                isRecruiterView: true);
                          } else {
                            showMissionInProgressSheet(context, mission,
                                isRecruiterView: true);
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
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
    showJobApplicationsOverlay(context, ref, job);
  }

  void _handleComplete(BuildContext context, JobEntity job) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditJobScreen(job: job)),
    );
  }

  void _navigateToJobDetails(BuildContext context, String jobId, WidgetRef ref) {
    // Récupérer le job depuis le provider
    final jobsAsync = ref.read(jobsNotifierProvider);
    jobsAsync.whenData((jobs) {
      final job = jobs.firstWhere(
        (j) => j.id == jobId,
        orElse: () => jobs.first, // Fallback si non trouvé
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => JobDetailsScreen(job: job)),
      );
    });
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
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFFEFEDF2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 68,
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


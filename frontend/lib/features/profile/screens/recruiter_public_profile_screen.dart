import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';
import 'package:job_app/features/jobs/widgets/candidate_job_card.dart';
import 'package:job_app/features/jobs/widgets/recruiter_filter_bar.dart';
import 'package:job_app/features/jobs/widgets/mission_card.dart';
import 'package:job_app/features/jobs/widgets/mission_in_progress_sheet.dart';
import 'package:job_app/features/messaging/screens/messaging_screen.dart';
import 'package:job_app/features/profile/data/providers/profile_provider.dart';
import 'package:job_app/features/profile/widgets/candidate_profile_header.dart';
import 'package:job_app/features/profile/widgets/share_profile_overlay.dart';
import 'package:job_app/features/profile/widgets/profile_description_section.dart';
import 'package:job_app/features/profile/widgets/profile_tabs.dart';

class RecruiterPublicProfileScreen extends ConsumerWidget {
  final String recruiterId;
  const RecruiterPublicProfileScreen({
    super.key,
    this.recruiterId = 'recruiter_1',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(publicRecruiterProvider(recruiterId));
    final selectedTab = ref.watch(profileTabProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: SafeArea(
        bottom: false,
        child: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Erreur: $error')),
          data: (user) => ProviderScope(
            overrides: [
              currentUserProvider.overrideWith((ref) async => user),
              employeeReviewsProvider.overrideWith(
                (ref) async =>
                    ref.watch(publicRecruiterReviewsProvider(recruiterId).future),
              ),
            ],
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CandidateProfileHeader(
                        user: user,
                        isRecruiterView: true,
                        isPublicRecruiterView: true,
                        onBackTap: () => Navigator.pop(context),
                        onMessageTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const MessagingScreen(isRecruiterView: true),
                          ),
                        ),
                        onShareTap: () => showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (_) => ShareProfileOverlay(user: user),
                        ),
                        onMoreTap: () => _showMoreOptions(context),
                      ),
                      const SizedBox(height: 2),
                    ],
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: ProfileTabsDelegate(
                    child: const ProfileTabs(),
                  ),
                ),
              ],
              body: _PublicTabContent(
                selectedTab: selectedTab,
                recruiterId: recruiterId,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            _OptionTile(icon: Icons.shield_moon_outlined, label: 'Restreindre'),
            _OptionTile(icon: Icons.flag_outlined, label: 'Signaler'),
            _OptionTile(icon: Icons.block_outlined, label: 'Bloquer'),
            _OptionTile(icon: Icons.link_outlined, label: 'Copier l\'URL du profil'),
          ],
        ),
      ),
    );
  }
}

class _PublicTabContent extends StatelessWidget {
  final ProfileTab selectedTab;
  final String recruiterId;
  const _PublicTabContent({
    required this.selectedTab,
    required this.recruiterId,
  });

  @override
  Widget build(BuildContext context) {
    return switch (selectedTab) {
      ProfileTab.description => const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: ProfileDescriptionSection(isRecruiterView: true),
        ),
      ProfileTab.annonces => CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(
              child: RecruiterFilterBar(forcedTab: JobsTab.myJobs),
            ),
            _PublicAnnoncesSection(recruiterId: recruiterId),
          ],
        ),
      ProfileTab.missions => CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(
              child: RecruiterFilterBar(forcedTab: JobsTab.missions),
            ),
            _PublicMissionsSection(recruiterId: recruiterId),
          ],
        ),
    };
  }
}

class _PublicAnnoncesSection extends ConsumerWidget {
  final String recruiterId;
  const _PublicAnnoncesSection({required this.recruiterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(recruiterFilteredPublishedJobsProvider(recruiterId)).when(
          loading: () => const SliverToBoxAdapter(
            child: Center(child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            )),
          ),
          error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('Erreur: $e'))),
          data: (jobs) => SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 100),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Column(
                children: jobs
                    .map((job) => CandidateJobCard(job: job, showSaveButton: false))
                    .toList(),
              ),
            ),
          ),
        );
  }
}

class _PublicMissionsSection extends ConsumerWidget {
  final String recruiterId;
  const _PublicMissionsSection({required this.recruiterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(publicRecruiterMissionsProvider(recruiterId)).when(
          loading: () => const SliverToBoxAdapter(
            child: Center(child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            )),
          ),
          error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('Erreur: $e'))),
          data: (missions) => SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 100),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Column(
                children: missions.map((mission) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MissionCard(
                      mission: mission,
                      cardColor: const Color(0xFFEFEDF2),
                      onTap: () {
                        if (mission.isCompleted) {
                          showCompletedMissionSheet(context, mission, isRecruiterView: true);
                        } else {
                          showMissionInProgressSheet(context, mission, isRecruiterView: true);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const _OptionTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF401E66)),
      title: Text(label),
      onTap: () => Navigator.pop(context),
    );
  }
}

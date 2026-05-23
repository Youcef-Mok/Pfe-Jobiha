import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/features/auth/providers/auth_providers.dart';

import 'package:job_app/features/profile/data/providers/profile_provider.dart';
import 'package:job_app/features/profile/widgets/candidate_profile_header.dart';
import 'package:job_app/features/profile/widgets/profile_tabs.dart';
import 'package:job_app/features/profile/widgets/profile_annonces_section.dart';
import 'package:job_app/features/profile/widgets/profile_missions_section.dart';
import 'package:job_app/features/profile/widgets/profile_description_section.dart';
import 'package:job_app/features/jobs/widgets/recruiter_filter_bar.dart';
import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';
import 'package:job_app/core/widgets/app_bottom_nav_bar.dart';

/// Page profil du recruteur
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final selectedTab = ref.watch(profileTabProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: SafeArea(
        bottom: false,
        child: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Erreur: $error')),
          data: (user) => NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        tooltip: 'Logout',
                        icon: const Icon(Icons.logout, size: 20, color: Color(0xFF401E66)),
                        onPressed: () async {
                          await ref.read(authProvider.notifier).logout();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                          }
                        },
                      ),
                    ),
                    CandidateProfileHeader(user: user, isRecruiterView: true),
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
            body: _TabContent(selectedTab: selectedTab),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
    );
  }
}

class _TabContent extends StatelessWidget {
  final ProfileTab selectedTab;
  const _TabContent({required this.selectedTab});

  @override
  Widget build(BuildContext context) {
    return switch (selectedTab) {
      ProfileTab.description => const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: ProfileDescriptionSection(isRecruiterView: true),
        ),
      ProfileTab.annonces => const CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: RecruiterFilterBar(forcedTab: JobsTab.myJobs),
            ),
            ProfileAnnoncesSection(),
          ],
        ),
      ProfileTab.missions => const CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: RecruiterFilterBar(forcedTab: JobsTab.missions),
            ),
            ProfileMissionsSection(),
          ],
        ),
    };
  }
}

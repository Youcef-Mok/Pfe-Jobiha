import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:job_app/core/widgets/candidate_nav_bar.dart';
import 'package:job_app/features/auth/providers/auth_providers.dart';
import 'package:job_app/features/profile/data/providers/profile_provider.dart';
import 'package:job_app/features/profile/widgets/candidate_profile_header.dart';
import 'package:job_app/features/profile/widgets/candidate_profile_tabs.dart';
import 'package:job_app/features/profile/widgets/candidate_profile_missions_section.dart';
import 'package:job_app/features/profile/widgets/profile_cv_section.dart';
import 'package:job_app/features/profile/widgets/profile_description_section.dart';

class CandidateOwnProfileScreen extends ConsumerWidget {
  const CandidateOwnProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(candidateCurrentUserProvider);
    final selectedTab = ref.watch(candidateProfileTabProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      bottomNavigationBar: const CandidateNavBar(currentIndex: 3),
      body: Column(
        children: [
          _buildTopBar(context, ref),
          Expanded(
            child: userAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF401E66)),
              ),
              error: (e, _) => Center(child: Text('Erreur: $e')),
              data: (user) => CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: CandidateProfileHeader(user: user),
                  ),
                  SliverPersistentHeader(
                    delegate: CandidateProfileTabsDelegate(
                      child: const CandidateProfileTabs(),
                    ),
                    pinned: true,
                  ),
                  if (selectedTab == CandidateProfileTab.description)
                    const SliverToBoxAdapter(
                      child: ProfileDescriptionSection(),
                    ),
                  if (selectedTab == CandidateProfileTab.competences)
                    SliverFillRemaining(
                      hasScrollBody: true,
                      child: const ProfileCvSection(),
                    ),
                  if (selectedTab == CandidateProfileTab.missions)
                    const CandidateProfileMissionsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, WidgetRef ref) {
    return Container(
      color: const Color(0xFFFBFBFB),
      child: SafeArea(
        bottom: false,
        child: Align(
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
      ),
    );
  }
}

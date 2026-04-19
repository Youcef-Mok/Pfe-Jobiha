import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'package:job_app/features/profile/data/providers/profile_provider.dart';
import 'package:job_app/features/profile/widgets/profile_header.dart';
import 'package:job_app/features/profile/widgets/profile_stats.dart';
import 'package:job_app/features/profile/widgets/profile_tabs.dart';
import 'package:job_app/features/profile/widgets/profile_annonces_section.dart';
import 'package:job_app/features/profile/widgets/profile_missions_section.dart';
import 'package:job_app/features/profile/widgets/profile_cv_section.dart';
import 'package:job_app/features/profile/widgets/profile_reviews_section.dart';
import 'package:job_app/core/widgets/app_bottom_nav_bar.dart';

/// Page profil du recruteur
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final selectedTab = ref.watch(profileTabProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F8), // Fond explicite F7F6F8
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
                    ProfileHeader(user: user),
                    const SizedBox(height: 12),
                    ProfileStats(user: user),
                    const SizedBox(height: 16),
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
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 4),
    );
  }
}

class _TabContent extends StatelessWidget {
  final ProfileTab selectedTab;
  const _TabContent({required this.selectedTab});

  @override
  Widget build(BuildContext context) {
    return switch (selectedTab) {
      ProfileTab.annonces  => const SingleChildScrollView(physics: AlwaysScrollableScrollPhysics(), child: ProfileAnnoncesSection()),
      ProfileTab.missions  => const SingleChildScrollView(physics: AlwaysScrollableScrollPhysics(), child: ProfileMissionsSection()),
      ProfileTab.competences  => const _CvBodyWrapper(),
      ProfileTab.reviews   => const SingleChildScrollView(physics: AlwaysScrollableScrollPhysics(), child: ProfileReviewsSection()),
    };
  }
}

class _CvBodyWrapper extends StatelessWidget {
  const _CvBodyWrapper();

  @override
  Widget build(BuildContext context) {
    // On laisse ProfileCvSection occuper tout l'espace restant du NestedScrollView body.
    // Cela permet au LayoutBuilder de ProfileCvSection de calculer précisément
    // la hauteur disponible pour caler les cartes en bas de l'écran.
    return const ProfileCvSection();
  }
}

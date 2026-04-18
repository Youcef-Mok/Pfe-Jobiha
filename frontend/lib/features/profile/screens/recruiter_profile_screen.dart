import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/profile/data/providers/profile_provider.dart';
import 'package:job_app/features/profile/widgets/profile_header.dart';
import 'package:job_app/features/profile/widgets/profile_stats.dart';
import 'package:job_app/features/profile/widgets/profile_tabs.dart';
import 'package:job_app/features/profile/widgets/profile_jobs_section.dart';
import 'package:job_app/features/profile/widgets/profile_reviews_section.dart';

/// Page profil du recruteur
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final selectedTab = ref.watch(profileTabProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erreur: $error'),
        ),
        data: (user) => CustomScrollView(
          slivers: [
            // Header avec overlay blur
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.white.withValues(alpha: 0.95),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Profil',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF0F172A),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: Color(0xFF0F172A)),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined,
                      color: Color(0xFF0F172A)),
                  onPressed: () {},
                ),
                const SizedBox(width: 16),
              ],
            ),

            // Contenu principal
            SliverToBoxAdapter(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 672),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ProfileHeader(user: user),
                      const SizedBox(height: 8),
                      ProfileStats(user: user),
                      const SizedBox(height: 12),
                      const ProfileTabs(),
                      ProfileJobsSection(selectedTab: selectedTab),
                      const ProfileReviewsSection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

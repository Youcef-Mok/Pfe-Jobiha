import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/features/jobs/domain/recruiter_filters.dart';
import 'package:job_app/features/profile/data/providers/profile_provider.dart';
import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';

final _annoncesFiltersStateProvider =
    StateProvider<RecruiterFilters?>((ref) => null);
final _missionsFiltersStateProvider =
    StateProvider<RecruiterFilters?>((ref) => null);

/// Tabs de navigation du profil recruteur : Description | Annonces | Missions
class ProfileTabs extends ConsumerWidget {
  const ProfileTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(profileTabProvider);

    const tabs = [
      (ProfileTab.description, 'Description'),
      (ProfileTab.annonces, 'Annonces'),
      (ProfileTab.missions, 'Missions'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFCFBFB),
      ),
      child: Row(
        children: [
          for (int i = 0; i < tabs.length; i++) ...[
            if (i > 0)
              Container(
                width: 1,
                height: 18,
                color: const Color(0xFFEFF1F5),
              ),
            Expanded(
              child: _TabButton(
                label: tabs[i].$2,
                isSelected: selectedTab == tabs[i].$1,
                onTap: () {
                  final nextTab = tabs[i].$1;
                  final currentTab = ref.read(profileTabProvider);
                  final currentFilters = ref.read(recruiterFiltersProvider);

                  // Sauvegarde les filtres de l'onglet courant.
                  if (currentTab == ProfileTab.annonces) {
                    ref.read(_annoncesFiltersStateProvider.notifier).state =
                        currentFilters;
                  } else if (currentTab == ProfileTab.missions) {
                    ref.read(_missionsFiltersStateProvider.notifier).state =
                        currentFilters;
                  }

                  // Bascule d'onglet profil.
                  ref.read(profileTabProvider.notifier).state = nextTab;

                  // Restaure les filtres propres à l'onglet cible.
                  if (nextTab == ProfileTab.annonces) {
                    final saved =
                        ref.read(_annoncesFiltersStateProvider) ??
                            const RecruiterFilters();
                    ref.read(recruiterFiltersProvider.notifier).apply(saved);
                  } else if (nextTab == ProfileTab.missions) {
                    final saved =
                        ref.read(_missionsFiltersStateProvider) ??
                            const RecruiterFilters();
                    ref.read(recruiterFiltersProvider.notifier).apply(saved);
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ProfileTabsDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  ProfileTabsDelegate({required this.child});

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant ProfileTabsDelegate oldDelegate) => false;
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        height: 48,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color:
                isSelected ? const Color(0xFF401E66) : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}

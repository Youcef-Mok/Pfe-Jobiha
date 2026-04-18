import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/profile/data/providers/profile_provider.dart';

/// Tabs de navigation du profil (All, Active Jobs, Brouillons).
class ProfileTabs extends ConsumerWidget {
  const ProfileTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(profileTabProvider);

    return Container(
      width: double.infinity,
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE7E6E6)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _TabButton(
            label: 'All',
            isSelected: selectedTab == ProfileTab.all,
            onTap: () =>
                ref.read(profileTabProvider.notifier).state = ProfileTab.all,
          ),
          _TabButton(
            label: 'Active jobs',
            isSelected: selectedTab == ProfileTab.activeJobs,
            onTap: () => ref.read(profileTabProvider.notifier).state =
                ProfileTab.activeJobs,
          ),
          _TabButton(
            label: 'Brouillons',
            isSelected: selectedTab == ProfileTab.drafts,
            onTap: () =>
                ref.read(profileTabProvider.notifier).state = ProfileTab.drafts,
          ),
        ],
      ),
    );
  }
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.violet : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
            height: 1.43,
            color: isSelected ? AppColors.violet : AppColors.slate600,
          ),
        ),
      ),
    );
  }
}

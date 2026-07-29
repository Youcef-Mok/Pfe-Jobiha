import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/features/profile/data/providers/profile_provider.dart';

class CandidateProfileTabs extends ConsumerWidget {
  const CandidateProfileTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(candidateProfileTabProvider);

    const tabs = [
      (CandidateProfileTab.description, 'Description'),
      (CandidateProfileTab.competences, 'Compétences'),
      (CandidateProfileTab.missions, 'Missions'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFBFBFB),
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
                onTap: () => ref
                    .read(candidateProfileTabProvider.notifier)
                    .state = tabs[i].$1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class CandidateProfileTabsDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  CandidateProfileTabsDelegate({required this.child});

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
  bool shouldRebuild(covariant CandidateProfileTabsDelegate oldDelegate) =>
      false;
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
            color: isSelected
                ? const Color(0xFF401E66)
                : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}

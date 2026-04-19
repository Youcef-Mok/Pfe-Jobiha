import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_app/features/profile/data/providers/profile_provider.dart';

/// Tabs de navigation du profil : Annonces | Missions | CV | Reviews
class ProfileTabs extends ConsumerWidget {
  const ProfileTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(profileTabProvider);

    const tabs = [
      (ProfileTab.annonces, 'Annonces'),
      (ProfileTab.missions, 'Missions'),
      (ProfileTab.competences, 'Compétences'),
      (ProfileTab.reviews, 'Reviews'),
    ];

    return Container(
      width: double.infinity,
      height: 52.5,
      decoration: const BoxDecoration(
        color: Color(0xFFF7F6F8),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE1E1E1)),
        ),
      ),
      child: Row(
        children: tabs.map((tab) {
          final (value, label) = tab;
          final isSelected = selectedTab == value;
          return Expanded(
            child: _TabButton(
              label: label,
              isSelected: isSelected,
              onTap: () =>
                  ref.read(profileTabProvider.notifier).state = value,
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Delegate pour rendre les onglets collants (sticky) dans un CustomScrollView/NestedScrollView
class ProfileTabsDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  ProfileTabsDelegate({required this.child});

  @override
  double get minExtent => 52.5; // Hauteur fixe specifiee dans ProfileTabs

  @override
  double get maxExtent => 52.5;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant ProfileTabsDelegate oldDelegate) {
    return false;
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
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        height: 51,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF401E66) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13, // Slightly reduced to fit 'Compétences' perfectly
            height: 1.43,
            color: isSelected ? const Color(0xFF401E66) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

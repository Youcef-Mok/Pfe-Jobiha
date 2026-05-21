import 'package:flutter/material.dart';

import 'package:job_app/features/jobs/screens/candidate_home_screen.dart';
import 'package:job_app/features/map/screens/map_screen.dart';
import 'package:job_app/features/messaging/screens/messaging_screen.dart';
import 'package:job_app/features/profile/screens/candidate_profile_screen.dart';

class CandidateNavBar extends StatelessWidget {
  final int currentIndex;

  const CandidateNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      decoration: const BoxDecoration(
        color: Color(0xFFEFEDF2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _NavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Accueil',
            index: 0,
            currentIndex: currentIndex,
            onTap: () {
              if (currentIndex != 0) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CandidateHomeScreen()),
                  (route) => false,
                );
              }
            },
          ),
          _NavItem(
            icon: Icons.map_outlined,
            activeIcon: Icons.map,
            label: 'Map',
            index: 1,
            currentIndex: currentIndex,
            onTap: () {
              if (currentIndex != 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MapScreen()),
                );
              }
            },
          ),
          _NavItem(
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble,
            label: 'mess',
            index: 2,
            currentIndex: currentIndex,
            onTap: () {
              if (currentIndex != 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MessagingScreen()),
                );
              }
            },
          ),
          _NavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profil',
            index: 3,
            currentIndex: currentIndex,
            onTap: () {
              if (currentIndex != 3) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CandidateOwnProfileScreen()),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;
    const activeColor = Color(0xFF401E66);
    const inactiveColor = Color(0xFF94A3B8);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 26,
              color: isActive ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 6),
            if (isActive)
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                ),
              )
            else
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                  height: 1.5,
                  color: inactiveColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

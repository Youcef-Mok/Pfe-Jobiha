import 'package:flutter/material.dart';
import 'package:job_app/features/jobs/screens/jobs_list_screen.dart';
import 'package:job_app/features/notifications/screens/notifications_screen.dart';
import 'package:job_app/features/profile/screens/recruiter_profile_screen.dart';
import 'package:job_app/features/messaging/screens/messaging_screen.dart';

// Index mapping:
// 0 = Home (Jobs List)
// 1 = Notifications
// 2 = Messages
// 3 = Profil

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavBar({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget screen;
    switch (index) {
      case 0:
        screen = const JobsListScreen();
        break;
      case 1:
        screen = const NotificationsScreen();
        break;
      case 2:
        screen = const MessagingScreen(isRecruiterView: true);
        break;
      case 3:
        screen = const ProfileScreen();
        break;
      default:
        return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      height: 80 + 14 + bottomInset + 6,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Carte blanche flottante
          Positioned(
            bottom: bottomInset + 6,
            left: 16,
            right: 16,
            height: 80,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(
                  color: const Color(0xFFEEEBF4),
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F0D0A2C),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          // Ligne des items
          Positioned(
            bottom: bottomInset + 6,
            left: 16,
            right: 16,
            height: 80,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Accueil',
                  index: 0,
                  currentIndex: currentIndex,
                  onTap: () => _onItemTapped(context, 0),
                ),
                _NavItem(
                  icon: Icons.notifications_outlined,
                  activeIcon: Icons.notifications_rounded,
                  label: 'Notifs',
                  index: 1,
                  currentIndex: currentIndex,
                  onTap: () => _onItemTapped(context, 1),
                ),
                _NavItem(
                  icon: Icons.message_outlined,
                  activeIcon: Icons.message_rounded,
                  label: 'Messages',
                  index: 2,
                  currentIndex: currentIndex,
                  onTap: () => _onItemTapped(context, 2),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person_rounded,
                  label: 'Profil',
                  index: 3,
                  currentIndex: currentIndex,
                  onTap: () => _onItemTapped(context, 3),
                ),
              ],
            ),
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
    final isActive = index == currentIndex;
    const violet = Color(0xFF401E66);
    const gray = Color(0xFFCFD6DC);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (isActive) ...[
              // Cercle violet solide flottant au-dessus
              Positioned(
                top: -14,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: violet,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x3D401E66),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(activeIcon, color: Colors.white, size: 22),
                  ),
                ),
              ),
              // Label violet en bas
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: violet,
                    ),
                  ),
                ),
              ),
            ] else
              Icon(icon, color: gray, size: 24),
          ],
        ),
      ),
    );
  }
}

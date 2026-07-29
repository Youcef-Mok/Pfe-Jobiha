import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  // Mapper les index vers les icônes personnalisées
  // index 0 = Create → Icon(1).png
  // index 1 = Notif → Icon(2).png
  // index 3 = Messages → Icon(3).png
  // index 4 = Profil → Icon(4).png
  String? _getIconPath(int index) {
    switch (index) {
      case 0:
        return 'assets/images/Icon(1).png';
      case 1:
        return 'assets/images/ICON(2).png';
      case 3:
        return 'assets/images/Icon(3).png';
      case 4:
        return 'assets/images/Icon(4).png';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Items de navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildNavItem(
                icon: Icons.edit_outlined,
                label: 'Create',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.notifications_outlined,
                label: 'Notif',
                index: 1,
              ),
              // Espace vide pour le bouton central
              const SizedBox(width: 56),
              _buildNavItem(
                icon: Icons.message_outlined,
                label: 'mess',
                index: 3,
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                label: 'Profil',
                index: 4,
              ),
            ],
          ),
          // Bouton central violet
          Positioned(
            left: 0,
            right: 0,
            top: -20,
            child: Center(
              child: Column(
                children: [
                  // Background blanc arrondi
                  Container(
                    width: 87,
                    height: 43,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(999),
                        topRight: Radius.circular(999),
                      ),
                    ),
                  ),
                  // Le bouton violet chevauche légèrement le background
                  Transform.translate(
                    offset: const Offset(0, -36),
                    child: GestureDetector(
                      onTap: () => onItemTapped(2),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFF401E66),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF401E66).withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.home,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = selectedIndex == index;
    final color = isSelected ? const Color(0xFF401E66) : const Color(0xFF94A3B8);

    // Mapper les indices vers les icônes personnalisées
    final iconPath = _getIconPath(index);

    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Container(
        width: 47,
        height: 85,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconPath != null)
              Image.asset(
                iconPath,
                width: 24,
                height: 24,
                color: color,
                errorBuilder: (context, error, stackTrace) => Icon(
                  icon,
                  color: color,
                  size: 26,
                ),
              )
            else
              Icon(
                icon,
                color: color,
                size: 26,
              ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

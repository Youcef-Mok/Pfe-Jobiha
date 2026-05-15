import 'package:flutter/material.dart';
import 'package:job_app/core/widgets/custom_nav_bar.dart';
import 'package:job_app/features/jobs/screens/jobs_list_screen.dart';
import 'package:job_app/features/notifications/screens/notifications_screen.dart';
import 'package:job_app/features/profile/screens/recruiter_profile_screen.dart';
import 'package:job_app/features/jobs/screens/create_job_screen.dart';
import 'package:job_app/features/candidates/screens/candidates_screen.dart'; // fallback for message if needed

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavBar({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget targetScreen;
    switch (index) {
      case 0:
        targetScreen = const CreateJobScreen();
        break;
      case 1:
        targetScreen = const NotificationsScreen();
        break;
      case 2:
        targetScreen = const JobsListScreen();
        break;
      case 3:
        targetScreen = const CandidatesScreen(); // Placeholder for messages
        break;
      case 4:
        targetScreen = const ProfileScreen();
        break;
      default:
        return;
    }

    // ← Vide le stack avant de naviguer, évite l'accumulation mémoire
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => targetScreen),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomNavBar(
      selectedIndex: currentIndex,
      onItemTapped: (index) => _onItemTapped(context, index),
    );
  }
}

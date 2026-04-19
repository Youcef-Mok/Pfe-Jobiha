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

    // We use pushReplacement to avoid infinite stack, or just push.
    // Given the previous code used push, we will align. Using pushReplacement for root level taps is better Practice. 
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => targetScreen),
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

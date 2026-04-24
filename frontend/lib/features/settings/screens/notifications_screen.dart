import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/features/auth/providers/auth_providers.dart';
import 'package:job_app/features/notifications/screens/candidate_notifications_screen.dart';
import 'package:job_app/features/notifications/screens/notifications_screen.dart'
    as recruiter;

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider).role;

    if (role == 'recruteur') {
      return const recruiter.NotificationsScreen();
    } else {
    return const CandidateNotificationsScreen();
    }
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/applications/data/providers/applications_provider.dart';
import 'package:job_app/features/applications/widgets/application_details_sheet.dart';
import 'package:job_app/features/applications/widgets/compact_application_card.dart';
import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';
import 'package:job_app/features/jobs/screens/job_details_screen.dart';

/// Liste candidatures recruteur (homepage ou overlay détail offre).
class RecruiterApplicationsListBody extends ConsumerWidget {
  const RecruiterApplicationsListBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(recruiterFilteredApplicationsProvider);
    final savedIds = ref.watch(savedApplicationsProvider);

    return applicationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
      data: (applications) {
        if (applications.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.work_outline, size: 48, color: AppColors.slate400),
                  SizedBox(height: 16),
                  Text(
                    'Aucune candidature',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate900,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.violet,
          onRefresh: () =>
              ref.read(applicationsNotifierProvider.notifier).fetch(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: applications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final app = applications[index];
              return CompactApplicationCard(
                application: app,
                isSaved: savedIds.contains(app.id),
                onAccept: () => ref
                    .read(applicationsNotifierProvider.notifier)
                    .accept(app.id),
                onReject: () => ref
                    .read(applicationsNotifierProvider.notifier)
                    .reject(app.id),
                onSave: () => ref
                    .read(savedApplicationsProvider.notifier)
                    .toggle(app.id),
                onTap: () => showApplicationDetailsSheet(context, app),
                onJobTap: () => _openJobDetails(context, ref, app.jobId),
              );
            },
          ),
        );
      },
    );
  }
}

void _openJobDetails(BuildContext context, WidgetRef ref, String jobId) {
  final jobs = ref.read(jobsNotifierProvider).valueOrNull;
  if (jobs == null) return;
  try {
    final job = jobs.firstWhere((j) => j.id == jobId);
    showJobDetailsSheet(context, job);
  } catch (_) {}
}

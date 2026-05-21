import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';
import 'package:job_app/features/applications/data/providers/applications_provider.dart';
import 'package:job_app/features/interviews/data/providers/interviews_provider.dart';

/// Modèle pour les analytics du recruteur
class RecruiterAnalytics {
  final int activeMissions;
  final int activeJobs;
  final int pendingApplications;
  final int upcomingInterviews;

  const RecruiterAnalytics({
    required this.activeMissions,
    required this.activeJobs,
    required this.pendingApplications,
    required this.upcomingInterviews,
  });
}

/// Provider pour les analytics du recruteur
final recruiterAnalyticsProvider = Provider<AsyncValue<RecruiterAnalytics>>((ref) {
  final jobsAsync = ref.watch(jobsNotifierProvider);
  final missionsAsync = ref.watch(missionsNotifierProvider);
  final applicationsAsync = ref.watch(applicationsNotifierProvider);
  final interviewsAsync = ref.watch(interviewsNotifierProvider);

  // Combiner tous les AsyncValue
  return jobsAsync.when(
    data: (jobs) => missionsAsync.when(
      data: (missions) => applicationsAsync.when(
        data: (applications) => interviewsAsync.when(
          data: (interviews) {
            final now = DateTime.now();
            return AsyncValue.data(RecruiterAnalytics(
              activeMissions: missions.where((m) => m.status == 'in_progress').length,
              activeJobs: jobs.where((j) => j.status.name == 'searching').length,
              pendingApplications: applications.where((a) => a.status.name == 'pending').length,
              upcomingInterviews: interviews.where((i) => 
                i.isScheduled && i.scheduledDate.isAfter(now)
              ).length,
            ));
          },
          loading: () => const AsyncValue.loading(),
          error: (e, s) => AsyncValue.error(e, s),
        ),
        loading: () => const AsyncValue.loading(),
        error: (e, s) => AsyncValue.error(e, s),
      ),
      loading: () => const AsyncValue.loading(),
      error: (e, s) => AsyncValue.error(e, s),
    ),
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});

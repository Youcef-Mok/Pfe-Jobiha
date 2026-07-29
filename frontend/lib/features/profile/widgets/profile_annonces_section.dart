import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';
import 'package:job_app/features/jobs/widgets/job_card.dart';
import 'package:job_app/features/jobs/screens/job_details_screen.dart';

/// Section "Mes annonces" du profil — grand cadre avec cartes colorées
class ProfileAnnoncesSection extends ConsumerWidget {
  const ProfileAnnoncesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(filteredJobsProvider);

    return jobsAsync.when(
      data: (jobs) {
        if (jobs.isEmpty) {
          return const SliverToBoxAdapter(
            child: _EmptyState(message: 'Aucune annonce'),
          );
        }

        return SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 100),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...jobs.map((job) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: JobCard(
                        job: job,
                        cardColor: const Color(0xFFEFEDF2),
                        onTap: () => showJobDetailsSheet(context, job),
                        onEdit: () {},
                        onViewCandidates: () =>
                            showJobApplicationsOverlay(context, ref, job),
                        onComplete: () {},
                      ),
                    )),
              ],
            ),
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(child: Text('Erreur: $e')),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.work_outline, size: 48, color: AppColors.slate400),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.slate600),
          ),
        ],
      ),
    );
  }
}

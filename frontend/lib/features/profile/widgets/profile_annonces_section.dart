import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';
import 'package:job_app/features/jobs/widgets/job_card.dart';

/// Section "Mes annonces" du profil — affiche les JobCards scrollables
class ProfileAnnoncesSection extends ConsumerWidget {
  const ProfileAnnoncesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(jobsNotifierProvider);

    return jobsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(32),
        child: Center(child: Text('Erreur: $e')),
      ),
      data: (jobs) {
        if (jobs.isEmpty) {
          return const _EmptyState(message: 'Aucune annonce');
        }

        return Column(
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              itemCount: jobs.length + 1,
              separatorBuilder: (context, index) => SizedBox(height: index == 0 ? 6 : 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      'Mes annonces',
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.slate900,
                        fontSize: 18,
                      ),
                    ),
                  );
                }
                final job = jobs[index - 1];
                return JobCard(
                  job: job,
                  onTap: () {},
                  onEdit: () {},
                  onViewCandidates: () {},
                  onComplete: () {},
                );
              },
            ),
          ],
        );
      },
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

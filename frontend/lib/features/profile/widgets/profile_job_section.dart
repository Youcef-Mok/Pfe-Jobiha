import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';
import 'package:job_app/features/jobs/widgets/job_card.dart';
import 'package:job_app/features/jobs/widgets/mission_card.dart';
import 'package:job_app/features/profile/data/providers/profile_provider.dart';
import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/features/jobs/domain/mission_entity.dart';

/// Section qui affiche les jobs et missions selon l'onglet sélectionné
class ProfileJobsSection extends ConsumerWidget {
  final ProfileTab selectedTab;

  const ProfileJobsSection({super.key, required this.selectedTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      color: Colors.white,
      child: _buildContent(context, ref),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    // Ce widget est désormais remplacé par les sections dédiées.
    // Conservé pour référence uniquement.
    return const SizedBox.shrink();
  }

  // Section "All" - affiche jobs + missions combinés
  Widget _buildAllSection(WidgetRef ref) {
    final combinedAsync = ref.watch(combinedJobsAndMissionsProvider);

    return combinedAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text('Erreur: $error'),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('Aucune annonce ou mission'),
            ),
          );
        }

        return Column(
          children: items.map((item) {
            if (item is JobEntity) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: JobCard(
                  job: item,
                  onTap: () {
                    // Navigation vers détails job
                  },
                  onEdit: () {},
                  onViewCandidates: () {},
                  onComplete: () {},
                ),
              );
            } else if (item is MissionEntity) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: MissionCard(
                  mission: item,
                  onTap: () {
                    // Navigation vers détails mission
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          }).toList(),
        );
      },
    );
  }

  // Section "Active Jobs" - uniquement les jobs actifs
  Widget _buildActiveJobsSection(WidgetRef ref) {
    final activeJobs = ref.watch(activeJobsProvider);

    if (activeJobs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('Aucune annonce active'),
        ),
      );
    }

    return Column(
      children: activeJobs
          .map((job) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: JobCard(
                  job: job,
                  onTap: () {},
                  onEdit: () {},
                  onViewCandidates: () {},
                ),
              ))
          .toList(),
    );
  }

  // Section "Brouillons" - uniquement les drafts
  Widget _buildDraftsSection(WidgetRef ref) {
    final drafts = ref.watch(draftJobsProvider);

    if (drafts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('Aucun brouillon'),
        ),
      );
    }

    return Column(
      children: drafts
          .map((job) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: JobCard(
                  job: job,
                  onTap: () {},
                  onComplete: () {},
                ),
              ))
          .toList(),
    );
  }
}

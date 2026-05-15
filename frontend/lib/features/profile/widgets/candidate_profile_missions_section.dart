import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/jobs/widgets/mission_card.dart';
import 'package:job_app/features/jobs/widgets/mission_in_progress_sheet.dart';
import 'package:job_app/features/profile/data/providers/profile_provider.dart';

class CandidateProfileMissionsSection extends ConsumerWidget {
  const CandidateProfileMissionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionsAsync = ref.watch(candidateMissionsProvider);

    return missionsAsync.when(
      data: (missions) {
        if (missions.isEmpty) {
          return const SliverToBoxAdapter(child: _EmptyState());
        }
        return SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...missions.map((mission) {
                  final isInProgress = mission.status == 'in_progress';
                  
                  return Padding(
                    padding: EdgeInsets.only(bottom: isInProgress ? 16 : 0),
                    child: MissionCard(
                      mission: mission,
                      cardColor: const Color(0xFFEFEDF2),
                      onTap: () {
                        if (mission.isCompleted) {
                          showCompletedMissionSheet(context, mission);
                        } else {
                          showMissionInProgressSheet(context, mission);
                        }
                      },
                    ),
                  );
                }),
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
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assignment_outlined, size: 48, color: AppColors.slate400),
          const SizedBox(height: 12),
          Text(
            'Aucune mission',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.slate600),
          ),
        ],
      ),
    );
  }
}

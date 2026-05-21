import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';
import 'package:job_app/features/jobs/widgets/mission_card.dart';
import 'package:job_app/features/jobs/widgets/mission_in_progress_sheet.dart';

/// Section "Mes missions" du profil — grand cadre avec cartes colorées
class ProfileMissionsSection extends ConsumerWidget {
  const ProfileMissionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionsAsync = ref.watch(filteredMissionsProvider);

    return missionsAsync.when(
      data: (missions) {
        if (missions.isEmpty) {
          return const SliverToBoxAdapter(
            child: _EmptyState(message: 'Aucune mission'),
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
                ...missions.map((mission) {
                  final isInProgress = mission.status == 'in_progress';
                  return Padding(
                    padding: EdgeInsets.only(bottom: isInProgress ? 16 : 12),
                    child: MissionCard(
                      mission: mission,
                      cardColor: const Color(0xFFEFEDF2),
                      onTap: () {
                        if (mission.isCompleted) {
                          showCompletedMissionSheet(context, mission,
                              isRecruiterView: true);
                        } else {
                          showMissionInProgressSheet(context, mission,
                              isRecruiterView: true);
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
  final String message;
  const _EmptyState({required this.message});

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
            message,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.slate600),
          ),
        ],
      ),
    );
  }
}

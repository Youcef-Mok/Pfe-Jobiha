import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/core/widgets/api_error_widget.dart';
import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';
import 'package:job_app/features/jobs/widgets/mission_card.dart';
import 'package:job_app/features/jobs/widgets/mission_in_progress_sheet.dart';

/// Section "Mes missions" du profil — affiche les MissionCards scrollables
class ProfileMissionsSection extends ConsumerWidget {
  const ProfileMissionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionsAsync = ref.watch(missionsNotifierProvider);

    return missionsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => ApiErrorWidget(
        error: e,
        icon: Icons.assignment_late_outlined,
        onRetry: () => ref.invalidate(missionsNotifierProvider),
      ),
      data: (missions) {
        if (missions.isEmpty) {
          return const _EmptyState(message: 'Aucune mission');
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          itemCount: missions.length + 1,
          separatorBuilder: (context, index) => SizedBox(height: index == 0 ? 6 : 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  'Mes missions',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.slate900,
                    fontSize: 18,
                  ),
                ),
              );
            }
            final mission = missions[index - 1];
            return MissionCard(
              mission: mission,
              onTap: () {
                if (mission.isCompleted) {
                  showCompletedMissionSheet(context, mission);
                } else {
                  showMissionInProgressSheet(context, mission);
                }
              },
            );
          },
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

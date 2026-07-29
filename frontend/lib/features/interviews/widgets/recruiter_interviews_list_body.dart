import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/interviews/data/providers/interviews_provider.dart';
import 'package:job_app/features/interviews/widgets/compact_interview_card.dart';
import 'package:job_app/features/interviews/widgets/edit_interview_sheet.dart';

/// Liste entretiens recruteur (homepage ou overlay détail offre).
class RecruiterInterviewsListBody extends ConsumerWidget {
  const RecruiterInterviewsListBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interviewsAsync = ref.watch(filteredInterviewsProvider);

    return interviewsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
      data: (interviews) {
        if (interviews.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, size: 48, color: AppColors.slate400),
                  SizedBox(height: 16),
                  Text(
                    'Aucun entretien',
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
          onRefresh: () => ref.read(interviewsNotifierProvider.notifier).fetch(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: interviews.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final interview = interviews[index];
              return CompactInterviewCard(
                interview: interview,
                onTap: () => showEditInterviewSheet(context, interview),
              );
            },
          ),
        );
      },
    );
  }
}

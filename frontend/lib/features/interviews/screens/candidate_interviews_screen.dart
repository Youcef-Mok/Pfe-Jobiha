import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/core/widgets/candidate_nav_bar.dart';
import 'package:job_app/features/interviews/domain/interview_entity.dart';
import 'package:job_app/features/interviews/data/providers/interviews_provider.dart';
import 'package:job_app/features/interviews/widgets/edit_interview_sheet.dart';

class CandidateInterviewsScreen extends ConsumerWidget {
  const CandidateInterviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interviewsAsync = ref.watch(interviewsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            Expanded(
              child: interviewsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.violet),
                ),
                error: (_, __) =>
                    const Center(child: Text('Erreur de chargement')),
                data: (interviews) => _buildList(context, ref, interviews),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CandidateNavBar(currentIndex: -1),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE4E4E7))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, size: 22, color: Color(0xFF18181B)),
          ),
          const SizedBox(width: 10),
          const Text(
            'Mes entretiens',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Color(0xFF18181B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<InterviewEntity> interviews,
  ) {
    final now = DateTime.now();
    final upcoming = interviews
        .where((i) => i.isScheduled && i.scheduledDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    final past = interviews
        .where((i) => !i.isScheduled || i.scheduledDate.isBefore(now))
        .toList()
      ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));

    if (interviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.event_outlined, size: 48, color: AppColors.slate400),
            SizedBox(height: 16),
            Text(
              'Aucun entretien planifié',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.slate600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        if (upcoming.isNotEmpty) ...[
          _sectionLabel('À venir'),
          const SizedBox(height: 8),
          ...upcoming.map((i) => _InterviewCard(
                interview: i,
                onEdit: () => showEditInterviewSheet(context, i),
              )),
        ],
        if (past.isNotEmpty) ...[
          const SizedBox(height: 16),
          _sectionLabel('Passés'),
          const SizedBox(height: 8),
          ...past.map((i) => _InterviewCard(interview: i)),
        ],
      ],
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: Color(0xFF1D1B1F),
      ),
    );
  }
}

class _InterviewCard extends StatelessWidget {
  final InterviewEntity interview;
  final VoidCallback? onEdit;

  const _InterviewCard({required this.interview, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (interview.status) {
      'completed' => const Color(0xFF10B981),
      'cancelled' => AppColors.slate400,
      _ => AppColors.violet,
    };
    final statusLabel = switch (interview.status) {
      'completed' => 'Terminé',
      'cancelled' => 'Annulé',
      _ => 'Planifié',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date badge
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFEFEDF2),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  interview.scheduledDate.day.toString(),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.violet,
                  ),
                ),
                Text(
                  interview.formattedDate.split(' ').last,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: AppColors.slate600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  interview.jobTitle,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF1D1B1F),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_outlined,
                        size: 13, color: AppColors.slate600),
                    const SizedBox(width: 4),
                    Text(
                      interview.formattedTime,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: AppColors.slate600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            GestureDetector(
              onTap: onEdit,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEDF2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit_outlined,
                    size: 16, color: AppColors.violet),
              ),
            ),
        ],
      ),
    );
  }
}

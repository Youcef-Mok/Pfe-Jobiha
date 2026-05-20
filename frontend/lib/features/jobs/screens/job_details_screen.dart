import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/candidates/data/providers/candidates_provider.dart';
import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';
import 'package:job_app/features/jobs/screens/edit_job_screen.dart';
import 'package:job_app/features/jobs/widgets/recruiter_filter_bar.dart';
import 'package:job_app/features/applications/data/providers/applications_provider.dart';
import 'package:job_app/features/applications/widgets/recruiter_applications_list_body.dart';
import 'package:job_app/features/applications/widgets/application_details_sheet.dart';
import 'package:job_app/features/applications/widgets/compact_application_card.dart';
import 'package:job_app/features/interviews/data/providers/interviews_provider.dart';
import 'package:job_app/features/interviews/widgets/compact_interview_card.dart';
import 'package:job_app/features/interviews/widgets/edit_interview_sheet.dart';
import 'package:job_app/features/interviews/widgets/recruiter_interviews_list_body.dart';

// ─────────────────────────────────────────────
// Entry-point: show the job details overlay
// ─────────────────────────────────────────────
void showJobDetailsSheet(BuildContext context, JobEntity job) {
  final container = ProviderScope.containerOf(context);
  container.read(currentJobIdProvider.notifier).state = job.id;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => JobDetailsSheet(job: job),
  );
}

void showJobApplicationsOverlay(
  BuildContext context,
  WidgetRef ref,
  JobEntity job,
) {
  final previousTab = ref.read(jobsTabProvider);
  final previousFilters = ref.read(recruiterFiltersProvider);

  ref.read(jobsTabProvider.notifier).state = JobsTab.applications;
  ref.read(recruiterFiltersProvider.notifier).setJobId(job.id);

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final height = MediaQuery.sizeOf(ctx).height * 0.92;
      return Container(
        height: height,
        decoration: const BoxDecoration(
          color: Color(0xFFF6F3F8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close, color: AppColors.slate600),
                  ),
                  Expanded(
                    child: Text(
                      'Candidatures — ${job.title}',
                      style: AppTextStyles.labelBold.copyWith(
                        fontSize: 16,
                        color: AppColors.slate900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const RecruiterFilterBar(forcedTab: JobsTab.applications),
            const Expanded(child: RecruiterApplicationsListBody()),
          ],
        ),
      );
    },
  ).whenComplete(() {
    ref.read(jobsTabProvider.notifier).state = previousTab;
    ref.read(recruiterFiltersProvider.notifier).apply(previousFilters);
  });
}

void showJobInterviewsOverlay(
  BuildContext context,
  WidgetRef ref,
  JobEntity job,
) {
  final previousTab = ref.read(jobsTabProvider);
  final previousFilters = ref.read(recruiterFiltersProvider);

  ref.read(jobsTabProvider.notifier).state = JobsTab.interviews;
  ref.read(recruiterFiltersProvider.notifier).setJobId(job.id);

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final height = MediaQuery.sizeOf(ctx).height * 0.92;
      return Container(
        height: height,
        decoration: const BoxDecoration(
          color: Color(0xFFF6F3F8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close, color: AppColors.slate600),
                  ),
                  Expanded(
                    child: Text(
                      'Entretiens — ${job.title}',
                      style: AppTextStyles.labelBold.copyWith(
                        fontSize: 16,
                        color: AppColors.slate900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const RecruiterFilterBar(forcedTab: JobsTab.interviews),
            const Expanded(child: RecruiterInterviewsListBody()),
          ],
        ),
      );
    },
  ).whenComplete(() {
    ref.read(jobsTabProvider.notifier).state = previousTab;
    ref.read(recruiterFiltersProvider.notifier).apply(previousFilters);
  });
}

// ─────────────────────────────────────────────
// JobDetailsSheet – root widget
// ─────────────────────────────────────────────
class JobDetailsSheet extends ConsumerWidget {
  final JobEntity job;
  const JobDetailsSheet({super.key, required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.94,
      decoration: const BoxDecoration(
        color: Color(0xFFF6F3F8),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _HeroSection(job: job),
          Expanded(
            child: _JobDetailsScrollBody(job: job),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Hero Section  (image + gradient + metadata + pencil btn)
// ─────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final JobEntity job;
  const _HeroSection({required this.job});

  @override
  Widget build(BuildContext context) {
    final postedDate = DateFormat('d MMM. yyyy', 'fr_FR').format(job.postedAt);
    final contractLabel = switch (job.contractType) {
      ContractType.cdi => 'CDI',
      ContractType.mission => 'Mission',
      ContractType.freelance => 'Freelance',
    };

    return SizedBox(
      height: 210,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              image: job.logoAsset != null
                  ? DecorationImage(
                      image: AssetImage(job.logoAsset!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),
          // Gradient overlay (bottom dark fade)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x00000000), Color(0x99000000)],
              ),
            ),
          ),
          // Text content
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Posté le $postedDate',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // Job title
                Text(
                  job.title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    height: 1.33,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // Location + contract
                Row(
                  children: [
                    Text(
                      '${job.companyName} • $contractLabel 6 mois',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Color(0xE6FFFFFF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Pencil / edit button (top right)
          Positioned(
            top: 6,
            right: 8,
            child: GestureDetector(
              onTap: () => _openEditOverlay(context),
              child: Container(
                width: 49,
                height: 27,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A1B5E),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 15,
                      offset: Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.edit, size: 14, color: Colors.white),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  void _openEditOverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.94,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: EditJobScreen(job: job),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Corps scrollable : candidatures → entretiens → commentaires
// ─────────────────────────────────────────────
class _JobDetailsScrollBody extends ConsumerWidget {
  final JobEntity job;
  const _JobDetailsScrollBody({required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ApplicationsCarousel(job: job),
          const SizedBox(height: 2),
          _InterviewsSection(job: job),
          const SizedBox(height: 5),
          _CommentairesSection(job: job),
        ],
      ),
    );
  }
}

class _ApplicationsCarousel extends ConsumerWidget {
  final JobEntity job;
  const _ApplicationsCarousel({required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(jobDetailApplicationsProvider(job.id));

    return appsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Erreur: $e'),
      data: (applications) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dernières candidatures',
                  style: const TextStyle(
                    fontFamily: 'Josefin Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (applications.isNotEmpty)
                  GestureDetector(
                    onTap: () =>
                        showJobApplicationsOverlay(context, ref, job),
                    child: const Text(
                      'Voir toutes',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF401E66),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (applications.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Aucune candidature pour le moment.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 170,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: applications.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final app = applications[index];
                    final cardWidth = MediaQuery.sizeOf(context).width * 0.9;
                    return SizedBox(
                      width: cardWidth,
                      child: CompactApplicationCard(
                        application: app,
                        dense: false,
                        onAccept: () => ref
                            .read(applicationsNotifierProvider.notifier)
                            .accept(app.id),
                        onReject: () => ref
                            .read(applicationsNotifierProvider.notifier)
                            .reject(app.id),
                        onTap: () =>
                            showApplicationDetailsSheet(context, app),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _InterviewsSection extends ConsumerWidget {
  final JobEntity job;
  const _InterviewsSection({required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interviewsAsync = ref.watch(jobDetailInterviewsProvider(job.id));

    return interviewsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (interviews) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Entretiens prévus',
                  style: TextStyle(
                    fontFamily: 'Josefin Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (interviews.isNotEmpty)
                  GestureDetector(
                    onTap: () =>
                        showJobInterviewsOverlay(context, ref, job),
                    child: const Text(
                      'Voir toutes',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF401E66),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (interviews.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
                ),
                child: const Center(
                  child: Text(
                    'Aucun entretien planifié',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
              )
            else
              ...interviews.map(
                (interview) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CompactInterviewCard(
                    interview: interview,
                    onTap: () =>
                        showEditInterviewSheet(context, interview),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CommentairesSection extends StatefulWidget {
  final JobEntity job;
  const _CommentairesSection({required this.job});

  @override
  State<_CommentairesSection> createState() => _CommentairesSectionState();
}

class _CommentairesSectionState extends State<_CommentairesSection> {
  bool _onlyUnanswered = false;

  @override
  Widget build(BuildContext context) {
    final comments = _onlyUnanswered
        ? widget.job.comments.where((c) => c.reply.trim().isEmpty).toList()
        : widget.job.comments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${comments.length} Commentaires',
              style: const TextStyle(
                fontFamily: 'Josefin Sans',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Color(0xFF0F172A),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() => _onlyUnanswered = !_onlyUnanswered),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _onlyUnanswered
                      ? AppColors.violet
                      : const Color(0xFFEFEDF2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Non répondus',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: _onlyUnanswered ? Colors.white : AppColors.violet,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
          ),
          child: comments.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'Aucun commentaire pour le moment.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                )
              : Column(
                  children: comments.asMap().entries.map((entry) {
                    final index = entry.key;
                    final comment = entry.value;
                    return Column(
                      children: [
                        if (index > 0) const SizedBox(height: 16),
                        _CommentCard(comment: comment, grouped: true),
                      ],
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}

class _CommentCard extends StatelessWidget {
  final JobCommentEntity comment;
  final bool grouped;
  const _CommentCard({required this.comment, this.grouped = false});

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      width: grouped ? double.infinity : null,
      constraints: grouped
          ? null
          : const BoxConstraints(maxWidth: 400),
      padding: EdgeInsets.symmetric(
        horizontal: grouped ? 8 : 10,
        vertical: grouped ? 10 : 15,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBFF),
        border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: avatar + name + date
          Row(
            children: [
              // Avatar initials
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEFEDF2),
                ),
                alignment: Alignment.center,
                child: Text(
                  comment.initials,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF401E66),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.authorName,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 1.43,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    comment.date,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      height: 1.33,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Comment text
          Text(
            '"${comment.question}"',
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
              fontSize: 13,
              height: 1.54,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          if (comment.reply.trim().isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
              decoration: BoxDecoration(
                color: const Color(0x0D7F13EC),
                border: const Border(
                  left: BorderSide(color: Color(0xFF401E66), width: 2),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        comment.recruitorLabel,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Color(0xFF401E66),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Ma r?ponse',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment.reply,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      height: 1.33,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
          if (comment.reply.trim().isEmpty) ...[
            const SizedBox(height: 8),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFEEEBF4), width: 1),
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const SizedBox(
                height: 33,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '?crire une r?ponse...',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.send,
                      size: 16,
                      color: Color(0xFF401E66),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (grouped) return cardContent;
    return Align(
      alignment: Alignment.center,
      child: cardContent,
    );
  }
}

// ─────────────────────────────────────────────
// Kept for backward compatibility — redirects to overlay
// ─────────────────────────────────────────────
class JobDetailsScreen extends StatelessWidget {
  final JobEntity job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pop();
      showJobDetailsSheet(context, job);
    });
    return const SizedBox.shrink();
  }
}

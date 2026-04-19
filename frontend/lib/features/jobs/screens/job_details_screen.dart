import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/features/candidates/domain/candidate_entity.dart';
import 'package:job_app/features/candidates/data/providers/candidates_provider.dart';
import 'package:job_app/features/candidates/widgets/candidate_card.dart';
import 'package:job_app/features/candidates/widgets/candidate_detail_sheet.dart';
import 'package:job_app/features/jobs/screens/edit_job_screen.dart';

// ─────────────────────────────────────────────
// Provider: active tab for the job details overlay
// ─────────────────────────────────────────────
enum JobDetailTab { candidatures, commentaires, messagerie }

final jobDetailTabProvider =
    StateProvider.autoDispose<JobDetailTab>((ref) => JobDetailTab.candidatures);

// ─────────────────────────────────────────────
// Entry-point: show the job details overlay
// ─────────────────────────────────────────────
void showJobDetailsSheet(BuildContext context, JobEntity job) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => JobDetailsSheet(job: job),
  );
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
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // ── Hero banner ──────────────────────
          _HeroSection(job: job),

          // ── Bottom tab bar ───────────────────
          _TabBar(job: job),

          // ── Content area ─────────────────────
          Expanded(
            child: _TabBody(job: job),
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 192,
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
                    // Status badge + posted date
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F0F8),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            _statusLabel(job.status),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              letterSpacing: 0.6,
                              color: Color(0xFF401E66),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Posté le $postedDate',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Color(0xCCFFFFFF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Job title
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        height: 1.33,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Location + contract
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: Color(0xE6FFFFFF)),
                        const SizedBox(width: 6),
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
                    child: const Icon(Icons.edit,
                        size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(JobStatus s) => switch (s) {
        JobStatus.searching => 'SEARCHING',
        JobStatus.draft => 'BROUILLON',
        JobStatus.closed => 'FERMÉ',
      };

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
// Tab Bar  (Candidatures | Commentaires | Messagerie)
// ─────────────────────────────────────────────
class _TabBar extends ConsumerWidget {
  final JobEntity job;
  const _TabBar({required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(jobDetailTabProvider);

    Widget tabBtn(String label, JobDetailTab tab) {
      final active = current == tab;
      return Expanded(
        child: GestureDetector(
          onTap: () => ref.read(jobDetailTabProvider.notifier).state = tab,
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: active ? const Color(0xFF401E66) : const Color(0xFFF6F3F8),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Josefin Sans',
                fontWeight: FontWeight.w700,
                fontSize: 13,
                height: 20 / 13,
                color: active ? Colors.white : const Color(0xFF434551),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.fromLTRB(7, 0, 7, 5),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFCCC3D0)),
          bottom: BorderSide(color: Color(0xFFCCC3D0)),
        ),
      ),
      child: Row(
        children: [
          tabBtn('Candidatures', JobDetailTab.candidatures),
          const SizedBox(width: 12),
          tabBtn('Commentaires', JobDetailTab.commentaires),
          const SizedBox(width: 12),
          tabBtn('Messagerie', JobDetailTab.messagerie),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tab Body – switches based on active tab
// ─────────────────────────────────────────────
class _TabBody extends ConsumerWidget {
  final JobEntity job;
  const _TabBody({required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(jobDetailTabProvider);

    return switch (tab) {
      JobDetailTab.candidatures => _CandidaturesTab(job: job),
      JobDetailTab.commentaires => _CommentairesTab(job: job),
      JobDetailTab.messagerie => _MessagerieTab(job: job),
    };
  }
}

// ═══════════════════════════════════════════════
// TAB 1 – CANDIDATURES
// Shows a 2-column grid of candidate cards (same CandidateCard from candidates feature)
// ═══════════════════════════════════════════════
class _CandidaturesTab extends ConsumerWidget {
  final JobEntity job;
  const _CandidaturesTab({required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidatesAsync = ref.watch(candidatesNotifierProvider);

    return candidatesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
      data: (allCandidates) {
        // Show nouveau candidates; fall back to job's embedded list stub
        final displayed = allCandidates
            .where((c) => c.status == CandidateStatus.nouveau)
            .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Count row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${displayed.length} Candidats',
                    style: const TextStyle(
                      fontFamily: 'Josefin Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 20 / 14,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const Icon(Icons.filter_list,
                      size: 15, color: Color(0xFF94A3B8)),
                ],
              ),
              const SizedBox(height: 12),

              if (displayed.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
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
                // 2-column grid using the existing CandidateCard
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 181 / 177,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: displayed.length,
                  itemBuilder: (ctx, i) {
                    final candidate = displayed[i];
                    return CandidateCard(
                      candidate: candidate,
                      onTap: () {
                        showModalBottomSheet(
                          context: ctx,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          isDismissible: true,
                          builder: (context) => Padding(
                            padding: EdgeInsets.only(
                              bottom:
                                  MediaQuery.of(context).viewInsets.bottom +
                                      24,
                              left: 16,
                              right: 16,
                            ),
                            child: Material(
                              type: MaterialType.transparency,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                children: [
                                  CandidateDetailSheet(
                                      candidate: candidate),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      onArchive: () {
                        final newStatus =
                            candidate.status == CandidateStatus.archive
                                ? CandidateStatus.nouveau
                                : CandidateStatus.archive;
                        ref
                            .read(candidatesNotifierProvider.notifier)
                            .updateStatus(candidate.id, newStatus);
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════
// TAB 2 – COMMENTAIRES
// Same comment card design as profile reviews section
// ═══════════════════════════════════════════════
class _CommentairesTab extends StatelessWidget {
  final JobEntity job;
  const _CommentairesTab({required this.job});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Count row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${job.comments.length} Commentaires',
                style: const TextStyle(
                  fontFamily: 'Josefin Sans',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  height: 20 / 14,
                  color: Color(0xFF0F172A),
                ),
              ),
              const Icon(Icons.filter_list,
                  size: 15, color: Color(0xFF94A3B8)),
            ],
          ),
          const SizedBox(height: 10),

          if (job.comments.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
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
          else
            Column(
              children: job.comments.asMap().entries.map((entry) {
                final index = entry.key;
                final comment = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == job.comments.length - 1 ? 0 : 10,
                  ),
                  child: _CommentCard(comment: comment),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final JobCommentEntity comment;
  const _CommentCard({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 15, 5, 15),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBFF),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFF6F3F8)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
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
                  color: const Color(0xFFF6F3F8),
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
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Text(
              comment.question,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 1.43,
                color: Color(0xFF475569),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Recruiter reply block
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
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
                // Recruiter name + date
                Row(
                  children: [
                    Text(
                      comment.recruitorLabel,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        height: 1.33,
                        color: Color(0xFF401E66),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.recruitorDate,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        height: 1.33,
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
          // Reply input (always shown for unanswered or quick reply)
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0x0D7F13EC),
              border: const Border(
                top: BorderSide(color: Color(0x1A7F13EC)),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0x337F13EC),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: const Icon(Icons.edit,
                      size: 12, color: Color(0xFF7F13EC)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      children: const [
                        Expanded(
                          child: Text(
                            'Écrire une réponse...',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                        Icon(Icons.send,
                            size: 16, color: Color(0xFF7F13EC)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// TAB 3 – MESSAGERIE
// List of message preview items
// ═══════════════════════════════════════════════
class _MessagerieTab extends StatelessWidget {
  final JobEntity job;
  const _MessagerieTab({required this.job});

  static const _messages = [
    _MessageItem(
      name: 'Sarah Jenkins',
      subtitle: 'HR @ TechCorp',
      preview: "We'd like to schedule an interview f…",
      time: '2m',
      isOnline: true,
      isUnread: true,
      initials: 'SJ',
    ),
    _MessageItem(
      name: 'Marcus Chen',
      subtitle: '',
      preview: "Thanks for the referral! I'll check out the po…",
      time: '1h',
      isOnline: false,
      isUnread: false,
      initials: 'MC',
    ),
    _MessageItem(
      name: 'Elena Rodriguez',
      subtitle: 'Creative Lead',
      preview: "The portfolio you shared is impressi…",
      time: '3h',
      isOnline: false,
      isUnread: true,
      initials: 'ER',
    ),
    _MessageItem(
      name: 'David Smith',
      subtitle: '',
      preview: "Checking in on your application status for …",
      time: 'Hier',
      isOnline: false,
      isUnread: false,
      initials: 'DS',
    ),
    _MessageItem(
      name: 'Product Design Team',
      subtitle: '',
      preview: "Alex: Let's meet in the lobby at 10 AM.",
      time: 'Mer',
      isOnline: false,
      isUnread: false,
      initials: 'PD',
      isGroup: true,
    ),
    _MessageItem(
      name: 'Jordan Lee',
      subtitle: '',
      preview: "It was great meeting you at the networkin…",
      time: '24 Oct',
      isOnline: false,
      isUnread: false,
      initials: 'JL',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Count label
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              '${_messages.length} messages',
              style: const TextStyle(
                fontFamily: 'Josefin Sans',
                fontWeight: FontWeight.w700,
                fontSize: 14,
                height: 20 / 14,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(height: 4),
          ..._messages.asMap().entries.map((e) {
            final idx = e.key;
            final msg = e.value;
            return _MessageRow(
              item: msg,
              showTopBorder: idx > 0,
            );
          }),
        ],
      ),
    );
  }
}

class _MessageItem {
  final String name;
  final String subtitle;
  final String preview;
  final String time;
  final bool isOnline;
  final bool isUnread;
  final String initials;
  final bool isGroup;

  const _MessageItem({
    required this.name,
    required this.subtitle,
    required this.preview,
    required this.time,
    required this.isOnline,
    required this.isUnread,
    required this.initials,
    this.isGroup = false,
  });
}

class _MessageRow extends StatelessWidget {
  final _MessageItem item;
  final bool showTopBorder;
  const _MessageRow({required this.item, required this.showTopBorder});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: showTopBorder
            ? const Border(
                top: BorderSide(color: Color(0x0D7F0DF2)),
              )
            : null,
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.isGroup
                      ? const Color(0x337F0DF2)
                      : const Color(0xFFE2D4F0),
                ),
                alignment: Alignment.center,
                child: item.isGroup
                    ? const Icon(Icons.group_outlined,
                        size: 22, color: Color(0xFF401E66))
                    : Text(
                        item.initials,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Color(0xFF401E66),
                        ),
                      ),
              ),
              if (!item.isGroup)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: item.isOnline
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFCBD5E1),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFFF7F5F8), width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Name row + time
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              height: 1.5,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          if (item.subtitle.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Text(
                              '· ${item.subtitle}',
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                height: 1.33,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      item.time,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        height: 1.33,
                        color: item.isUnread
                            ? const Color(0xFF401E66)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                // Preview row + unread dot
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.preview,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: item.isUnread
                              ? FontWeight.w600
                              : FontWeight.w400,
                          fontSize: 14,
                          height: 1.43,
                          color: item.isUnread
                              ? const Color(0xFF334155)
                              : const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.isUnread) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF401E66),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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

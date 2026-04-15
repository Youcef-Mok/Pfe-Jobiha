import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/core/theme/app_theme.dart';

// ─────────────────────────────────────────────
// Overlay centré pour les jobs en recherche
// ─────────────────────────────────────────────
void showJobDetailsSheet(BuildContext context, JobEntity job) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => JobDetailsSheet(job: job),
  );
}

class JobDetailsSheet extends StatelessWidget {
  final JobEntity job;
  const JobDetailsSheet({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: _HeroSection(job: job),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _StatsBar(job: job),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _CandidatesSection(job: job),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _CommentsSection(job: job),
                    ),
                  ],
                ),
              ),
            ),
            // Bouton fermer (croix)
            Positioned(
              top: 3,
              right: 7,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close,
                    color: AppColors.slate400, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.slate100,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kept for backward compatibility — redirects to overlay
class JobDetailsScreen extends StatelessWidget {
  final JobEntity job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    // Show the overlay and pop this route immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pop();
      showJobDetailsSheet(context, job);
    });
    return const SizedBox.shrink();
  }
}

// ─────────────────────────────────────────────
// Hero Section
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 192,
        decoration: BoxDecoration(
          color: const Color(0xFF334155),
          image: job.logoAsset != null
              ? DecorationImage(
                  image: job.logoAsset!.startsWith('http')
                      ? NetworkImage(job.logoAsset!) as ImageProvider
                      : AssetImage(job.logoAsset!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x00000000), Color(0x99000000)],
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC1AA62),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: const Text(
                      'EN COURS',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 0.6,
                        color: Color(0xFF4E3E00),
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
                      fontSize: 14,
                      color: Color(0xE6FFFFFF),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Stats Bar
// ─────────────────────────────────────────────
class _StatsBar extends StatelessWidget {
  final JobEntity job;

  const _StatsBar({required this.job});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
            icon: Icons.people_outline,
            value: '${job.candidateCount}',
            label: 'Candidatures'),
        const SizedBox(width: 20),
        _StatCard(
            icon: Icons.chat_bubble_outline, value: '4', label: 'Messages'),
        const SizedBox(width: 16),
        _StatCard(
            icon: Icons.remove_red_eye_outlined,
            value: '${job.viewCount}',
            label: "Vues de l'annonce"),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: AppColors.violet),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: AppColors.violet,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 11,
                color: Color(0xFF4A454F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Candidates Section
// ─────────────────────────────────────────────
class _CandidatesSection extends StatelessWidget {
  final JobEntity job;

  const _CandidatesSection({required this.job});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Candidatures',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Color(0xFF1E293B),
              ),
            ),
            if (job.candidates.isNotEmpty)
              const Text(
                'See all',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.violet,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (job.candidates.isEmpty)
          const Text(
            'Aucune candidature pour le moment.',
            style: TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFF64748B),
              fontSize: 14,
            ),
          )
        else
          ...job.candidates.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CandidateCard(candidate: c),
            ),
          ),
      ],
    );
  }
}

class _CandidateCard extends StatelessWidget {
  final JobCandidateEntity candidate;

  const _CandidateCard({required this.candidate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF8FAFC)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF513376),
                  shape: BoxShape.circle,
                  image: candidate.avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(candidate.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: candidate.avatarUrl == null
                    ? Center(
                        child: Text(
                          candidate.initials,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  candidate.name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  candidate.role,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 13, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 4),
                    Text(
                      '${candidate.rating}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.chat_bubble_outline,
                size: 20, color: Color(0xFF513376)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Comments Section
// ─────────────────────────────────────────────
class _CommentsSection extends StatelessWidget {
  final JobEntity job;

  const _CommentsSection({required this.job});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Commentaires',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 18),
          if (job.comments.isEmpty)
            const Text(
              'Aucun commentaire pour le moment.',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF64748B),
                fontSize: 14,
              ),
            )
          else
            ...job.comments.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _CommentItem(comment: c),
              ),
            ),
        ],
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  final JobCommentEntity comment;

  const _CommentItem({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFFE4E4E7),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              comment.initials,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: Color(0xFF52525B),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Bulle question
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F3F8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          comment.authorName,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xFF1D1B1F),
                          ),
                        ),
                        Text(
                          comment.date,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 10,
                            color: Color(0xFF4A454F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.question,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        height: 1.43,
                        color: Color(0xFF4A454F),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Réponse recruteur avec bordure violette gauche
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(left: 16),
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Color(0xFF513376), width: 2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.recruitorLabel,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            color: Color(0xFF3A1B5E),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          comment.recruitorDate,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 10,
                            color: Color(0xFF4A454F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.reply,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        height: 1.33,
                        color: Color(0xFF4A454F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

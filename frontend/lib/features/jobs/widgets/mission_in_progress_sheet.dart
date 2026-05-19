import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:job_app/features/jobs/domain/mission_entity.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/jobs/screens/end_mission_screen.dart';

/// Overlay centré pour les missions en cours et terminées.
void showMissionInProgressSheet(BuildContext context, MissionEntity mission) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => MissionInProgressSheet(mission: mission),
  );
}

void showCompletedMissionSheet(BuildContext context, MissionEntity mission) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CompletedMissionSheet(mission: mission),
  );
}

class MissionInProgressSheet extends StatelessWidget {
  final MissionEntity mission;
  const MissionInProgressSheet({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
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
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              child: _InProgressMissionView(mission: mission),
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
            // Bouton fixe en bas
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EndMissionScreen(mission: mission),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.violet,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Mettre fin à la mission',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InProgressMissionView extends StatelessWidget {
  final MissionEntity mission;
  const _InProgressMissionView({required this.mission});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MissionHeader(mission: mission),
        _MissionBody(mission: mission),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Header (Commun)
// ─────────────────────────────────────────────
class _MissionHeader extends StatelessWidget {
  final MissionEntity mission;
  const _MissionHeader({required this.mission});

  @override
  Widget build(BuildContext context) {
    final dateRange = '${_fmt(mission.startDate)} — ${_fmt(mission.endDate)}';

    return SizedBox(
      height: 153,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 9.75,
            child: _StatusBadge(status: mission.status),
          ),
          Positioned(
            top: 41,
            left: 8,
            child: Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: AppColors.slate100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: mission.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        mission.imageUrl!,
                        width: 75,
                        height: 75,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.restaurant, size: 32, color: AppColors.slate400),
                      ),
                    )
                  : const Icon(Icons.restaurant,
                      size: 32, color: AppColors.slate400),
            ),
          ),
          Positioned(
            top: 35,
            left: 104,
            right: 16,
            child: Text(
              mission.jobTitle,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w800,
                fontSize: 24, // Taille réduite pour le format overlay
                height: 1.25,
                color: Color(0xFF331554),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Positioned(
            top: 67, // Ajusté pour le titre en 24px
            left: 104,
            right: 26,
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 12, color: Color(0xFF4A454F)),
                const SizedBox(width: 4),
                Text(
                  dateRange,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color(0xFF4A454F),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 87,
            left: 104,
            right: 26,
            child: Row(
              children: [
                const Icon(Icons.business_outlined,
                    size: 12, color: AppColors.slate600),
                const SizedBox(width: 4),
                Text(
                  mission.companyName,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppColors.slate600,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 107,
            left: 104,
            right: 26,
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 12, color: AppColors.slate300),
                const SizedBox(width: 4),
                Text(
                  mission.location,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: AppColors.slate300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) => DateFormat('d MMM yyyy', 'fr_FR').format(d);
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor, label) = switch (status) {
      'in_progress' => (const Color(0xFFEEDCFD), AppColors.violet, 'EN COURS'),
      'completed' => (const Color(0xFFDCFCE7), const Color(0xFF15803D), 'MISSION TERMINÉE'),
      _ => (const Color(0xFFEEDCFD), AppColors.violet, 'EN COURS'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 0.6,
          color: textColor,
        ),
      ),
    );
  }
}

class _MissionBody extends StatelessWidget {
  final MissionEntity mission;
  const _MissionBody({required this.mission});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Équipe sur place',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          ...mission.team.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _EmployeeCard(member: m),
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final MissionMemberEntity member;
  const _EmployeeCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 94),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF8FAFC)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.slate100,
                  shape: BoxShape.circle,
                ),
                child: member.avatarUrl != null
                    ? ClipOval(
                        child: Image.asset(
                          member.avatarUrl!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              member.name[0],
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: AppColors.violet,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          member.name[0],
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: AppColors.violet,
                          ),
                        ),
                      ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  member.role,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: AppColors.slate300,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 14, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 4),
                    Text(
                      member.rating.toStringAsFixed(1),
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
              color: AppColors.slate100,
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
// Overlay pour missions TERMINÉES
// ─────────────────────────────────────────────
class CompletedMissionSheet extends StatelessWidget {
  final MissionEntity mission;
  const CompletedMissionSheet({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFFF7F6F8),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 30, bottom: 16),
                  child: _CompletedMissionView(mission: mission),
                ),
              ),
              // Fixed bottom button
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF401E66),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Valider fin mission',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Close button - floating on top
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.slate200,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: AppColors.slate600, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedMissionView extends StatelessWidget {
  final MissionEntity mission;
  const _CompletedMissionView({required this.mission});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CompletedMissionHeader(mission: mission),
        _CompletedMissionBody(mission: mission),
      ],
    );
  }
}

class _CompletedMissionHeader extends StatelessWidget {
  final MissionEntity mission;
  const _CompletedMissionHeader({required this.mission});

  @override
  Widget build(BuildContext context) {
    final dateRange = '${_fmt(mission.startDate)} — ${_fmt(mission.endDate)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: mission.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      mission.imageUrl!,
                      width: 75,
                      height: 75,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.restaurant, size: 32, color: AppColors.slate400),
                    ),
                  )
                : const Icon(Icons.restaurant,
                    size: 32, color: AppColors.slate400),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  mission.jobTitle,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                    height: 1.25,
                    color: Color(0xFF331554),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Date
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 12, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      dateRange,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        height: 1.43,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Company
                Row(
                  children: [
                    const Icon(Icons.business_outlined,
                        size: 12, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      mission.companyName,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        height: 1.43,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      mission.location,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        height: 1.43,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) => DateFormat('d MMM yyyy', 'fr_FR').format(d);
}

class _CompletedMissionBody extends StatelessWidget {
  final MissionEntity mission;
  const _CompletedMissionBody({required this.mission});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Équipe sur place
          Row(
            children: [
              const Icon(Icons.people_outline,
                  size: 20, color: Color(0xFF401E66)),
              const SizedBox(width: 8),
              const Text(
                'Équipe sur place',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...mission.team.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _EmployeeCard(member: m),
              )),
          const SizedBox(height: 16),
          // Évaluations
          Row(
            children: [
              const Icon(Icons.star_rounded,
                  size: 20, color: Color(0xFF401E66)),
              const SizedBox(width: 10),
              const Text(
                'Évaluations candidat/recruteur',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Évaluation candidat
          _EvaluationCard(
            title: 'Évaluation Candidat',
            subtitle: 'Feedback en cours',
            rating: mission.candidateRating,
            feedback: mission.candidateFeedback,
            bgColor: const Color(0xFFF6F3F8),
            isRecruiter: false,
            candidateAvatar: mission.team.isNotEmpty ? mission.team[0].avatarUrl : null,
            candidateName: mission.team.isNotEmpty ? mission.team[0].name : 'Candidat',
          ),
          const SizedBox(height: 12),
          // Évaluation recruteur
          _EvaluationCard(
            title: 'Évaluation Recruteur',
            subtitle: 'Par ${mission.companyName}',
            rating: mission.recruiterRating,
            feedback: mission.recruiterFeedback,
            bgColor: Colors.white,
            isRecruiter: true,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _EvaluationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double rating;
  final String feedback;
  final Color bgColor;
  final bool isRecruiter;
  final String? candidateAvatar;
  final String? candidateName;

  const _EvaluationCard({
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.feedback,
    required this.bgColor,
    required this.isRecruiter,
    this.candidateAvatar,
    this.candidateName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: isRecruiter
            ? Border.all(color: const Color(0xFFF8FAFC))
            : Border.all(color: const Color(0xFF513376).withValues(alpha: 0.1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + title row
          Row(
            children: [
              if (!isRecruiter)
                // Candidate: circular photo avatar
                SizedBox(
                  width: 48,
                  height: 48,
                  child: ClipOval(
                    child: candidateAvatar != null
                        ? Image.asset(
                            candidateAvatar!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFF6F3F8),
                              child: Center(
                                child: Text(
                                  candidateName?[0] ?? 'C',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: Color(0xFF401E66),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: const Color(0xFFF6F3F8),
                            child: Center(
                              child: Text(
                                candidateName?[0] ?? 'C',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color: Color(0xFF401E66),
                                ),
                              ),
                            ),
                          ),
                  ),
                )
              else
                // Recruiter: store icon in orange circle
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFEDD5)),
                  ),
                  child: const Icon(
                    Icons.store_outlined,
                    color: Color(0xFFFB923C),
                    size: 22,
                  ),
                ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 1.43,
                      color: Color(0xFF513376),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      height: 1.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Stars + rating
          Row(
            children: [
              ...List.generate(5, (i) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.star_rounded,
                  size: 15,
                  color: i < rating.floor()
                      ? const Color(0xFF6E14C7)
                      : const Color(0xFFCBD5E1),
                ),
              )),
              const SizedBox(width: 8),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  height: 1.5,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Feedback text
          Text(
            feedback,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              fontSize: 12,
              height: 1.62,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:job_app/features/jobs/domain/mission_entity.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/jobs/screens/end_mission_screen.dart';

class MissionDetailsScreen extends StatelessWidget {
  final MissionEntity mission;
  /// Libellés type « Employés » vs vocabulaire candidat.
  final bool isRecruiterMissionDetail;

  const MissionDetailsScreen({
    super.key,
    required this.mission,
    this.isRecruiterMissionDetail = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _TopAppBar(
              title: 'Détail de la mission',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                child: _CompletedMissionView(
                  mission: mission,
                  isRecruiterMissionDetail: isRecruiterMissionDetail,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(35),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x0A000000),
                offset: Offset(0, -4),
                blurRadius: 16,
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EndMissionScreen(mission: mission),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF401E66),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Notez la mission',
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
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Top App Bar (consistent with other screens)
// ─────────────────────────────────────────────
class _TopAppBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  const _TopAppBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0x1A8B5CF6)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: AppColors.slate900),
            onPressed: onBack,
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 48),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Vue pour les missions terminées (design premium)
class _CompletedMissionView extends StatelessWidget {
  final MissionEntity mission;
  final bool isRecruiterMissionDetail;

  const _CompletedMissionView({
    required this.mission,
    this.isRecruiterMissionDetail = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MissionHeader(mission: mission),
        
        // Section Équipe
        _MissionBody(
          mission: mission,
          isCompleted: true,
          isRecruiterMissionDetail: isRecruiterMissionDetail,
        ),

        // Section Évaluations préliminaires
        _PreliminaryEvaluations(
          mission: mission,
          isRecruiterMissionDetail: isRecruiterMissionDetail,
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Header : badge statut + grande image + titre
// ─────────────────────────────────────────────
class _MissionHeader extends StatelessWidget {
  final MissionEntity mission;
  const _MissionHeader({required this.mission});

  @override
  Widget build(BuildContext context) {
    final dateRange =
        '${_fmt(mission.startDate)} — ${_fmt(mission.endDate)}';

    return SizedBox(
      height: 153,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Badge statut (en haut à gauche)
          Positioned(
            top: 0,
            left: 9.75,
            child: _StatusBadge(status: mission.status),
          ),

          // Photo du lieu (carré arrondi)
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

          // Titre (grand, bold)
          Positioned(
            top: 35,
            left: 104,
            right: 16,
            child: Text(
              mission.jobTitle,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w800,
                fontSize: 36,
                height: 1.25,
                color: Color(0xFF331554),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Date range
          Positioned(
            top: 87,
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

          // Entreprise
          Positioned(
            top: 107,
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

          // Localisation
          Positioned(
            top: 127,
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

  String _fmt(DateTime d) =>
      DateFormat('d MMM yyyy', 'fr_FR').format(d);
}

// ─────────────────────────────────────────────
// Badge statut
// ─────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      'completed' => 'TERMINÉE',
      'in_progress' => 'EN COURS',
      _ => status.toUpperCase(),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEEDCFD),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 0.6,
          color: status == 'completed' 
              ? const Color(0xFF6D5F7B)
              : AppColors.violet,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Body : équipe + CTA
// ─────────────────────────────────────────────
class _MissionBody extends StatelessWidget {
  final MissionEntity mission;
  final bool isCompleted;
  final bool isRecruiterMissionDetail;

  const _MissionBody({
    required this.mission,
    this.isCompleted = false,
    this.isRecruiterMissionDetail = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRecruiterMissionDetail ? 'Employés' : 'Équipe sur place',
            style: const TextStyle(
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
      padding: const EdgeInsets.all(16),
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
            child: const Icon(Icons.chat_bubble_outline, size: 20, color: Color(0xFF513376)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Section Évaluations Préliminaires
// ─────────────────────────────────────────────
class _PreliminaryEvaluations extends StatelessWidget {
  final MissionEntity mission;
  final bool isRecruiterMissionDetail;

  const _PreliminaryEvaluations({
    required this.mission,
    this.isRecruiterMissionDetail = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Évaluations préliminaires',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          
          _EvaluationCard(
            title: 'Evaluation Candidat',
            subtitle: 'Feedback en cours',
            rating: mission.candidateRating,
            feedback: mission.candidateFeedback,
            isCustomBg: true,
          ),
          
          const SizedBox(height: 12),
          
          _EvaluationCard(
            title: isRecruiterMissionDetail
                ? 'Évaluation de l\'employeur'
                : 'Évaluation du Recruteur',
            subtitle: 'Feedback en cours',
            rating: mission.recruiterRating,
            feedback: mission.recruiterFeedback,
            icon: Icons.business_center_outlined,
            isCustomBg: false,
          ),
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
  final IconData? icon;
  final bool isCustomBg;

  const _EvaluationCard({
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.feedback,
    this.icon,
    this.isCustomBg = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isCustomBg ? const Color(0x0D513376) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCustomBg ? const Color(0x1A513376) : const Color(0xFFF8FAFC),
        ),
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
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCustomBg ? const Color(0x1A513376) : const Color(0xFFFFF7ED),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: icon != null 
                    ? Icon(icon, color: const Color(0xFFFB923C), size: 24)
                    : const Icon(Icons.person_outline, color: Color(0xFF513376), size: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: const Color(0xFF513376),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  index < rating.floor() ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: index < rating.floor() ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
                  size: 20,
                );
              }),
              const SizedBox(width: 8),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            feedback,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              fontSize: 12,
              height: 1.6,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}

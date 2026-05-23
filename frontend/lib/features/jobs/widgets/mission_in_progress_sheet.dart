import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:job_app/features/jobs/domain/mission_entity.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';
import 'package:job_app/features/jobs/screens/end_mission_screen.dart';
import 'package:job_app/features/messaging/data/providers/messaging_provider.dart';
import 'package:job_app/features/messaging/screens/private_message_screen.dart';

/// Overlay centré pour les missions en cours et terminées.
void showMissionInProgressSheet(
  BuildContext context,
  MissionEntity mission, {
  bool isRecruiterView = false,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => MissionInProgressSheet(
      mission: mission,
      isRecruiterView: isRecruiterView,
    ),
  );
}

void showCompletedMissionSheet(
  BuildContext context,
  MissionEntity mission, {
  bool isRecruiterView = false,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CompletedMissionSheet(
      mission: mission,
      isRecruiterView: isRecruiterView,
    ),
  );
}

class MissionInProgressSheet extends ConsumerWidget {
  final MissionEntity mission;
  final bool isRecruiterView;

  const MissionInProgressSheet({
    super.key,
    required this.mission,
    this.isRecruiterView = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFBFB),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 8, bottom: 60),
              child: _InProgressMissionView(
                mission: mission,
                isRecruiterView: isRecruiterView,
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
            // Bouton fixe en bas
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    if (mission.isUnconfirmed) {
                      await ref
                          .read(jobsControllerProvider)
                          .confirmMission(mission.id);
                      await ref
                          .read(missionsNotifierProvider.notifier)
                          .fetch();
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mission confirmée'),
                          ),
                        );
                      }
                    } else {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EndMissionScreen(mission: mission),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.violet,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    mission.isUnconfirmed
                        ? 'Confirmer la mission'
                        : 'Mettre fin à la mission',
                    style: const TextStyle(
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
  final bool isRecruiterView;

  const _InProgressMissionView({
    required this.mission,
    this.isRecruiterView = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MissionHeader(mission: mission),
        const SizedBox(height: 25),
        _MissionBody(mission: mission, isRecruiterView: isRecruiterView),
        const SizedBox(height: 27),
      ],
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Header (Commun)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _MissionHeader extends StatelessWidget {
  final MissionEntity mission;
  const _MissionHeader({required this.mission});

  @override
  Widget build(BuildContext context) {
    final dateRange = '${_fmt(mission.startDate)} "” ${_fmt(mission.endDate)}';

    return SizedBox(
      height:120,
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
                      child: mission.imageUrl!.startsWith('http')
                          ? Image.network(
                              mission.imageUrl!,
                              width: 75,
                              height: 75,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.restaurant, size: 32, color: AppColors.slate400),
                            )
                          : Image.asset(
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
                fontSize: 22, // Taille réduite pour le format overlay
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
                    fontSize: 16,
                    color: Color(0xFF475569),
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
                    fontSize: 16,
                    color: Color(0xFF475569),
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
                    fontSize: 16,
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
  final bool isRecruiterView;

  const _MissionBody({
    required this.mission,
    this.isRecruiterView = false,
  });

  @override
  Widget build(BuildContext context) {
    final recruiterMember = MissionMemberEntity(
      name: mission.recruiterName,
      role: mission.companyName,
      rating: mission.recruiterRating,
      avatarUrl: null,
    );

    final visibleTeam = isRecruiterView ? mission.team : <MissionMemberEntity>[recruiterMember];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description de la mission',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          _MissionSummaryCard(
            description: mission.description,
            summary: mission.summary,
          ),
          const SizedBox(height: 14),
          Text(
            isRecruiterView ? 'Employés' : 'Recruteur',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          ...visibleTeam.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: _RecruiterCard(member: m),
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _MissionSummaryCard extends StatelessWidget {
  final String description;
  final String? summary;

  const _MissionSummaryCard({
    required this.description,
    this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final raw = description.trim().isNotEmpty
        ? description.trim()
        : (summary ?? '').trim();
    final hasContent = raw.isNotEmpty;
    final objectives = raw
        .split(RegExp(r'[\n•\-]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .take(3)
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasContent ? raw : 'Aucune description fournie pour cette mission.',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 13,
              height: 1.45,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Objectifs',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          if (objectives.isEmpty)
            const Text(
              'Objectifs non renseignés.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            )
          else
            ...objectives.map(
              (objective) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(Icons.circle, size: 6, color: Color(0xFF401E66)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        objective,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          height: 1.4,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecruiterCard extends ConsumerWidget {
  final MissionMemberEntity member;
  const _RecruiterCard({required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Avatar with premium badge
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.slate100,
                    shape: BoxShape.circle,
                  ),
                  child: member.avatarUrl != null
                      ? ClipOval(
                          child: Image.asset(
                            member.avatarUrl!,
                            width: 47,
                            height: 47,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                member.name[0],
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
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
                              fontSize: 16,
                              color: AppColors.violet,
                            ),
                          ),
                        ),
                ),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Container(
                    width: 18,
                    height: 17.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC1AA62),
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      size: 8,
                      color: Color(0xFF4E3E00),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    height: 1.5,
                    color: Color(0xFF1D1B1F),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  member.role,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    height: 1.33,
                    color: Color(0xFF665976),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: Color(0xFF6F5D1D)),
                    const SizedBox(width: 4),
                    Text(
                      member.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        height: 1.43,
                        color: Color(0xFF1D1B1F),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Message button
          GestureDetector(
            onTap: () async {
              // Créer ou récupérer la conversation avec le recruteur
              final conversation = await ref
                  .read(messagingControllerProvider.notifier)
                  .getOrCreateConversation(
                    contactName: member.name,
                    contactRole: member.role,
                    contactAvatar: member.avatarUrl,
                  );
              
              // Fermer l'overlay actuel
              if (context.mounted) {
                Navigator.pop(context);
                
                // Naviguer vers la page de messagerie privée
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PrivateMessageScreen(conversation: conversation),
                  ),
                );
              }
            },
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFFEFEDF2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.message_outlined,
                  size: 16, color: AppColors.violet),
            ),
          ),
        ],
      ),
    );
  }
}


// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Overlay pour missions TERMINÉES
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class CompletedMissionSheet extends StatelessWidget {
  final MissionEntity mission;
  final bool isRecruiterView;

  const CompletedMissionSheet({
    super.key,
    required this.mission,
    this.isRecruiterView = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFFFBFBFB),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // Scrollable content - always scrollable to prevent overflow
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: 30, 
                    bottom: mission.recruiterRating == 0.0 ? 96 : 16,
                  ),
                  child: _CompletedMissionView(
                    mission: mission,
                    isRecruiterView: isRecruiterView,
                  ),
                ),
              ),
              // Fixed bottom button - only show if candidate hasn't rated yet
              if (mission.recruiterRating == 0.0)
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
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
                        backgroundColor: const Color(0xFF401E66),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Noter mission',
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
  final bool isRecruiterView;

  const _CompletedMissionView({
    required this.mission,
    this.isRecruiterView = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CompletedMissionHeader(mission: mission),
        const SizedBox(height: 0),
        _CompletedMissionBody(
          mission: mission,
          isRecruiterView: isRecruiterView,
        ),
      ],
    );
  }
}

class _CompletedMissionHeader extends StatelessWidget {
  final MissionEntity mission;
  const _CompletedMissionHeader({required this.mission});

  @override
  Widget build(BuildContext context) {
    final dateRange = '${_fmt(mission.startDate)} "” ${_fmt(mission.endDate)}';

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
                    fontSize: 22,
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
                        fontSize: 16,
                        height: 1.43,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Company and Location on same line
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
                        fontSize: 16,
                        height: 1.43,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        mission.location,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          height: 1.43,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
  final bool isRecruiterView;

  const _CompletedMissionBody({
    required this.mission,
    this.isRecruiterView = false,
  });

  @override
  Widget build(BuildContext context) {
    final recruiterMember = MissionMemberEntity(
      name: mission.recruiterName,
      role: mission.companyName,
      rating: mission.recruiterRating,
      avatarUrl: null,
    );
    final visibleTeam = isRecruiterView ? mission.team : <MissionMemberEntity>[recruiterMember];
    final hasTeam = visibleTeam.isNotEmpty;
    final hasCandidateReview = mission.candidateRating > 0 || mission.candidateFeedback.isNotEmpty;
    final hasRecruiterReview = mission.recruiterRating > 0 || mission.recruiterFeedback.isNotEmpty;
    final hasAnyReview = hasCandidateReview || hasRecruiterReview;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Évaluations - afficher en premier
          if (hasAnyReview) ...[
            const Text(
              'Evaluations',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Color(0xFF2A292B),
              ),
            ),
            const SizedBox(height: 12),
            // Container with border wrapping both evaluation cards
            Container(
              padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  // Évaluation candidat - n'afficher que si elle existe
                  if (hasCandidateReview) ...[
                    _EvaluationCard(
                      title: 'Évaluation Candidat',
                      subtitle: 'Par ${mission.companyName}',
                      rating: mission.candidateRating,
                      feedback: mission.candidateFeedback,
                      bgColor: const Color(0xFFEFEDF4),
                      isRecruiter: false,
                      candidateAvatar: null,
                      candidateName: mission.candidateName,
                    ),
                    const SizedBox(height: 8),
                  ],
                  // Évaluation recruteur - n'afficher que si elle existe
                  if (hasRecruiterReview) ...[
                    _EvaluationCard(
                      title: isRecruiterView
                          ? 'Évaluation employeur'
                          : 'Évaluation Recruteur',
                      subtitle: 'Par ${mission.companyName}',
                      rating: mission.recruiterRating,
                      feedback: mission.recruiterFeedback,
                      bgColor: Colors.white,
                      isRecruiter: true,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          const Text(
            'Description de la mission',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          _MissionSummaryCard(
            description: mission.description,
            summary: mission.summary,
          ),
          const SizedBox(height: 14),
          
          // Recruteur - afficher après les évaluations
          if (hasTeam) ...[
            Text(
              isRecruiterView ? 'Employés' : 'Recruteur',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: Color.fromARGB(255, 44, 45, 48),
              ),
            ),
            const SizedBox(height: 12),
            ...visibleTeam.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RecruiterCard(member: m),
                )),
            const SizedBox(height: 0),
          ],
          
          // Message si pas d'équipe ni d'évaluations
          if (!hasTeam && !hasAnyReview)
            Container(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.rate_review_outlined, size: 48, color: Color(0xFF401E66)),
                    const SizedBox(height: 12),
                    const Text(
                      'Évaluer votre recruteur',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF401E66),
                      ),
                    ),
                  ],
                ),
              ),
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
        border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
      ),
      child: Stack(
        children: [
          // Decorative quote mark for recruiter card
          if (isRecruiter)
            Positioned(
              top: 8,
              right: 8,
              child: Opacity(
                opacity: 0.1,
                child: Text(
                  '"',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 0.8,
                  ),
                ),
              ),
            ),
          Column(
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
                      fontWeight: FontWeight.w800,
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
                  size: 17,
                  color: i < rating.floor()
                      ? (isRecruiter ? const Color(0xFFF59E0B) : const Color(0xFF9843DA))
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
        ],
      ),
    );
  }
}

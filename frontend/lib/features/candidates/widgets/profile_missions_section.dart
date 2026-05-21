import 'package:flutter/material.dart';
import 'package:job_app/features/candidates/domain/profile_mission_entity.dart';

class ProfileMissionsSection extends StatelessWidget {
  final List<ProfileMissionEntity> missions;

  const ProfileMissionsSection({
    super.key,
    required this.missions,
  });

  @override
  Widget build(BuildContext context) {
    if (missions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          children: [
            Icon(Icons.work_outline, size: 40, color: Color(0xFFD1C9DD)),
            SizedBox(height: 12),
            Text(
              'Aucune mission pour le moment',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (int i = 0; i < missions.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEBF4)),
            _MissionRow(mission: missions[i]),
          ],
        ],
      ),
    );
  }
}

class _MissionRow extends StatelessWidget {
  final ProfileMissionEntity mission;

  const _MissionRow({required this.mission});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F0FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.business_center_outlined,
              size: 22,
              color: Color(0xFF401E66),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.jobTitle,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF0B1C30),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${mission.companyName} · ${mission.duration}',
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
                    ...List.generate(5, (i) {
                      return Icon(
                        Icons.star_rounded,
                        size: 12,
                        color: i < mission.rating.round()
                            ? const Color(0xFF401E66)
                            : const Color(0xFFD1C9DD),
                      );
                    }),
                    const SizedBox(width: 4),
                    Text(
                      mission.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusBadge(status: mission.status),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ProfileMissionStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      ProfileMissionStatus.termine => (
          'Terminé',
          const Color(0xFFEAF4EC),
          const Color(0xFF2D8B4E),
        ),
      ProfileMissionStatus.enCours => (
          'En cours',
          const Color(0xFFFFF3E0),
          const Color(0xFFF59E0B),
        ),
      ProfileMissionStatus.annule => (
          'Annulé',
          const Color(0xFFFEF2F2),
          const Color(0xFFEF4444),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          fontSize: 11,
          color: fg,
        ),
      ),
    );
  }
}

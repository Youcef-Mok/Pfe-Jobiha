import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/jobs/domain/mission_entity.dart';
final _styleW50014Slate700 = GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.slate700);
/// Widget réutilisable pour afficher les missions terminées
/// Utilisé dans:
/// - Onglet Compétences > Expériences (pour les APP MISSION)
/// - Onglet Missions (pour les missions terminées)
class CompletedMissionCard extends StatelessWidget {
  final MissionEntity mission;
  final VoidCallback? onTap;
  final bool showAppMissionBadge;

  const CompletedMissionCard({
    super.key,
    required this.mission,
    this.onTap,
    this.showAppMissionBadge = false,
  });

  String _formatDateRange() {
    final start = DateFormat('d MMM', 'fr_FR').format(mission.startDate);
    final end = DateFormat('d MMM yyyy', 'fr_FR').format(mission.endDate);
    return '$start – $end';
  }

  @override
  Widget build(BuildContext context) {
    final hasReview = mission.recruiterRating > 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image (si disponible)
                if (mission.imageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: mission.imageUrl!.startsWith('http')
                      ? Image.network(
                          mission.imageUrl!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F2F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.description_outlined,
                              size: 28,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                        )
                      : Image.asset(
                          mission.imageUrl!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F2F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.description_outlined,
                              size: 28,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                        ),
                  ),
                  const SizedBox(width: 16),
                ],

                // Contenu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre
                      Text(
                        mission.jobTitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: const Color.fromARGB(255, 9, 9, 9),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Entreprise + dates
                      Text(
                        '${mission.companyName} • ${_formatDateRange()}',
                        style: _styleW50014Slate700,
                      ),
                      const SizedBox(height: 8),

                      // Évaluation reçue + note OU message pas encore de reviews
                      if (hasReview)
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Évaluation reçue',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                  color: AppColors.violet,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppColors.violet,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.star_rounded,
                                size: 10,
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              mission.recruiterRating.toStringAsFixed(1),
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                                color: AppColors.violet,
                              ),
                            ),
                          ],
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF9C3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Évaluer votre recruteur',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                              color: const Color(0xFF92400E),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // Badge APP MISSION (si activé)
            if (showAppMissionBadge)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.violet,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified,
                        size: 10,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'APP MISSION',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 8,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/applications/domain/application_entity.dart';
import 'package:job_app/features/applications/widgets/launch_mission_sheet.dart';
import 'package:job_app/features/applications/widgets/schedule_interview_sheet.dart';
import 'package:job_app/features/applications/data/providers/applications_provider.dart';
import 'package:job_app/core/services/notification_toast_service.dart';
import 'package:job_app/core/services/cross_user_notif_service.dart';
import 'package:job_app/features/notifications/domain/notification_entity.dart';
import 'package:job_app/features/profile/screens/candidate_public_profile_screen.dart';

/// Overlay pour afficher les détails d'une candidature
void showApplicationDetailsSheet(BuildContext context, ApplicationEntity application) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ApplicationDetailsSheet(application: application),
  );
}

class ApplicationDetailsSheet extends ConsumerStatefulWidget {
  final ApplicationEntity application;
  
  const ApplicationDetailsSheet({super.key, required this.application});

  @override
  ConsumerState<ApplicationDetailsSheet> createState() => _ApplicationDetailsSheetState();
}

class _ApplicationDetailsSheetState extends ConsumerState<ApplicationDetailsSheet> {
  bool isAccepted = false;

  @override
  void initState() {
    super.initState();
    isAccepted = widget.application.status == ApplicationStatus.accepted;
  }

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
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 30, bottom: 180),
                  child: _ApplicationDetailsView(
                    application: widget.application,
                    isAccepted: isAccepted,
                  ),
                ),
              ),
            ],
          ),
          
          // Close button
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.slate200,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: AppColors.slate600, size: 22),
              ),
            ),
          ),
          
          // Fixed bottom buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFBFBFB),
                border: Border(
                  top: BorderSide(color: const Color(0xFFEEEBF4), width: 1.5),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Accepter et Prévoir interview buttons
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isAccepted ? null : () async {
                              await ref.read(applicationsNotifierProvider.notifier).accept(widget.application.id);
                              setState(() { isAccepted = true; });
                              // Notif cross-user pour le candidat (localStorage)
                              CrossUserNotifService.push(
                                title: 'Votre candidature pour\n"${widget.application.jobTitle}" a été acceptée !',
                                targetRole: 'candidat',
                                type: NotificationType.applicationAccepted,
                                jobTitle: widget.application.jobTitle,
                                senderName: widget.application.candidateName,
                              );
                              if (context.mounted) {
                                ref.read(notificationToastServiceProvider).show(
                                  context: context,
                                  title: '${widget.application.candidateName} a validé sa candidature\npour "${widget.application.jobTitle}"',
                                  type: NotificationType.interviewAccepted,
                                  senderName: widget.application.candidateName,
                                  jobTitle: widget.application.jobTitle,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isAccepted ? AppColors.slate200 : AppColors.violet,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors.slate200,
                              disabledForegroundColor: AppColors.slate400,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              isAccepted ? 'Acceptée' : 'Accepter candidature',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: isAccepted ? AppColors.slate400 : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () {
                              showScheduleInterviewSheet(context, widget.application);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.violet,
                              side: const BorderSide(color: AppColors.violet, width: 1.5),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Prévoir interview',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppColors.violet,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Lancer mission button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isAccepted ? () {
                        showLaunchMissionSheet(context, widget.application);
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAccepted ? AppColors.violet : AppColors.slate200,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.slate200,
                        disabledForegroundColor: AppColors.slate400,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Lancer mission',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: isAccepted ? Colors.white : AppColors.slate400,
                        ),
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

class _ApplicationDetailsView extends StatelessWidget {
  final ApplicationEntity application;
  final bool isAccepted;
  
  const _ApplicationDetailsView({
    required this.application,
    required this.isAccepted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Candidate Card
          _CandidateCard(application: application),
          const SizedBox(height: 24),
          
          // Lettre de motivation
          const Text(
            'Lettre de motivation',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
            ),
            child: Text(
              application.motivationLetter ?? 
              'Motivé(e) par ce poste, je souhaite mettre mes compétences à votre service et contribuer au succès de votre équipe. Fort(e) de mon expérience dans le domaine, je suis convaincu(e) de pouvoir apporter une réelle valeur ajoutée à votre entreprise.\n\nMon parcours professionnel m\'a permis de développer des compétences solides et une expertise reconnue. Je suis particulièrement intéressé(e) par les défis que représente ce poste et je suis prêt(e) à m\'investir pleinement pour atteindre les objectifs fixés.\n\nJe reste à votre disposition pour un entretien afin de discuter plus en détail de ma candidature.',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 1.6,
                color: Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  final ApplicationEntity application;

  const _CandidateCard({required this.application});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: application.candidateId != null
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CandidatePublicProfileScreen(
                    candidateId: application.candidateId!,
                  ),
                ),
              )
          : null,
      child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              _buildAvatar(),
              const SizedBox(width: 16),
              // Name and domain
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.candidateName ?? 'Candidat',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Color(0xFF1D1B1F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      application.candidateDomain ?? 'Domaine non spécifié',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFF665976),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Rating
          Row(
            children: [
              const Icon(Icons.star, size: 16, color: Color(0xFF6F5D1D)),
              const SizedBox(width: 6),
              Text(
                application.candidateRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF1D1B1F),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${(application.candidateRating * 10).toInt()} avis)',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFF7C7580),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildAvatar() {
    final avatar = application.candidateAvatar;
    if (avatar != null) {
      final image = avatar.startsWith('http')
          ? NetworkImage(avatar) as ImageProvider
          : AssetImage(avatar);
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: image, fit: BoxFit.cover),
        ),
      );
    }

    // Avatar par défaut avec initiales
    final name = application.candidateName ?? 'C';
    final initials = name.split(' ').map((n) => n[0]).take(2).join().toUpperCase();

    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.violetLight,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.violet,
          ),
        ),
      ),
    );
  }
}

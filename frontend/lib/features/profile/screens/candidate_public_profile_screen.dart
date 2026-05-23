import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';
import 'package:job_app/features/jobs/widgets/mission_card.dart';
import 'package:job_app/features/jobs/widgets/mission_in_progress_sheet.dart';
import 'package:job_app/features/messaging/data/providers/messaging_provider.dart';
import 'package:job_app/features/messaging/screens/private_message_screen.dart';
import 'package:job_app/features/profile/data/providers/profile_provider.dart';
import 'package:job_app/features/profile/widgets/candidate_profile_header.dart';
import 'package:job_app/features/profile/widgets/candidate_profile_tabs.dart';
import 'package:job_app/features/profile/widgets/profile_cv_section.dart';
import 'package:job_app/features/profile/widgets/profile_description_section.dart';

class CandidatePublicProfileScreen extends ConsumerWidget {
  final String candidateId;

  const CandidatePublicProfileScreen({
    super.key,
    required this.candidateId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(publicUserProvider(candidateId));
    final selectedTab = ref.watch(candidateProfileTabProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: SafeArea(
        bottom: false,
        child: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur: $e')),
          data: (user) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: CandidateProfileHeader(
                  user: user,
                  isPublicCandidateView: true,
                  onBackTap: () => Navigator.pop(context),
                  onMessageTap: () async {
                    final controller =
                        ref.read(messagingControllerProvider.notifier);
                    final conversation =
                        await controller.getOrCreateConversation(
                      contactName: user.name,
                      contactRole: user.role,
                      contactAvatar: user.avatarUrl,
                    );
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PrivateMessageScreen(
                            conversation: conversation,
                          ),
                        ),
                      );
                    }
                  },
                  onShareTap: () => _shareProfile(context, user.name),
                  onMoreTap: () => _showMoreOptions(context),
                ),
              ),
              SliverPersistentHeader(
                delegate: CandidateProfileTabsDelegate(
                  child: const CandidateProfileTabs(),
                ),
                pinned: true,
              ),
              if (selectedTab == CandidateProfileTab.description)
                SliverToBoxAdapter(
                  child: ProfileDescriptionSection(
                    isRecruiterView: false,
                    canReplyToReviews: false,
                    userProvider: publicUserProvider(candidateId),
                    reviewsProvider: publicUserReviewsProvider(candidateId),
                  ),
                ),
              if (selectedTab == CandidateProfileTab.competences)
                SliverFillRemaining(
                  hasScrollBody: true,
                  child: ProfileCvSection(
                    readOnly: true,
                    cvProvider: publicCandidateCvProvider(candidateId),
                  ),
                ),
              if (selectedTab == CandidateProfileTab.missions)
                _PublicCandidateMissionsSection(candidateName: user.name),
            ],
          ),
        ),
      ),
    );
  }

  void _shareProfile(BuildContext context, String name) {
    final profileUrl = 'https://petitsjobs.dz/candidats/$candidateId';
    Clipboard.setData(ClipboardData(text: profileUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lien du profil de $name copié'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            _OptionTile(icon: Icons.shield_moon_outlined, label: 'Restreindre'),
            _OptionTile(icon: Icons.flag_outlined, label: 'Signaler'),
            _OptionTile(icon: Icons.block_outlined, label: 'Bloquer'),
          ],
        ),
      ),
    );
  }
}

class _PublicCandidateMissionsSection extends ConsumerWidget {
  final String candidateName;
  const _PublicCandidateMissionsSection({required this.candidateName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionsAsync = ref.watch(candidateMissionsByNameProvider(candidateName));

    return missionsAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(child: Text('Erreur: $e')),
        ),
      ),
      data: (missions) {
        if (missions.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: Center(
                child: Text(
                  'Aucune mission',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),
          );
        }
        return SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 100),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Column(
              children: missions.map((mission) {
                final isInProgress = mission.status == 'in_progress';
                return Padding(
                  padding: EdgeInsets.only(bottom: isInProgress ? 16 : 12),
                  child: MissionCard(
                    mission: mission,
                    cardColor: const Color(0xFFEFEDF2),
                    onTap: () {
                      if (mission.isCompleted) {
                        showCompletedMissionSheet(context, mission,
                            isRecruiterView: false);
                      } else {
                        showMissionInProgressSheet(context, mission,
                            isRecruiterView: false);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const _OptionTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF401E66)),
      title: Text(label),
      onTap: () => Navigator.pop(context),
    );
  }
}

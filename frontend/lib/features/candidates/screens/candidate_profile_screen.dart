import 'package:flutter/material.dart';
import 'package:job_app/features/candidates/domain/candidate_entity.dart';
import 'package:job_app/features/candidates/domain/feedback_entity.dart';
import 'package:job_app/features/candidates/domain/profile_mission_entity.dart';
import 'package:job_app/features/candidates/domain/skill_entity.dart';
import 'package:job_app/features/candidates/widgets/profile_competences_section.dart';
import 'package:job_app/features/candidates/widgets/profile_feedback_section.dart';
import 'package:job_app/features/candidates/widgets/profile_missions_section.dart';

class CandidateProfileScreen extends StatefulWidget {
  final CandidateEntity candidate;
  final bool isOwnProfile;
  final Widget? bottomNavBar;

  const CandidateProfileScreen({
    super.key,
    required this.candidate,
    this.isOwnProfile = false,
    this.bottomNavBar,
  });

  @override
  State<CandidateProfileScreen> createState() => _CandidateProfileScreenState();
}

class _CandidateProfileScreenState extends State<CandidateProfileScreen> {
  int _activeTab = 0;

  static const _tabs = ['Description', 'Competences', 'Missions'];

  List<FeedbackEntity> get _feedbacks => [
        FeedbackEntity(
          id: 'f1',
          reviewerName: 'Sophie Martin',
          reviewerRole: 'Restaurant Manager',
          starCount: 4,
          reviewText:
              'Lucas was punctual, professional, and exceeded our service expectations. Would definitely hire again.',
          cardType: FeedbackCardType.collapsed,
        ),
        FeedbackEntity(
          id: 'f2',
          reviewerName: 'Jean-Pierre Dupont',
          reviewerRole: 'Event Coordinator',
          starCount: 0,
          reviewText: 'Great communication and teamwork during the event.',
          cardType: FeedbackCardType.replyInput,
        ),
        FeedbackEntity(
          id: 'f3',
          reviewerName: 'Amira Bensalah',
          reviewerRole: 'HR @HotelRitz',
          starCount: 5,
          reviewText:
              'Outstanding performance. Lucas brought a level of professionalism that impressed our entire team.',
          response: const FeedbackResponseEntity(
            authorName: 'Lucas Moreau',
            responseText:
                'Thank you so much! It was a pleasure working with your team.',
          ),
          cardType: FeedbackCardType.expanded,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      bottomNavigationBar: widget.bottomNavBar,
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(),
                  _buildTabBar(),
                  if (_activeTab == 0) _buildDescriptionTab(),
                  if (_activeTab == 1) _buildCompetencesTab(),
                  if (_activeTab == 2) _buildMissionsTab(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                if (widget.isOwnProfile)
                  const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Text(
                      'Mon Profil',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Color(0xFF0B1C30),
                      ),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: Color(0xFF0B1C30),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.share_outlined,
                    size: 20,
                    color: Color(0xFF0B1C30),
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(
                    Icons.more_horiz,
                    size: 22,
                    color: Color(0xFF0B1C30),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: Center(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    image: DecorationImage(
                      image: AssetImage(widget.candidate.photoUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D7FEA),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.check, size: 12, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.candidate.name,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 24,
                color: Color(0xFF0B1C30),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.candidate.title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: Color(0xFF401E66),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEFF1F5), width: 1),
        ),
      ),
      child: Row(
        children: [
          for (int i = 0; i < _tabs.length; i++) ...[
            if (i > 0)
              Container(
                width: 1,
                height: 18,
                color: const Color(0xFFEFF1F5),
              ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _activeTab = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: _activeTab == i
                            ? const Color(0xFF401E66)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    _tabs[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: _activeTab == i
                          ? const Color(0xFF401E66)
                          : (i == 2
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDescriptionTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildInfoChips(),
          const SizedBox(height: 16),
          _buildDescriptionCard(),
          const SizedBox(height: 20),
          ProfileFeedbackSection(
            feedbacks: _feedbacks,
            onViewAll: () {},
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoChips() {
    return Row(
      children: [
        _buildInfoChip(
          iconBg: const Color(0xFFEFEDF2),
          icon: Icons.location_on,
          iconColor: const Color(0xFF401E66),
          label: 'Paris, France',
        ),
        const SizedBox(width: 10),
        _buildInfoChip(
          iconBg: const Color(0xFFEFEDF2),
          icon: Icons.restaurant,
          iconColor: const Color(0xFF401E66),
          label: 'Restauration',
        ),
        const SizedBox(width: 10),
        _buildInfoChip(
          iconBg: const Color(0xFF401E66),
          icon: Icons.work_outline,
          iconColor: Colors.white,
          label: '${widget.candidate.reviewsCount} missions',
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required Color iconBg,
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 11,
                color: Color(0xFF4B444F),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  List<SkillGroupEntity> get _skillGroups => const [
        SkillGroupEntity(
          title: 'Compétences métier',
          skills: [
            SkillEntity(name: 'Service en salle', level: SkillLevel.expert),
            SkillEntity(name: 'Sommellerie', level: SkillLevel.expert),
            SkillEntity(name: 'Barman', level: SkillLevel.avance),
            SkillEntity(name: 'Cuisine', level: SkillLevel.intermediaire),
          ],
        ),
      ];

  List<LanguageEntity> get _languages => const [
        LanguageEntity(name: 'Français', proficiency: 'Natif'),
        LanguageEntity(name: 'Anglais', proficiency: 'Avancé'),
        LanguageEntity(name: 'Arabe', proficiency: 'Intermédiaire'),
      ];

  List<String> get _tools => const [
        'Lightspeed',
        'Square POS',
        'Microsoft Office',
        'Toast POS',
        'OpenTable',
      ];

  List<ProfileMissionEntity> get _missions => const [
        ProfileMissionEntity(
          id: 'pm1',
          jobTitle: 'Service en salle',
          companyName: 'Hôtel Ritz Paris',
          duration: '3 mois',
          rating: 5.0,
          status: ProfileMissionStatus.termine,
        ),
        ProfileMissionEntity(
          id: 'pm2',
          jobTitle: 'Barman',
          companyName: 'Le Meurice',
          duration: '2 mois',
          rating: 4.0,
          status: ProfileMissionStatus.termine,
        ),
        ProfileMissionEntity(
          id: 'pm3',
          jobTitle: 'Chef de rang',
          companyName: 'Brasserie Lipp',
          duration: '1 mois',
          rating: 4.5,
          status: ProfileMissionStatus.enCours,
        ),
      ];

  Widget _buildCompetencesTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          ProfileCompetencesSection(
            skillGroups: _skillGroups,
            languages: _languages,
            tools: _tools,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMissionsTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mes missions',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Color(0xFF0B1C30),
                ),
              ),
              Text(
                '${_missions.length} mission${_missions.length > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF401E66),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProfileMissionsSection(missions: _missions),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About Me',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Color(0xFF1B1B1B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.candidate.coverLetter,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color(0xFF4B444F),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

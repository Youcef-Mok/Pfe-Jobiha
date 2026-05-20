import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_app/features/profile/data/providers/profile_provider.dart';
import 'package:job_app/features/profile/domain/cv_entity.dart';
import 'package:job_app/features/profile/widgets/profile_add_overlays.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/jobs/widgets/completed_mission_card.dart';
import 'package:job_app/features/jobs/domain/mission_entity.dart';
import 'package:job_app/features/jobs/widgets/mission_in_progress_sheet.dart';

const double _kPeekHeight = 52.0;
const Color _kViolet = Color(0xFF401E66);
const Color _kLightBg = Color(0xFFF5F2F9);
const Color _kBlack = Color(0xFF000000);
const Color _kJobCardGray = Color(0xFFEFEDF2);

final _titleStyleBlack = GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16, color: _kBlack);
final _titleStyleViolet = GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16, color: _kViolet);
final _titleStyleDark = GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16, color: const Color(0xFF0F172A));
final _styleW70012Slate700LS11 = GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.slate700, letterSpacing: 1.1);
final _styleW70012Slate600LS11 = GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.slate600, letterSpacing: 1.1);
final _styleW70014Slate900 = GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.slate900);
final _style12Slate700 = GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.slate700);
final _styleW60014Slate900 = GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.slate900);
final _styleW70010Violet = GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 10, color: _kViolet);
final _styleW50012Slate700 = GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.slate700);
final _styleW70016Slate900 = GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.slate900);
final _styleW50014Slate700 = GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.slate700);
final _style14Slate700 = GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.slate700);

class ProfileCvSection extends ConsumerStatefulWidget {
  final ProviderListenable<AsyncValue<CvEntity>>? cvProvider;
  final bool readOnly;

  const ProfileCvSection({super.key, this.cvProvider, this.readOnly = false});

  @override
  ConsumerState<ProfileCvSection> createState() => _ProfileCvSectionState();
}

class _ProfileCvSectionState extends ConsumerState<ProfileCvSection>
    with TickerProviderStateMixin {
  late AnimationController _card2Controller;
  late AnimationController _card3Controller;

  // ScrollControllers pour lier le scroll du contenu au mouvement des cartes
  final ScrollController _card1ScrollController = ScrollController();
  final ScrollController _card2ScrollController = ScrollController();
  final ScrollController _card3ScrollController = ScrollController();

  // Pixels supplémentaires au-delà de l'openedTop (extension de la montée)
  double _card2ExtraOffset = 0.0;
  double _card3ExtraOffset = 0.0;

  // Index de la carte ouverte : 1 (Exp), 2 (Form), 3 (Compétences)
  int _openIndex = 1;

  @override
  void initState() {
    super.initState();
    _card2Controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _card3Controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));

    // Par défaut, cv card 1 (Experience) est ouverte
    _openIndex = 1;
    _card2Controller.value = 0.0;
    _card3Controller.value = 0.0;
  }

  @override
  void dispose() {
    _card1ScrollController.dispose();
    _card2ScrollController.dispose();
    _card3ScrollController.dispose();
    _card2Controller.dispose();
    _card3Controller.dispose();
    super.dispose();
  }

  /// Appelé par NotificationListener quand le contenu d'une carte scrolle.
  /// - Fait monter la carte active d'un coup lors de l'overscroll
  /// - Scrolle simultanément le NestedScrollView pour pousser le header vers le haut.
  bool _onScrollNotification(ScrollNotification n, int cardIndex) {
    // Overscroll au bord supérieur → fait monter la carte d'un coup
    if (n is OverscrollNotification && n.overscroll < 0) {
      _pushOuterScroll(n.overscroll.abs());
      
      // Déclenche l'animation complète de la carte lors de l'overscroll
      if (cardIndex == 2 && _card2Controller.value < 1.0) {
        _toggle(2);
        return true;
      } else if (cardIndex == 3 && _card3Controller.value < 1.0) {
        _toggle(3);
        return true;
      }
      return false;
    }

    if (n is! ScrollUpdateNotification) return false;
    final double rawDelta = n.scrollDelta ?? 0;
    if (rawDelta <= 0) return false; // scroll vers le bas : ne pas interférer

    // Tout scroll vers le haut pousse simultanément le header de la page
    _pushOuterScroll(rawDelta);

    return false;
  }

  /// Fait défiler le header de la page vers le haut (collapse le SliverAppBar)
  void _pushOuterScroll(double amount) {
    final outerCtrl = context.findAncestorStateOfType<NestedScrollViewState>()?.outerController;
    if (outerCtrl == null || !outerCtrl.hasClients) return;
    if (!outerCtrl.position.hasContentDimensions) return;
    final newOffset = (outerCtrl.offset + amount).clamp(0.0, outerCtrl.position.maxScrollExtent);
    outerCtrl.jumpTo(newOffset);
  }

  void _toggle(int index) {
    _openIndex = index;

    // Réinitialise les offsets supplémentaires
    if (_card2ExtraOffset != 0.0 || _card3ExtraOffset != 0.0) {
      setState(() {
        _card2ExtraOffset = 0.0;
        _card3ExtraOffset = 0.0;
      });
    }

    // Collapse le header quand on ouvre une carte, expand quand on revient à la carte 1
    final nestedState = context.findAncestorStateOfType<NestedScrollViewState>();
    final outerCtrl = nestedState?.outerController;
    if (outerCtrl != null && outerCtrl.hasClients && outerCtrl.position.hasContentDimensions) {
      outerCtrl.animateTo(
        index == 1 ? 0.0 : outerCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }

    const duration = Duration(milliseconds: 500);
    const curve = Curves.easeOutCubic;

    if (index == 1) {
      _card2Controller.animateTo(0.0, duration: duration, curve: curve);
      _card3Controller.animateTo(0.0, duration: duration, curve: curve);
    } else if (index == 2) {
      _card2Controller.animateTo(1.0, duration: duration, curve: curve);
      _card3Controller.animateTo(0.0, duration: duration, curve: curve);
    } else if (index == 3) {
      _card2Controller.animateTo(1.0, duration: duration, curve: curve);
      _card3Controller.animateTo(1.0, duration: duration, curve: curve);
    }
  }

  void _handleDragUpdate(DragUpdateDetails details, int index) {
    // Height minus peek height
    final double maxScroll = MediaQuery.of(context).size.height - (2 * _kPeekHeight);
    final double delta = -(details.primaryDelta ?? 0) / (maxScroll > 0 ? maxScroll : 300.0);

    if (index == 2) {
      _card2Controller.value = (_card2Controller.value + delta).clamp(0.0, 1.0);
      if (_card3Controller.value > _card2Controller.value) {
        _card3Controller.value = _card2Controller.value;
      }
    } else if (index == 3) {
      _card3Controller.value = (_card3Controller.value + delta).clamp(0.0, 1.0);
      if (_card2Controller.value < _card3Controller.value) {
        _card2Controller.value = _card3Controller.value;
      }
    }
  }

  void _handleDragEnd(DragEndDetails details, int index) {
    final double maxScroll = MediaQuery.of(context).size.height - (2 * _kPeekHeight);
    final double velocity = -details.primaryVelocity! / (maxScroll > 0 ? maxScroll : 300.0);
    final double projection = 0.2 * velocity;

    int targetIndex = _openIndex;

    if (index == 2) {
      double future = _card2Controller.value + projection;
      bool wasOpen = _openIndex >= 2;
      bool stayOpen = wasOpen ? (future > 0.8) : (future > 0.2);
      
      if (!stayOpen && wasOpen) targetIndex = 1;
      if (stayOpen && !wasOpen) targetIndex = 2;
    } else if (index == 3) {
      double future = _card3Controller.value + projection;
      bool wasOpen = _openIndex == 3;
      bool stayOpen = wasOpen ? (future > 0.8) : (future > 0.2);

      if (!stayOpen && wasOpen) targetIndex = 2;
      if (stayOpen && !wasOpen) targetIndex = 3;
    }

    _toggle(targetIndex);
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.cvProvider ?? cvNotifierProvider;
    final cvAsync = ref.watch(provider);

    return Container(
      color: const Color(0xFFFBFBFB),
      child: cvAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (cv) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final h = constraints.maxHeight;
                      return Stack(
                        children: [
                          // 1. CARTE EXPERIENCE (Base)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: RepaintBoundary(
                              child: _CvCardBase(
                                index: 1,
                                title: 'Experience',
                                icon: Icons.description_outlined,
                                onHeaderTap: () => _toggle(1),
                                onAddPressed: widget.readOnly
                                    ? null
                                    : () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const AddExperienceOverlay(),
                                          ),
                                        ),
                                child: NotificationListener<ScrollNotification>(
                                  onNotification: (n) {
                                    if (n is OverscrollNotification && n.overscroll < 0) {
                                      _pushOuterScroll(n.overscroll.abs());
                                    } else if (n is ScrollUpdateNotification) {
                                      final delta = n.scrollDelta ?? 0;
                                      if (delta > 0) _pushOuterScroll(delta);
                                    }
                                    return false; // laisser le ListView défiler normalement
                                  },
                                  child: ListView.builder(
                                    controller: _card1ScrollController,
                                    primary: false,
                                    physics: const ClampingScrollPhysics(),
                                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                                    itemCount: cv.experiences.length,
                                    itemBuilder: (context, i) {
                                      final exp = cv.experiences[i];
                                      return _TimelineContent(
                                        title: exp.title,
                                        company: exp.company,
                                        location: exp.location,
                                        date: exp.endDate ?? '',
                                        secondaryDate: exp.period,
                                        isAppMission: exp.isAppMission,
                                        icon: Icons.business_center,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 2. CARTE FORMATIONS (Animée)
                          // Écoute les deux controllers : carte 2 peut être poussée par carte 3
                          AnimatedBuilder(
                            animation: Listenable.merge([_card2Controller, _card3Controller]),
                            child: RepaintBoundary(
                              child: _CvCardBase(
                                index: 2,
                                title: 'Formations',
                                icon: Icons.school_outlined,
                                onHeaderTap: () => _toggle(2),
                                onHeaderDragUpdate: (details) => _handleDragUpdate(details, 2),
                                onHeaderDragEnd: (details) => _handleDragEnd(details, 2),
                                onAddPressed: widget.readOnly
                                    ? null
                                    : () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const AddFormationOverlay(),
                                          ),
                                        ),
                                child: NotificationListener<ScrollNotification>(
                                  onNotification: (n) => _onScrollNotification(n, 2),
                                  child: ListView.builder(
                                    controller: _card2ScrollController,
                                    primary: false,
                                    physics: const ClampingScrollPhysics(),
                                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                                    itemCount: cv.formations.length,
                                    itemBuilder: (context, i) {
                                      final f = cv.formations[i];
                                      final isValidated = f.isActive;
                                      return _TimelineContent(
                                        title: f.title,
                                        company: f.institution,
                                        location: f.location,
                                        date: f.year.toString(),
                                        badgeText: isValidated ? 'VALIDE' : null,
                                        icon: Icons.school_outlined,
                                        isValidated: isValidated,
                                        onTap: isValidated ? () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (context) => CertificateViewerOverlay(
                                              title: f.title,
                                              institution: f.institution,
                                              fileName: f.fileName ?? 'diplome_${f.title.toLowerCase().replaceAll(' ', '_')}.pdf',
                                              filePath: f.filePath,
                                            ),
                                          );
                                        } : null,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            builder: (context, child) {
                              final c2Closed = h - _kPeekHeight - 50;
                              const double c2Opened = _kPeekHeight;
                              final c2Natural = c2Closed - (c2Closed - c2Opened) * _card2Controller.value - _card2ExtraOffset;

                              // Position actuelle de la carte 3 (pour calculer le push)
                              final c3Closed = h - 50;
                              const double c3Opened = 2 * _kPeekHeight;
                              final c3Current = c3Closed - (c3Closed - c3Opened) * _card3Controller.value - _card3ExtraOffset;

                              // La carte 2 est poussée vers le haut par la carte 3 :
                              // elle doit toujours être au moins _kPeekHeight au-dessus de carte 3
                              final double pushedTop = c3Current - _kPeekHeight;
                              // Minimum = 48 (hauteur de la barre des onglets) pour ne jamais la couvrir
                              final c2Top = (c2Natural < pushedTop ? c2Natural : pushedTop)
                                  .clamp(48.0, c2Closed);

                              return Positioned(
                                top: c2Top,
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: child!,
                              );
                            },
                          ),

                          // 3. CARTE SKILLS ET LANGUES
                          // Écoute les deux controllers : carte 3 ne peut pas monter au-dessus de carte 2
                          AnimatedBuilder(
                            animation: Listenable.merge([_card2Controller, _card3Controller]),
                            child: RepaintBoundary(
                              child: _CvCardBase(
                                index: 3,
                                title: 'Skillls et langues',
                                icon: Icons.notes_outlined,
                                onHeaderTap: () => _toggle(3),
                                onHeaderDragUpdate: (details) => _handleDragUpdate(details, 3),
                                onHeaderDragEnd: (details) => _handleDragEnd(details, 3),
                                onAddPressed: widget.readOnly
                                    ? null
                                    : () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const AddSkillsAndLanguagesOverlay(),
                                          ),
                                        ),
                                child: NotificationListener<ScrollNotification>(
                                  onNotification: (n) => _onScrollNotification(n, 3),
                                  child: ListView(
                                    controller: _card3ScrollController,
                                    primary: false,
                                    physics: const ClampingScrollPhysics(),
                                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                                    children: [
                                      _SkillsList(cv: cv),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            builder: (context, child) {
                              // Recalcule la position de la carte 2 pour contraindre la carte 3
                              final c2Closed = h - _kPeekHeight - 55;
                              const double c2Opened = _kPeekHeight;
                              final c2Natural = c2Closed - (c2Closed - c2Opened) * _card2Controller.value - _card2ExtraOffset;
                              final c3Closed = h - 55;
                              final c3Natural = c3Closed - (c3Closed - c2Opened * 2) * _card3Controller.value - _card3ExtraOffset;

                              // Position de la carte 2 avec son propre push par la carte 3
                              final c3Min = c2Natural.clamp(48.0, c2Closed) + _kPeekHeight;

                              // Carte 3 ne peut jamais monter au-dessus du header de carte 2
                              final c3Top = c3Natural.clamp(c3Min, c3Closed.toDouble());

                              return Positioned(
                                top: c3Top,
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: child!,
                              );
                            },
                          ),
                        ],
                      );
                    },
              ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}

class _SkillsList extends StatelessWidget {
  final CvEntity cv;
  const _SkillsList({required this.cv});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LANGUES',
              style: _styleW70012Slate700LS11,
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddSkillsAndLanguagesOverlay(),
                ),
              ),
              child: const Icon(Icons.add, size: 18, color: AppColors.slate900),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 70,
          ),
          itemCount: cv.languages.length,
          itemBuilder: (context, index) => _LanguageCard(cv.languages[index]),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SKILLS',
              style: _styleW70012Slate600LS11,
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddSkillsAndLanguagesOverlay(),
                ),
              ),
              icon: const Icon(Icons.add, size: 20, color: AppColors.slate900),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...cv.skills.map((s) => _SkillRow(s)),
      ],
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final CvLanguageEntity language;
  const _LanguageCard(this.language);

  @override
  Widget build(BuildContext context) {
     return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _kJobCardGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(language.name, style: _styleW70014Slate900),
          const SizedBox(height: 4),
          Text(language.level, style: _style12Slate700),
        ],
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  final CvSkillEntity skill;
  const _SkillRow(this.skill);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(skill.name, style: _styleW60014Slate900),
              if (skill.levelLabel != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kLightBg,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(skill.levelLabel!, style: _styleW70010Violet),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: skill.progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation<Color>(_kViolet),
            ),
          ),
        ],
      ),
    );
  }
}


class _CvCardBase extends StatelessWidget {
  final int index;
  final String title;
  final IconData icon;
  final Widget child;
  final VoidCallback onHeaderTap;
  final VoidCallback? onAddPressed;

  const _CvCardBase({
    required this.index,
    required this.title,
    required this.icon,
    required this.child,
    required this.onHeaderTap,
    required this.onAddPressed,
    this.onHeaderDragUpdate,
    this.onHeaderDragEnd,
  });

  final void Function(DragUpdateDetails)? onHeaderDragUpdate;
  final void Function(DragEndDetails)? onHeaderDragEnd;


  static const _decoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(20)),
    border: Border.fromBorderSide(
      BorderSide(color: Color(0xFFEEEBF4), width: 1.5),
    ),
    boxShadow: [
      BoxShadow(
        color: Color(0x0D3A1B5E),
        blurRadius: 4,
        spreadRadius: 3,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final Color headerColor = index == 1
        ? _kBlack
        : index == 2
            ? _kViolet
            : const Color(0xFF0F172A);

    final textStyle = index == 1 ? _titleStyleBlack
        : index == 2 ? _titleStyleViolet
        : _titleStyleDark;

    return Container(
      decoration: _decoration,
      child: Column(
        children: [
          GestureDetector(
            onTap: onHeaderTap,
            onVerticalDragUpdate: onHeaderDragUpdate,
            onVerticalDragEnd: onHeaderDragEnd,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: _kPeekHeight,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: const BoxDecoration(
                color: _kJobCardGray, // Utiliser la même couleur que les formations validées
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 24, color: headerColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: textStyle,
                    ),
                  ),
                  if (onAddPressed != null)
                    GestureDetector(
                      onTap: onAddPressed,
                      child: const Icon(Icons.add, color: _kViolet, size: 20),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineContent extends StatelessWidget {
  final String title, company, location, date;
  final String? secondaryDate;
  final bool isAppMission;
  final String? badgeText;
  final IconData? icon;
  final bool isValidated;
  final VoidCallback? onTap;

  const _TimelineContent({
    required this.title,
    required this.company,
    required this.location,
    required this.date,
    this.secondaryDate,
    this.isAppMission = false,
    this.badgeText,
    this.icon,
    this.isValidated = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final showBadge = isAppMission || badgeText != null;
    final displayBadgeText = badgeText ?? (isAppMission ? 'APP MISSION' : '');

    // Design spécial pour APP MISSION (comme missions terminées)
    if (isAppMission) {
      // Créer une MissionEntity avec des données complètes pour les APP MISSION
      final mission = MissionEntity(
        id: 'app_mission_${title.hashCode}',
        jobTitle: title,
        companyName: company,
        startDate: DateTime.now().subtract(const Duration(days: 90)),
        endDate: DateTime.now().subtract(const Duration(days: 30)),
        location: location,
        status: 'completed',
        recruiterName: 'Sophie Laurent',
        candidateName: 'Farouja',
        candidateRating: 4.8,
        candidateFeedback: 'Excellente prestation lors de cette mission.',
        recruiterRating: 4.8,
        recruiterFeedback: 'Professionnalisme exemplaire.',
        imageUrl: 'assets/images/imageannonc(${(title.hashCode % 5) + 1}).jpg',
        team: [
          MissionMemberEntity(
            name: 'Sophie Laurent',
            role: 'Event Manager',
            rating: 4.9,
            avatarUrl: 'assets/images/pdp_1.png',
          ),
        ],
      );
      
      return CompletedMissionCard(
        mission: mission,
        showAppMissionBadge: true,
        onTap: () {
          showCompletedMissionSheet(context, mission);
        },
      );
    }

    // Design normal pour les autres cartes
    final cardContent = Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 16),
      decoration: BoxDecoration(
        color: isValidated ? const Color(0xFFEFEDF2) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showBadge)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.violet,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        displayBadgeText,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              if (date.isNotEmpty)
                Text(
                  date,
                  style: _styleW50012Slate700,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: _styleW70016Slate900,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: AppColors.violet),
                const SizedBox(width: 6),
              ],
              Text(
                company,
                style: _styleW50014Slate700,
              ),
              const SizedBox(width: 4),
              Text(
                '•',
                style: _style14Slate700,
              ),
              const SizedBox(width: 4),
              const Icon(Icons.location_on, size: 12, color:AppColors.violet),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: _styleW50014Slate700,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (secondaryDate != null && secondaryDate!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              secondaryDate!,
              style: _styleW50012Slate700,
            ),
          ],
        ],
      ),
    );

    // Si onTap est fourni, rendre la carte cliquable
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }

    return cardContent;
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/applications/domain/application_entity.dart';
import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/features/applications/data/providers/applications_provider.dart';
import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';
import 'package:job_app/features/messaging/data/providers/messaging_provider.dart';
import 'package:job_app/features/messaging/screens/private_message_screen.dart';
import 'package:job_app/features/profile/data/providers/profile_provider.dart';
import 'package:job_app/features/profile/screens/recruiter_public_profile_screen.dart';
import 'package:job_app/features/profile/screens/report_comment_screen.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Thread / comment state provider
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
final _expandedThreadsProvider =
    StateProvider.autoDispose<Set<int>>((ref) => <int>{});

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Main screen
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class CandidateJobDetailsScreen extends ConsumerWidget {
  final JobEntity job;
  final ApplicationEntity? application;
  const CandidateJobDetailsScreen({
    super.key,
    required this.job,
    this.application,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Fixed Hero Image Background
          SizedBox(
            height: 245,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (job.logoAsset != null)
                  Image.asset(
                    job.logoAsset!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: const Color(0xFF334155)),
                  )
                else
                  Container(color: const Color(0xFF334155)),
              ],
            ),
          ),

          // 2. Scrollable Overlay Card
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Spacer to let background image show at top
              const SliverToBoxAdapter(
                child: SizedBox(height: 220),
              ),
              // The white card content
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 15, 7, 40),
                    child: _DetailsContent(job: job, application: application),
                  ),
                ),
              ),
            ],
          ),

          // 3. Floating UI controls
          Positioned(
            top: 45,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsContent extends ConsumerStatefulWidget {
  final JobEntity job;
  final ApplicationEntity? application;
  const _DetailsContent({required this.job, this.application});

  @override
  ConsumerState<_DetailsContent> createState() => _DetailsContentState();
}

class _DetailsContentState extends ConsumerState<_DetailsContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final targetTabsWidth = screenWidth * 0.80;
        final tabsWidth = targetTabsWidth < constraints.maxWidth
            ? targetTabsWidth
            : constraints.maxWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MinimalistHeader(
                  width: constraints.maxWidth,
                  title: widget.job.title,
                  subtitle: widget.job.companyName,
                  showApplyButton: widget.application == null,
                  job: widget.job,
                  application: widget.application,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.center,
              child: _TabToggle(
                controller: _tabController,
                width: tabsWidth,
              ),
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _tabController,
              builder: (ctx, _) {
                if (_tabController.index == 0) {
                  return _DescriptionTab(job: widget.job);
                } else {
                  return _CommentsTab(job: widget.job);
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class _TabToggle extends StatelessWidget {
  final TabController controller;
  final double width;
  const _TabToggle({required this.controller, required this.width});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (ctx, _) {
        final activeIdx = controller.index;
        return Container(
          width: width,
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFEFEDF2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: _buildTab(0, 'Description', activeIdx == 0),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 1,
                child: _buildTab(1, 'Commentaires', activeIdx == 1),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTab(int idx, String label, bool isActive) {
    return GestureDetector(
      onTap: () => controller.animateTo(idx),
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: const Color(0xFF401E66),
          ),
        ),
      ),
    );
  }
}

class _MinimalistHeader extends StatelessWidget {
  final double width;
  final String title;
  final String subtitle;
  final bool showApplyButton;
  final JobEntity job;
  final ApplicationEntity? application;

  const _MinimalistHeader({
    required this.width,
    required this.title,
    required this.subtitle,
    required this.showApplyButton,
    required this.job,
    this.application,
  });

  @override
  Widget build(BuildContext context) {
    final isAccepted = application?.status == ApplicationStatus.accepted;

    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: isAccepted ? 24 : 22,
                      height: 32 / 24,
                      letterSpacing: -0.3,
                      color: const Color(0xFF1B1C1C),
                    ),
                  ),
                ),
                if (application != null)
                  _WithdrawApplicationButton(applicationId: application!.id)
                else if (showApplyButton)
                  _InlineApplyButton(job: job),
              ],
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                height: 24 / 16,
                color: const Color(0xFF4A454F),
              ),
            ),
            if (isAccepted && application?.interviewDate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 14,
                    color: Color(0xFF059669),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Entretien prévu le ${application!.interviewDate!}',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        height: 16 / 12,
                        color: const Color(0xFF059669),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _validerButton(),
                ],
              ),
            ],
          ],
        ),
      );
    }

  Widget _statusBadge(ApplicationStatus status) {
    final (bgColor, textColor, label) = switch (status) {
      ApplicationStatus.pending => (
          const Color(0xFFFEF9C3),
          const Color(0xFF92400E),
          'ATTENTE',
        ),
      ApplicationStatus.accepted => (
          const Color(0xFFD1FAE5),
          const Color(0xFF1D8869),
          'ACCEPTE',
        ),
      ApplicationStatus.rejected => (
          const Color(0xFFFFE4E6),
          const Color(0xFFBE123C),
          'REFUSE',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      height: 17,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 9,
            letterSpacing: 0.55,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _validerButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      height: 17,
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, size: 10, color: Color(0xFF1D8869)),
          const SizedBox(width: 4),
          Text(
            'VALIDER',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 9,
              letterSpacing: 0.55,
              color: const Color(0xFF1D8869),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TAB 1 - DESCRIPTION
// -----------------------------------------------------------------------------
class _DescriptionTab extends StatelessWidget {
  final JobEntity job;
  const _DescriptionTab({required this.job});

  @override
  Widget build(BuildContext context) {
    final contractLabel = switch (job.contractType) {
      ContractType.cdi => 'CDI',
      ContractType.mission => 'Mission',
      ContractType.freelance => 'Freelance',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(7, 0, 7, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // â”€â”€ Job Description section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          _sectionHeader('Description du poste'),
          const SizedBox(height: 9),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.description.trim().isNotEmpty
                      ? job.description
                      : 'Description non precisee.',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    height: 26 / 15,
                    color: const Color(0xFF4A454F),
                  ),
                ),
                const SizedBox(height: 12),
                // Tags
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    contractLabel,
                    if ((job.scheduleLabel ?? '').trim().isNotEmpty)
                      job.scheduleLabel!,
                    if ((job.city ?? '').trim().isNotEmpty)
                      job.city!,
                  ]
                      .map((t) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF401E66),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              t.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                                letterSpacing: 0.5,
                                color: Colors.white,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12), // Gap 12px

          // â”€â”€ Hiring Manager section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          _sectionHeader('Responsable du recrutement'),
          const SizedBox(height: 9),
          _HiringManagerCard(job: job),
          const SizedBox(height: 12), // Gap 12px
          _MapPreview(
            placeName: (job.city ?? '').trim().isNotEmpty
                ? job.city!
                : ((job.location ?? '').trim().isNotEmpty
                    ? job.location!
                    : job.companyName),
            lat: job.latitude,
            lng: job.longitude,
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String label) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF3A1B5E),
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: const Color(0xFF401E66),
          ),
        ),
      ],
    );
  }
}

class _HiringManagerCard extends ConsumerWidget {
  final JobEntity job;
  const _HiringManagerCard({required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void openRecruiterPublicProfile() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecruiterPublicProfileScreen(
            recruiterId: job.recruiterId,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: openRecruiterPublicProfile,
              child: Row(
                children: [
                  // Avatar
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipOval(
                          child: Builder(builder: (_) {
                            final avatar = job.recruiterAvatarAsset;
                            final fallback = Container(
                              width: 56,
                              height: 56,
                              color: const Color(0xFFE9E6EC),
                              alignment: Alignment.center,
                              child: const Icon(Icons.person, size: 30, color: AppColors.violet),
                            );
                            if (avatar == null || avatar.isEmpty) return fallback;
                            if (avatar.startsWith('http')) {
                              return Image.network(
                                avatar,
                                width: 56, height: 56, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => fallback,
                              );
                            }
                            return Image.asset(
                              avatar,
                              width: 56, height: 56, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => fallback,
                            );
                          }),
                        ),
                        Positioned(
                          right: -4,
                          bottom: -4,
                          child: Container(
                            width: 23,
                            height: 22.5,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC1AA62),
                              borderRadius: BorderRadius.circular(9999),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.workspace_premium,
                              size: 11,
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
                          job.recruiterName,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            height: 24 / 16,
                            color: const Color(0xFF1D1B1F),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          job.recruiterRole,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            height: 16 / 12,
                            color: const Color(0xFF665976),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Builder(builder: (context) {
                          final recruiterAsync = ref.watch(publicRecruiterProvider(job.recruiterId));
                          final reviewsAsync = ref.watch(publicRecruiterReviewsProvider(job.recruiterId));
                          final rating = recruiterAsync.valueOrNull?.rating ?? 0.0;
                          final reviewCount = reviewsAsync.valueOrNull?.length ?? 0;
                          return Row(
                            children: [
                              const Icon(Icons.star, size: 12, color: Color(0xFF6F5D1D)),
                              const SizedBox(width: 4),
                              Text(
                                rating > 0 ? rating.toStringAsFixed(1) : '-',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  height: 20 / 14,
                                  color: const Color(0xFF1D1B1F),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '($reviewCount avis)',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  height: 16 / 12,
                                  color: const Color(0xFF7C7580),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Message button
          GestureDetector(
            onTap: () async {
              final messagingController = ref.read(messagingControllerProvider.notifier);
              final contactId = int.tryParse(job.recruiterId) ?? 0;
              final conversation = await messagingController.getOrCreateConversationById(contactId);

              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrivateMessageScreen(
                      conversation: conversation,
                    ),
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
                  size: 18, color: Color(0xFF545665)),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;
  const _BulletList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ',
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            color: const Color(0xFF4A454F))),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          height: 26 / 15,
                          color: const Color(0xFF4A454F),
                        ),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _MapPreview extends StatefulWidget {
  final String placeName;
  final double? lat;
  final double? lng;
  const _MapPreview({required this.placeName, this.lat, this.lng});

  @override
  State<_MapPreview> createState() => _MapPreviewState();
}

class _MapPreviewState extends State<_MapPreview> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final lat = widget.lat ?? 36.762;
    final lng = widget.lng ?? 3.040;
    final placeName = widget.placeName.trim().isEmpty
        ? 'Emplacement non precise'
        : widget.placeName;
    
    return GestureDetector(
      onTap: () async {
        // Ouvrir Google Maps avec les coordonnées
        final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        height: 158,
        decoration: BoxDecoration(
          color: const Color(0xFFEFEDF2),
          border: Border.all(color: const Color(0xFFCCC3D0)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(lat, lng),
                  initialZoom: 12.6,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                  ),
                ],
              ),
            ),
            Center(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _animation.value,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0x337F13EC),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.location_on, size: 20, color: AppColors.violet),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 12,
              left: 49,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Color(0xFF401E66)),
                    const SizedBox(width: 8),
                    Text(
                      placeName,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 20 / 13,
                        color: const Color(0xFF401E66),
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

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// TAB 2 "“ COMMENTAIRES (collapsible threads)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class _CommentsTab extends ConsumerStatefulWidget {
  final JobEntity job;
  const _CommentsTab({required this.job});

  @override
  ConsumerState<_CommentsTab> createState() => _CommentsTabState();
}

class _CommentsTabState extends ConsumerState<_CommentsTab> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  late List<JobCommentEntity> _comments;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _comments = List<JobCommentEntity>.from(widget.job.comments);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final question = _commentController.text.trim();
    if (question.isEmpty || _isSending) return;
    setState(() => _isSending = true);
    try {
      final newComment = await ref
          .read(jobsControllerProvider)
          .addJobComment(widget.job.id, question);
      if (!mounted) return;
      setState(() {
        _comments = [newComment, ..._comments];
        _commentController.clear();
        _isSending = false;
      });
      _commentFocusNode.unfocus();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'envoyer le commentaire.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final expanded = ref.watch(_expandedThreadsProvider);
    final currentUserAsync = ref.watch(candidateCurrentUserProvider);
    final currentUser = currentUserAsync.valueOrNull;
    final userInitial =
        (currentUser?.name.trim().isNotEmpty ?? false) ? currentUser!.name[0].toUpperCase() : 'U';
    final avatarUrl = currentUser?.avatarUrl?.trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            if (_comments.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Center(
                  child: Text(
                    'Aucun commentaire pour le moment.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
              )
            else
              ..._comments.asMap().entries.map((entry) {
                final idx = entry.key;
                final comment = entry.value;
                final isExpanded = expanded.contains(idx);
                final isLast = idx == _comments.length - 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  child: _CommentThread(
                    comment: comment,
                    jobId: widget.job.id,
                    isExpanded: isExpanded,
                    isFirst: idx == 0,
                    onToggle: () {
                      final notifier = ref.read(_expandedThreadsProvider.notifier);
                      final current = Set<int>.from(notifier.state);
                      if (current.contains(idx)) {
                        current.remove(idx);
                      } else {
                        current.add(idx);
                      }
                      notifier.state = current;
                    },
                  ),
                );
              }),
            const SizedBox(height: 12),
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE7E0E7))),
              ),
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFF4F1F9),
                    backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                        ? (avatarUrl.startsWith('http')
                            ? NetworkImage(avatarUrl)
                            : AssetImage(avatarUrl) as ImageProvider)
                        : null,
                    child: (avatarUrl == null || avatarUrl.isEmpty)
                        ? Text(
                            userInitial,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4A454F),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEDF2),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        controller: _commentController,
                        focusNode: _commentFocusNode,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _submitComment(),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: Color(0xFF1D1B1F),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Ajouter un commentaire...',
                          hintStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: _isSending ? null : _submitComment,
                    icon: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            size: 20,
                            color: Color(0xFF4A454F),
                          ),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentThread extends ConsumerStatefulWidget {
  final JobCommentEntity comment;
  final String jobId;
  final bool isExpanded;
  final bool isFirst;
  final VoidCallback onToggle;

  const _CommentThread({
    required this.comment,
    required this.jobId,
    required this.isExpanded,
    required this.isFirst,
    required this.onToggle,
  });

  @override
  ConsumerState<_CommentThread> createState() => _CommentThreadState();
}

class _CommentThreadState extends ConsumerState<_CommentThread> {
  final _replyController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSendingReply = false;

  @override
  void dispose() {
    _replyController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasReply = widget.comment.reply.trim().isNotEmpty;
    final repliesCount = hasReply ? 1 : 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFEBD9FC),
                                    width: 2,
                                  ),
                                  color: const Color(0xFFF4F1F9),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  widget.comment.authorName.isNotEmpty ? widget.comment.authorName[0] : '?',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Color(0xFF4A454F),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.comment.authorName,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  height: 20 / 13,
                                  color: AppColors.violet,
                                ),
                              ),
                              Text(
                                'Candidate • ${_formatCommentDate(widget.comment.date)}',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                  height: 16 / 13,
                                  color: Color(0xFF4A454F),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReportCommentScreen(
                              authorName: widget.comment.authorName,
                              commentText: widget.comment.question,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.outlined_flag,
                        size: 16,
                        color: Color(0xFF4A454F),
                      ),
                      label: const Text(
                        'Signaler',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF4A454F),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 6,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.comment.question,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    height: 23 / 13,
                    color: Color(0xFF545665),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFFE7E0E7)),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onToggle,
                        child: Row(
                          children: [
                            Text(
                              'Réponses ($repliesCount)',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF3A1B5E),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.chat_bubble_outline,
                              size: 18,
                              color: Color(0xFF4A454F),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      const Icon(
                        Icons.share_outlined,
                        size: 18,
                        color: Color(0xFF4A454F),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (widget.isExpanded) ...[
            Container(
              decoration: const BoxDecoration(
                color: Color(0x08513376), // Subtle purple tint
              ),
              child: Column(
                children: [
                  
                  if (hasReply)
                    _NestedReply(
                      name: widget.comment.recruitorLabel,
                      role: 'Recruteur',
                      date: _formatCommentDate(widget.comment.recruitorDate),
                      text: widget.comment.reply,
                      highlighted: true,
                    ),
                  InkWell(
                    onTap: widget.onToggle,
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(24, 12, 24, 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.keyboard_arrow_up,
                            size: 16,
                            color: Color(0xFF3A1B5E),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Voir moins',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Color(0xFF3A1B5E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE7E0E7))),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 43,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEDF2),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        controller: _replyController,
                        focusNode: _focusNode,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: Color(0xFF1D1B1F),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Écrire une réponse...',
                          hintStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _isSendingReply ? null : () async {
                      final text = _replyController.text.trim();
                      if (text.isEmpty) return;
                      setState(() => _isSendingReply = true);
                      try {
                        await ref
                            .read(jobsControllerProvider)
                            .replyToJobComment(widget.jobId, widget.comment.id, text);
                        _replyController.clear();
                        _focusNode.unfocus();
                      } catch (_) {
                        // silent
                      } finally {
                        if (mounted) setState(() => _isSendingReply = false);
                      }
                    },
                    child: _isSendingReply
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            size: 24,
                            color: Color(0xFF401E66),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _formatCommentDate(String isoDate) {
  try {
    final dt = DateTime.parse(isoDate).toLocal();
    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${dt.day} ${months[dt.month - 1]}';
  } catch (_) {
    return isoDate;
  }
}

class _NestedReply extends StatelessWidget {
  final String name;
  final String? role;
  final String date;
  final String text;
  final bool highlighted;

  const _NestedReply({
    required this.name,
    required this.role,
    required this.date,
    required this.text,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: highlighted ? const Color(0xFFF3F1F9) : Colors.white,
            border: const Border(
              left: BorderSide(color: Color(0x33513376), width: 2),
            ),
          ),
          padding: EdgeInsets.fromLTRB(16, 16, 16, highlighted ? 16 : 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE9E6EC),
                ),
                alignment: Alignment.center,
                child: Text(
                  name.isNotEmpty ? name[0] : '?',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF4A454F),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Color(0xFF1D1B1F),
                            ),
                          ),
                        ),
                        if (role != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            role!,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              color: Color(0xFF401E66),
                            ),
                          ),
                        ],
                        const Spacer(),
                        Text(
                          date,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: Color(0xFF4A454F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      text,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        height: 21 / 13,
                        color: Color(0xFF4A454F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          top: 16,
          child: Container(
            width: 16,
            height: 2,
            color: const Color(0x33513376),
          ),
        ),
      ],
    );
  }
}

// Floating Apply Button
class _InlineApplyButton extends ConsumerWidget {
  final JobEntity job;
  const _InlineApplyButton({required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final motivationLetter = await _showMotivationLetterOverlay(context);
        if (motivationLetter == null) return;
        ref
            .read(applicationsNotifierProvider.notifier)
            .apply(job.id, motivationLetter: motivationLetter);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Candidature envoyee !'),
              backgroundColor: AppColors.violet,
            ),
          );
        }
      },
      child: Container(
        width: 86,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(106.58, 0), // Note: CSS degrees to Alignment is tricky, but we'll approximate with the provided colors
            end: Alignment.bottomRight,
            colors: [Color(0xFF331554), Color(0xFF4A2D6B)],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'Candidater',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 12,
            height: 20 / 12,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<String?> _showMotivationLetterOverlay(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lettre de motivation',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                minLines: 4,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Ecrivez votre motivation...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(ctx).pop(controller.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.violet,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Envoyer candidature'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return result;
  }
}

class _WithdrawApplicationButton extends ConsumerWidget {
  final String applicationId;
  const _WithdrawApplicationButton({required this.applicationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        await ref
            .read(applicationsNotifierProvider.notifier)
            .cancel(applicationId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Candidature retiree'),
              backgroundColor: AppColors.violet,
            ),
          );
          Navigator.pop(context);
        }
      },
      child: Container(
        width: 86,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFEFEDF2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD1C9DA)),
        ),
        child: const Text(
          'Retirer',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 12,
            height: 20 / 12,
            color: Color(0xFF401E66),
          ),
        ),
      ),
    );
  }
}


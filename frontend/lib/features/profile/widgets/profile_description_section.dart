import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/features/profile/data/providers/profile_provider.dart';
import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';
import 'package:job_app/features/profile/domain/user_entity.dart';
import 'package:job_app/core/utils/icon_utils.dart';
import 'package:job_app/core/utils/color_utils.dart';

class ProfileDescriptionSection extends ConsumerWidget {
  final bool isRecruiterView;
  final bool canReplyToReviews;
  final ProviderListenable<AsyncValue<UserEntity>>? userProvider;
  final ProviderListenable<AsyncValue<List<EmployeeReviewEntity>>>?
      reviewsProvider;

  const ProfileDescriptionSection({
    super.key,
    this.isRecruiterView = false,
    this.canReplyToReviews = true,
    this.userProvider,
    this.reviewsProvider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = userProvider != null
        ? ref.watch(userProvider!)
        : isRecruiterView
            ? ref.watch(currentUserProvider)
            : ref.watch(candidateCurrentUserProvider);
    final reviewsAsync = reviewsProvider != null
        ? ref.watch(reviewsProvider!)
        : isRecruiterView
            ? ref.watch(employeeReviewsProvider)
            : ref.watch(candidateEmployeeReviewsProvider);
    final jobsCount = ref.watch(jobsNotifierProvider).valueOrNull?.length ?? 0;

    return userAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: Color(0xFF401E66)),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (user) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Info chips ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22.5),
                child: Row(
                  children: [
                    _InfoChip(
                      circleColor: const Color(0xFFF3F3F3),
                      icon: Icons.star_rounded,
                      iconColor: const Color(0xFF401E66),
                      mainText: user.rating.toStringAsFixed(1),
                      mainTextSize: 14,
                      subText: 'Notation',
                      iconSpacing: 18,
                    ),
                    const SizedBox(width: 13),
                    if (isRecruiterView)
                      _InfoChip(
                        circleColor: const Color(0xFFF3F3F3),
                        icon: Icons.campaign_outlined,
                        iconColor: Colors.black,
                        mainText: '$jobsCount',
                        mainTextSize: 14,
                        subText: 'Annonces',
                        iconSpacing: 10,
                      )
                    else
                      _InfoChip(
                        circleColor: const Color(0xFFF3F3F3),
                        icon: IconUtils.getSmartIcon(user.domain),
                        iconColor: Colors.black,
                        mainText: user.domain,
                        mainTextSize: 11,
                        iconSpacing: 6,
                      ),
                    const SizedBox(width: 13),
                    _InfoChip(
                      circleColor: const Color(0xFF401E66),
                      icon: Icons.description_outlined,
                      iconColor: Colors.white,
                      mainText: '${user.missionsCount}',
                      mainTextSize: 16,
                      subText: 'Missions',
                      iconSpacing: 18,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── About Me card ───────────────────────────────────────────
              Container(
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
                      'À propos',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Color(0xFF1B1B1B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.bio,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF4B444F),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Recent Feedback header ──────────────────────────────────
              const Text(
                'Avis sur mes missions',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Color(0xFF1B1B1B),
                ),
              ),
              const SizedBox(height: 8),

              // ── Reviews container ───────────────────────────────────────
              reviewsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(color: Color(0xFF401E66)),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (reviews) {
                  final items = reviews.take(3).toList();
                  if (items.isEmpty) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border:
                          Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < items.length; i++) ...[
                          if (i > 0) const SizedBox(height: 16),
                          _ReviewCard(
                            review: items[i],
                            canReply: canReplyToReviews,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Info Chip ──────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final Color circleColor;
  final IconData icon;
  final Color iconColor;
  final String mainText;
  final double mainTextSize;
  final String? subText;
  final double iconSpacing;

  const _InfoChip({
    required this.circleColor,
    required this.icon,
    required this.iconColor,
    required this.mainText,
    required this.mainTextSize,
    this.subText,
    this.iconSpacing = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFEEEBF4), width: 1),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3A1B5E).withAlphaValue(0.05),
              blurRadius: 4,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 6),
            Container(
              width: 30,
              height: 35,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size:16, color: iconColor),
            ),
            SizedBox(width: iconSpacing),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mainText,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize:15 ,
                      color: const Color.fromARGB(255, 27, 26, 26),
                      height: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subText != null && subText!.isNotEmpty)
                    Text(
                      subText!,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        height: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
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

// ─── Review Card ─────────────────────────────────────────────────────────────

class _ReviewCard extends StatefulWidget {
  final EmployeeReviewEntity review;
  final bool canReply;

  const _ReviewCard({required this.review, this.canReply = true});

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _isExpanded = false;
  bool _isReplying = false;
  final TextEditingController _replyController = TextEditingController();
  String? _localReply;
  String? _localReplyAuthor;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  ImageProvider? get _avatarProvider {
    final av = widget.review.authorAvatar;
    if (av == null || av.trim().isEmpty) return null;
    return av.startsWith('http') ? NetworkImage(av) : AssetImage(av) as ImageProvider;
  }

  @override
  Widget build(BuildContext context) {
    final hasReply = widget.review.recruiterReply != null || _localReply != null;
    final hasStars = widget.review.rating > 0;
    final avatar = _avatarProvider;
    final displayReply = _localReply ?? widget.review.recruiterReply;
    final displayReplyAuthor = _localReplyAuthor ?? widget.review.recruiterName ?? 'Réponse';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBFF),
        border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 14, 8, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEFEDF2),
                    image: avatar != null
                        ? DecorationImage(image: avatar, fit: BoxFit.cover)
                        : null,
                  ),
                  child: avatar == null
                      ? Center(
                          child: Text(
                            widget.review.authorName[0].toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xFF401E66),
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                // Name + Role
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.review.authorName,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        widget.review.authorRole,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                // Stars + Report icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (hasStars) ...[
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: i < widget.review.rating.round()
                                ? const Color(0xFF401E66)
                                : const Color(0xFFCBD5E1),
                          );
                        }),
                      ),
                      const SizedBox(width: 5),
                    ],
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/report-comment',
                          arguments: {
                            'authorName': widget.review.authorName,
                            'commentText': widget.review.comment,
                          },
                        );
                      },
                      child: const Icon(
                        Icons.flag_outlined,
                        size: 18,
                        color: Color(0xFF401E66),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Review text ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
            child: Text(
              '"${widget.review.comment}"',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w400,
                fontSize: 13,
                height: 1.54,
                color: Color(0xFF475569),
              ),
            ),
          ),

          // ── Footer ────────────────────────────────────────────────
          if (hasReply && _isExpanded) ...[
            // Response block
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
                decoration: BoxDecoration(
                  color: const Color(0x0D7F13EC),
                  borderRadius: BorderRadius.circular(8),
                  border: const Border(
                    left: BorderSide(color: Color(0xFF401E66), width: 2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          displayReplyAuthor,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: Color(0xFF401E66),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Ma réponse',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayReply!,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        height: 1.33,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Voir moin
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => setState(() => _isExpanded = false),
                  child: const Text(
                    'Voir moin',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Color(0xFF3A1B5E),
                    ),
                  ),
                ),
              ),
            ),
          ] else if (hasReply && !_isExpanded) ...[
            // Voir reponse
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => setState(() => _isExpanded = true),
                  child: const Text(
                    'Voir reponse',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Color(0xFF3A1B5E),
                    ),
                  ),
                ),
              ),
            ),
          ] else if (widget.canReply) ...[
            // Reply input
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFEEEBF4), width: 1),
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _isReplying
                  ? Column(
                      children: [
                        TextField(
                          controller: _replyController,
                          decoration: const InputDecoration(
                            hintText: 'Écrire une réponse...',
                            hintStyle: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Color(0xFF94A3B8),
                            ),
                            border: InputBorder.none,
                          ),
                          maxLines: 3,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isReplying = false;
                                  _replyController.clear();
                                });
                              },
                              child: const Text(
                                'Annuler',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                if (_replyController.text.trim().isNotEmpty) {
                                  setState(() {
                                    _localReply = _replyController.text.trim();
                                    _localReplyAuthor = 'Farouja';
                                    _isReplying = false;
                                    _isExpanded = true;
                                    _replyController.clear();
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF401E66),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text(
                                'Envoyer',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : GestureDetector(
                      onTap: () {
                        setState(() {
                          _isReplying = true;
                        });
                      },
                      child: Container(
                        height: 33,
                        alignment: Alignment.centerLeft,
                        child: const Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Écrire une réponse...',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                            Icon(
                              Icons.send,
                              size: 16,
                              color: Color(0xFF401E66),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

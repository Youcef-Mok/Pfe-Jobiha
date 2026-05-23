import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/profile/data/providers/profile_provider.dart';
import 'package:job_app/features/profile/domain/user_entity.dart';

/// Section des avis des employés
class ProfileReviewsSection extends ConsumerStatefulWidget {
  final ProviderListenable<AsyncValue<List<EmployeeReviewEntity>>>?
      reviewsProvider;

  const ProfileReviewsSection({super.key, this.reviewsProvider});

  @override
  ConsumerState<ProfileReviewsSection> createState() =>
      _ProfileReviewsSectionState();
}

class _ProfileReviewsSectionState extends ConsumerState<ProfileReviewsSection> {
  String _selectedFilter = 'recent';

  @override
  Widget build(BuildContext context) {
    final provider = widget.reviewsProvider ?? employeeReviewsProvider;
    final reviewsAsync = ref.watch(provider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 40),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          reviewsAsync.when(
            loading: () => const _RatingSummaryCard(rating: 0, count: 0),
            error: (_, __) => const _RatingSummaryCard(rating: 0, count: 0),
            data: (reviews) {
              final count = reviews.length;
              final avg = count == 0
                  ? 0.0
                  : reviews.map((r) => r.rating).reduce((a, b) => a + b) / count;
              return _RatingSummaryCard(rating: avg, count: count);
            },
          ),
          const SizedBox(height: 16),
          // Liste horizontale de filtres
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('recent', 'Plus récents'),
                const SizedBox(width: 8),
                _buildFilterChip('best', 'Mieux notés'),
                const SizedBox(width: 8),
                _buildFilterChip('replied', 'Avec réponse'),
                const SizedBox(width: 8),
                _buildFilterChip('unreplied', 'Sans réponse'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Liste des avis
          reviewsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Center(
              child: Text('Erreur: $error'),
            ),
            data: (reviews) {
              // Appliquer le filtrage
              var filtered = List<EmployeeReviewEntity>.from(reviews);
              if (_selectedFilter == 'best') {
                filtered.sort((a, b) => b.rating.compareTo(a.rating));
              } else if (_selectedFilter == 'replied') {
                filtered = filtered.where((r) => r.recruiterReply != null).toList();
              } else if (_selectedFilter == 'unreplied') {
                filtered = filtered.where((r) => r.recruiterReply == null).toList();
              }
              // 'recent' est supposé être le défaut du backend

              if (filtered.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Aucun avis pour le moment'),
                  ),
                );
              }

              return Column(
                children: filtered.asMap().entries.map((entry) {
                  final index = entry.key;
                  final review = entry.value;

                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: index == filtered.length - 1 ? 0 : 16),
                    child: _ReviewCard(review: review),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          setState(() => _selectedFilter = value);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF401E66) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF401E66) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF401E66).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            fontSize: 13,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatefulWidget {
  final EmployeeReviewEntity review;

  const _ReviewCard({required this.review});

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  final TextEditingController _replyController = TextEditingController();
  String? _localReply;
  bool _isExpanded = false;

  ImageProvider? _avatarProvider(String? avatar) {
    if (avatar == null || avatar.trim().isEmpty) return null;
    final v = avatar.trim();
    if (v.startsWith('http://') || v.startsWith('https://')) {
      return NetworkImage(v);
    }
    return AssetImage(v);
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _submitReply() {
    final text = _replyController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _localReply = text;
        _isExpanded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasReply = widget.review.recruiterReply != null || _localReply != null;
    final replyText = _localReply ?? widget.review.recruiterReply;
    final avatarProvider = _avatarProvider(widget.review.authorAvatar);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBFF),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(15),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFEFEDF2), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avec avatar + nom + rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar + Nom + Rôle
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9999),
                            color: AppColors.slate100,
                            image: avatarProvider != null
                                ? DecorationImage(
                                    image: avatarProvider,
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: avatarProvider == null
                              ? Center(
                                  child: Text(
                                    widget.review.authorName[0].toUpperCase(),
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: const Color(0xFF3A1B5E),
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),

                        // Nom + Rôle
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.review.authorName,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                height: 1.43,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              widget.review.authorRole,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                height: 1.33,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Rating étoiles
                    _StarRating(rating: widget.review.rating),
                  ],
                ),
                const SizedBox(height: 12),

                // Commentaire
                Text(
                  widget.review.comment.trim().isEmpty
                      ? 'Aucun commentaire'
                      : '"${widget.review.comment}"',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    height: 1.43,
                    color: const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),

          // Bouton Voir réponse
          if (hasReply)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, bottom: 12),
                child: InkWell(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Text(
                    _isExpanded ? 'Masquer réponse' : 'Voir reponse',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: const Color(0xFF3A1B5E),
                    ),
                  ),
                ),
              ),
            ),

          // Section Réponse (Expandable)
          if (hasReply && _isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F3FE),
                border: const Border(
                  left: BorderSide(color: Color(0xFF401E66), width: 2),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.review.recruiterName ?? 'Marc-Antoine Lefebvre',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: const Color(0xFF401E66),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Response',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    replyText!,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      height: 1.33,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),

          // Champ de réponse (si pas de réponse)
          if (!hasReply)
            _ReplyInput(
              controller: _replyController,
              onSubmit: _submitReply,
            ),
        ],
      ),
    );
  }
}

class _ReplyInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const _ReplyInput({required this.controller, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0x0D7F13EC),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0x337F13EC),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: const Icon(Icons.edit, size: 12, color: Color(0xFF7F13EC)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onSubmit(),
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.slate900),
                decoration: InputDecoration(
                  hintText: 'Écrire une réponse...',
                  hintStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: const Color(0xFF94A3B8),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 9),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onSubmit,
            icon: const Icon(Icons.send, size: 16, color: Color(0xFF401E66)),
          ),
        ],
      ),
    );
  }
}

class _RatingSummaryCard extends StatelessWidget {
  final double rating;
  final int count;
  const _RatingSummaryCard({required this.rating, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 384),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            const SizedBox(width: 8),
            // Note
            Text(
              rating > 0 ? rating.toStringAsFixed(1) : '-',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w800,
                fontSize: 25,
                color: const Color(0xFF3A1B5E),
                letterSpacing: -1.2,
              ),
            ),
            const SizedBox(width: 16),
            // Diviseur
            const VerticalDivider(
              color: Color(0xFFE2E8F0),
              width: 1,
              thickness: 1,
              indent: 8,
              endIndent: 8,
            ),
            const SizedBox(width: 16),
            // Étoiles et nombre d'avis
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return const Padding(
                        padding: EdgeInsets.only(right: 2),
                        child: Icon(
                          Icons.star,
                          size: 13,
                          color: Color(0xFFC1AA62),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$count AVIS VÉRIFIÉS',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                      letterSpacing: 0.6,
                      color: const Color(0xFF665976),
                    ),
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

class _StarRating extends StatelessWidget {
  final double rating;

  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            Icons.star,
            size: 13,
            color: index < rating.floor()
                ? const Color(0xFF7F13EC)
                : const Color(0xFFCBD5E1),
          ),
        );
      }),
    );
  }
}

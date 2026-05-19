import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/profile/data/providers/profile_provider.dart';
import 'package:job_app/features/profile/domain/user_entity.dart';

/// Section des avis des employés
class ProfileReviewsSection extends ConsumerStatefulWidget {
  const ProfileReviewsSection({super.key});

  @override
  ConsumerState<ProfileReviewsSection> createState() =>
      _ProfileReviewsSectionState();
}

class _ProfileReviewsSectionState extends ConsumerState<ProfileReviewsSection> {
  String _selectedFilter = 'recent';

  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(employeeReviewsProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 40),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Employee Reviews',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              height: 1.56,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 8),

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
                children: reviews.asMap().entries.map((entry) {
                  final index = entry.key;
                  final review = entry.value;

                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: index == reviews.length - 1 ? 0 : 16),
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
                    color: const Color(0xFF401E66).withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            fontSize: 13,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasReply =
        widget.review.recruiterReply != null || _localReply != null;
    final replyText = _localReply ?? widget.review.recruiterReply;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 15, 5, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(15),
      ),
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
                    ),
                    child: widget.review.authorAvatar != null
                        ? ClipOval(
                            child: Image.asset(
                              widget.review.authorAvatar!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  widget.review.authorName[0].toUpperCase(),
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
                              widget.review.authorName[0].toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: AppColors.violet,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),

                  // Nom + Rôle
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.review.authorName,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          height: 1.43,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        widget.review.authorRole,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          height: 1.33,
                          color: Color(0xFF64748B),
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
          const SizedBox(height: 8),

          // Commentaire
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Text(
              widget.review.comment.trim().isEmpty
                  ? 'Aucun commentaire'
                  : widget.review.comment,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 1.43,
                color: Color(0xFF475569),
              ),
            ),
          ),

          if (hasReply) ...[
            const SizedBox(height: 9),
            Container(
              width: 342,
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F3FE),
                border: const Border(
                  left: BorderSide(color: Color(0xFF401E66), width: 2),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom du recruteur + Label Response
                  Row(
                    children: [
                      Text(
                        widget.review.recruiterName ?? 'Marc-Antoine Lefebvre',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          height: 1.33,
                          color: Color(0xFF401E66),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Response',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          height: 1.33,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Réponse
                  Text(
                    replyText!,
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
          ],

          // Champ de réponse (si pas de réponse du recruteur)
          if (!hasReply) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0x0D7F13EC),
                border: const Border(
                  top: BorderSide(color: Color(0x1A7F13EC)),
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  // Avatar du recruteur
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0x337F13EC),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 12,
                      color: Color(0xFF7F13EC),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Input field
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0), // Modifié pour TextField
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _replyController,
                              onSubmitted: (_) => _submitReply(),
                              decoration: const InputDecoration(
                                hintText: 'Écrire une réponse...',
                                hintStyle: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Color(0xFF94A3B8),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 9),
                              ),
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _submitReply,
                            child: const Icon(
                              Icons.send,
                              size: 16,
                              color: AppColors.violet,
                            ),
                          ),
                        ],
                      ),
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

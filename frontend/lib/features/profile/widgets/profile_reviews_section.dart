import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/profile/data/providers/profile_provider.dart';
import 'package:job_app/features/profile/domain/user_entity.dart';

/// Section des avis des employés
class ProfileReviewsSection extends ConsumerStatefulWidget {
  const ProfileReviewsSection({super.key});

  @override
  ConsumerState<ProfileReviewsSection> createState() => _ProfileReviewsSectionState();
}

class _ProfileReviewsSectionState extends ConsumerState<ProfileReviewsSection> {
  String _selectedFilter = 'recent';

  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(employeeReviewsProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 16, 15, 40),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre de section
          const Text(
            'Recent Employee Reviews',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              height: 1.56,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),

          // Filter Tabs
          SizedBox(
            height: 38,
            child: Row(
              children: [
                _FilterButton(
                  label: 'Plus récents',
                  isSelected: _selectedFilter == 'recent',
                  onTap: () => setState(() => _selectedFilter = 'recent'),
                ),
                const SizedBox(width: 8),
                _FilterButton(
                  label: 'Mieux notés',
                  isSelected: _selectedFilter == 'best',
                  onTap: () => setState(() => _selectedFilter = 'best'),
                ),
                const SizedBox(width: 8),
                _FilterButton(
                  label: 'Avec réponse',
                  isSelected: _selectedFilter == 'replied',
                  onTap: () => setState(() => _selectedFilter = 'replied'),
                ),
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
              if (reviews.isEmpty) {
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
                    padding: EdgeInsets.only(bottom: index == reviews.length - 1 ? 0 : 16),
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
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isSelected ? 9 : 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF401E66) : Colors.white,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
            height: 1.43,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final EmployeeReviewEntity review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 15, 5, 15),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBFF),
        border: Border.all(color: const Color(0xFFF6F3F8)),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
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
                    child: review.authorAvatar != null
                        ? ClipOval(
                            child: Image.network(
                              review.authorAvatar!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  review.authorName[0].toUpperCase(),
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
                              review.authorName[0].toUpperCase(),
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
                        review.authorName,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          height: 1.43,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        review.authorRole,
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
              _StarRating(rating: review.rating),
            ],
          ),
          const SizedBox(height: 8),

          // Commentaire
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Text(
              review.comment.trim().isEmpty ? 'Aucun commentaire' : review.comment,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 1.43,
                color: Color(0xFF475569),
              ),
            ),
          ),

          // Réponse du recruteur (si elle existe)
          if (review.recruiterReply != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
              decoration: BoxDecoration(
                color: const Color(0x0D7F13EC),
                border: const Border(
                  left: BorderSide(color: Color(0xFF401E66), width: 2),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom du recruteur + Date
                  Row(
                    children: [
                      Text(
                        review.recruiterName ?? 'Marc-Antoine Lefebvre',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          height: 1.33,
                          color: Color(0xFF401E66),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        review.recruiterReplyDate ?? 'Réponse',
                        style: const TextStyle(
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
                    review.recruiterReply!,
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
          if (review.recruiterReply == null) ...[
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
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
                          const Icon(
                            Icons.send,
                            size: 16,
                            color: Color(0xFF7F13EC),
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
        return Icon(
          Icons.star,
          size: 15,
          color: index < rating.floor()
              ? const Color(0xFF7F13EC)
              : const Color(0xFFCBD5E1),
        );
      }),
    );
  }
}

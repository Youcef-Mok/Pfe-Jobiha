// features/candidates/widgets/candidate_card.dart
import 'package:flutter/material.dart';
import 'package:job_app/features/candidates/domain/candidate_entity.dart';

class CandidateCard extends StatelessWidget {
  final CandidateEntity candidate;
  final VoidCallback onTap;
  final VoidCallback? onArchive;

  const CandidateCard({
    super.key,
    required this.candidate,
    required this.onTap,
    this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final isArchived = candidate.status == CandidateStatus.archive;
    
    return Opacity(
      opacity: isArchived ? 0.7 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 181,
          height: 177,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: isArchived ? const Color(0xFF401E66).withValues(alpha: 0.3) : const Color(0xFFE7E0E7),
              width: isArchived ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isArchived ? const Color(0x0A401E66) : const Color(0x0D000000),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(11, 14, 11, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo - left aligned with padding
                Padding(
                  padding: const EdgeInsets.only(left: 45),
                  child: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(candidate.photoUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                // Name and title container
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      candidate.name,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 19,
                        height: 20 / 19,
                        color: Color(0xFF401E66),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Title
                    Text(
                      candidate.title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        height: 20 / 13,
                        color: Color(0xFF4A454F),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Rating row
                Row(
                  children: [
                    // Star icon
                    const Icon(
                      Icons.star,
                      size: 12,
                      color: Color(0xFF6F5D1D),
                    ),
                    const SizedBox(width: 4),
                    // Rating number
                    Text(
                      candidate.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        height: 24 / 15,
                        color: Color(0xFF1D1B1F),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Reviews text
                    Text(
                      '(${candidate.reviewsCount})', // Raccourci car l'espace est limité
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        height: 16 / 11,
                        color: Color(0xFF7C7580),
                      ),
                    ),
                    const Spacer(),
                    // Bookmark icon
                    GestureDetector(
                      onTap: onArchive,
                      child: Icon(
                        isArchived
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        size: 16,
                        color: isArchived ? const Color(0xFF401E66) : const Color(0xFF000000),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:job_app/features/candidates/domain/feedback_entity.dart';
import 'package:job_app/features/candidates/widgets/profile_feedback_card.dart';

class ProfileFeedbackSection extends StatelessWidget {
  final List<FeedbackEntity> feedbacks;
  final VoidCallback? onViewAll;

  const ProfileFeedbackSection({
    super.key,
    required this.feedbacks,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Feedback',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Color(0xFF0B1C30),
              ),
            ),
            GestureDetector(
              onTap: onViewAll,
              child: const Text(
                'View all',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF401E66),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              for (int i = 0; i < feedbacks.length; i++)
                ProfileFeedbackCard(
                  feedback: feedbacks[i],
                  isLast: i == feedbacks.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

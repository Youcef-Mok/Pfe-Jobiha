import 'package:flutter/material.dart';
import 'package:job_app/features/candidates/domain/feedback_entity.dart';

class ProfileFeedbackCard extends StatelessWidget {
  final FeedbackEntity feedback;
  final bool isLast;

  const ProfileFeedbackCard({
    super.key,
    required this.feedback,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 10),
              _buildReviewText(),
              ..._buildFooter(context),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEBF4)),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatar(),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      feedback.reviewerName,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF0B1C30),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.outlined_flag,
                    size: 14,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                feedback.reviewerRole,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
              if (feedback.cardType != FeedbackCardType.replyInput &&
                  feedback.starCount > 0) ...[
                const SizedBox(height: 5),
                _buildStars(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFEFEDF2),
        image: feedback.reviewerAvatar != null
            ? DecorationImage(
                image: AssetImage(feedback.reviewerAvatar!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: feedback.reviewerAvatar == null
          ? const Icon(Icons.person, size: 20, color: Color(0xFF94A3B8))
          : null,
    );
  }

  Widget _buildStars() {
    return Row(
      children: List.generate(5, (i) {
        return Icon(
          Icons.star_rounded,
          size: 12,
          color: i < feedback.starCount
              ? const Color(0xFF401E66)
              : const Color(0xFFD1C9DD),
        );
      }),
    );
  }

  Widget _buildReviewText() {
    return Text(
      feedback.reviewText,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
        fontSize: 13,
        color: Color(0xFF4B444F),
        height: 1.5,
      ),
    );
  }

  List<Widget> _buildFooter(BuildContext context) {
    switch (feedback.cardType) {
      case FeedbackCardType.collapsed:
        return [
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {},
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Voir réponse',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Color(0xFF3A1B5E),
                    ),
                  ),
                  SizedBox(width: 3),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 10,
                    color: Color(0xFF3A1B5E),
                  ),
                ],
              ),
            ),
          ),
        ];

      case FeedbackCardType.replyInput:
        return [
          const SizedBox(height: 10),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFEEEBF4), width: 1),
              ),
            ),
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Écrire une réponse...',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF401E66),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ];

      case FeedbackCardType.expanded:
        return [
          const SizedBox(height: 10),
          if (feedback.response != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
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
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: feedback.response!.authorName,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: Color(0xFF401E66),
                          ),
                        ),
                        const TextSpan(
                          text: '  •  Response',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    feedback.response!.responseText,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      color: Color(0xFF4B444F),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {},
              child: const Text(
                'Voir moins',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Color(0xFF3A1B5E),
                ),
              ),
            ),
          ),
        ];
    }
  }
}

import 'package:job_app/features/candidates/domain/feedback_entity.dart';

class FeedbackResponseModel {
  final String authorName;
  final String responseText;

  const FeedbackResponseModel({
    required this.authorName,
    required this.responseText,
  });

  FeedbackResponseEntity toEntity() => FeedbackResponseEntity(
        authorName: authorName,
        responseText: responseText,
      );
}

class FeedbackModel {
  final String id;
  final String reviewerName;
  final String reviewerRole;
  final String? reviewerAvatar;
  final int starCount;
  final String reviewText;
  final FeedbackResponseModel? response;
  final FeedbackCardType cardType;

  const FeedbackModel({
    required this.id,
    required this.reviewerName,
    required this.reviewerRole,
    this.reviewerAvatar,
    required this.starCount,
    required this.reviewText,
    this.response,
    required this.cardType,
  });

  FeedbackEntity toEntity() => FeedbackEntity(
        id: id,
        reviewerName: reviewerName,
        reviewerRole: reviewerRole,
        reviewerAvatar: reviewerAvatar,
        starCount: starCount,
        reviewText: reviewText,
        response: response?.toEntity(),
        cardType: cardType,
      );
}

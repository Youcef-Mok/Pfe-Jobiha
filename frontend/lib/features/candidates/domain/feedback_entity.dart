enum FeedbackCardType { collapsed, replyInput, expanded }

class FeedbackResponseEntity {
  final String authorName;
  final String responseText;

  const FeedbackResponseEntity({
    required this.authorName,
    required this.responseText,
  });
}

class FeedbackEntity {
  final String id;
  final String reviewerName;
  final String reviewerRole;
  final String? reviewerAvatar;
  final int starCount;
  final String reviewText;
  final FeedbackResponseEntity? response;
  final FeedbackCardType cardType;

  const FeedbackEntity({
    required this.id,
    required this.reviewerName,
    required this.reviewerRole,
    this.reviewerAvatar,
    required this.starCount,
    required this.reviewText,
    this.response,
    required this.cardType,
  });
}

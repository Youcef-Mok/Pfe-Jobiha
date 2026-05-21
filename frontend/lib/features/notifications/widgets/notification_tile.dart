import 'package:flutter/material.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/notifications/domain/notification_entity.dart';

// Widget tuile notification simplifié (liste compacte).
// Pour la carte complète avec avatar et catégorie, voir notification_card.dart.
//
// TODO(API): Les données viennent de NotificationsRepositoryMock.
//            Brancher sur GET /api/notifications lors de l'intégration backend.

class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: notification.isRead ? Colors.transparent : AppColors.violet.withValues(alpha: 0.04),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDot(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: AppTextStyles.labelBold.copyWith(
                      fontSize: 14,
                      color: notification.isRead
                          ? AppColors.slate600
                          : AppColors.slate900,
                    ),
                  ),
                  if (notification.message != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      notification.message!,
                      style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (onDismiss != null)
              GestureDetector(
                onTap: onDismiss,
                child: const Icon(Icons.close, size: 16, color: AppColors.slate400),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot() {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: notification.isRead
              ? Colors.transparent
              : notification.category.borderColor,
        ),
      ),
    );
  }
}

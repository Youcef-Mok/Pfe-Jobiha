import 'package:flutter/material.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/profile/domain/user_entity.dart';

/// Section des statistiques (Followers, Missions, Rating)
class ProfileStats extends StatelessWidget {
  final UserEntity user;

  const ProfileStats({super.key, required this.user});

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(47, 8, 47, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatCard(
            value: _formatNumber(user.followersCount),
            label: 'FOLLOWERS',
          ),
          const SizedBox(width: 12),

          _StatCard(
            value: user.missionsCount.toString(),
            label: 'MISSIONS',
          ),
          const SizedBox(width: 12),

          _StatCard(
            value: user.rating.toStringAsFixed(1),
            label: 'RATING',
            showStar: true,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final bool showStar;

  const _StatCard({
    required this.value,
    required this.label,
    this.showStar = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 95,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tightHeight =
              constraints.hasBoundedHeight && constraints.maxHeight < 52;
          final narrow = constraints.maxWidth < 78;
          final compact = tightHeight || narrow;

          final valueSize = compact ? 13.0 : 16.0;
          final labelSize = compact ? 9.0 : 11.0;
          final verticalPad = compact ? 4.0 : 8.0;
          final gap = compact ? 1.0 : 3.0;

          return Container(
            padding:
                EdgeInsets.symmetric(vertical: verticalPad, horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0x0D7F13EC),
              border: Border.all(color: const Color(0x1A7F13EC)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: valueSize,
                      height: 1.1,
                      color: AppColors.violet,
                    ),
                  ),
                ),
                SizedBox(height: gap),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (showStar) ...[
                        Icon(
                          Icons.star,
                          size: compact ? 10 : 12,
                          color: AppColors.violet,
                        ),
                        const SizedBox(width: 3),
                      ],
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w600,
                          fontSize: labelSize,
                          height: 1.2,
                          letterSpacing: 0.5,
                          color: AppColors.slate600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/map/domain/map_job_entity.dart';

// TODO(API): Connecter ce widget au vrai SDK cartographique (ex: flutter_map,
//            google_maps_flutter) lors du branchement backend.
//            Remplacer MapJobEntity mock par les données temps réel.

class MapJobMarker extends StatelessWidget {
  final MapJobEntity job;
  final bool isSelected;
  final VoidCallback? onTap;

  const MapJobMarker({
    super.key,
    required this.job,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.violet : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.violet.withValues(alpha: isSelected ? 0.4 : 0.15),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: AppColors.violet,
            width: isSelected ? 0 : 1.5,
          ),
        ),
        child: Text(
          job.salary > 0 ? '${job.salary.toStringAsFixed(0)}€' : job.contractType,
          style: AppTextStyles.badge.copyWith(
            color: isSelected ? Colors.white : AppColors.violet,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

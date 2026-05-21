import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/applications/domain/application_entity.dart';
import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';
import 'package:job_app/features/jobs/domain/create_mission_params.dart';

/// Overlay pour lancer une mission (statut initial : non confirmée).
void showLaunchMissionSheet(
  BuildContext context,
  ApplicationEntity application,
) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => LaunchMissionSheet(application: application),
  );
}

class LaunchMissionSheet extends ConsumerStatefulWidget {
  final ApplicationEntity application;

  const LaunchMissionSheet({super.key, required this.application});

  @override
  ConsumerState<LaunchMissionSheet> createState() =>
      _LaunchMissionSheetState();
}

class _LaunchMissionSheetState extends ConsumerState<LaunchMissionSheet> {
  DateTime? startDate;
  DateTime? endDate;
  bool _submitting = false;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.violet,
              onPrimary: Colors.white,
              onSurface: AppColors.slate900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
          if (endDate != null && endDate!.isBefore(picked)) {
            endDate = null;
          }
        } else {
          endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Sélectionner';
    const months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _launchMission() async {
    if (startDate == null || endDate == null || _submitting) return;
    setState(() => _submitting = true);
    try {
      final app = widget.application;
      await ref.read(jobsControllerProvider).createMission(
            CreateMissionParams(
              jobId: app.jobId,
              jobTitle: app.jobTitle,
              companyName: app.companyName,
              department: app.department,
              startDate: startDate!,
              endDate: endDate!,
              location: app.location,
              candidateName: app.candidateName ?? 'Candidat',
              imageUrl: app.logoAsset,
            ),
          );
      await ref.read(missionsNotifierProvider.notifier).fetch();
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mission créée — en attente de confirmation avant la date de début',
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canLaunch =
        startDate != null && endDate != null && !_submitting;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 350, maxHeight: 380),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFBFB),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Lancer la mission',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Mission pour « ${widget.application.jobTitle} » — statut non confirmée jusqu\'à validation.',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Date de début',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _selectDate(context, true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFFE2E8F0), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 18, color: AppColors.violet),
                          const SizedBox(width: 10),
                          Text(
                            _formatDate(startDate),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: startDate != null
                                  ? AppColors.slate900
                                  : AppColors.slate400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Date de fin',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _selectDate(context, false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFFE2E8F0), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 18, color: AppColors.violet),
                          const SizedBox(width: 10),
                          Text(
                            _formatDate(endDate),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: endDate != null
                                  ? AppColors.slate900
                                  : AppColors.slate400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.slate200,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close,
                      color: AppColors.slate600, size: 22),
                ),
              ),
            ),
            Positioned(
              bottom: 14,
              left: 20,
              right: 20,
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: canLaunch ? _launchMission : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        canLaunch ? AppColors.violet : AppColors.slate200,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.slate200,
                    disabledForegroundColor: AppColors.slate400,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Lancer la mission',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

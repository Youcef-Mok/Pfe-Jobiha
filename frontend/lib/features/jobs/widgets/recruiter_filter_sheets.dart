import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';
import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/features/jobs/widgets/job_card.dart';

Future<void> _openRecruiterSheet(BuildContext context, Widget child) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    showDragHandle: true,
    barrierColor: Colors.black54,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16 + MediaQuery.paddingOf(ctx).bottom,
      ),
      child: child,
    ),
  );
}

void showRecruiterStatusSheet(BuildContext context, JobsTab tab) {
  _openRecruiterSheet(context, _StatusSheet(tab: tab));
}

void showRecruiterDateSheet(BuildContext context, JobsTab tab) {
  _openRecruiterSheet(context, _DateSheet(tab: tab));
}

void showRecruiterDepartmentSheet(BuildContext context) {
  _openRecruiterSheet(context, const _DepartmentSheet());
}

void showRecruiterJobOfferSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    showDragHandle: true,
    barrierColor: Colors.black54,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, scrollController) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 16 + MediaQuery.paddingOf(ctx).bottom,
        ),
        child: _JobOfferSheet(scrollController: scrollController),
      ),
    ),
  );
}

// ─────────────────────────────────────────────
// Status Sheet (Dropdown style)
// ─────────────────────────────────────────────
class _StatusSheet extends ConsumerWidget {
  final JobsTab tab;
  const _StatusSheet({required this.tab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(recruiterFiltersProvider);
    final notifier = ref.read(recruiterFiltersProvider.notifier);

    // Determine status options based on current tab
    List<String> statusOptions = [];
    if (tab == JobsTab.myJobs) {
      statusOptions = ['Brouillon', 'Publié', 'Terminé'];
    } else if (tab == JobsTab.missions) {
      statusOptions = ['Non confirmée', 'En cours', 'Terminé'];
    } else if (tab == JobsTab.applications) {
      statusOptions = ['En attente', 'Acceptée', 'Refusée'];
    } else if (tab == JobsTab.interviews) {
      statusOptions = ['Planifié', 'Terminé', 'Annulé'];
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Statut',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        height: 26 / 18,
                        letterSpacing: -0.4,
                        color: Color(0xFF3A1B5E),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => notifier.setStatus(null),
                      child: const Text(
                        'Réinitialiser',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF401E66),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...statusOptions.map((status) {
                  final isSelected = filters.status == status;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () {
                        notifier.setStatus(status);
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF3A1B5E)
                              : const Color(0xFFEFEDF2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF3A1B5E),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Date Sheet (Overlay style)
// ─────────────────────────────────────────────
class _DateSheet extends ConsumerWidget {
  final JobsTab tab;
  const _DateSheet({required this.tab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(recruiterFiltersProvider);
    final notifier = ref.read(recruiterFiltersProvider.notifier);

    // Determine date options based on tab
    List<String> dateOptions = [];
    String title = 'Date';
    
    if (tab == JobsTab.myJobs) {
      title = 'Publié il y a';
      dateOptions = ['3 jours', '1 semaine', '1 mois', '3 mois', '6 mois'];
    } else if (tab == JobsTab.missions) {
      title = 'Durée';
      dateOptions = ['1 semaine', '2 semaines', '1 mois', '3 mois', '6 mois'];
    } else if (tab == JobsTab.applications) {
      title = 'Date de dépôt';
      dateOptions = ['Aujourd\'hui', '3 jours', '1 semaine', '1 mois'];
    } else if (tab == JobsTab.interviews) {
      title = 'Date de l\'entretien';
      dateOptions = ['Aujourd\'hui', 'Cette semaine', 'Ce mois-ci', 'Mois prochain'];
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        height: 26 / 18,
                        letterSpacing: -0.4,
                        color: Color(0xFF3A1B5E),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => notifier.setDateFilter(null),
                      child: const Text(
                        'Réinitialiser',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF401E66),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: dateOptions.map((date) {
                    final isSelected = filters.dateFilter == date;
                    return GestureDetector(
                      onTap: () {
                        notifier.setDateFilter(date);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF3A1B5E)
                              : const Color(0xFFEFEDF2),
                          border: isSelected
                              ? null
                              : Border.all(
                                  color: const Color(0xFF513376), width: 1),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          date,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            height: 20 / 14,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF3A1B5E),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Department Sheet (Overlay style)
// ─────────────────────────────────────────────
class _DepartmentSheet extends ConsumerWidget {
  const _DepartmentSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(recruiterFiltersProvider);
    final notifier = ref.read(recruiterFiltersProvider.notifier);

    final departments = [
      'Marketing',
      'IT',
      'Ventes',
      'RH',
      'Finance',
      'Opérations',
      'Support Client',
      'Design',
    ];

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Département',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        height: 26 / 18,
                        letterSpacing: -0.4,
                        color: Color(0xFF3A1B5E),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => notifier.setDepartment(null),
                      child: const Text(
                        'Réinitialiser',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF401E66),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: departments.map((dept) {
                    final isSelected = filters.department == dept;
                    return GestureDetector(
                      onTap: () {
                        notifier.setDepartment(dept);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF3A1B5E)
                              : const Color(0xFFEFEDF2),
                          border: isSelected
                              ? null
                              : Border.all(
                                  color: const Color(0xFF513376), width: 1),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          dept,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            height: 20 / 14,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF3A1B5E),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Job offer Sheet (candidatures & entretiens)
// ─────────────────────────────────────────────
class _JobOfferSheet extends ConsumerWidget {
  final ScrollController scrollController;

  const _JobOfferSheet({required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(recruiterFiltersProvider);
    final notifier = ref.read(recruiterFiltersProvider.notifier);
    final jobsAsync = ref.watch(jobsNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Annonce concernée',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: Color(0xFF3A1B5E),
              ),
            ),
            GestureDetector(
              onTap: () {
                notifier.setJobId(null);
                Navigator.pop(context);
              },
              child: const Text(
                'Réinitialiser',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF401E66),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: jobsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(
              child: Text('Impossible de charger les annonces'),
            ),
            data: (jobs) {
              if (jobs.isEmpty) {
                return const Center(child: Text('Aucune annonce disponible'));
              }
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: jobs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    final isSelected = filters.jobId == job.id;
                    return _SelectableJobRow(
                      job: job,
                      isSelected: isSelected,
                      onToggle: () {
                        notifier.setJobId(isSelected ? null : job.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SelectableJobRow extends StatelessWidget {
  final JobEntity job;
  final bool isSelected;
  final VoidCallback onToggle;

  const _SelectableJobRow({
    required this.job,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        JobCard(
          job: job,
          cardColor: Colors.white,
          showActions: false,
          onTap: onToggle,
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Material(
            color: Colors.transparent,
            child: Checkbox(
              value: isSelected,
              onChanged: (_) => onToggle(),
              activeColor: AppColors.violet,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

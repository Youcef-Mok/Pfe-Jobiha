import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';
import 'package:job_app/features/applications/data/providers/applications_provider.dart';
import 'package:job_app/features/jobs/widgets/candidate_job_card.dart';

class SavedJobsScreen extends ConsumerStatefulWidget {
  const SavedJobsScreen({super.key});

  @override
  ConsumerState<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends ConsumerState<SavedJobsScreen> {
  static const _chips = ['Horraires', 'Categorie', 'Contrat', 'Localisation', 'Domaine'];
  static const _chipKeys = ['horraires', 'categorie', 'contrat', 'localisation', 'domaine'];

  final List<GlobalKey> _filterChipKeys =
      List<GlobalKey>.generate(5, (_) => GlobalKey());

  String? _openedChip;
  double _overlayLeft = 0;
  double _overlayTop = 0;
  final Map<String, List<String>> _draftFilterValues = {};

  @override
  Widget build(BuildContext context) {
    final savedIds = ref.watch(savedJobsProvider);
    final jobsAsync = ref.watch(jobsNotifierProvider);
    final selectedChip = ref.watch(savedJobsActiveChipProvider);
    final savedFilterValues = ref.watch(savedJobsFilterValuesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 20),
                _buildHeader(context),
                const SizedBox(height: 16),
                _buildFilterOptionsRow(selectedChip, savedFilterValues),
                const SizedBox(height: 14),
                Expanded(
                  child: jobsAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.violet),
                    ),
                    error: (_, __) =>
                        const Center(child: Text('Erreur de chargement')),
                    data: (jobs) {
                      final saved = jobs.where((j) => savedIds.contains(j.id)).toList();
                      final filtered = _applySavedFilters(saved, savedFilterValues);
                      final display = _sortSavedJobs(
                        filtered,
                        selectedChip,
                        savedFilterValues,
                      );
                      return _buildList(context, ref, display);
                    },
                  ),
                ),
              ],
            ),
            if (_openedChip != null) ...[
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _openedChip = null),
                  child: Container(color: Colors.transparent),
                ),
              ),
              Positioned(
                left: _overlayLeft,
                top: _overlayTop,
                child: _SavedInlineSelectionModal(
                  options: _optionsForChip(_openedChip!),
                  currentValues: _draftFilterValues[_openedChip!] ?? [],
                  onChanged: (selected) {
                    setState(() {
                      _draftFilterValues[_openedChip!] = selected;
                    });
                  },
                  onConfirm: () {
                    final currentMap = ref.read(savedJobsFilterValuesProvider);
                    ref.read(savedJobsFilterValuesProvider.notifier).state = {
                      ...currentMap,
                      _openedChip!: _draftFilterValues[_openedChip!] ?? [],
                    };
                    setState(() => _openedChip = null);
                  },
                  onReset: () {
                    setState(() {
                      _draftFilterValues[_openedChip!] = [];
                    });
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openInlineOverlay(int chipIndex, String chipKey) {
    final chipContext = _filterChipKeys[chipIndex].currentContext;
    if (chipContext == null) return;
    final box = chipContext.findRenderObject() as RenderBox;
    final global = box.localToGlobal(Offset.zero);
    final safeTop = MediaQuery.of(context).padding.top;
    final maxWidth = MediaQuery.of(context).size.width;
    const overlayWidth = 186.0;
    final desiredLeft = global.dx + (box.size.width / 2) - (overlayWidth / 2);
    final clampedLeft = desiredLeft.clamp(0.0, maxWidth - overlayWidth);
    final currentMap = ref.read(savedJobsFilterValuesProvider);

    setState(() {
      _openedChip = chipKey;
      _draftFilterValues[chipKey] = List.from(currentMap[chipKey] ?? []);
      _overlayLeft = clampedLeft;
      _overlayTop = global.dy - safeTop + box.size.height + 10;
    });
  }

  Widget _buildFilterOptionsRow(
    String selectedChip,
    Map<String, List<String>> selectedValues,
  ) {
    final selected = selectedValues.entries
        .where((e) => e.value.isNotEmpty)
        .expand((e) => e.value.map((v) => MapEntry(e.key, v)))
        .toList();

    return SizedBox(
      height: 45,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 10, right: 12),
        children: [
          ...selected.map((entry) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _SelectedAppliedChip(
                  label: entry.value,
                  icon: _iconForSelectedFilter(entry.key, entry.value),
                  onRemove: () {
                    final currentMap = ref.read(savedJobsFilterValuesProvider);
                    final newList = List<String>.from(currentMap[entry.key] ?? []);
                    newList.remove(entry.value);
                    ref.read(savedJobsFilterValuesProvider.notifier).state = {
                      ...currentMap,
                      entry.key: newList,
                    };
                  },
                ),
              )),
          ...List<Widget>.generate(
            _chips.length,
            (i) => Padding(
              padding: EdgeInsets.only(right: i == _chips.length - 1 ? 0 : 12),
              child: _SavedFilterChip(
                key: _filterChipKeys[i],
                label: _chips[i],
                isActive: selectedChip == _chipKeys[i],
                onTap: () {
                  final chipKey = _chipKeys[i];
                  ref.read(savedJobsActiveChipProvider.notifier).state = chipKey;
                  _openInlineOverlay(i, chipKey);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForSelectedFilter(String key, String value) {
    final options = _optionsForChip(key);
    for (final opt in options) {
      if (opt.label == value) return opt.icon;
    }
    return Icons.tune;
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE4E4E7))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const SizedBox(
              width: 32,
              height: 32,
              child: Icon(Icons.arrow_back, size: 30, color: Color(0xFF18181B)),
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'Saved jobs',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              height: 28 / 18,
              color: Color(0xFF18181B),
            ),
          ),
        ],
      ),
    );
  }

  List<_SavedFilterOption> _optionsForChip(String chipKey) {
    switch (chipKey) {
      case 'horraires':
        return const [
          _SavedFilterOption('Matin', Icons.wb_sunny_outlined),
          _SavedFilterOption('Après-midi', Icons.wb_cloudy_outlined),
          _SavedFilterOption('Soir', Icons.nightlight_round),
          _SavedFilterOption('Nuit', Icons.bedtime_outlined),
        ];
      case 'categorie':
        return const [
          _SavedFilterOption('Restauration', Icons.restaurant_outlined),
          _SavedFilterOption('Vente', Icons.shopping_bag_outlined),
          _SavedFilterOption('Livraison', Icons.local_shipping_outlined),
        ];
      case 'contrat':
        return const [
          _SavedFilterOption('CDD', Icons.assignment_outlined),
          _SavedFilterOption('CDI', Icons.badge_outlined),
          _SavedFilterOption('Freelance', Icons.work_outline),
        ];
      case 'localisation':
        return const [
          _SavedFilterOption('Alger', Icons.location_on_outlined),
          _SavedFilterOption('Birkhadem', Icons.location_on_outlined),
          _SavedFilterOption('Bab Ezzouar', Icons.location_on_outlined),
        ];
      case 'domaine':
        return const [
          _SavedFilterOption('IT', Icons.computer_outlined),
          _SavedFilterOption('Marketing', Icons.campaign_outlined),
          _SavedFilterOption('Design', Icons.palette_outlined),
        ];
      default:
        return const [
          _SavedFilterOption('Option 1', Icons.radio_button_unchecked),
          _SavedFilterOption('Option 2', Icons.radio_button_unchecked),
          _SavedFilterOption('Option 3', Icons.radio_button_unchecked),
        ];
    }
  }

  Widget _buildList(BuildContext context, WidgetRef ref, List<JobEntity> jobs) {
    if (jobs.isEmpty) {
      return const Center(
        child: Text(
          'Aucun job enregistrÃƒÂ©',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppColors.slate600,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 16, bottom: 14),
          child: Text(
            '${jobs.length} Job${jobs.length > 1 ? 's' : ''} enregistré${jobs.length > 1 ? 's' : ''}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600, // Reverted to w600
              fontSize: 17,
              color: Color(0xFF060527),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Column(
                  children: [
                    for (final job in jobs) CandidateJobCard(job: job),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<JobEntity> _applySavedFilters(
    List<JobEntity> jobs,
    Map<String, List<String>> selectedValues,
  ) {
    return jobs.where((job) {
      final contracts = selectedValues['contrat'] ?? [];
      if (contracts.isNotEmpty) {
        final matchesContract = contracts.any((contract) {
          return switch (contract.toLowerCase()) {
            'cdi' => job.contractType == ContractType.cdi,
            'cdd' => job.contractType == ContractType.mission,
            'freelance' => job.contractType == ContractType.freelance,
            _ => true,
          };
        });
        if (!matchesContract) return false;
      }

      for (final cat in ['horraires', 'categorie', 'localisation', 'domaine']) {
        final options = selectedValues[cat] ?? [];
        if (options.isNotEmpty) {
          final haystack = '${job.title} ${job.companyName}'.toLowerCase();
          final matchesCat = options.any((opt) => haystack.contains(opt.toLowerCase()));
          if (!matchesCat) return false;
        }
      }
      return true;
    }).toList();
  }

  List<JobEntity> _sortSavedJobs(
    List<JobEntity> jobs,
    String chip,
    Map<String, List<String>> selectedValues,
  ) {
    final sorted = [...jobs];
    switch (chip) {
      case 'categorie':
        sorted.sort((a, b) => a.title.compareTo(b.title));
        return sorted;
      case 'contrat':
        sorted.sort((a, b) => a.contractType.index.compareTo(b.contractType.index));
        return sorted;
      case 'localisation':
        sorted.sort((a, b) => a.companyName.compareTo(b.companyName));
        return sorted;
      case 'domaine':
        sorted.sort((a, b) => b.viewCount.compareTo(a.viewCount));
        return sorted;
      case 'horraires':
      default:
        sorted.sort((a, b) => b.postedAt.compareTo(a.postedAt));
        return sorted;
    }
  }
}

class _SavedFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SavedFilterChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEFEDF2),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 14,
            height: 21 / 14,
            color: isActive ? const Color(0xFF401E66) : const Color(0xFF401E66),
          ),
        ),
      ),
    );
  }
}

class _SelectedAppliedChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onRemove;

  const _SelectedAppliedChip({
    required this.label,
    required this.icon,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF3A1B5E), // Violet background
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 25,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2), // Light translucent background for icon
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 14, color: Colors.white), // White icon
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              height: 21 / 14,
              color: Colors.white, // White text
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 14,
              color: Colors.white, // White close icon
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedFilterOption {
  final String label;
  final IconData icon;
  const _SavedFilterOption(this.label, this.icon);
}

class _SavedInlineSelectionModal extends StatefulWidget {
  final List<_SavedFilterOption> options;
  final List<String> currentValues;
  final ValueChanged<List<String>> onChanged;
  final VoidCallback onConfirm;
  final VoidCallback onReset;

  const _SavedInlineSelectionModal({
    required this.options,
    required this.currentValues,
    required this.onChanged,
    required this.onConfirm,
    required this.onReset,
  });

  @override
  State<_SavedInlineSelectionModal> createState() => _SavedInlineSelectionModalState();
}

class _SavedInlineSelectionModalState extends State<_SavedInlineSelectionModal> {

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 171,
      padding: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEDF2),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000), // rgba(0, 0, 0, 0.25)
            blurRadius: 50,
            offset: Offset(0, 25),
            spreadRadius: -12,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Options List
          Container(
            constraints: const BoxConstraints(maxHeight: 132), // 3 items (44px each)
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.options.asMap().entries.map((entry) {
                  final i = entry.key;
                  final option = entry.value;
                  final isSelected = widget.currentValues.contains(option.label);
                  return InkWell(
                    onTap: () {
                      final newValues = List<String>.from(widget.currentValues);
                      if (newValues.contains(option.label)) {
                        newValues.remove(option.label);
                      } else {
                        newValues.add(option.label);
                      }
                      widget.onChanged(newValues);
                    },
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.fromLTRB(12, 8, 24, 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFEBE6F2) : Colors.transparent,
                        border: i == 0
                            ? null
                            : const Border(top: BorderSide(color: Color(0xFFFAFAFA))),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: isSelected ? 28 : 27,
                            height: isSelected ? 28 : 27,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF513376)
                                  : const Color(0xFFE8E1F4),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                option.icon,
                                size: isSelected ? 12 : 13,
                                color: isSelected ? Colors.white : const Color(0xFF401E66),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              option.label,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                fontSize: 13,
                                color: const Color(0xFF401E66),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF3A1B5E)
                                    : const Color(0xFFE4E4E7),
                                width: 2,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: isSelected
                                ? Center(
                                    child: Container(
                                      width: 9,
                                      height: 9,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF3A1B5E),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Footer Action
          Container(
            width: double.infinity,
            height: 28, // Shrink height
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFF4F4F5))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: widget.onConfirm,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      overlayColor: Colors.transparent,
                    ),
                    child: const Text(
                      'Confirmer',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Color(0xFFA1A1AA),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    widget.onReset();
                    widget.onConfirm();
                  },
                  child: const Icon(
                    Icons.settings_backup_restore,
                    size: 14,
                    color: Color(0xFFA1A1AA),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

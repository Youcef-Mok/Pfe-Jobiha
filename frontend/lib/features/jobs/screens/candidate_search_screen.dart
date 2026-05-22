import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';
import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/features/jobs/screens/candidate_filters_screen.dart';
import 'package:job_app/features/jobs/widgets/candidate_job_card.dart';
import 'package:job_app/features/jobs/screens/saved_jobs_screen.dart';
import 'package:job_app/features/applications/screens/applications_screen.dart';
import 'package:job_app/features/jobs/widgets/candidate_filter_sheets.dart';
import 'package:job_app/features/applications/data/providers/applications_provider.dart';

class CandidateSearchScreen extends ConsumerStatefulWidget {
  const CandidateSearchScreen({super.key});

  @override
  ConsumerState<CandidateSearchScreen> createState() => _CandidateSearchScreenState();
}

class _CandidateSearchScreenState extends ConsumerState<CandidateSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onTextChanged);
    Future.microtask(() => _focusNode.requestFocus());
  }

  void _onTextChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        ref.read(candidateJobSearchQueryProvider.notifier).state =
            _searchController.text;
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onTextChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSubmitted(String val) {
    _debounce?.cancel();
    ref.read(candidateJobSearchQueryProvider.notifier).state = val;
    if (val.trim().isNotEmpty) {
      ref.read(recentSearchesProvider.notifier).addSearch(val.trim());
    }
  }

  void _fillSearch(String text) {
    _searchController.text = text;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
    _onSubmitted(text);
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(candidateJobSearchQueryProvider);
    final filters = ref.watch(candidateFiltersProvider);
    final jobsAsync = ref.watch(jobSearchProvider);
    final nearbyAsync = ref.watch(nearbyJobsProvider);
    final showFilterResultsWhenQueryEmpty = query.isEmpty && !filters.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF18181B), size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEDF2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _focusNode,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                              onSubmitted: _onSubmitted,
                              decoration: InputDecoration(
                                hintText: 'Rechercher par nom d\'emploi',
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: const Color(0xFF8D8DA6),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          if (query.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                ref.read(candidateJobSearchQueryProvider.notifier).state = '';
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFCBD5E1),
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 14),
                              ),
                            ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CandidateFiltersScreen()),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.only(left: 8, right: 16),
                              child: Icon(Icons.tune, size: 24, color: Color(0xFF060527)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: (query.isEmpty && !showFilterResultsWhenQueryEmpty)
                  ? _buildRecentSearches()
                  : Column(
                      children: [
                        const SizedBox(height: 8),
                        const _FilterChips(),
                        Expanded(
                          child: showFilterResultsWhenQueryEmpty
                              ? _buildFilterResults(nearbyAsync)
                              : _buildSearchResults(jobsAsync),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    final searchesAsync = ref.watch(recentSearchesProvider);

    return Container(
      color: Colors.white,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RECHERCHES RÉCENTES',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: const Color(0xFF000000),
                    letterSpacing: 0.7,
                  ),
                ),
                GestureDetector(
                  onTap: () => ref.read(recentSearchesProvider.notifier).clearSearches(),
                  child: Text(
                    'Tout effacer',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.violet,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: searchesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
              data: (searches) => ListView.builder(
                itemCount: searches.length,
                itemBuilder: (context, index) {
                  final query = searches[index];
                  return InkWell(
                    onTap: () => _fillSearch(query),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFEDF2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.history,
                              size: 18,
                              color: Color(0xFF545665),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              query,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => ref
                                .read(recentSearchesProvider.notifier)
                                .removeSearch(index),
                            child: const Icon(Icons.close, size: 16, color: Color(0xFFCBD5E1)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(AsyncValue<List<JobEntity>> jobsAsync) {
    return Container(
      color: Colors.white,
      child: jobsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Erreur de chargement')),
        data: (results) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Text(
                  '${results.length} Emplois disponibles',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black,
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
                          for (final job in results) CandidateJobCard(job: job),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterResults(AsyncValue<List<JobEntity>> jobsAsync) {
    return Container(
      color: Colors.white,
      child: jobsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Erreur de chargement')),
        data: (results) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Text(
                  '${results.length} Emplois disponibles',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black,
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
                          for (final job in results) CandidateJobCard(job: job),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Filter Chips
// -----------------------------------------------------------------------------
class _FilterChips extends ConsumerWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(candidateFiltersProvider);
    final List<Widget> chips = [];

    // Navigation chips
    chips.add(_FilterChip(
      label: 'Jobs enregistrés',
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const SavedJobsScreen())),
    ));
    chips.add(_FilterChip(
      label: 'Candidatures',
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const ApplicationsScreen())),
    ));

    // Selected Filters
    if (filters.category != null) {
      chips.add(_FilterChip(
        label: filters.category!,
        isSelected: true,
        onTap: () => showContractTypeSheet(context),
        onRemove: () =>
            ref.read(candidateFiltersProvider.notifier).setCategory(null),
      ));
    }
    for (var contract in filters.contractTypes) {
      chips.add(_FilterChip(
        label: contract,
        isSelected: true,
        onTap: () => showContractTypeSheet(context),
        onRemove: () => ref
            .read(candidateFiltersProvider.notifier)
            .toggleContractType(contract),
      ));
    }
    for (var avail in filters.availability) {
      chips.add(_FilterChip(
        label: avail,
        isSelected: true,
        onTap: () => showAvailabilitySheet(context),
        onRemove: () => ref
            .read(candidateFiltersProvider.notifier)
            .toggleAvailability(avail),
      ));
    }
    if (filters.location != null) {
      chips.add(_FilterChip(
        label: filters.location!,
        isSelected: true,
        onTap: () => showLocationSheet(context),
        onRemove: () =>
            ref.read(candidateFiltersProvider.notifier).setLocation(null),
      ));
    }

    // Default category chips
    chips.add(_FilterChip(label: 'Horaires', showArrow: true, onTap: () => showAvailabilitySheet(context)));
    chips.add(_FilterChip(label: 'Contrat', showArrow: true, onTap: () => showContractTypeSheet(context)));
    chips.add(_FilterChip(label: 'Localisation', showArrow: true, onTap: () => showLocationSheet(context)));

    return SizedBox(
      height: 41,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) => chips[i],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final bool isSelected;
  final bool showArrow;
  const _FilterChip({
    required this.label,
    this.onTap,
    this.onRemove,
    this.isSelected = false,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.violet : const Color(0xFFEFEDF2),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.poppinsSemiBold14.copyWith(
                color: isSelected ? Colors.white : AppColors.violet,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onRemove ?? onTap,
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ] else if (showArrow) ...[
              const SizedBox(width: 2),
              const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.violet),
            ],
          ],
        ),
      ),
    );
  }
}

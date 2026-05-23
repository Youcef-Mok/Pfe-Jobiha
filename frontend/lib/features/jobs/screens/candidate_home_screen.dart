import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';
import 'package:job_app/features/applications/data/providers/applications_provider.dart';
import 'package:job_app/features/jobs/screens/candidate_job_details_screen.dart';
import 'package:job_app/features/jobs/screens/candidate_filters_screen.dart';
import 'package:job_app/features/jobs/screens/saved_jobs_screen.dart';
import 'package:job_app/features/applications/screens/applications_screen.dart';
import 'package:job_app/features/jobs/screens/candidate_search_screen.dart';
import 'package:job_app/core/widgets/candidate_nav_bar.dart';
import 'package:job_app/features/jobs/widgets/candidate_filter_sheets.dart';
import 'package:job_app/features/jobs/widgets/candidate_job_card.dart';
import 'package:job_app/features/notifications/screens/candidate_notifications_screen.dart';
import 'package:job_app/features/profile/data/providers/profile_provider.dart';

class CandidateHomeScreen extends ConsumerStatefulWidget {
  const CandidateHomeScreen({super.key});

  @override
  ConsumerState<CandidateHomeScreen> createState() =>
      _CandidateHomeScreenState();
}

class _CandidateHomeScreenState extends ConsumerState<CandidateHomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(candidateCurrentUserProvider, (_, __) {
      ref.invalidate(nearbyJobsProvider);
    });
    ref.listen(userGpsPositionProvider, (_, __) {
      ref.invalidate(nearbyJobsProvider);
    });

    final nearbyJobsAsync = ref.watch(nearbyJobsProvider);
    final publishedJobsAsync = ref.watch(candidateFilteredPublishedJobsProvider);
    final topJobsAsync = ref.watch(candidateAllPublishedJobsProvider);
    final candidateFilters = ref.watch(candidateFiltersProvider);
    final filteredJobsAsync = _stableJobs(
      nearbyJobsAsync,
      publishedJobsAsync,
      !candidateFilters.isEmpty,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top Section (Header + Search)
            SliverToBoxAdapter(child: _buildTopSection()),

            // Horizontal filter chips
            SliverToBoxAdapter(child: _FilterChips()),

            // Section title
            SliverToBoxAdapter(child: _buildSectionTitle()),

            // ── Featured horizontal cards ──────────
            SliverToBoxAdapter(
              child: topJobsAsync.when(
                    loading: () => _buildHeroShimmer(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (jobs) => jobs.isEmpty
                        ? const SizedBox.shrink()
                        : _buildHeroCards(jobs),
                  ),
            ),

            // Suggested jobs title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Posts sugérés',
                  style: AppTextStyles.h2Inter.copyWith(
                    color: const Color(0xFF2A292B),
                    fontSize: 20,
                  ),
                ),
              ),
            ),

            // Vertical job list — jobs proches (GPS > profil > wilaya)
            filteredJobsAsync.when(
                  loading: () =>
                      SliverToBoxAdapter(child: _buildSuggestedJobsShimmer()),
                  error: (_, __) => const SliverToBoxAdapter(
                    child: Center(child: Text('Erreur de chargement')),
                  ),
                  data: (list) {
                    if (list.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: const Color(0xFFEEEBF4), width: 1.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            candidateFilters.isEmpty
                                ? 'Aucune annonce disponible pour le moment.'
                                : 'Aucune annonce ne correspond à vos filtres.',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: Color(0xFF8D8DA6),
                            ),
                          ),
                        ),
                      );
                    }
                    return SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: const Color(0xFFEEEBF4), width: 1.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                          child: Column(
                          children: list
                              .map((job) => CandidateJobCard(
                                    job: job,
                                    showApplyButton: true,
                                    onApply: () async {
                                      await ref
                                          .read(applicationsNotifierProvider.notifier)
                                          .apply(job.id);
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Candidature envoyee'),
                                          backgroundColor: AppColors.violet,
                                        ),
                                      );
                                    },
                                  ))
                              .toList(),
                        ),
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
      bottomNavigationBar: const CandidateNavBar(currentIndex: 0),
    );
  }

  AsyncValue<List<JobEntity>> _stableJobs(
    AsyncValue<List<JobEntity>> nearby,
    AsyncValue<List<JobEntity>> published,
    bool hasActiveFilters,
  ) {
    return nearby.when(
      loading: () => published,
      error: (_, __) => published,
      data: (nearbyList) {
        if (nearbyList.isNotEmpty) return AsyncValue.data(nearbyList);
        if (hasActiveFilters) return const AsyncValue.data(<JobEntity>[]);
        return published.whenData((list) => list);
      },
    );
  }

  // Top Section (Header + Search)
  Widget _buildTopSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          // Search field
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CandidateSearchScreen()),
                );
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEDF2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    const Icon(Icons.search,
                        size: 20, color: Color(0xFF8D8DA6)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        readOnly: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CandidateSearchScreen()),
                          );
                        },
                        style: AppTextStyles.poppins16,
                        decoration: InputDecoration(
                          hintText: 'Rechercher par nom d\'emploi',
                          hintStyle: AppTextStyles.poppins16,
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    // Filter icon
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CandidateFiltersScreen()),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(Icons.tune,
                            size: 22, color: Color(0xFF060527)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Notification bell
          Stack(
            children: [
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CandidateNotificationsScreen()),
                ),
                icon: const Icon(Icons.notifications_none_outlined,
                    size: 24, color: Color(0xFF060527)),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFF2929),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // â”€â”€ Section title â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Annonces populaires',
            style: AppTextStyles.h2Inter.copyWith(
              color: const Color.fromARGB(255, 26, 26, 27),
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'POUR VOUS',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 1.33,
              letterSpacing: 1.2,
              color: Color(0xFF331554),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------------
  // Hero image cards (horizontal)
  // -----------------------------------------------------------------------------
  Widget _buildHeroCards(List<JobEntity> jobs) {
    final sortedJobs = List<JobEntity>.from(jobs)
      ..sort((a, b) => b.postedAt.compareTo(a.postedAt));
    return SizedBox(
      height: 223,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        itemCount: sortedJobs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 24),
        itemBuilder: (ctx, i) => _HeroJobCard(job: sortedJobs[i]),
      ),
    );
  }

  Widget _buildHeroShimmer() {
    return SizedBox(
      height: 223,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(15, 18, 15, 0),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 24),
        itemBuilder: (_, __) => Container(
          width: 310,
          height: 195,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestedJobsShimmer() {
    return const Center(child: CircularProgressIndicator());
  }
}

// -----------------------------------------------------------------------------
// Hero Job Card (280x200, immersive design)
// -----------------------------------------------------------------------------
class _HeroJobCard extends ConsumerWidget {
  final JobEntity job;
  const _HeroJobCard({required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(
      savedJobsProvider.select((saved) => saved.contains(job.id)),
    );
    final contractLabel = _contractLabel(job.contractType);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CandidateJobDetailsScreen(job: job)),
      ),
      child: Container(
        width: 310,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: _buildBackgroundImage(job.logoAsset),
          color: const Color(0xFF1A1A1A),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color(0xBB000000),
                        Color(0x44000000),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),

              // Top Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEDF2),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        contractLabel.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          letterSpacing: 0.6,
                          color: Color(0xFF401E66),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        _GlassButton(
                          onTap: () => ref
                              .read(savedJobsProvider.notifier)
                              .toggle(job.id),
                          child: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const _GlassButton(
                          child: Icon(Icons.chat_bubble_outline,
                              size: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Bottom Content
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.white,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${job.companyName} • ${job.city?.trim().isNotEmpty == true ? job.city! : 'Ville non precisee'}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xCCFFFFFF),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          job.scheduleLabel?.trim().isNotEmpty == true
                              ? job.scheduleLabel!
                              : 'Horaire non precise',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CandidateJobDetailsScreen(job: job),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.violet,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Postuler',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _contractLabel(ContractType t) => switch (t) {
        ContractType.cdi => 'CDI',
        ContractType.mission => 'Mission',
        ContractType.freelance => 'Freelance',
      };

  DecorationImage? _buildBackgroundImage(String? source) {
    if (source == null || source.isEmpty) return null;
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return DecorationImage(
        image: NetworkImage(source),
        fit: BoxFit.cover,
      );
    }
    return DecorationImage(
      image: AssetImage(source),
      fit: BoxFit.cover,
    );
  }
}

class _GlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _GlassButton({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            width: 32,
            height: 32,
            color: Colors.white.withValues(alpha: 0.2),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Vertical Job Card (Candidate version)
// -----------------------------------------------------------------------------
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
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CandidateFiltersScreen()),
        ),
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
    chips.add(_FilterChip(
      label: 'Horaires',
      showArrow: true,
      onTap: () => showAvailabilitySheet(context),
    ));
    chips.add(_FilterChip(
      label: 'Contrat',
      showArrow: true,
      onTap: () => showContractTypeSheet(context),
    ));
    chips.add(_FilterChip(
      label: 'Localisation',
      showArrow: true,
      onTap: () => showLocationSheet(context),
    ));
    chips.add(_FilterChip(
      label: 'Domaine',
      showArrow: true,
      onTap: () => showDomainSheet(context),
    ));

    return SizedBox(
      height: 41,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) => chips[i],
      ),
    );
  }
}

// Widget chip séparé pour isoler les rebuilds
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
      onTap: isSelected ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.violet : const Color(0xFFEFEDF2),
          borderRadius: BorderRadius.circular(8),
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

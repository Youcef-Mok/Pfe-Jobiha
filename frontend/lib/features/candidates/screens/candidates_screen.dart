/// features/candidates/screens/candidates_screen.dart
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/features/candidates/domain/candidate_entity.dart';
import 'package:job_app/features/candidates/data/providers/candidates_provider.dart';
import 'package:job_app/features/candidates/widgets/candidate_card.dart';
import 'package:job_app/features/candidates/widgets/candidate_detail_sheet.dart';
import 'package:job_app/core/widgets/app_bottom_nav_bar.dart';

class CandidatesScreen extends ConsumerStatefulWidget {
  const CandidatesScreen({super.key});

  @override
  ConsumerState<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends ConsumerState<CandidatesScreen> {
  @override
  Widget build(BuildContext context) {
    final sortMode = ref.watch(candidatesSortModeProvider);
    final filteredAsync = ref.watch(filteredCandidatesProvider);
    final count = filteredAsync.whenOrNull(data: (list) => list.length) ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F3F8),
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _JobInfoCard(),
                    _CandidatesCountRow(
                      count: count,
                      currentSort: sortMode,
                      onSortChanged: (val) => ref
                          .read(candidatesSortModeProvider.notifier)
                          .state = val,
                    ),
                    const _TabSection(),
                    const SizedBox(height: 10),
                    const _CandidatesGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }
}

// ─────────────────────────────────────────────
// Header - Back button + centered title
// ─────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 47,
      color: const Color(0xFFF6F3F8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back button - left aligned
          Positioned(
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_back,
                  size: 16,
                  color: Color(0xFF2B2A2A),
                ),
              ),
            ),
          ),
          // Title - centered
          const Text(
            'Candidats',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: -0.45,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Job Info Card with purple left border
// ─────────────────────────────────────────────
class _JobInfoCard extends ConsumerWidget {
  const _JobInfoCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedJob = ref.watch(selectedJobProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 5, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF401E66), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Job image
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: selectedJob?.logoAsset != null
                    ? (selectedJob!.logoAsset!.startsWith('http')
                        ? Image.asset(selectedJob.logoAsset!,
                            fit: BoxFit.cover)
                        : Image.asset(selectedJob.logoAsset!,
                            fit: BoxFit.cover))
                    : const Icon(Icons.coffee, color: Color(0xFF7C7580)),
              ),
            ),
            const SizedBox(width: 12),
            // Job title and company
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedJob?.title ?? 'Serveur de cafe',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 20 / 14,
                      color: Color(0xFF1D1B1F),
                    ),
                  ),
                  Text(
                    selectedJob?.companyName ?? 'Le Petit Bistro',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      height: 16 / 12,
                      color: Color(0xFF4A454F),
                    ),
                  ),
                ],
              ),
            ),
            // Chevron arrow
            const Icon(
              Icons.chevron_right,
              size: 14,
              color: Color(0xFF7C7580),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Candidates count row with filter icon
// ─────────────────────────────────────────────
class _CandidatesCountRow extends StatelessWidget {
  final int count;
  final String currentSort;
  final Function(String) onSortChanged;

  const _CandidatesCountRow({
    required this.count,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$count Candidats',
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              height: 20 / 14,
              color: Color(0xFF0F172A),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: onSortChanged,
            offset: const Offset(0, 30),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (context) => [
              _buildMenuItem('recent', 'Plus récents'),
              _buildMenuItem('best', 'Mieux notés'),
              _buildMenuItem('unprocessed', 'Non traités'),
            ],
            child: Row(
              children: [
                Text(
                  _getSortLabel(currentSort),
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.filter_list,
                  size: 15,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, String label) {
    final isSelected = currentSort == value;
    return PopupMenuItem(
      value: value,
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFF401E66) : const Color(0xFF64748B),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  String _getSortLabel(String value) {
    switch (value) {
      case 'recent': return 'Pus récents';
      case 'best': return 'Mieux notés';
      case 'unprocessed': return 'Non traités';
      default: return 'Tri';
    }
  }
}

// ─────────────────────────────────────────────
// Tab Section - Full width with gaps
// ─────────────────────────────────────────────
class _TabSection extends ConsumerWidget {
  const _TabSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(candidatesTabProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      height: 35,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Nouveaux',
              isActive: currentTab == CandidateStatus.nouveau,
              onTap: () => ref.read(candidatesTabProvider.notifier).state =
                  CandidateStatus.nouveau,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: _TabButton(
              label: 'Examines',
              isActive: currentTab == CandidateStatus.examine,
              onTap: () => ref.read(candidatesTabProvider.notifier).state =
                  CandidateStatus.examine,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: _TabButton(
              label: 'Archives',
              isActive: currentTab == CandidateStatus.archive,
              onTap: () => ref.read(candidatesTabProvider.notifier).state =
                  CandidateStatus.archive,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 35,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF401E66) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
                  const BoxShadow(
                    color: Color(0x1A7F13EC),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            fontSize: 12,
            height: 16 / 12,
            color: isActive ? Colors.white : const Color(0xFF401E66),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Candidates Grid - 2 columns
// ─────────────────────────────────────────────
class _CandidatesGrid extends ConsumerWidget {
  const _CandidatesGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidatesAsync = ref.watch(filteredCandidatesProvider);

    return candidatesAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text('Erreur: $e'),
        ),
      ),
      data: (filtered) {
        if (filtered.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Aucun candidat',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 181 / 177,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final candidate = filtered[index];
              return CandidateCard(
                candidate: candidate,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    isDismissible: true,
                    builder: (context) => Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                        left: 16,
                        right: 16,
                      ),
                      child: Material(
                        type: MaterialType.transparency,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CandidateDetailSheet(candidate: candidate),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                onArchive: () {
                  final newStatus = candidate.status == CandidateStatus.archive
                      ? CandidateStatus.nouveau
                      : CandidateStatus.archive;
                      
                  ref.read(candidatesNotifierProvider.notifier).updateStatus(
                        candidate.id,
                        newStatus,
                      );
                },
              );
            },
          ),
        );
      },
    );
  }
}



import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';
import 'package:job_app/features/jobs/domain/mission_entity.dart';
import 'package:job_app/core/theme/app_theme.dart';

class EndMissionScreen extends ConsumerStatefulWidget {
  final MissionEntity mission;
  const EndMissionScreen({super.key, required this.mission});

  @override
  ConsumerState<EndMissionScreen> createState() => _EndMissionScreenState();
}

class _EndMissionScreenState extends ConsumerState<EndMissionScreen> {
  final _commentCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final review = ref.watch(missionReviewProvider(widget.mission.id));
    final notifier = ref.read(missionReviewProvider(widget.mission.id).notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _ReviewHeader(onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profil employeur
                    _EmployerProfileCard(mission: widget.mission),
                    const SizedBox(height: 32),

                    // Section notation
                    _RatingSection(
                      rating: review.rating,
                      onRate: notifier.setRating,
                    ),
                    const SizedBox(height: 32),

                    // Avis texte
                    _ReviewTextSection(
                      controller: _commentCtrl,
                      onChanged: notifier.setComment,
                      charCount: review.comment.length,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _SubmitFooter(
        isValid: review.isValid,
        isLoading: _isLoading,
        onSubmit: () => _handleSubmit(context, review),
      ),
    );
  }

  Future<void> _handleSubmit(
      BuildContext context, MissionReview review) async {
    if (!review.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Ajoutez une note et un commentaire (min. 10 caractères)'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _isLoading = true);
    final success = await ref
        .read(missionReviewProvider(widget.mission.id).notifier)
        .submit();
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Mission terminée · Avis publié ✓'),
        backgroundColor: AppColors.violet,
        behavior: SnackBarBehavior.floating,
      ));
      // Pop jusqu'à la liste
      Navigator.of(context)
        ..pop()   // ferme end_mission_screen
        ..pop();  // ferme le mission_detail_sheet
    }
  }
}

// ─────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────
class _ReviewHeader extends StatelessWidget {
  final VoidCallback onBack;
  const _ReviewHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 57,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xCCFFFFFF),
        border: Border(bottom: BorderSide(color: Color(0x1A7F13EC))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 16, color: AppColors.slate900),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            "Noter l'employé",
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: -0.45,
              color: AppColors.slate900,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Profil employeur
// ─────────────────────────────────────────────
class _EmployerProfileCard extends StatelessWidget {
  final MissionEntity mission;
  const _EmployerProfileCard({required this.mission});

  @override
  Widget build(BuildContext context) {
    final endFmt =
        DateFormat('d MMM.', 'fr_FR').format(mission.endDate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x0D7F13EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x1A7F13EC)),
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x337F13EC),
                      blurRadius: 0,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    mission.companyName[0],
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      color: AppColors.violet,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Infos
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mission.companyName,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.slate900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                mission.jobTitle,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: AppColors.violet,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 12, color: AppColors.slate300),
                  const SizedBox(width: 4),
                  Text(
                    'Mission terminée le $endFmt',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: AppColors.slate300,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Section notation étoiles
// ─────────────────────────────────────────────
class _RatingSection extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRate;

  const _RatingSection({required this.rating, required this.onRate});

  static const _labels = {
    1: ('Insuffisant', '1/5'),
    2: ('Passable', '2/5'),
    3: ('Bien', '3/5'),
    4: ('Très bien', '4/5'),
    5: ('Excellent', '5/5'),
  };

  @override
  Widget build(BuildContext context) {
    final label = rating > 0 ? _labels[rating] : null;

    return Column(
      children: [
        // Titre
        const Text(
          'Quelle note donneriez-vous ?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.slate900,
          ),
        ),
        const SizedBox(height: 16),

        // Sous-titre
        const Text(
          "Votre évaluation aide la communauté à trouver les meilleurs établissements.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.43,
            color: AppColors.slate300,
          ),
        ),
        const SizedBox(height: 16),

        // Étoiles
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final filled = i < rating;
            return GestureDetector(
              onTap: () => onRate(i + 1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 40,
                  color: filled ? AppColors.violet : const Color(0xFFCBD5E1),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),

        // Badge label dynamique
        if (label != null)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x1A7F13EC),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text(
              '${label.$1} (${label.$2})',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.violet,
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Section avis texte
// ─────────────────────────────────────────────
class _ReviewTextSection extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final int charCount;

  const _ReviewTextSection({
    required this.controller,
    required this.onChanged,
    required this.charCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Votre avis détaillé',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 12),

        // Textarea
        Container(
          height: 154,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x337F13EC)),
          ),
          child: TextField(
            controller: controller,
            maxLines: null,
            expands: true,
            onChanged: onChanged,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              height: 1.5,
              color: AppColors.slate900,
            ),
            decoration: const InputDecoration(
              hintText:
                  "Votre avis sur votre employé (assiduité, sérieux, etc...)",
              hintStyle: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: AppColors.slate400,
              ),
              contentPadding: EdgeInsets.fromLTRB(16, 16, 16, 88),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Compteur
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            charCount < 10
                ? 'Minimum 10 caractères'
                : '$charCount caractères',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: charCount < 10
                  ? AppColors.slate400
                  : AppColors.violet,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Footer
// ─────────────────────────────────────────────
class _SubmitFooter extends StatelessWidget {
  final bool isValid;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _SubmitFooter({
    required this.isValid,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: Color(0xCCF8FAFC),
        border: Border(top: BorderSide(color: Color(0x0D7F13EC))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bouton principal
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.violet,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.slate400,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Valider fin mission',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          // Mention légale
          const Text(
            "En publiant cet avis, vous acceptez nos conditions d'utilisation.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: AppColors.slate400,
            ),
          ),
        ],
      ),
    );
  }
}
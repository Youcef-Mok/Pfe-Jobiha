import 'package:flutter/material.dart';
import 'package:job_app/core/theme/app_theme.dart';

class _ReportCategory {
  final String title;
  final List<String> reasons;

  _ReportCategory({required this.title, required this.reasons});
}

class ReportScreen extends StatefulWidget {
  final String contactName;
  final bool isRecruiter;

  const ReportScreen({
    super.key,
    required this.contactName,
    required this.isRecruiter,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String? _selectedReason;

  List<_ReportCategory> get _recruiterCategories => [
        _ReportCategory(
          title: 'Fraude / Arnaque',
          reasons: [
            'Offre suspecte (trop beau pour être vrai)',
            'Demande d\'argent (formation, dossier, etc.)',
            'Usurpation d\'identité d\'une entreprise',
          ],
        ),
        _ReportCategory(
          title: 'Contenu trompeur',
          reasons: [
            'Description de poste mensongère',
            'Salaire ou avantages faux',
            'Conditions non précisées (temps, lieu, contrat)',
          ],
        ),
        _ReportCategory(
          title: 'Discrimination',
          reasons: [
            'Basée sur le sexe ou l\'âge',
            'Basée sur l\'origine ou la religion',
            'Critères illégaux dans l\'annonce',
          ],
        ),
        _ReportCategory(
          title: 'Comportement inapproprié',
          reasons: [
            'Harcèlement via messages',
            'Langage irrespectueux',
            'Pression excessive',
          ],
        ),
        _ReportCategory(
          title: 'Mauvaise utilisation des données',
          reasons: [
            'Demande d\'infos personnelles sensibles',
            'Revente ou usage abusif des CV',
          ],
        ),
        _ReportCategory(
          title: 'Faux recruteur',
          reasons: [
            'Profil non vérifié',
            'Entreprise inexistante',
          ],
        ),
      ];

  List<_ReportCategory> get _candidateCategories => [
        _ReportCategory(
          title: 'Faux profil / CV mensonger',
          reasons: [
            'Expériences inventées',
            'Diplômes falsifiés',
            'Compétences exagérées',
          ],
        ),
        _ReportCategory(
          title: 'Spam / abus',
          reasons: [
            'Envoi massif de candidatures',
            'Messages répétitifs non pertinents',
          ],
        ),
        _ReportCategory(
          title: 'Comportement inapproprié',
          reasons: [
            'Insultes ou harcèlement',
            'Non-respect lors d\'un entretien',
          ],
        ),
        _ReportCategory(
          title: 'Non-professionnalisme',
          reasons: [
            'Absence à un entretien sans prévenir',
            'Abandon de processus sans réponse',
          ],
        ),
        _ReportCategory(
          title: 'Usurpation d\'identité',
          reasons: [
            'Utilisation du profil d\'une autre personne',
          ],
        ),
      ];

  List<_ReportCategory> get _categories =>
      widget.isRecruiter ? _recruiterCategories : _candidateCategories;

  void _onSend() {
    if (_selectedReason == null) return;
    _showDetailOverlay();
  }

  void _showDetailOverlay() {
    final detailController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: _ReportDetailSheet(
            selectedReason: _selectedReason!,
            detailController: detailController,
            onConfirm: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Signalement envoyé'),
                  backgroundColor: Color(0xFF401E66),
                ),
              );
              Navigator.pop(context);
            },
          ),
        );
      },
    ).whenComplete(() => detailController.dispose());
  }

  @override
  Widget build(BuildContext context) {
    final bool canSend = _selectedReason != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Container(
                height: 56,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          size: 18, color: Color(0xFF1D1B1F)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Signaler',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Color(0xFF1D1B1F),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 16, bottom: 32),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildCategoryWidgets(),
                ),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: GestureDetector(
                  onTap: canSend ? _onSend : null,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: canSend
                          ? const Color(0xFF401E66)
                          : const Color(0xFFEFEDF2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Envoyer le signalement',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: canSend ? Colors.white : const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryWidgets() {
    final widgets = <Widget>[];
    final categories = _categories;

    for (int ci = 0; ci < categories.length; ci++) {
      final category = categories[ci];

      if (ci > 0) {
        widgets.add(
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEBF4)),
        );
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            category.title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Color(0xFF401E66),
            ),
          ),
        ),
      );

      for (int ri = 0; ri < category.reasons.length; ri++) {
        final reason = category.reasons[ri];
        final isSelected = _selectedReason == reason;

        if (ri > 0) {
          widgets.add(
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1, thickness: 1, color: Color(0xFFEEEBF4)),
            ),
          );
        }

        widgets.add(
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _selectedReason = reason),
            child: SizedBox(
              height: 52,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        reason,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Color(0xFF1D1B1F),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 17,
                      height: 17,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? const Color(0xFF401E66)
                            : Colors.transparent,
                        border: Border.all(
                          color: const Color(0xFF401E66),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      if (ci == categories.length - 1) {
        widgets.add(const SizedBox(height: 8));
      }
    }

    return widgets;
  }
}

class _ReportDetailSheet extends StatefulWidget {
  final String selectedReason;
  final TextEditingController detailController;
  final VoidCallback onConfirm;

  const _ReportDetailSheet({
    required this.selectedReason,
    required this.detailController,
    required this.onConfirm,
  });

  @override
  State<_ReportDetailSheet> createState() => _ReportDetailSheetState();
}

class _ReportDetailSheetState extends State<_ReportDetailSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1C9DD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Décrivez le problème',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Color(0xFF1D1B1F),
            ),
          ),
          const SizedBox(height: 6),
          // Selected reason tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEBF4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.selectedReason,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: Color(0xFF401E66),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F6FB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2D9EF), width: 1),
            ),
            child: TextField(
              controller: widget.detailController,
              maxLines: 5,
              minLines: 4,
              autofocus: true,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF1D1B1F),
                height: 1.5,
              ),
              decoration: const InputDecoration(
                hintText: 'Décrivez la situation en détail (optionnel)...',
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0xFF94A3B8),
                ),
                contentPadding: EdgeInsets.all(14),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: widget.onConfirm,
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF401E66),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Envoyer le signalement',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

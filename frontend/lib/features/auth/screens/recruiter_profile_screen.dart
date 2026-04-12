import 'package:flutter/material.dart';
import '../widgets/auth_logo.dart';
import '../widgets/auth_header.dart';

// ── Data Models ───────────────────────────────────────────────────────────────

class RecruiterProfile {
  String? companyName;
  String? industry;
  String? location;
  String? aboutUs;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class RecruiterProfileScreen extends StatefulWidget {
  const RecruiterProfileScreen({super.key});

  @override
  State<RecruiterProfileScreen> createState() => _RecruiterProfileScreenState();
}

class _RecruiterProfileScreenState extends State<RecruiterProfileScreen> {
  // Field values
  String? _companyName;
  String? _industry;
  String? _location;
  String? _aboutUs;

  final Color primaryColor = const Color(0xFF3A1B5E);

  // ── Industry options ────────────────────────────────────────────────────────
  static const List<String> _industries = [
    'Technologie',
    'Santé',
    'Éducation',
    'Commerce',
    'Services',
    'Autre',
  ];

  // ── POPUP HELPERS ───────────────────────────────────────────────────────────

  Widget _dialogTitle(String title, BuildContext ctx) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: () => Navigator.pop(ctx),
          child: const Icon(Icons.close, size: 20, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _dialogField(
    TextEditingController ctrl,
    String hint,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    String? error,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontWeight: FontWeight.w600, color: primaryColor, fontSize: 13)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(10),
            border: error != null ? Border.all(color: Colors.red.shade300) : null,
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: maxLines > 1 ? 14 : 12,
              ),
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(error, style: const TextStyle(color: Colors.red, fontSize: 11)),
          ),
      ],
    );
  }

  Widget _dialogButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }

  // ── POPUPS ──────────────────────────────────────────────────────────────────

  /// Company Name – simple single-line text input
  void _showCompanyNameDialog() {
    final ctrl = TextEditingController(text: _companyName ?? '');
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: _dialogTitle('Nom de l\'entreprise', ctx),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(
                ctrl,
                'Ex: Google, StartupXYZ...',
                'Nom de l\'entreprise',
                error: error,
              ),
            ],
          ),
          actions: [
            _dialogButton('Enregistrer', () {
              final val = ctrl.text.trim();
              if (val.isEmpty) {
                setS(() => error = 'Ce champ est obligatoire');
                return;
              }
              if (val.length < 2) {
                setS(() => error = 'Minimum 2 caractères');
                return;
              }
              setState(() => _companyName = val);
              Navigator.pop(ctx);
            }),
          ],
        ),
      ),
    );
  }

  /// Industry – chip picker with optional "Autre" free-text field
  void _showIndustryDialog() {
    String? selected = _industry;
    // If the current value is not in the predefined list (i.e. it's a custom "Autre" value)
    bool isCustom = selected != null && !_industries.contains(selected);
    String selectedChip = isCustom ? 'Autre' : (selected ?? '');
    final otherCtrl = TextEditingController(text: isCustom ? selected : '');
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: _dialogTitle('Secteur d\'activité', ctx),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sélectionnez le secteur de votre entreprise',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _industries.map((industry) {
                    final isSelected = selectedChip == industry;
                    return GestureDetector(
                      onTap: () => setS(() {
                        selectedChip = industry;
                        if (industry != 'Autre') otherCtrl.clear();
                        error = null;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(22),
                          border: isSelected
                              ? null
                              : Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          industry,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // "Autre" free-text input — only visible when 'Autre' is selected
                if (selectedChip == 'Autre') ...[
                  const SizedBox(height: 16),
                  _dialogField(
                    otherCtrl,
                    'Précisez votre secteur...',
                    'Autre secteur',
                    error: error,
                  ),
                ],

                if (error != null && selectedChip.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(error!,
                        style: const TextStyle(color: Colors.red, fontSize: 11)),
                  ),
              ],
            ),
          ),
          actions: [
            _dialogButton('Enregistrer', () {
              if (selectedChip.isEmpty) {
                setS(() => error = 'Veuillez sélectionner un secteur');
                return;
              }
              if (selectedChip == 'Autre') {
                final custom = otherCtrl.text.trim();
                if (custom.isEmpty) {
                  setS(() => error = 'Ce champ est obligatoire');
                  return;
                }
                if (custom.length < 2) {
                  setS(() => error = 'Minimum 2 caractères');
                  return;
                }
                setState(() => _industry = custom);
              } else {
                setState(() => _industry = selectedChip);
              }
              Navigator.pop(ctx);
            }),
          ],
        ),
      ),
    );
  }

  /// Location – simple text input (Ville / Pays)
  void _showLocationDialog() {
    final ctrl = TextEditingController(text: _location ?? '');
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: _dialogTitle('Localisation', ctx),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(
                ctrl,
                'Ex: Alger, Algérie',
                'Ville / Pays',
                error: error,
              ),
            ],
          ),
          actions: [
            _dialogButton('Enregistrer', () {
              final val = ctrl.text.trim();
              if (val.isEmpty) {
                setS(() => error = 'Ce champ est obligatoire');
                return;
              }
              if (val.length < 2) {
                setS(() => error = 'Minimum 2 caractères');
                return;
              }
              setState(() => _location = val);
              Navigator.pop(ctx);
            }),
          ],
        ),
      ),
    );
  }

  /// About Us – multi-line textarea
  void _showAboutUsDialog() {
    final ctrl = TextEditingController(text: _aboutUs ?? '');
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: _dialogTitle('À propos de nous', ctx),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bio de l\'entreprise',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: primaryColor, fontSize: 13),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: error != null ? Border.all(color: Colors.red.shade300) : null,
                ),
                child: TextField(
                  controller: ctrl,
                  maxLines: 5,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText:
                        'Décrivez votre entreprise, votre mission\net vos valeurs...',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(14),
                  ),
                ),
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text(error!, style: const TextStyle(color: Colors.red, fontSize: 11)),
                ),
            ],
          ),
          actions: [
            _dialogButton('Enregistrer', () {
              final text = ctrl.text.trim();
              if (text.isEmpty) {
                setS(() => error = 'Ce champ est obligatoire');
                return;
              }
              if (text.length < 10) {
                setS(() => error = 'Minimum 10 caractères');
                return;
              }
              setState(() => _aboutUs = text);
              Navigator.pop(ctx);
            }),
          ],
        ),
      ),
    );
  }

  // ── BUILD ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AuthHeader(onBackPressed: () => Navigator.pop(context)),

            const SizedBox(height: 24),
            const Text(
              'Complétez votre profil',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E)),
            ),

            const SizedBox(height: 16),

            // ── Sections list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // 1 – Company Name
                  _buildSection(
                    icon: Icons.business_outlined,
                    label: 'Nom de l\'entreprise',
                    onAdd: _showCompanyNameDialog,
                    addIcon: _companyName != null ? Icons.edit_outlined : Icons.add,
                    hasItems: _companyName != null,
                    children: _companyName != null
                        ? [
                            _deletableValueTile(
                              icon: Icons.business_outlined,
                              text: _companyName!,
                              onDelete: () => setState(() => _companyName = null),
                            )
                          ]
                        : [],
                  ),

                  const SizedBox(height: 12),

                  // 2 – Industry
                  _buildSection(
                    icon: Icons.category_outlined,
                    label: 'Secteur d\'activité',
                    onAdd: _showIndustryDialog,
                    addIcon: _industry != null ? Icons.edit_outlined : Icons.add,
                    hasItems: _industry != null,
                    children: _industry != null
                        ? [
                            _deletableChipTile(
                              text: _industry!,
                              onDelete: () => setState(() => _industry = null),
                            )
                          ]
                        : [],
                  ),

                  const SizedBox(height: 12),

                  // 3 – Location
                  _buildSection(
                    icon: Icons.location_on_outlined,
                    label: 'Localisation',
                    onAdd: _showLocationDialog,
                    addIcon: _location != null ? Icons.edit_outlined : Icons.add,
                    hasItems: _location != null,
                    children: _location != null
                        ? [
                            _deletableValueTile(
                              icon: Icons.location_on_outlined,
                              text: _location!,
                              onDelete: () => setState(() => _location = null),
                            )
                          ]
                        : [],
                  ),

                  const SizedBox(height: 12),

                  // 4 – About Us
                  _buildSection(
                    icon: Icons.format_align_left_outlined,
                    label: 'À propos de nous',
                    onAdd: _showAboutUsDialog,
                    addIcon: _aboutUs != null ? Icons.edit_outlined : Icons.add,
                    hasItems: _aboutUs != null,
                    children: _aboutUs != null
                        ? [
                            _deletableDescriptionTile(
                              text: _aboutUs!,
                              onDelete: () => setState(() => _aboutUs = null),
                            )
                          ]
                        : [],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),

            // ── Bottom CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: const Text('Enregistrer mon profil',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section card ─────────────────────────────────────────────────────────────

  Widget _buildSection({
    required IconData icon,
    required String label,
    required VoidCallback onAdd,
    required bool hasItems,
    required List<Widget> children,
    IconData addIcon = Icons.add,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                Icon(icon, color: primaryColor, size: 22),
                const SizedBox(width: 12),
                Text(label,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const Spacer(),
                GestureDetector(
                  onTap: onAdd,
                  child: Icon(addIcon, color: primaryColor, size: 22),
                ),
              ],
            ),
          ),
          if (hasItems)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children),
            ),
        ],
      ),
    );
  }

  // ── Item tiles ────────────────────────────────────────────────────────────────

  /// Generic one-liner tile (Company Name, Location)
  Widget _deletableValueTile({
    required IconData icon,
    required String text,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 16),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500))),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close, size: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Pill/chip tile for Industry
  Widget _deletableChipTile({
    required String text,
    required VoidCallback onDelete,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(text,
                  style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDelete,
                child: Icon(Icons.close, size: 15, color: primaryColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Multi-line bio tile (About Us)
  Widget _deletableDescriptionTile({
    required String text,
    required VoidCallback onDelete,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 13, color: Colors.black87))),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close, size: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

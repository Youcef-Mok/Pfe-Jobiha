import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';

class PreferencesScreen extends ConsumerStatefulWidget {
  const PreferencesScreen({super.key});

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  // ── Constants ─────────────────────────────────────────────────────────────
  static const Color _primary = Color(0xFF3A1B5E);
  static const Color _accent  = Color(0xFF6B35D9);
  static const Color _bg      = Color(0xFFF7F5FF);

  // ── Job Categories ────────────────────────────────────────────────────────
  final List<_Category> _categories = [
    _Category('Informatique & IT',    Icons.computer_outlined),
    _Category('Design & Créativité',  Icons.brush_outlined),
    _Category('Marketing & Comm.',    Icons.campaign_outlined),
    _Category('Finance & Comptabilité', Icons.account_balance_outlined),
    _Category('Ressources Humaines',  Icons.people_outline),
    _Category('Ventes & Commerce',    Icons.storefront_outlined),
    _Category('Ingénierie',           Icons.engineering_outlined),
    _Category('Droit & Juridique',    Icons.gavel_outlined),
    _Category('Santé & Médical',      Icons.local_hospital_outlined),
    _Category('Éducation',            Icons.school_outlined),
  ];
  final Set<String> _selectedCategories = {};

  // ── Work Type ─────────────────────────────────────────────────────────────
  String? _workType; // 'remote' | 'onsite' | 'hybrid'

  // ── Cities ────────────────────────────────────────────────────────────────
  final List<String> _cities = [
    'Alger', 'Oran', 'Constantine', 'Annaba', 'Blida',
    'Tlemcen', 'Sétif', 'Béjaïa', 'Tizi Ouzou', 'Batna',
  ];
  final Set<String> _selectedCities = {};

  // ── Submit ────────────────────────────────────────────────────────────────
  void _handleTerminer() {
    // TODO: persist preferences before navigating

    final role = ref.read(authProvider).role;
    final route = role == 'recruteur' ? '/home-recruteur' : '/home-candidat';
    Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
  }

  // ═════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 18),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                  ),
                  const Spacer(),
                  Row(children: [
                    Icon(Icons.directions_walk, color: _accent, size: 20),
                    const SizedBox(width: 4),
                    Text('Jobiha',
                        style: TextStyle(
                            color: _accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ]),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // ── Title ─────────────────────────────────────────────────────
            const Text(
              'Vos Préférences',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Personnalisez vos recherches pour trouver les offres qui vous correspondent.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),

            // ── Scrollable content ─────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // ── 1. Job Categories ──────────────────────────────────
                  _buildCard(
                    icon: Icons.category_outlined,
                    title: 'Catégories de postes',
                    subtitle: 'Sélectionnez tous les domaines qui vous intéressent',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((cat) {
                        final selected = _selectedCategories.contains(cat.label);
                        return FilterChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(cat.icon,
                                  size: 14,
                                  color: selected ? Colors.white : _primary),
                              const SizedBox(width: 5),
                              Text(cat.label,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: selected ? Colors.white : Colors.black87)),
                            ],
                          ),
                          selected: selected,
                          onSelected: (_) => setState(() {
                            if (selected) {
                              _selectedCategories.remove(cat.label);
                            } else {
                              _selectedCategories.add(cat.label);
                            }
                          }),
                          selectedColor: _primary,
                          backgroundColor: Colors.white,
                          checkmarkColor: Colors.transparent,
                          showCheckmark: false,
                          side: BorderSide(
                              color: selected ? _primary : Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── 2. Work Type ───────────────────────────────────────
                  _buildCard(
                    icon: Icons.location_on_outlined,
                    title: 'Type de travail',
                    subtitle: 'Comment préférez-vous travailler ?',
                    child: Row(
                      children: [
                        _workTypeChip(
                          value: 'remote',
                          label: 'Télétravail',
                          icon: Icons.home_work_outlined,
                        ),
                        const SizedBox(width: 8),
                        _workTypeChip(
                          value: 'hybrid',
                          label: 'Hybride',
                          icon: Icons.sync_alt_outlined,
                        ),
                        const SizedBox(width: 8),
                        _workTypeChip(
                          value: 'onsite',
                          label: 'Présentiel',
                          icon: Icons.business_outlined,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── 3. Preferred Cities ────────────────────────────────
                  _buildCard(
                    icon: Icons.apartment_outlined,
                    title: 'Villes préférées',
                    subtitle: 'Choisissez dans quelles villes vous souhaitez travailler',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _cities.map((city) {
                        final selected = _selectedCities.contains(city);
                        return ChoiceChip(
                          label: Text(
                            city,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: selected ? Colors.white : Colors.black87),
                          ),
                          selected: selected,
                          onSelected: (_) => setState(() {
                            if (selected) {
                              _selectedCities.remove(city);
                            } else {
                              _selectedCities.add(city);
                            }
                          }),
                          selectedColor: _accent,
                          backgroundColor: Colors.white,
                          checkmarkColor: Colors.transparent,
                          showCheckmark: false,
                          side: BorderSide(
                              color: selected ? _accent : Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),

            // ── Terminer button ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _handleTerminer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: const Text('Terminer',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Work type choice chip ─────────────────────────────────────────────────
  Widget _workTypeChip({
    required String value,
    required String label,
    required IconData icon,
  }) {
    final selected = _workType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _workType = selected ? null : value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? _primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: selected ? _primary : Colors.grey.shade300, width: 1.5),
            boxShadow: selected
                ? [
                    BoxShadow(
                        color: _primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3))
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 22, color: selected ? Colors.white : Colors.grey),
              const SizedBox(height: 6),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section card wrapper ──────────────────────────────────────────────────
  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
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
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────
class _Category {
  final String label;
  final IconData icon;
  const _Category(this.label, this.icon);
}
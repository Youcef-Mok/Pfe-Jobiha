import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_header.dart';

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

  // ── Wilayas (all 58) ────────────────────────────────────────────────────
  final List<String> _cities = [
    'Adrar', 'Chlef', 'Laghouat', 'Oum El Bouaghi', 'Batna',
    'Béjaïa', 'Biskra', 'Béchar', 'Blida', 'Bouira',
    'Tamanrasset', 'Tébessa', 'Tlemcen', 'Tiaret', 'Tizi Ouzou',
    'Alger', 'Djelfa', 'Jijel', 'Sétif', 'Saïda',
    'Skikda', 'Sidi Bel Abbès', 'Annaba', 'Guelma', 'Constantine',
    'Médéa', 'Mostaganem', 'M\'Sila', 'Mascara', 'Ouargla',
    'Oran', 'El Bayadh', 'Illizi', 'Bordj Bou Arréridj', 'Boumerdès',
    'El Tarf', 'Tindouf', 'Tissemsilt', 'El Oued', 'Khenchela',
    'Souk Ahras', 'Tipaza', 'Mila', 'Aïn Defla', 'Naâma',
    'Aïn Témouchent', 'Ghardaïa', 'Relizane', 'Timimoun',
    'Bordj Badji Mokhtar', 'Ouled Djellal','Béni Abbès',
    'In Salah', 'In Guezzam', 'Touggourt', 'Djanet', 'EL m\'Ghair',
    'El Meniaa', 'Aflou', 'Barika', 'El Kantara', 'Bir el-Ater', 'El Aricha',
    'Ksar Chellala', 'Aïn Oussera', 'Messaad', 'Ksar El Boukhari', 'Bou Saâda', 'El Abiodh Sidi Cheikh'
  ];
  final Set<String> _selectedCities = {};
  final TextEditingController _citySearchCtrl = TextEditingController();

  @override
  void dispose() {
    _citySearchCtrl.dispose();
    super.dispose();
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  void _handleTerminer() {
    // TODO: persist preferences before navigating

    final role = ref.read(authProvider).role;
    final route = role == 'recruteur' ? '/home-recruteur' : '/home-candidat';
    Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
  }

  // ── City picker bottom sheet ──────────────────────────────────────────────
  void _openCityPicker() {
    _citySearchCtrl.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CityPickerSheet(
        allCities: _cities,
        selected: _selectedCities,
        searchController: _citySearchCtrl,
        accent: _accent,
        primary: _primary,
        onChanged: (city, value) {
          setState(() {
            if (value) {
              _selectedCities.add(city);
            } else {
              _selectedCities.remove(city);
            }
          });
        },
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AuthHeader(onBackPressed: () => Navigator.pop(context)),

            // ── Title ─────────────────────────────────────────────────────
            const SizedBox(height: 24),
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

                  // ── 3. Preferred Cities (dropdown) ─────────────────────
                  _buildCard(
                    icon: Icons.apartment_outlined,
                    title: 'Wilayas préférées',
                    subtitle: 'Choisissez dans quelles wilayas vous souhaitez travailler',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Tappable dropdown field ───────────────────────
                        GestureDetector(
                          onTap: _openCityPicker,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: _bg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedCities.isNotEmpty
                                    ? _accent
                                    : Colors.grey.shade300,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search,
                                    size: 18, color: Colors.grey.shade500),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _selectedCities.isEmpty
                                        ? 'Rechercher une wilaya…'
                                        : '${_selectedCities.length} wilaya${_selectedCities.length > 1 ? 's' : ''} sélectionnée${_selectedCities.length > 1 ? 's' : ''}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _selectedCities.isEmpty
                                          ? Colors.grey.shade500
                                          : Colors.black87,
                                      fontWeight: _selectedCities.isEmpty
                                          ? FontWeight.w400
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_down_rounded,
                                    color: Colors.grey.shade500),
                              ],
                            ),
                          ),
                        ),

                        // ── Selected chips ────────────────────────────────
                        if (_selectedCities.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: _selectedCities.map((city) {
                              return Chip(
                                label: Text(city,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white)),
                                backgroundColor: _accent,
                                deleteIcon: const Icon(Icons.close,
                                    size: 14, color: Colors.white70),
                                onDeleted: () => setState(
                                    () => _selectedCities.remove(city)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                side: BorderSide.none,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              );
                            }).toList(),
                          ),
                        ],
                      ],
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

// ══════════════════════════════════════════════════════════════════════════
// ── Searchable multi-select bottom sheet ──────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════
class _CityPickerSheet extends StatefulWidget {
  final List<String> allCities;
  final Set<String> selected;
  final TextEditingController searchController;
  final Color accent;
  final Color primary;
  final void Function(String city, bool value) onChanged;

  const _CityPickerSheet({
    required this.allCities,
    required this.selected,
    required this.searchController,
    required this.accent,
    required this.primary,
    required this.onChanged,
  });

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  String _query = '';

  List<String> get _filtered => _query.isEmpty
      ? widget.allCities
      : widget.allCities
            .where((c) => c.toLowerCase().contains(_query.toLowerCase()))
            .toList();

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      padding: EdgeInsets.only(bottom: bottomPad),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ── Handle bar ─────────────────────────────────────────────────
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // ── Title row ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.apartment_outlined,
                    color: widget.primary, size: 22),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('Sélectionner les wilayas',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK',
                      style: TextStyle(
                          color: widget.accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                ),
              ],
            ),
          ),

          // ── Search field ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
            child: TextField(
              controller: widget.searchController,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Rechercher…',
                hintStyle: TextStyle(
                    fontSize: 13, color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search,
                    size: 20, color: Colors.grey.shade400),
                suffixIcon: _query.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          widget.searchController.clear();
                          setState(() => _query = '');
                        },
                        child: Icon(Icons.close,
                            size: 18, color: Colors.grey.shade400),
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF7F5FF),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── Results count ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  '${_filtered.length} wilaya${_filtered.length > 1 ? 's' : ''}',
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500),
                ),
                const Spacer(),
                if (widget.selected.isNotEmpty)
                  Text(
                    '${widget.selected.length} sélectionnée${widget.selected.length > 1 ? 's' : ''}',
                    style: TextStyle(
                        fontSize: 11,
                        color: widget.accent,
                        fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // ── List ───────────────────────────────────────────────────────
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text('Aucun résultat',
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 13)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final city = _filtered[i];
                      final checked = widget.selected.contains(city);
                      // Wilaya number (1-indexed from master list)
                      final num = widget.allCities.indexOf(city) + 1;
                      return ListTile(
                        dense: true,
                        visualDensity: const VisualDensity(
                            horizontal: 0, vertical: -2),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        leading: Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: checked
                                ? widget.accent.withValues(alpha: 0.12)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            num.toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: checked
                                  ? widget.accent
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ),
                        title: Text(city,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: checked
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: checked
                                  ? Colors.black87
                                  : Colors.black54,
                            )),
                        trailing: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: checked
                              ? Icon(Icons.check_circle_rounded,
                                  key: const ValueKey('on'),
                                  color: widget.accent,
                                  size: 22)
                              : Icon(Icons.circle_outlined,
                                  key: const ValueKey('off'),
                                  color: Colors.grey.shade300,
                                  size: 22),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        onTap: () {
                          widget.onChanged(city, !checked);
                          setState(() {});
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
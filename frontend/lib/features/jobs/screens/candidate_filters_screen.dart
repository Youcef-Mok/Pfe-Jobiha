import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/applications/data/providers/applications_provider.dart';
import 'package:job_app/features/jobs/widgets/candidate_filter_sheets.dart';

class CandidateFiltersScreen extends ConsumerStatefulWidget {
  const CandidateFiltersScreen({super.key});

  @override
  ConsumerState<CandidateFiltersScreen> createState() =>
      _CandidateFiltersScreenState();
}

class _CandidateFiltersScreenState
    extends ConsumerState<CandidateFiltersScreen> {
  double _distance = 10;
  LatLng? _pickedLatLng;
  String? _pickedLabel;
  final MapController _previewMapController = MapController();

  @override
  void dispose() {
    _previewMapController.dispose();
    super.dispose();
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => LocationPickerPage(
          initialPosition: _pickedLatLng,
          radius: _distance,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _pickedLatLng = result['latlng'] as LatLng;
        _pickedLabel = result['label'] as String?;
      });
      ref
          .read(candidateFiltersProvider.notifier)
          .setLocation(_pickedLabel ?? 'Position choisie');
      _previewMapController.move(_pickedLatLng!, 13.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(candidateFiltersProvider);
    final notifier = ref.read(candidateFiltersProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.white,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back,
                        size: 22, color: Color(0xFF18181B)),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Filtres',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                      color: Color(0xFF18181B),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: notifier.reset,
                    child: const Icon(Icons.refresh_outlined,
                        size: 20, color: Color(0xFF401E66)),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Appliquer',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF401E66),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable filter sections
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  // Catégorie du Job
                  _FilterCard(
                    icon: Icons.category_outlined,
                    title: 'Catégorie du Job',
                    child: _CategoryDropdown(
                      value: filters.category,
                      onChanged: notifier.setCategory,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Disponibilité
                  _FilterCard(
                    icon: Icons.calendar_today_outlined,
                    title: 'Disponibilité',
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: ['Temps plein', 'Temps partiel', 'Flexible']
                          .map((label) {
                        final selected = filters.availability.contains(label);
                        return GestureDetector(
                          onTap: () => notifier.toggleAvailability(label),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFEDF2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected
                                    ? const Color(0xFF401E66)
                                    : const Color(0xFFD8D4DE),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 15,
                                  height: 15,
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? const Color(0xFF3A1B5E)
                                        : Colors.white,
                                    border: selected
                                        ? null
                                        : Border.all(
                                            color: const Color(0xFF7C7580)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: selected
                                      ? const Icon(Icons.check,
                                          size: 13, color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  label,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Color.fromARGB(255, 23, 23, 24),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Localisation
                  _FilterCard(
                    icon: Icons.location_on_outlined,
                    title: 'Localisation',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Map preview
                        GestureDetector(
                          onTap: _openMapPicker,
                          child: Container(
                            height: 166,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 4),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0D000000),
                                  blurRadius: 4,
                                  spreadRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                children: [
                                  IgnorePointer(
                                    child: FlutterMap(
                                      mapController: _previewMapController,
                                      options: MapOptions(
                                        initialCenter: _pickedLatLng ??
                                            const LatLng(36.737, 3.086),
                                        initialZoom: 13.0,
                                        interactionOptions:
                                            const InteractionOptions(
                                          flags: InteractiveFlag.none,
                                        ),
                                      ),
                                      children: [
                                        TileLayer(
                                          urlTemplate:
                                              'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                                          subdomains: const [
                                            'a',
                                            'b',
                                            'c',
                                            'd'
                                          ],
                                          userAgentPackageName:
                                              'com.jobiha.app',
                                          maxZoom: 18,
                                          maxNativeZoom: 18,
                                          errorTileCallback: (_, __, ___) {},
                                        ),
                                        if (_pickedLatLng != null)
                                          MarkerLayer(
                                            markers: [
                                              Marker(
                                                point: _pickedLatLng!,
                                                width: 36,
                                                height: 44,
                                                alignment: Alignment.topCenter,
                                                child: const Icon(
                                                  Icons.location_pin,
                                                  size: 36,
                                                  color: Color(0xFF3A1B5E),
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Tap label
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 10,
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3A1B5E),
                                          borderRadius:
                                              BorderRadius.circular(9999),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0x44000000),
                                              blurRadius: 8,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _pickedLatLng == null
                                                  ? Icons.touch_app_rounded
                                                  : Icons
                                                      .edit_location_alt_outlined,
                                              size: 13,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              _pickedLatLng == null
                                                  ? 'Appuyer pour choisir'
                                                  : (_pickedLabel ??
                                                      'Position choisie'),
                                              style: const TextStyle(
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Secteur Actif badge
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF3A1B5E),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Secteur Actif',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Radius label
                        const Text(
                          'Rayon (km)',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Color(0xFF1D1B1F),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 8,
                            activeTrackColor: const Color(0xFF401E66),
                            inactiveTrackColor: const Color(0xFFE7E0E7),
                            thumbColor: const Color(0xFF3A1B5E),
                            overlayShape: SliderComponentShape.noOverlay,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 7),
                          ),
                          child: Slider(
                            value: _distance,
                            min: 1,
                            max: 50,
                            onChanged: (val) => setState(() => _distance = val),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('1 km',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: Color(0xFF7C7580))),
                            Text('10 km',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: Color(0xFF7C7580))),
                            Text('50 km',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: Color(0xFF7C7580))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Type de contrat
                  _FilterCard(
                    icon: Icons.description_outlined,
                    title: 'Type de contrat',
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: ['CDI', 'Mission', 'Freelance']
                          .map((label) {
                        final selected = filters.contractTypes.contains(label);
                        return GestureDetector(
                          onTap: () => notifier.toggleContractType(label),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFF3A1B5E)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(9999),
                              border: selected
                                  ? null
                                  : Border.all(color: const Color(0xFF513376)),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF3A1B5E),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Filter card container
class _FilterCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _FilterCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Color(0xFF1D1B1F),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// Category item definition
class _CategoryItem {
  final String label;
  final IconData icon;
  const _CategoryItem(this.label, this.icon);
}

// Category picker — styled DropdownButton
class _CategoryDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  static const _categories = <_CategoryItem>[
    _CategoryItem('Restauration', Icons.restaurant_outlined),
    _CategoryItem('Technologie', Icons.computer_outlined),
    _CategoryItem('Commerce', Icons.storefront_outlined),
    _CategoryItem('Sante', Icons.health_and_safety_outlined),
    _CategoryItem('Education', Icons.school_outlined),
    _CategoryItem('Transport', Icons.directions_car_outlined),
  ];

  const _CategoryDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEDF2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              value != null ? const Color(0xFF401E66) : const Color(0xFFD8D4DE),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              size: 20, color: Color(0xFF401E66)),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Color(0xFF401E66),
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          hint: const Row(
            children: [
              Icon(Icons.category_outlined, size: 16, color: Color(0xFF9E99A5)),
              SizedBox(width: 8),
              Text(
                'Choisir une catégorie',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: Color(0xFF9E99A5),
                ),
              ),
            ],
          ),
          selectedItemBuilder: (_) => [
            // Reset/Hint item
            const Row(
              children: [
                Icon(Icons.category_outlined,
                    size: 16, color: Color(0xFF9E99A5)),
                SizedBox(width: 8),
                Text(
                  'Choisir une catégorie',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: Color(0xFF9E99A5),
                  ),
                ),
              ],
            ),
            ..._categories.map(
              (cat) => Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF513376),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(cat.icon, size: 13, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cat.label,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF401E66),
                    ),
                  ),
                ],
              ),
            ),
          ],
          items: [
            // Reset option
            const DropdownMenuItem<String?>(
              value: null,
              child: Row(
                children: [
                  Icon(Icons.close, size: 14, color: Color(0xFF9E99A5)),
                  SizedBox(width: 8),
                  Text(
                    'Aucune catégorie',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: Color(0xFF9E99A5),
                    ),
                  ),
                ],
              ),
            ),
            ..._categories.map(
              (cat) => DropdownMenuItem<String?>(
                value: cat.label,
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: value == cat.label
                            ? const Color(0xFF513376)
                            : const Color(0xFFE8E1F4),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          cat.icon,
                          size: 13,
                          color: value == cat.label
                              ? Colors.white
                              : const Color(0xFF401E66),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      cat.label,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: value == cat.label
                            ? FontWeight.w700
                            : FontWeight.w600,
                        fontSize: 13,
                        color: const Color(0xFF401E66),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}


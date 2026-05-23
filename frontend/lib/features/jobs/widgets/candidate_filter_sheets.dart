import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/applications/data/providers/applications_provider.dart';
import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';

Future<void> showAvailabilitySheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    useSafeArea: true,
    builder: (context) => const _AvailabilitySheetV2(),
  );
}

Future<void> showContractTypeSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    useSafeArea: true,
    builder: (context) => const _ContractTypeSheet(),
  );
}

Future<void> showLocationSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => const _LocationSheet(),
  );
}

Future<void> showDomainSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    useSafeArea: true,
    builder: (context) => const _DomainSheet(),
  );
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// DISPONIBILITÉ
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _AvailabilitySheet extends ConsumerWidget {
  const _AvailabilitySheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(candidateFiltersProvider);
    final notifier = ref.read(candidateFiltersProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 358,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFCCC3D0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000), // 0.05
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined,
                        size: 20, color: Color(0xFF3A1B5E)),
                    const SizedBox(width: 12),
                    const Text(
                      'Disponibilité',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF1D1B1F),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Dropdown Horaires
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEDF2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Horaires',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Color(0xFF4A454F),
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: Color(0xFF3A1B5E)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Checkboxes Wrap
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    'Temps plein',
                    'Temps partiel',
                    'Flexible',
                  ].map((label) {
                    final isSelected = filters.availability.contains(label);
                    return GestureDetector(
                      onTap: () => notifier.toggleAvailability(label),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFEDF2),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Checkbox
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF3A1B5E)
                                    : Colors.white,
                                border: isSelected
                                    ? null
                                    : Border.all(
                                        color: const Color(0xFF7C7580)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check,
                                      size: 14, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              label,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Color(0xFF1D1B1F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _ContractTypeSheet extends ConsumerWidget {
  const _ContractTypeSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(candidateFiltersProvider);
    final notifier = ref.read(candidateFiltersProvider.notifier);

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFCCC3D0)),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDEDEDE),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Catégorie',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        height: 26 / 18,
                        letterSpacing: -0.4,
                        color: Color(0xFF3A1B5E),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        for (final type
                            in ['CDI', 'Mission', 'Freelance']) {
                          if (filters.contractTypes.contains(type)) {
                            notifier.toggleContractType(type);
                          }
                        }
                      },
                      child: const Text(
                        'Réinitialiser',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF401E66),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: ['CDI', 'Mission', 'Freelance']
                      .map((label) {
                    final isSelected = filters.contractTypes.contains(label);
                    return GestureDetector(
                      onTap: () => notifier.toggleContractType(label),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF3A1B5E)
                              : const Color(0xFFEFEDF2),
                          border: isSelected
                              ? null
                              : Border.all(
                                  color: const Color(0xFF513376), width: 1),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            height: 20 / 14,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF3A1B5E),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.invalidate(nearbyJobsProvider);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A1B5E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                    child: const Text(
                      'Confirmer',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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
    );
  }
}

class _DomainSheet extends ConsumerWidget {
  const _DomainSheet();

  static const _domains = <String>[
    'Restauration',
    'Technologie',
    'Commerce',
    'Sante',
    'Education',
    'Transport',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(candidateFiltersProvider);
    final notifier = ref.read(candidateFiltersProvider.notifier);

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFCCC3D0)),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDEDEDE),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Domaine',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: Color(0xFF3A1B5E),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => notifier.setCategory(null),
                    child: const Text(
                      'Réinitialiser',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF401E66),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _domains.map((label) {
                  final isSelected = filters.category == label;
                  return GestureDetector(
                    onTap: () => notifier.setCategory(isSelected ? null : label),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF3A1B5E)
                            : const Color(0xFFEFEDF2),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: isSelected ? Colors.white : const Color(0xFF3A1B5E),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    ref.invalidate(nearbyJobsProvider);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A1B5E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                  child: const Text(
                    'Confirmer',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// LOCALISATION
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _LocationSheet extends ConsumerStatefulWidget {
  const _LocationSheet();

  @override
  ConsumerState<_LocationSheet> createState() => _LocationSheetState();
}

class _LocationSheetState extends ConsumerState<_LocationSheet> {
  static const _cities = [
    'Sidi Abdallah (Alger - 16)',
    'Zeralda (Alger - 16)',
    'Cheraga (Alger - 16)',
    'Akid Lotfi (Oran - 31)',
    'Bir El Djir (Oran - 31)',
    'Canastel (Oran - 31)',
    'Daksi (Constantine - 25)',
    'Zouaghi (Constantine - 25)',
    'Khroub (Constantine - 25)',
    'Blida Centre (Blida - 09)',
    'Ouled Yaich (Blida - 09)'
  ];
  double _distance = 10;
  final bool _isCityExpanded = false;
  String _searchQuery = '';
  final LayerLink _layerLink = LayerLink();
  LatLng? _pickedLatLng;
  String? _pickedLabel;
  final MapController _previewMapController = MapController();

  void _clearAll() {
    ref.read(candidateFiltersProvider.notifier).setLocation(null);
    ref
        .read(candidateFiltersProvider.notifier)
        .setLocationGeo(lat: null, lng: null, radiusKm: null);
    setState(() {
      _distance = 10;
      _searchQuery = '';
      _pickedLatLng = null;
      _pickedLabel = null;
    });
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
      ref.read(candidateFiltersProvider.notifier).setLocationGeo(
            lat: _pickedLatLng?.latitude,
            lng: _pickedLatLng?.longitude,
            radiusKm: _distance,
          );
      // Animate the preview map to the new position
      _previewMapController.move(_pickedLatLng!, 13.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(candidateFiltersProvider);
    final notifier = ref.read(candidateFiltersProvider.notifier);
    final selectedCity = filters.location;

    return SafeArea(
      child: Padding(
        padding:
            const EdgeInsets.only(bottom: 20), // Increased padding from bottom
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 22),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFCCC3D0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000), // 0.05
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDEDEDE),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Emplacement',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            height: 26 / 18,
                            letterSpacing: -0.4,
                            color: Color(0xFF3A1B5E),
                          ),
                        ),
                        GestureDetector(
                          onTap: _clearAll,
                          child: const Text(
                            'Réinitialiser',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Color(0xFF401E66),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
                                      subdomains: const ['a', 'b', 'c', 'd'],
                                      userAgentPackageName: 'com.jobiha.app',
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
                                      borderRadius: BorderRadius.circular(9999),
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
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Rayon (km)',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        height: 32 / 22,
                        color: Color(0xFF1D1B1F),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 8,
                        activeTrackColor: const Color(0xFF401E66),
                        inactiveTrackColor: const Color(0xFFE7E0E7),
                        thumbColor: const Color(0xFF3A1B5E),
                        overlayShape: SliderComponentShape.noOverlay,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 7),
                      ),
                      child: Slider(
                        value: _distance,
                        min: 1,
                        max: 50,
                        onChanged: (val) {
                          setState(() => _distance = val);
                          final picked = _pickedLatLng;
                          if (picked != null) {
                            ref.read(candidateFiltersProvider.notifier).setLocationGeo(
                                  lat: picked.latitude,
                                  lng: picked.longitude,
                                  radiusKm: val,
                                );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '1 km',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            height: 16 / 12,
                            color: Color(0xFF7C7580),
                          ),
                        ),
                        Text(
                          '10 km',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            height: 16 / 12,
                            color: Color(0xFF7C7580),
                          ),
                        ),
                        Text(
                          '50 km',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            height: 16 / 12,
                            color: Color(0xFF7C7580),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AvailabilitySheetV2 extends ConsumerStatefulWidget {
  const _AvailabilitySheetV2();

  @override
  ConsumerState<_AvailabilitySheetV2> createState() =>
      _AvailabilitySheetV2State();
}

class _AvailabilitySheetV2State extends ConsumerState<_AvailabilitySheetV2> {
  static const _contractOptions = ['Temps plein', 'Temps partiel', 'Freelance'];
  String _selectedContract = '';

  @override
  void initState() {
    super.initState();
    final current = ref.read(candidateFiltersProvider).availability;
    _selectedContract = _contractOptions.firstWhere(
      current.contains,
      orElse: () => '',
    );
  }

  void _selectContract(String value) {
    final notifier = ref.read(candidateFiltersProvider.notifier);
    final current = ref.read(candidateFiltersProvider).availability;
    for (final option in _contractOptions) {
      if (current.contains(option)) {
        notifier.toggleAvailability(option);
      }
    }
    if (value.isNotEmpty && !current.contains(value)) {
      notifier.toggleAvailability(value);
    }
    setState(() => _selectedContract = value);
  }

  void _clearAll() {
    final notifier = ref.read(candidateFiltersProvider.notifier);
    final current = ref.read(candidateFiltersProvider).availability;
    for (final option in _contractOptions) {
      if (current.contains(option)) {
        notifier.toggleAvailability(option);
      }
    }
    setState(() => _selectedContract = '');
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(candidateFiltersProvider);

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(10, 11, 10, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFCCC3D0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000), // rgba(0, 0, 0, 0.05)
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDEDEDE),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Disponibilités',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          height: 26 / 18,
                          letterSpacing: -0.4,
                          color: Color(0xFF3A1B5E),
                        ),
                      ),
                      GestureDetector(
                        onTap: _clearAll,
                        child: const Text(
                          'Réinitialiser',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Color(0xFF401E66),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CRÉNEAUX HORAIRES',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          height: 16 / 12,
                          letterSpacing: 1.2,
                          color: Color(0xFF7C7580),
                        ),
                      ),
                      const SizedBox(height: 13),
                      Column(
                        children: [
                          ...[
                            {
                              'label': 'Temps plein',
                              'icon': Icons.work_outline
                            },
                            {
                              'label': 'Temps partiel',
                              'icon': Icons.access_time_outlined
                            },
                            {
                              'label': 'Flexible',
                              'icon': Icons.tune
                            },
                          ].map<Widget>((item) {
                            final label = item['label'] as String;
                            final icon = item['icon'] as IconData;
                            final isSelected =
                                filters.availability.contains(label);
                            return _HorairesOptionRow(
                              label: label,
                              icon: icon,
                              isSelected: isSelected,
                              onTap: () {
                                ref
                                    .read(candidateFiltersProvider.notifier)
                                    .toggleAvailability(label);
                              },
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TYPE DE CONTRAT',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          height: 16 / 12,
                          letterSpacing: 1.2,
                          color: Color(0xFF7C7580),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _contractOptions.map((option) {
                          final isSelected = _selectedContract == option ||
                              filters.availability.contains(option);
                          return GestureDetector(
                            onTap: () => _selectContract(option),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF3A1B5E)
                                    : const Color(0xFFEFEDF2),
                                border: isSelected
                                    ? null
                                    : Border.all(
                                        color: const Color(0xFF513376),
                                        width: 1),
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  height: 20 / 14,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF3A1B5E),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.invalidate(nearbyJobsProvider);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A1B5E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                    child: const Text(
                      'Confirmer',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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
    );
  }
}

class _HorairesOptionRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _HorairesOptionRow({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.fromLTRB(12, 8, 24, 8),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEBE6F2) : const Color(0xFFEFEDF2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF513376)
                    : const Color(0xFFE8E1F4),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 14,
                  color: isSelected ? Colors.white : const Color(0xFF401E66),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
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
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// FULL-SCREEN MAP LOCATION PICKER
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class LocationPickerPage extends StatefulWidget {
  final LatLng? initialPosition;
  final double radius;
  const LocationPickerPage(
      {super.key, this.initialPosition, required this.radius});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage>
    with TickerProviderStateMixin {
  static const _defaultCenter = LatLng(36.737, 3.086); // Algiers
  static const _userLocation = LatLng(36.762, 3.040); // Chéraga

  late final MapController _mapController;
  late final AnimationController _moveCtrl;
  late Animation<double> _moveAnim;
  Tween<double>? _latTween, _lngTween, _zoomTween;

  final TextEditingController _searchCtrl = TextEditingController();
  final bool _showSearch = false;

  // The center of the map (updated on every camera-move event)
  LatLng _center = _defaultCenter;
  String _communeName = 'Chéraga, Alger';

  String _getCommuneName(LatLng p) {
    final lat = p.latitude;
    final lng = p.longitude;
    // â”€â”€ Alger (36.6-36.85, 2.8-3.35) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    if (lat > 36.75 && lat < 36.80 && lng > 3.00 && lng < 3.06) {
      return 'Chéraga, Alger';
    }
    if (lat > 36.73 && lat < 36.77 && lng > 3.06 && lng < 3.12) {
      return 'Bab El Oued, Alger';
    }
    if (lat > 36.76 && lat < 36.80 && lng > 3.04 && lng < 3.10) {
      return 'El Biar, Alger';
    }
    if (lat > 36.77 && lat < 36.83 && lng > 3.07 && lng < 3.15) {
      return 'Rouïba, Alger';
    }
    if (lat > 36.74 && lat < 36.77 && lng > 3.06 && lng < 3.10) {
      return 'Sidi M\'Hamed, Alger';
    }
    if (lat > 36.72 && lat < 36.75 && lng > 3.05 && lng < 3.10) {
      return 'Hussein Dey, Alger';
    }
    if (lat > 36.70 && lat < 36.73 && lng > 3.08 && lng < 3.14) {
      return 'El Harrach, Alger';
    }
    if (lat > 36.74 && lat < 36.77 && lng > 2.96 && lng < 3.01) {
      return 'Zéralda, Alger';
    }
    if (lat > 36.71 && lat < 36.74 && lng > 2.93 && lng < 2.98) {
      return 'Sidi Abdallah, Alger';
    }
    if (lat > 36.67 && lat < 36.72 && lng > 3.01 && lng < 3.08) {
      return 'Bir Mourad Raïs, Alger';
    }
    if (lat > 36.76 && lat < 36.82 && lng > 3.12 && lng < 3.20) {
      return 'Dar El Beïda, Alger';
    }
    if (lat > 36.80 && lat < 36.86 && lng > 3.05 && lng < 3.15) {
      return 'Bordj El Kiffan, Alger';
    }
    if (lat > 36.83 && lat < 36.90 && lng > 3.13 && lng < 3.25) {
      return 'Bab Ezzouar, Alger';
    }
    if (lat > 36.6 && lat < 36.9 && lng > 2.8 && lng < 3.35) return 'Alger';
    // â”€â”€ Oran (35.5-35.8, -0.7-0.8) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    if (lat > 35.60 && lat < 35.75 && lng > -0.68 && lng < -0.55) {
      return 'Oran Centre';
    }
    if (lat > 35.58 && lat < 35.65 && lng > -0.62 && lng < -0.54) {
      return 'Bir El Djir, Oran';
    }
    if (lat > 35.65 && lat < 35.72 && lng > -0.68 && lng < -0.60) {
      return 'Bir El Djir, Oran';
    }
    if (lat > 35.70 && lat < 35.78 && lng > -0.68 && lng < -0.58) {
      return 'Aïn El Turck, Oran';
    }
    if (lat > 35.5 && lat < 35.8 && lng > -0.8 && lng < 0.0) return 'Oran';
    // â”€â”€ Constantine (36.3-36.5, 6.5-6.7) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    if (lat > 36.35 && lat < 36.42 && lng > 6.59 && lng < 6.66) {
      return 'Constantine Centre';
    }
    if (lat > 36.30 && lat < 36.38 && lng > 6.54 && lng < 6.63) {
      return 'El Khroub, Constantine';
    }
    if (lat > 36.28 && lat < 36.35 && lng > 6.56 && lng < 6.65) {
      return 'Hamma Bouziane';
    }
    if (lat > 36.2 && lat < 36.5 && lng > 6.4 && lng < 6.8) {
      return 'Constantine';
    }
    // â”€â”€ Annaba (36.9-37.0, 7.7-7.9) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    if (lat > 36.88 && lat < 36.96 && lng > 7.74 && lng < 7.84) {
      return 'Annaba Centre';
    }
    if (lat > 36.8 && lat < 37.0 && lng > 7.6 && lng < 8.0) return 'Annaba';
    // â”€â”€ Blida (36.4-36.5, 2.8-2.95) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    if (lat > 36.46 && lat < 36.52 && lng > 2.83 && lng < 2.92) {
      return 'Blida Centre';
    }
    if (lat > 36.50 && lat < 36.56 && lng > 2.86 && lng < 2.96) {
      return 'Ouled Yaïch, Blida';
    }
    if (lat > 36.4 && lat < 36.6 && lng > 2.7 && lng < 3.0) return 'Blida';
    // â”€â”€ Tlemcen (34.8-35.0, -1.4--1.2) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    if (lat > 34.86 && lat < 34.93 && lng > -1.35 && lng < -1.28) {
      return 'Tlemcen Centre';
    }
    if (lat > 34.7 && lat < 35.1 && lng > -1.5 && lng < -1.1) return 'Tlemcen';
    // â”€â”€ Sétif (36.1-36.2, 5.4-5.5) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    if (lat > 36.17 && lat < 36.22 && lng > 5.39 && lng < 5.47) {
      return 'Sétif Centre';
    }
    if (lat > 36.0 && lat < 36.4 && lng > 5.2 && lng < 5.7) return 'Sétif';
    // â”€â”€ Batna (35.5-35.6, 6.1-6.2) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    if (lat > 35.54 && lat < 35.60 && lng > 6.14 && lng < 6.20) {
      return 'Batna Centre';
    }
    if (lat > 35.4 && lat < 35.7 && lng > 5.9 && lng < 6.4) return 'Batna';
    // â”€â”€ Béjaïa (36.7-36.8, 5.0-5.1) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    if (lat > 36.73 && lat < 36.77 && lng > 5.05 && lng < 5.10) {
      return 'Béjaïa Centre';
    }
    if (lat > 36.6 && lat < 36.9 && lng > 4.9 && lng < 5.3) return 'Béjaïa';
    // â”€â”€ Fallback by wilaya zones â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    if (lat > 33.0 && lat < 35.0 && lng > 5.0 && lng < 9.0) {
      return 'Biskra / Oasis';
    }
    if (lat > 28.0 && lat < 33.0) return 'Sahara Algérien';
    if (lat > 36.9 && lat < 37.2 && lng > 6.5 && lng < 9.0) {
      return 'Skikda / Nord-Est';
    }
    return 'Algérie';
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _center = widget.initialPosition ?? _defaultCenter;

    _moveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _moveAnim = CurvedAnimation(parent: _moveCtrl, curve: Curves.fastOutSlowIn);
    _moveCtrl.addListener(() {
      if (_latTween != null) {
        _mapController.move(
          LatLng(
            _latTween!.evaluate(_moveAnim),
            _lngTween!.evaluate(_moveAnim),
          ),
          _zoomTween!.evaluate(_moveAnim),
        );
      }
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    _moveCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _animateTo(LatLng dest, double zoom) {
    _moveCtrl.stop();
    _latTween =
        Tween(begin: _mapController.camera.center.latitude, end: dest.latitude);
    _lngTween = Tween(
        begin: _mapController.camera.center.longitude, end: dest.longitude);
    _zoomTween = Tween(begin: _mapController.camera.zoom, end: zoom);
    _moveCtrl.reset();
    _moveCtrl.forward();
  }

  void _confirm() {
    Navigator.of(context).pop<Map<String, dynamic>>({
      'latlng': _center,
      'label': _communeName,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // â”€â”€ OSM Map â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 14.0,
              minZoom: 5,
              maxZoom: 18,
              onPositionChanged: (camera, _) {
                setState(() {
                  _center = camera.center;
                  _communeName = _getCommuneName(_center);
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.jobiha.app',
                maxZoom: 18,
                maxNativeZoom: 18,
                tileSize: 256,
                keepBuffer: 4,
                panBuffer: 2,
                errorTileCallback: (_, __, ___) {},
                evictErrorTileStrategy: EvictErrorTileStrategy.dispose,
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _center,
                    radius: widget.radius * 1000, // KM to Meters
                    useRadiusInMeter: true,
                    color: const Color(0x223A1B5E),
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  // User current position dot (same style as main map)
                  Marker(
                    point: _userLocation,
                    width: 22,
                    height: 22,
                    child: _UserLocationDot(),
                  ),
                ],
              ),
            ],
          ),

          IgnorePointer(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(
                    bottom:
                        22), // Offset to make the tip of the icon point to the center
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 44,
                    ),
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFF3A1B5E),
                      size: 40,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // â”€â”€ Top bar: back + search â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: Row(
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back,
                            size: 20, color: Color(0xFF1D1B1F)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Search bar
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(9999),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: Color(0xFF1D1B1F),
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Rechercher un lieu…',
                            hintStyle: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: Color(0xFF9CA3AF),
                            ),
                            prefixIcon: Icon(Icons.search,
                                size: 20, color: Color(0xFF6B7280)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 13),
                          ),
                          onSubmitted: (_) => FocusScope.of(context).unfocus(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // â”€â”€ GPS recenter button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Positioned(
            right: 16,
            bottom: 200,
            child: GestureDetector(
              onTap: () => _animateTo(_userLocation, 15.0),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.gps_fixed,
                    color: Color(0xFF3A1B5E), size: 22),
              ),
            ),
          ),

          // â”€â”€ Coordinate label + Confirm button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 16,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag indicator
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDEDEDE),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Color(0xFF3A1B5E), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _communeName,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D1B1F),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _confirm,
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text(
                          'Choisir cette position',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3A1B5E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€ User location dot widget â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _UserLocationDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF725199).withOpacity(0.6),
            blurRadius: 8,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: Color(0xFF401E66),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

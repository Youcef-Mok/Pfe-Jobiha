import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/core/widgets/candidate_nav_bar.dart';
import 'package:job_app/features/map/domain/map_job_entity.dart';
import 'package:job_app/features/map/data/providers/map_providers.dart';
import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/features/jobs/screens/candidate_filters_screen.dart';
import 'package:job_app/features/jobs/widgets/candidate_job_card.dart';
import 'package:job_app/features/profile/data/providers/profile_provider.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:url_launcher/url_launcher.dart';

// Default fallback (Alger-Centre) used when user has no location set
const _defaultLat = 36.762;
const _defaultLng = 3.040;

// ─── Screen ─────────────────────────────────────────────────────────────
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  bool _ready = false;
  bool _showSearch = false;
  bool _showResults = false;
  late AnimationController _moveController;
  Tween<double>? _latTween;
  Tween<double>? _lngTween;
  Tween<double>? _zoomTween;
  late Animation<double> _moveAnimation;

  @override
  void initState() {
    super.initState();
    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _moveAnimation = CurvedAnimation(
      parent: _moveController,
      curve: Curves.fastOutSlowIn,
    );
    _moveController.addListener(() {
      if (_latTween != null && _lngTween != null && _zoomTween != null) {
        _mapController.move(
          LatLng(
            _latTween!.evaluate(_moveAnimation),
            _lngTween!.evaluate(_moveAnimation),
          ),
          _zoomTween!.evaluate(_moveAnimation),
        );
      }
    });
    _sheetController.addListener(_onSheetScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _ready = true);
        _checkAndRequestLocation();
      }
    });
  }

  void _onSheetScroll() {
    if (mounted) setState(() {});
  }

  void _selectJob(MapJobEntity job) {
    ref.read(selectedMapJobProvider.notifier).state = job;
    ref.read(recentSearchesProvider.notifier).addSearch(job.title);

    // Smoothly animate map to center on job icon, with offset to avoid overlay
    _animatedMapMove(LatLng(job.lat - 0.0038, job.lng), 15.5);

    // Snap sheet up to show full job detail
    if (_sheetController.isAttached) {
      _sheetController.animateTo(
        0.95,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Stop animation en cours si l'utilisateur retap rapidement
    _moveController.stop();

    _latTween = Tween<double>(
      begin: _mapController.camera.center.latitude,
      end: destLocation.latitude,
    );
    _lngTween = Tween<double>(
      begin: _mapController.camera.center.longitude,
      end: destLocation.longitude,
    );
    _zoomTween = Tween<double>(
      begin: _mapController.camera.zoom,
      end: destZoom,
    );

    _moveController.reset();
    _moveController.forward();
  }

  void _openSearch() => setState(() => _showSearch = true);
  void _closeSearch() => setState(() => _showSearch = false);
  void _submitSearch(String q) {
    ref.read(mapSearchQueryProvider.notifier).state = q;
    ref.read(recentSearchesProvider.notifier).addSearch(q);
    setState(() {
      _showSearch = false;
      _showResults = true;
    });
  }

  void _clearResults() {
    ref.read(mapSearchQueryProvider.notifier).state = '';
    setState(() {
      _showResults = false;
    });
  }

  void _recenterMap() {
    ref.read(selectedMapJobProvider.notifier).state = null;
    final gps = ref.read(userGpsPositionProvider);
    final user = ref.read(candidateCurrentUserProvider).valueOrNull;
    final lat = gps?.lat ?? user?.latitude ?? _defaultLat;
    final lng = gps?.lng ?? user?.longitude ?? _defaultLng;
    _animatedMapMove(LatLng(lat, lng), 14.0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_sheetController.isAttached) {
        _sheetController.animateTo(
          0.30,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _deselectJob() {
    ref.read(selectedMapJobProvider.notifier).state = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_sheetController.isAttached) {
        _sheetController.animateTo(
          0.30,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _checkAndRequestLocation() async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      final shouldRequest = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const _LocationPermissionDialog(),
      );
      if (shouldRequest != true) { return; }

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openLocationSettings();
        return;
      }
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) { return; }
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (!mounted) return;
      ref.read(userGpsPositionProvider.notifier).state = (
        lat: pos.latitude,
        lng: pos.longitude,
      );
      _animatedMapMove(LatLng(pos.latitude, pos.longitude), 14.0);
    } catch (_) {}
  }

  @override
  void dispose() {
    _mapController.dispose();
    _sheetController.dispose();
    _moveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF401E66),
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    final searchQuery = ref.watch(mapSearchQueryProvider);
    final selectedJob = ref.watch(selectedMapJobProvider);
    final filtered = ref.watch(filteredMapJobsProvider);
    final gps = ref.watch(userGpsPositionProvider);
    final userEntity = ref.watch(candidateCurrentUserProvider).valueOrNull;
    final userLat = gps?.lat ?? userEntity?.latitude ?? _defaultLat;
    final userLng = gps?.lng ?? userEntity?.longitude ?? _defaultLng;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── OSM Map ───────────────────────────────────────────────────────────
          Positioned.fill(
            child: RepaintBoundary(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(userLat, userLng),
                  initialZoom: 14.0,
                  minZoom: 10,
                  maxZoom: 18,
                  onTap: (_, __) => _deselectJob(),
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
                    keepBuffer: 2,
                    panBuffer: 0,
                    tileProvider: CancellableNetworkTileProvider(),
                    errorTileCallback: (tile, error, stackTrace) {},
                    evictErrorTileStrategy: EvictErrorTileStrategy.dispose,
                  ),
                  MarkerLayer(
                    rotate: false,
                    markers: [
                      Marker(
                        point: LatLng(userLat, userLng),
                        width: 22,
                        height: 22,
                        child: _UserLocationDot(),
                      ),
                      ...filtered.map((job) => Marker(
                            point: LatLng(job.lat, job.lng),
                            width: 134,
                            height: 62,
                            alignment: Alignment.bottomCenter,
                            child: GestureDetector(
                              onTap: () => _selectJob(job),
                              child: _MapPin(
                                job: job,
                                isSelected: selectedJob?.id == job.id,
                              ),
                            ),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Recenter FAB (Moves up based on sheet) ───────────────────────────
          if (!_showSearch && !_showResults)
            () {
              double bottomOffset;

              if (selectedJob != null) {
                // Fixed height for selected job overlay is 352
                bottomOffset = 352.0 + 16.0;
              } else {
                final double screenHeight = MediaQuery.of(context).size.height;
                double currentSize = 0.30;

                if (_sheetController.isAttached) {
                  try {
                    currentSize = _sheetController.size;
                  } catch (_) {
                    // Attached but not yet laid out
                  }
                }

                // Cap the FAB's upward movement so it doesn't go too high (e.g., stops at middle snap point)
                if (currentSize > 0.42) {
                  currentSize = 0.42;
                }

                // Scaffold body height is roughly screenHeight minus bottom nav
                bottomOffset = (currentSize * screenHeight) + 12.0;
              }

              return Positioned(
                right: 16,
                bottom: bottomOffset,
                child: _RecenterButton(onTap: _recenterMap),
              );
            }(),

          if (selectedJob != null && !_showSearch && !_showResults)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 352,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: _SelectedJobDetail(
                  job: selectedJob,
                  onClose: _deselectJob,
                ),
              ),
            ),

          // ── Bottom draggable sheet (suggestions, only when no job selected) ─
          if (!_showSearch && !_showResults && selectedJob == null)
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.34,
              minChildSize: 0.12,
              maxChildSize: 0.95,
              snap: true,
              snapSizes: const [0.12, 0.34, 0.52, 0.88, 0.95],
              builder: (context, scrollController) {
                return _BottomSheet(
                  scrollController: scrollController,
                  selectedJob: selectedJob,
                  allJobs: filtered,
                  onJobTap: _selectJob,
                );
              },
            ),

          // ── Search results sheet ─────────────────────────────────────────────
          if (_showResults)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: MediaQuery.of(context).padding.top + 132,
              child: _SearchResultsSheet(
                query: searchQuery,
                jobs: filtered,
                onClose: _clearResults,
                onJobTap: (j) {
                  _clearResults();
                  _selectJob(j);
                },
              ),
            ),

          // ── Search overlay (full screen) ─────────────────────────────────────
          if (_showSearch)
            Positioned.fill(
              child: _SearchOverlay(
                onClose: _closeSearch,
                onSubmit: _submitSearch,
              ),
            ),

          // TopOverlay LAST -> z-index max, dropdowns au-dessus de tout
          if (!_showSearch)
            () {
              return Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _TopOverlay(
                  onSearchTap: _openSearch,
                  hideSearchBar: false,
                  hideFilterRow: false,
                  onFilterApplied: () => setState(() => _showResults = true),
                ),
              );
            }(),

        ],
      ),
      bottomNavigationBar: const CandidateNavBar(currentIndex: 1),
    );
  }
}

// ─── User location dot ────────────────────────────────────────────────────────
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
            color: const Color(0xFF725199).withValues(alpha: 0.6),
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

// ─── Map pin (Redesigned: 134x46 white box with shadow) ─────────────────────
class _MapPin extends StatelessWidget {
  final MapJobEntity job;
  final bool isSelected;

  const _MapPin({required this.job, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 134,
          height: 44,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF401E66) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 25,
                spreadRadius: -5,
                offset: const Offset(0, 20),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: -6,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(12, 7, 12, 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : const Color(0xFF4B256B),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    job.categoryIcon,
                    size: 13,
                    color: isSelected ? const Color(0xFF401E66) : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      job.company,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color:
                            isSelected ? Colors.white : const Color(0xFF0F172A),
                        height: 1.25,
                      ),
                    ),
                    Text(
                      job.title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.8)
                            : const Color(0xFF4B256B),
                        letterSpacing: 0.45,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF401E66) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0x66512D6D), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isSelected ? 0.2 : 0.08),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Top overlay ─────────────────────────────────────────────────────────────
class _TopOverlay extends ConsumerStatefulWidget {
  final VoidCallback onSearchTap;
  final bool hideSearchBar;
  final bool hideFilterRow;
  final VoidCallback? onFilterApplied;

  const _TopOverlay({
    required this.onSearchTap,
    this.hideSearchBar = false,
    this.hideFilterRow = false,
    this.onFilterApplied,
  });

  @override
  ConsumerState<_TopOverlay> createState() => _TopOverlayState();
}

class _TopOverlayState extends ConsumerState<_TopOverlay> {
  // Which filter dropdown is open (null = none)
  String? _openFilter;

  void _toggleFilter(String key) {
    setState(() => _openFilter = _openFilter == key ? null : key);
  }

  void _selectOption(String filterKey, String value) {
    final current = ref.read(mapFiltersProvider);
    ref.read(mapFiltersProvider.notifier).state = {
      ...current,
      filterKey: value,
    };
    setState(() => _openFilter = null);
    // Ouvre l'overlay des résultats filtrés
    widget.onFilterApplied?.call();
  }

  void _removeFilter(String key) {
    final current = ref.read(mapFiltersProvider);
    final next = Map<String, String>.from(current)..remove(key);
    ref.read(mapFiltersProvider.notifier).state = next;
  }

  @override
  Widget build(BuildContext context) {
    final activeFilters = ref.watch(mapFiltersProvider);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            child: widget.hideSearchBar
                ? const SizedBox.shrink()
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(7, 6, 7, 0),
                        child: GestureDetector(
                          onTap: widget.onSearchTap,
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color(0x1A000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 2)),
                              ],
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 20),
                                const Icon(Icons.search,
                                    size: 22, color: Color(0xFF8D8DA6)),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Rechercher par nom d\'emploi',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      color: Color(0xFF8D8DA6),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const CandidateFiltersScreen()),
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
                      const SizedBox(height: 8),
                    ],
                  ),
          ),

          // Filter row — masquée quand le sheet est trop haut
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: widget.hideFilterRow
                ? const SizedBox(height: 0)
                : SizedBox(
                    height: 45,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      children: [
                        // Active filter chips
                        ...activeFilters.entries.map((e) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _ActiveFilterChip(
                                label: e.value,
                                onRemove: () => _removeFilter(e.key),
                              ),
                            )),

                        // Filter buttons
                        ...mapFilterOptions.keys.map((key) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _FilterButton(
                                label: key,
                                isOpen: _openFilter == key,
                                hasActive: activeFilters.containsKey(key),
                                onTap: () => _toggleFilter(key),
                              ),
                            )),
                      ],
                    ),
                  ),
          ),

          // Dropdown panel — toujours rendu ici (z-index max grâce à Stack order)
          AnimatedSwitcher(
            key: ValueKey(_openFilter ?? 'none'),
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return SizeTransition(
                sizeFactor: animation,
                axisAlignment: -1.0,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: _openFilter != null
                ? _DropdownPanel(
                    key: ValueKey(_openFilter),
                    options: mapFilterOptions[_openFilter!]!,
                    onSelect: (val) => _selectOption(_openFilter!, val),
                    activeValue: activeFilters[_openFilter!],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ─── Filter button ────────────────────────────────────────────────────────────
class _FilterButton extends StatelessWidget {
  final String label;
  final bool isOpen;
  final bool hasActive;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isOpen,
    required this.hasActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = isOpen || hasActive;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF401E66) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? null
              : [
                  const BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 6,
                      offset: Offset(0, 2))
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isActive ? Colors.white : const Color(0xFF401E66),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 16,
              color: isActive ? Colors.white : const Color(0xFF401E66),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Active filter chip ──────────────────────────
class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _ActiveFilterChip({
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRemove,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Label text
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Color(0xFF401E66),
              ),
            ),
            const SizedBox(width: 8),
            // Close icon
            const Icon(
              Icons.close,
              size: 14,
              color: Color(0xFF401E66),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Emplacement Filter Sheet ───────────────────────────────────────────────
class _LocationFilterSheet extends ConsumerStatefulWidget {
  final Function(String) onSelect;
  const _LocationFilterSheet({required this.onSelect});

  @override
  ConsumerState<_LocationFilterSheet> createState() =>
      _LocationFilterSheetState();
}

class _LocationFilterSheetState extends ConsumerState<_LocationFilterSheet> {
  String _selectedCity = '';
  double _radius = 10.0;

  final List<String> _cities = [
    'Alger',
    'Oran',
    'Constantine',
    'Annaba',
    'Blida',
    'Setif'
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(candidateCurrentUserProvider).valueOrNull;
    final candidateLocation = (user?.location ?? '').trim().isEmpty
        ? 'Localisation inconnue'
        : user!.location!.trim();
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 50,
              height: 3,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFDEDEDE),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),

          // Header: title + Effacer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Emplacement',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      letterSpacing: -0.6,
                      color: Color(0xFF3A1B5E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Configurez vos créneaux de travail',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xFF4A454F),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCity = '';
                    _radius = 10.0;
                  });
                  widget.onSelect('');
                },
                child: const Text(
                  'Effacer',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color(0xFF401E66),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // VILLE label
          const Text(
            'VILLE',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 1.2,
              color: Color(0xFF7C7580),
            ),
          ),
          const SizedBox(height: 8),

          // City dropdown
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFEFEDF2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCity.isEmpty ? null : _selectedCity,
                hint: const Padding(
                  padding: EdgeInsets.only(left: 17),
                  child: Text(
                    'choisir une ville',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Color(0xFF4A454F),
                    ),
                  ),
                ),
                isExpanded: true,
                icon: const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child:
                      Icon(Icons.keyboard_arrow_down, color: Color(0xFF3A1B5E)),
                ),
                items: _cities
                    .map((city) => DropdownMenuItem(
                          value: city,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 17),
                            child: Text(city,
                                style: const TextStyle(
                                    fontFamily: 'Inter', fontSize: 16)),
                          ),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCity = val);
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Mini map preview
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 158,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                border: Border.all(color: const Color(0xFFFFFFFF), width: 4),
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
              child: Stack(
                children: [
                  // Map placeholder
                  Positioned.fill(
                    child: Container(color: const Color(0xFFE8E4F0)),
                  ),
                  // Location circle indicator
                  Center(
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A1B5E).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF3A1B5E), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF8869B0).withValues(alpha: 0.2),
                            blurRadius: 40,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3A1B5E),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3A1B5E)
                                    .withValues(alpha: 0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Candidate location indicator
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: Color(0xFF3A1B5E),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            candidateLocation,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              color: Color(0xFF3A1B5E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Rayon (km) label
          const Text(
            'Rayon (km)',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF1D1B1F),
            ),
          ),
          const SizedBox(height: 12),

          // Slider
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 8,
              activeTrackColor: const Color(0xFF401E66),
              inactiveTrackColor: const Color(0xFFE7E0E7),
              thumbColor: const Color(0xFF3A1B5E),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              trackShape: const RoundedRectSliderTrackShape(),
            ),
            child: Slider(
              value: _radius,
              min: 1,
              max: 50,
              onChanged: (val) => setState(() => _radius = val),
              onChangeEnd: (val) => widget.onSelect('${val.round()} km'),
            ),
          ),

          // Labels
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
    );
  }
}

// ─── Dropdown panel ──────────────────────────────────────────────────────────
class _DropdownPanel extends StatelessWidget {
  final List<(String, IconData)> options;
  final Function(String) onSelect;
  final String? activeValue;

  const _DropdownPanel({
    super.key,
    required this.options,
    required this.onSelect,
    this.activeValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(7, 6, 7, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) {
          final (label, icon) = opt;
          final isSelected = activeValue == label;
          return GestureDetector(
            onTap: () => onSelect(label),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isSelected ? const Color(0xFFF4EEFF) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF401E66)
                          : const Color(0xFFEEE6F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      size: 16,
                      color:
                          isSelected ? Colors.white : const Color(0xFF401E66),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 14,
                        color: isSelected
                            ? const Color(0xFF401E66)
                            : const Color(0xFF1D1B1F),
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle,
                        size: 18, color: Color(0xFF401E66)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Location permission dialog ───────────────────────────────────────────────
class _LocationPermissionDialog extends StatelessWidget {
  const _LocationPermissionDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFEEE6F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.location_on_outlined,
                  size: 28, color: Color(0xFF401E66)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Activer la localisation',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Color(0xFF1D1B1F),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pour afficher les emplois les plus proches de vous et centrer la carte sur votre position exacte.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF4A454F),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF401E66),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text(
                  'Activer',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Plus tard',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF7C7580),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recenter button ──────────────────────────────────────────────────────────
class _RecenterButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RecenterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF401E66),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 15,
              spreadRadius: -3,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              spreadRadius: -4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.my_location, color: Colors.white, size: 22),
      ),
    );
  }
}

// ─── Bottom sheet ───────────────────────────────────────────────────────────────
class _BottomSheet extends StatelessWidget {
  final ScrollController scrollController;
  final MapJobEntity? selectedJob;
  final List<MapJobEntity> allJobs;
  final Function(MapJobEntity) onJobTap;

  const _BottomSheet({
    required this.scrollController,
    required this.selectedJob,
    required this.allJobs,
    required this.onJobTap,
  });

  @override
  Widget build(BuildContext context) {
    // When a job is selected, show fixed non-scrollable detail sheet
    if (selectedJob != null) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 50,
                  height: 3,
                  margin: const EdgeInsets.only(top: 10, bottom: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDEDEDE),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ),
              _SelectedJobDetail(job: selectedJob!),
            ],
          ),
        ),
      );
    }

    // Default: suggestions sheet
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (n) => false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: _BottomSheetContent(
          scrollController: scrollController,
          selectedJob: null,
          allJobs: allJobs,
          onJobTap: onJobTap,
        ),
      ),
    );
  }
}

// ─── Bottom sheet content (scroll-aware) ───────────────────────────────────────
class _BottomSheetContent extends StatefulWidget {
  final ScrollController scrollController;
  final MapJobEntity? selectedJob;
  final List<MapJobEntity> allJobs;
  final Function(MapJobEntity) onJobTap;

  const _BottomSheetContent({
    required this.scrollController,
    required this.selectedJob,
    required this.allJobs,
    required this.onJobTap,
  });

  @override
  State<_BottomSheetContent> createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<_BottomSheetContent> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // When user scrolls the sheet controller, check if we're at max
    // We use the DraggableScrollableSheet notification instead
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (n) {
        // Only show 'Nearby jobs' list when clearly expanded
        final expanded = n.extent >= 0.70;
        if (expanded != _isExpanded) {
          setState(() => _isExpanded = expanded);
        }
        return false;
      },
      child: CustomScrollView(
        controller: widget.scrollController,
        // Using ClampingScrollPhysics allows the sheet to drag properly
        physics: const ClampingScrollPhysics(),
        slivers: [
          // Header + Suggestions (visible in both states)
          SliverToBoxAdapter(child: _buildHeader()),

          // Nearby jobs section only appears when fully expanded
          if (_isExpanded) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  children: [
                    const Icon(Icons.map_outlined,
                        size: 22, color: Color(0xFF401E66)),
                    const SizedBox(width: 8),
                    const Text(
                      'Emplois à proximité',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Color(0xFF401E66),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: widget.allJobs
                      .map((job) => CandidateJobCard(
                            job: _mapJobToEntity(job),
                            onTap: () => widget.onJobTap(job),
                          ))
                      .toList(),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drag handle
        Center(
          child: Container(
            width: 50,
            height: 3,
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFDEDEDE),
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
        ),

        // "| Suggestions" title
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              Container(width: 5, height: 16, color: const Color.fromARGB(255, 37, 37, 38)),
              const SizedBox(width: 10),
              const Text(
                'Suggestions',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  height: 32 / 22,
                  color: Color.fromARGB(255, 55, 56, 58),
                ),
              ),
            ],
          ),
        ),

        // Horizontal suggestions cards
        if (widget.selectedJob != null)
          _SelectedJobDetail(job: widget.selectedJob!)
        else
          _SuggestionsCardList(
            jobs: widget.allJobs,
            onJobTap: widget.onJobTap,
          ),
      ],
    );
  }
}

// ─── Horizontal suggestions list ─────────────────────────────────────────────
class _SuggestionsCardList extends StatelessWidget {
  final List<MapJobEntity> jobs;
  final Function(MapJobEntity) onJobTap;

  const _SuggestionsCardList({required this.jobs, required this.onJobTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 227,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: jobs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (ctx, i) =>
            _SuggestionCard(job: jobs[i], onTap: () => onJobTap(jobs[i])),
      ),
    );
  }
}

// ─── Suggestion card (image + title + company + 2 buttons) ───────────────────
class _SuggestionCard extends StatelessWidget {
  final MapJobEntity job;
  final VoidCallback onTap;

  const _SuggestionCard({required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: const Color(0xFFEFEDF2),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              child: Stack(
                children: [
                  SizedBox(
                    width: 280,
                    height: 105,
                    child: job.imageAsset != null
                        ? Image.asset(job.imageAsset!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: const Color(0xFF334155)))
                        : Container(color: const Color(0xFF334155)),
                  ),
                  // Gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.25),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Distance badge
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 10, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            job.distance,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info section
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Color(0xFF331554),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    job.company,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFF4A454F),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Candidater button
                      Expanded(
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF331554),
                                Color(0xFF4A2D6B),
                              ],
                              transform: GradientRotation(1.86),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Candidater',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Itinéraire button
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _openGoogleMapsItinerary(job),
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.near_me_outlined,
                                    size: 13, color: Color(0xFF4A454F)),
                                SizedBox(width: 4),
                                Text(
                                  'Itinéraire',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Color(0xFF4A454F),
                                  ),
                                ),
                              ],
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
    );
  }
}

JobEntity _mapJobToEntity(MapJobEntity mapJob) {
  return JobEntity(
    id: mapJob.id,
    title: mapJob.title,
    description: null,
    companyName: mapJob.company,
    recruiterId: null,
    recruiterName: null,
    recruiterRole: null,
    contractType: ContractType.mission,
    postedAt: DateTime.now(),
    status: JobStatus.searching,
    candidateCount: 0,
    viewCount: 0,
    logoAsset: mapJob.imageAsset,
    isPublished: true,
  );
}

Future<void> _openGoogleMapsItinerary(MapJobEntity job) async {
  final uri = Uri.parse(
    'https://www.google.com/maps/dir/?api=1&destination=${job.lat},${job.lng}&travelmode=driving',
  );
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

// ─── Selected job detail ───────────────────────────────────────────────────────
class _SelectedJobDetail extends StatelessWidget {
  final MapJobEntity job;
  final VoidCallback? onClose;
  const _SelectedJobDetail({required this.job, this.onClose});

  void _openJobDetails(BuildContext context, MapJobEntity mapJob) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.88,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          child: _MapJobDetailsOverlay(job: mapJob),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 352,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Image (Top 184px)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 184,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  job.imageAsset != null
                      ? Image.asset(job.imageAsset!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF334155)))
                      : Container(color: const Color(0xFF334155)),
                  // Gradient
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A292B).withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Drag handle — top: 8px, centered, 50×3
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 50,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
          ),

          if (onClose != null)
            Positioned(
              top: 12,
              right: 16,
              child: GestureDetector(
                onTap: onClose,
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Title + company — top: 16 + 184 = 200, left: 19, height: 52
          Positioned(
            top: 200,
            left: 19,
            right: 59,
            height: 52,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 32,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      job.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        height: 1,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      job.company,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1,
                        color: Color(0xFF512D6D),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Avatar 40×40 — top: 200, right: 19
          Positioned(
            top: 200,
            right: 19,
            child: ClipOval(
              child: job.recruiterAvatar != null
                  ? Image.asset(
                      job.recruiterAvatar!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 40,
                        height: 40,
                        color: const Color(0xFF401E66),
                        child: const Icon(Icons.person,
                            color: Colors.white, size: 20),
                      ),
                    )
                  : Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF401E66),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person,
                          color: Colors.white, size: 20),
                    ),
            ),
          ),

          // Rating (star + 4.9) — top: 58 + 184 = 242, right: 22
          Positioned(
            top: 242,
            right: 22,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 10, color: Color(0xFFEAB308)),
                const SizedBox(width: 3),
                Text(
                  job.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    height: 1,
                    color: Color(0xFFCA8A04),
                  ),
                ),
              ],
            ),
          ),

          // Tags row — top: 78 + 184 = 262, left: 19, height: 36
          Positioned(
            top: 262,
            left: 19,
            height: 36,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Distance: #EFEDF2, radius 12, padding 8px 12px 8px 14px
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 0, 16, 0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEDF2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.near_me_outlined,
                          size: 14, color: Color(0xFF545665)),
                      const SizedBox(width: 6),
                      Text(
                        job.distance,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          height: 1,
                          color: Color(0xFF1D1B1F),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Contract: #401E66, radius 10, padding 8px 13px
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF401E66),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      job.contractType,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Hours: #EAE8F2, radius 10, padding 8px 14px
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAE8F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time_outlined,
                          size: 15, color: Color(0xFF512D6D)),
                      const SizedBox(width: 6),
                      Text(
                        job.hours,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          height: 1,
                          color: Color(0xFF401E66),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Buttons row — top: 122 + 184 = 306, left: 19, height: 40
          Positioned(
            top: 306,
            left: 19,
            height: 40,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Candidater — gradient, radius 12, width 134
                SizedBox(
                  width: 134,
                  height: 40,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF331554), Color(0xFF4A2D6B)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Candidater',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          height: 1,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Voir details — #EFEDF2, radius 12, width 129
                SizedBox(
                  width: 129,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => _openJobDetails(context, job),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEDF2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.north_east,
                              size: 15, color: Color(0xFF401E66)),
                          SizedBox(width: 6),
                          Text(
                            'Voir details',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              height: 1,
                              color: Color(0xFF401E66),
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
        ],
      ),
    );
  }
}


// ─── Search overlay (full screen) ─────────────────────────────────────────────
class _MapJobDetailsOverlay extends StatefulWidget {
  final MapJobEntity job;
  const _MapJobDetailsOverlay({required this.job});

  @override
  State<_MapJobDetailsOverlay> createState() => _MapJobDetailsOverlayState();
}

class _MapJobDetailsOverlayState extends State<_MapJobDetailsOverlay> {
  bool _showComments = false;

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    return Container(
      color: AppColors.background,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 202,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    job.imageAsset != null
                        ? Image.asset(
                            job.imageAsset!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: const Color(0xFF334155)),
                          )
                        : Container(color: const Color(0xFF334155)),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.35),
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        height: 32 / 22,
                        letterSpacing: -0.6,
                        color: Color(0xFF1D1B1F),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${job.company} • Alger, Algérie',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 24 / 16,
                        color: Color(0xFF4A454F),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 44,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEDF2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _showComments = false),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: !_showComments
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Description',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: Color(0xFF401E66),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _showComments = true),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _showComments
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Commentaires',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: Color(0xFF401E66),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!_showComments) ...[
                      _mapSectionHeader('Job Description'),
                      const SizedBox(height: 12),
                      _jobDescriptionCard(job),
                      const SizedBox(height: 16),
                      _managerSectionHeader(),
                      const SizedBox(height: 12),
                      const _HiringManagerStaticCard(),
                    ] else ...[
                      _mapSectionHeader('Commentaires'),
                      const SizedBox(height: 12),
                      _MapCommentsPanel(job: _mapJobToEntity(job)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mapSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF3A1B5E),
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            height: 28 / 18,
            color: Color(0xFF401E66),
          ),
        ),
      ],
    );
  }

  Widget _managerSectionHeader() {
    return const Row(
      children: [
        Icon(Icons.person_outline, size: 24, color: Color(0xFF331554)),
        SizedBox(width: 8),
        Text(
          'Hiring Manager',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            height: 28 / 18,
            color: Color(0xFF1D1B1F),
          ),
        ),
      ],
    );
  }

  Widget _jobDescriptionCard(MapJobEntity job) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'We are seeking a visionary Senior Product Designer to join our core product team. You will be responsible for defining the user experience of our next-generation creative platform.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 15,
              height: 26 / 15,
              color: Color(0xFF4A454F),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StaticBullet('Drive the design process from discovery through delivery.'),
                SizedBox(height: 8),
                _StaticBullet('Collaborate with engineers to ensure high-fidelity implementation.'),
                SizedBox(height: 8),
                _StaticBullet('Maintain and evolve our internal design system.'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StaticTag(job.contractType.toUpperCase()),
              _StaticTag('PART-TIME'),
              _StaticTag('REMOTE'),
              _StaticTagWithIcon(label: job.hours, icon: Icons.access_time),
              _StaticTagWithIcon(
                  label: job.distance, icon: Icons.near_me_outlined),
            ],
          ),
        ],
      ),
    );
  }
}

class _MapCommentsPanel extends StatelessWidget {
  final JobEntity job;
  const _MapCommentsPanel({required this.job});

  @override
  Widget build(BuildContext context) {
    if (job.comments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'Aucun commentaire pour ce poste pour le moment.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
      );
    }

    return Column(
      children: job.comments
          .map(
            (c) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.authorName,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Color(0xFF1D1B1F),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    c.date,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF7C7580),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    c.question,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Color(0xFF545665),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _StaticBullet extends StatelessWidget {
  final String text;
  const _StaticBullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            fontSize: 15,
            color: Color(0xFF4A454F),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 15,
              height: 26 / 15,
              color: Color(0xFF4A454F),
            ),
          ),
        ),
      ],
    );
  }
}

class _StaticTag extends StatelessWidget {
  final String label;
  const _StaticTag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF401E66),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          fontSize: 10,
          letterSpacing: 0.5,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _StaticTagWithIcon extends StatelessWidget {
  final String label;
  final IconData icon;
  const _StaticTagWithIcon({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF401E66),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _HiringManagerStaticCard extends StatelessWidget {
  const _HiringManagerStaticCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipOval(
            child: Image.asset(
              'assets/images/pdp_1.png',
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 56,
                height: 56,
                color: const Color(0xFFE9E6EC),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.person,
                  size: 30,
                  color: Color(0xFF401E66),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sarah Jenkins',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF1D1B1F),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Head of Design',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Color(0xFF665976),
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, size: 12, color: Color(0xFF6F5D1D)),
                    SizedBox(width: 4),
                    Text(
                      '4.9',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1D1B1F),
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '(42 reviews)',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Color(0xFF7C7580),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Color(0xFFEFEDF2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.message_outlined,
              size: 20,
              color: Color(0xFF545665),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchOverlay extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final Function(String) onSubmit;

  const _SearchOverlay({required this.onClose, required this.onSubmit});

  @override
  ConsumerState<_SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends ConsumerState<_SearchOverlay> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allJobs = ref.watch(allMapJobsProvider).maybeWhen(
          data: (jobs) => jobs,
          orElse: () => const <MapJobEntity>[],
        );
    final q = _controller.text.trim().toLowerCase();
    final jobSuggestions = allJobs
        .where((j) =>
            q.isEmpty ||
            j.title.toLowerCase().contains(q) ||
            j.company.toLowerCase().contains(q))
        .take(6)
        .toList();

    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Search bar row
            Padding(
              padding: const EdgeInsets.fromLTRB(7, 8, 7, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onClose,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.arrow_back,
                          size: 22, color: Color(0xFF1D1B1F)),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEDF2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focus,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: Color(0xFF1D1B1F),
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Search by job name',
                                hintStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  color: Color(0xFF8D8DA6),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (v) => setState(() {}),
                              onSubmitted: (v) {
                                if (v.trim().isNotEmpty) {
                                  widget.onSubmit(v.trim());
                                }
                              },
                            ),
                          ),
                          if (_controller.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                setState(() => _controller.clear());
                                _focus.requestFocus();
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Icon(Icons.cancel,
                                    size: 18, color: Color(0xFF94A3B8)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Croix pour fermer l'overlay de recherche
                  GestureDetector(
                    onTap: widget.onClose,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 8, right: 4),
                      child: Icon(
                        Icons.close,
                        size: 22,
                        color: Color(0xFF060527),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Recent searches header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'RECHERCHES RÉCENTES',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0.7,
                      color: Color(0xFF1D1B1F),
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        ref.read(recentSearchesProvider.notifier).clearAll(),
                    child: const Text(
                      'Tout effacer',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF401E66),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // List
            Expanded(
              child: Container(
                color: Colors.white,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Recent text searches
                    ...ref.watch(recentSearchesProvider).map((s) => _SearchItem(
                          icon: Icons.history,
                          iconBg: const Color(0xFFEFEDF2),
                          iconColor: const Color(0xFF545665),
                          title: s,
                          onTap: () => widget.onSubmit(s),
                        )),

                    // Job suggestions from API /jobs/map
                    ...jobSuggestions.map((j) => _SearchItem(
                          icon: j.categoryIcon,
                          iconBg: const Color(0xFFEFEDF2),
                          iconColor: const Color(0xFF401E66),
                          title: j.title,
                          subtitle: j.company,
                          titleColor: const Color(0xFF401E66),
                          onTap: () => widget.onSubmit(j.title),
                        )),

                    // Voir plus
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      child: GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'voir plus de recherches recentes',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Color(0xFF401E66),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Color titleColor;
  final VoidCallback onTap;

  const _SearchItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.titleColor = const Color(0xFF000000),
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: titleColor,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.close, size: 14, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}


// ──────────────────────────────────────────────────────────────────────────
class _SearchResultsSheet extends StatelessWidget {
  final String query;
  final List<MapJobEntity> jobs;
  final Function(MapJobEntity) onJobTap;
  final VoidCallback? onClose;

  const _SearchResultsSheet({
    required this.query,
    required this.jobs,
    required this.onJobTap,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 50,
              height: 3,
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFDEDEDE),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),

          // Header: map-search icon + resultat + filter icon
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Row(
              children: [
                const Icon(Icons.map_outlined,
                    size: 22, color: Color(0xFF331554)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'resultat',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Color(0xFF331554),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(Icons.close,
                      size: 24, color: Color(0xFF331554)),
                ),
              ],
            ),
          ),

          // Job list with frame
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: jobs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (ctx, i) => CandidateJobCard(
                  job: _mapJobToEntity(jobs[i]),
                  onTap: () => onJobTap(jobs[i]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

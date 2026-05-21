import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:job_app/features/profile/data/providers/profile_provider.dart';
import 'dart:io';

// Constantes de couleur
const Color _kViolet = Color(0xFF401E66);
const Color _kSlate900 = Color(0xFF0F172A);
const Color _kSlate200 = Color(0xFFE2E8F0);

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  
  String _selectedDomain = 'Restauration';
  IconData _selectedDomainIcon = Icons.restaurant;

  @override
  void initState() {
    super.initState();
    // Charger les données actuelles
    Future.microtask(() {
      final userAsync = ref.read(candidateCurrentUserProvider);
      userAsync.whenData((user) {
        if (mounted) {
          setState(() {
            _nameController.text = user.name;
            _usernameController.text = user.name.toLowerCase().replaceAll(' ', '_');
            _bioController.text = user.bio;
            _locationController.text = user.location;
            _selectedDomain = user.domain;
            // Définir l'icône selon le domaine
            _selectedDomainIcon = _getDomainIcon(user.domain);
          });
        }
      });
    });
  }

  IconData _getDomainIcon(String domain) {
    switch (domain) {
      case 'Restauration':
        return Icons.restaurant;
      case 'Hôtellerie':
        return Icons.hotel;
      case 'Événementiel':
        return Icons.event;
      case 'Commerce':
        return Icons.shopping_bag;
      case 'Services':
        return Icons.room_service;
      default:
        return Icons.work;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      // Update the profile photo in the state
      ref.read(candidateCurrentUserProvider.notifier).updateProfilePhoto(image.path);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Photo de profil mise à jour'),
            backgroundColor: const Color(0xFF401E66),
          ),
        );
      }
    }
  }

  void _saveProfile() {
    // Save profile changes to state including domain
    ref.read(candidateCurrentUserProvider.notifier).updateProfileInfo(
      name: _nameController.text,
      bio: _bioController.text,
      location: _locationController.text,
      domain: _selectedDomain, // Ajout du domaine
    );
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profil mis à jour avec succès'),
        backgroundColor: const Color(0xFF401E66),
      ),
    );
  }

  void _showDomainSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DomainSelectorOverlay(
        onDomainSelected: (domain, icon) {
          setState(() {
            _selectedDomain = domain;
            _selectedDomainIcon = icon;
          });
        },
      ),
    );
  }

  void _showLocationSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LocationSelectorOverlay(
        onLocationSelected: (location) {
          setState(() {
            _locationController.text = location;
          });
        },
      ),
    );
  }

  Widget _buildProfileImage(String? avatarUrl) {
    // Check if it's a local file path
    if (avatarUrl != null && !avatarUrl.startsWith('assets/') && File(avatarUrl).existsSync()) {
      return Image.file(
        File(avatarUrl),
        fit: BoxFit.cover,
        width: 96,
        height: 96,
      );
    }
    
    // Use asset image
    return Image.asset(
      avatarUrl ?? 'assets/images/imageannonc(3).jpg',
      fit: BoxFit.cover,
      width: 96,
      height: 96,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.person, size: 48, color: Colors.grey);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(candidateCurrentUserProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Profile Photo Section
                    _buildProfilePhotoSection(userAsync),
                    
                    // User Info Section
                    _buildUserInfoSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bouton Annuler
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF262626),
              ),
            ),
          ),
          
          // Titre
          Text(
            'Modifier le profil',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF262626),
            ),
          ),
          
          // Bouton Terminé
          GestureDetector(
            onTap: _saveProfile,
            child: Text(
              'Terminé',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF513376),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePhotoSection(AsyncValue userAsync) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(9999),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE5E7EB).withOpacity(1.0),
                  spreadRadius: 1,
                  blurRadius: 0,
                ),
              ],
            ),
            child: userAsync.when(
              data: (user) => ClipRRect(
                borderRadius: BorderRadius.circular(9999),
                child: _buildProfileImage(user.avatarUrl),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Icon(Icons.person, size: 48),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Bouton Modifier la photo
          GestureDetector(
            onTap: _pickImage,
            child: Text(
              'Modifier la photo de profil',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF401E66),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre "Utilisateur"
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              'Utilisateur',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2A292B),
              ),
            ),
          ),
          
          // Container avec tous les champs
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                _buildTextField('Nom', _nameController, 'Jean Dupont'),
                _buildDivider(),
                _buildTextField('Nom d\'utilisateur', _usernameController, 'jean_dpt'),
                _buildDivider(),
                _buildTextArea('Bio', _bioController, 'Décrivez votre parcours...'),
                _buildDivider(),
                _buildCompetencesRow(),
                _buildDivider(),
                _buildDomainRow(),
                _buildDivider(),
                _buildLocationRow(),
                _buildDivider(),
                _buildPersonalInfoButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String placeholder) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label au-dessus
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          
          // Input
          TextField(
            controller: controller,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF262626),
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF9CA3AF),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextArea(String label, TextEditingController controller, String placeholder) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label au-dessus
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          
          // Textarea
          TextField(
            controller: controller,
            maxLines: 3,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF262626),
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF9CA3AF),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompetencesRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Competences',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF262626),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment(-0.26, -0.97),
                end: Alignment(0.26, 0.97),
                colors: [Color(0xFF331554), Color(0xFF4A2D6B)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  'Modifier',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 5),
                Transform.rotate(
                  angle: 0.67, // 38.49 degrees in radians
                  child: const Icon(
                    Icons.arrow_upward,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDomainRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 112,
            child: Text(
              'Domaine',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF262626),
              ),
            ),
          ),
          
          GestureDetector(
            onTap: () => _showDomainSelector(),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Color(0xFF513376),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _selectedDomainIcon,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 13),
                Text(
                  _selectedDomain,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF401E66),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.keyboard_arrow_right,
                  size: 16,
                  color: Color(0xFF401E66),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label au-dessus
          Text(
            'Emplacement',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          
          // Input avec icône
          GestureDetector(
            onTap: () => _showLocationSelector(),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: Color(0xFF262626),
                ),
                const SizedBox(width: 4),
                
                Expanded(
                  child: Text(
                    _locationController.text.isEmpty ? 'Paris, France' : _locationController.text,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: _locationController.text.isEmpty ? const Color(0xFF9CA3AF) : const Color(0xFF262626),
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_right,
                  size: 16,
                  color: Color(0xFF401E66),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Center(
        child: Text(
          'Informations personnelles',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF513376),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: const Color(0xFFF3F4F6),
    );
  }
}

class _DomainSelectorOverlay extends StatefulWidget {
  final Function(String, IconData) onDomainSelected;

  const _DomainSelectorOverlay({required this.onDomainSelected});

  @override
  State<_DomainSelectorOverlay> createState() => _DomainSelectorOverlayState();
}

class _DomainSelectorOverlayState extends State<_DomainSelectorOverlay> {
  String? _selectedDomain;

  final List<Map<String, dynamic>> _domains = [
    {'name': 'Restauration', 'icon': Icons.restaurant, 'color': Color(0xFF513376)},
    {'name': 'Hôtellerie', 'icon': Icons.hotel, 'color': Color(0xFF059669)},
    {'name': 'Événementiel', 'icon': Icons.event, 'color': Color(0xFFDC2626)},
    {'name': 'Commerce', 'icon': Icons.shopping_cart, 'color': Color(0xFF2563EB)},
    {'name': 'Services', 'icon': Icons.build, 'color': Color(0xFFF59E0B)},
    {'name': 'Santé', 'icon': Icons.local_hospital, 'color': Color(0xFF7C3AED)},
    {'name': 'Éducation', 'icon': Icons.school, 'color': Color(0xFF0891B2)},
    {'name': 'Transport', 'icon': Icons.directions_car, 'color': Color(0xFF65A30D)},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choisir un domaine',
                          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)
                              .copyWith(color: const Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sélectionnez votre secteur d\'activité principal.',
                          style: GoogleFonts.inter(fontSize: 12).copyWith(color: const Color(0xFF334155)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Liste verticale des domaines avec radio buttons
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: _kSlate200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: _domains.map((domain) {
                    final isSelected = _selectedDomain == domain['name'];
                    final isLast = domain == _domains.last;
                    
                    return Column(
                      children: [
                        ListTile(
                          leading: Radio<String>(
                            value: domain['name'],
                            groupValue: _selectedDomain,
                            activeColor: _kViolet,
                            onChanged: (value) {
                              setState(() {
                                _selectedDomain = value;
                              });
                            },
                          ),
                          title: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: _kViolet,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  domain['icon'],
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                domain['name'],
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected ? _kViolet : _kSlate900,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              _selectedDomain = domain['name'];
                            });
                          },
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        if (!isLast)
                          const Divider(height: 1, color: _kSlate200),
                      ],
                    );
                  }).toList(),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Bouton Confirmer
              ElevatedButton(
                onPressed: _selectedDomain != null ? () {
                  final selectedDomainData = _domains.firstWhere((d) => d['name'] == _selectedDomain);
                  widget.onDomainSelected(_selectedDomain!, selectedDomainData['icon']);
                  Navigator.pop(context);
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF401E66),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Text(
                  'Confirmer',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationSelectorOverlay extends StatefulWidget {
  final Function(String) onLocationSelected;

  const _LocationSelectorOverlay({required this.onLocationSelected});

  @override
  State<_LocationSelectorOverlay> createState() => _LocationSelectorOverlayState();
}

class _LocationSelectorOverlayState extends State<_LocationSelectorOverlay> {
  String? _selectedLocation;
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredLocations = [];

  final List<String> _algerianCities = [
    'Alger',
    'Oran',
    'Constantine',
    'Annaba',
    'Blida',
    'Batna',
    'Djelfa',
    'Sétif',
    'Sidi Bel Abbès',
    'Biskra',
    'Tébessa',
    'El Oued',
    'Skikda',
    'Tiaret',
    'Béjaïa',
    'Tlemcen',
    'Ouargla',
    'Béchar',
    'Mostaganem',
    'Bordj Bou Arréridj',
    'Chlef',
    'Bouira',
    'Tizi Ouzou',
    'Jijel',
    'Relizane',
    'M\'Sila',
    'Saïda',
    'Mascara',
    'Ouled Djellal',
    'Boumerdès',
  ];

  @override
  void initState() {
    super.initState();
    _filteredLocations = _algerianCities;
    _searchController.addListener(_filterLocations);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLocations() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredLocations = _algerianCities;
      } else {
        _filteredLocations = _algerianCities
            .where((city) => city.toLowerCase().contains(_searchController.text.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choisir un emplacement',
                          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)
                              .copyWith(color: const Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sélectionnez votre ville de résidence.',
                          style: GoogleFonts.inter(fontSize: 12).copyWith(color: const Color(0xFF334155)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Barre de recherche
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 16, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Rechercher une ville...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF9CA3AF),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF262626),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Liste des villes
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredLocations.length,
                  itemBuilder: (context, index) {
                    final city = _filteredLocations[index];
                    final isSelected = _selectedLocation == city;
                    final isLast = index == _filteredLocations.length - 1;
                    
                    return Column(
                      children: [
                        ListTile(
                          title: Text(
                            city,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF0F172A),
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                          leading: Radio<String>(
                            value: city,
                            groupValue: _selectedLocation,
                            activeColor: const Color(0xFF401E66),
                            onChanged: (value) {
                              setState(() {
                                _selectedLocation = value;
                              });
                            },
                          ),
                          onTap: () {
                            setState(() {
                              _selectedLocation = city;
                            });
                          },
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        if (!isLast)
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      ],
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Bouton Confirmer
              ElevatedButton(
                onPressed: _selectedLocation != null ? () {
                  widget.onLocationSelected(_selectedLocation!);
                  Navigator.pop(context);
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF401E66),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Text(
                  'Confirmer',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

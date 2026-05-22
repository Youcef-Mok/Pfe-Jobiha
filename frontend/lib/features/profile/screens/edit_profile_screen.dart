import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:job_app/features/profile/data/providers/profile_provider.dart';
import 'package:dio/dio.dart';
import 'dart:io';

// Constantes de couleur
const Color _kViolet = Color(0xFF401E66);
const Color _kSlate900 = Color(0xFF0F172A);
const Color _kSlate200 = Color(0xFFE2E8F0);

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedDomain = '';
  IconData _selectedDomainIcon = Icons.work;

  bool _isSaving = false;
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final userAsync = ref.read(candidateCurrentUserProvider);
      userAsync.whenData((user) {
        if (mounted && !_controllersInitialized) {
          setState(() {
            _nameController.text = user.name;
            _usernameController.text =
                user.name.toLowerCase().replaceAll(' ', '_');
            _bioController.text = user.bio;
            _locationController.text = user.location;
            _selectedDomain = user.domain;
            _selectedDomainIcon = _getDomainIcon(user.domain);
            _controllersInitialized = true;
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
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    try {
      final dio = Dio();

      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          image.path,
          filename: image.name,
        ),
      });

      final response =
          await dio.post('YOUR_API_ENDPOINT/avatar', data: formData);

      final avatarUrl = response.data['avatar_url'];

      ref
          .read(candidateCurrentUserProvider.notifier)
          .updateProfilePhoto(avatarUrl);

      await ref.read(candidateCurrentUserProvider.notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo mise à jour'),
            backgroundColor: _kViolet,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur upload: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    final currentUser =
        ref.read(candidateCurrentUserProvider).valueOrNull;

    if (currentUser == null) return;

    setState(() => _isSaving = true);

    try {
      final updatedUser = currentUser.copyWith(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        location: _locationController.text.trim(),
        domain: _selectedDomain,
      );

      final saved = await ref
          .read(profileControllerProvider)
          .updateProfile(updatedUser);

      ref.read(candidateCurrentUserProvider.notifier).updateUser(saved);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour'),
            backgroundColor: _kViolet,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildProfileImage(String? url, String initials) {
    if (url != null &&
        url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        width: 96,
        height: 96,
        errorBuilder: (_, __, ___) => _buildInitials(initials),
      );
    }

    if (url != null &&
        File(url).existsSync()) {
      return Image.file(
        File(url),
        fit: BoxFit.cover,
        width: 96,
        height: 96,
      );
    }

    return _buildInitials(initials);
  }

  Widget _buildInitials(String initials) {
    return Container(
      width: 96,
      height: 96,
      color: _kViolet,
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
            // HEADER
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text("Annuler"),
                  ),
                  const Text(
                    "Modifier profil",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: _isSaving ? null : _saveProfile,
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(),
                          )
                        : const Text("Terminé"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // AVATAR
            userAsync.when(
              data: (user) => GestureDetector(
                onTap: _pickImage,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: _buildProfileImage(
                    user.avatarUrl,
                    user.initials,
                  ),
                ),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Icon(Icons.error),
            ),

            const SizedBox(height: 20),

            // FORM
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration:
                          const InputDecoration(labelText: "Nom"),
                    ),
                    TextField(
                      controller: _bioController,
                      decoration:
                          const InputDecoration(labelText: "Bio"),
                    ),
                    TextField(
                      controller: _locationController,
                      decoration:
                          const InputDecoration(labelText: "Location"),
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
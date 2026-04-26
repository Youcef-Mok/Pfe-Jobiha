// lib/features/settings/screens/personal_info_screen.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _nomCtrl        = TextEditingController();
  final _prenomCtrl     = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _telephoneCtrl  = TextEditingController();

  bool _loading = true;
  bool _saving  = false;

  // ── Profile photo ──────────────────────────────────────────────────────────
  File? _profileImage;
  String? _existingPhotoUrl;
  final ImagePicker _picker = ImagePicker();

  static const _purple      = Color(0xFF401E66);
  static const _bg          = Color(0xFFF6F3F8);
  static const _inputBorder = Color(0xFFCDCDCD);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.me);
      final data = response.data as Map<String, dynamic>;
      _nomCtrl.text       = data['nom']       ?? '';
      _prenomCtrl.text    = data['prenom']    ?? '';
      _emailCtrl.text     = data['email']     ?? '';
      _telephoneCtrl.text = data['telephone'] ?? '';
      _existingPhotoUrl   = data['photo']     ?? data['avatar'];
    } catch (_) {
      // backend not reachable — fields stay empty
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Pick profile photo ─────────────────────────────────────────────────────
  Future<void> _pickProfilePhoto() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: _purple),
              title: const Text('Prendre une photo'),
              onTap: () async {
                Navigator.pop(ctx);
                final XFile? photo = await _picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                  maxWidth: 512,
                );
                if (photo != null) setState(() => _profileImage = File(photo.path));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: _purple),
              title: const Text('Choisir depuis la galerie'),
              onTap: () async {
                Navigator.pop(ctx);
                final XFile? photo = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                  maxWidth: 512,
                );
                if (photo != null) setState(() => _profileImage = File(photo.path));
              },
            ),
            if (_profileImage != null || _existingPhotoUrl != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Supprimer la photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _profileImage = null;
                    _existingPhotoUrl = null;
                  });
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ApiClient.instance.patch(
        ApiEndpoints.me,
        data: {
          'nom':       _nomCtrl.text.trim(),
          'prenom':    _prenomCtrl.text.trim(),
          'telephone': _telephoneCtrl.text.trim(),
        },
      );

      // TODO: upload _profileImage when backend endpoint is ready
      // if (_profileImage != null) {
      //   await ApiClient.instance.patch(ApiEndpoints.me,
      //     data: FormData.fromMap({'photo': await MultipartFile.fromFile(_profileImage!.path)}));
      // }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour !')),
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.response?.data?['detail'] ?? 'Erreur lors de la sauvegarde.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _emailCtrl.dispose();
    _telephoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: const Text(
          'Informations personnelles',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _purple))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Profile avatar ───────────────────────────────────
                    Center(
                      child: GestureDetector(
                        onTap: _pickProfilePhoto,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.white,
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : _existingPhotoUrl != null
                                      ? NetworkImage(_existingPhotoUrl!) as ImageProvider
                                      : null,
                              child: _profileImage == null && _existingPhotoUrl == null
                                  ? Icon(Icons.person, size: 48, color: Colors.grey.shade400)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0, right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: _purple,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Prénom + Nom ─────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            controller: _prenomCtrl,
                            label: 'PRÉNOM',
                            hint: 'Ex: Jean',
                            validator: (v) => v!.isEmpty ? 'Requis' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _field(
                            controller: _nomCtrl,
                            label: 'NOM',
                            hint: 'Ex: Dupont',
                            validator: (v) => v!.isEmpty ? 'Requis' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _field(
                      controller: _emailCtrl,
                      label: 'EMAIL',
                      hint: 'jean.dupont@email.com',
                      enabled: false,
                    ),
                    const SizedBox(height: 16),

                    _field(
                      controller: _telephoneCtrl,
                      label: 'NUMÉRO DE TÉLÉPHONE',
                      hint: '06 12 34 56 78',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 36),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _purple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          elevation: 0,
                        ),
                        child: _saving
                            ? const SizedBox(
                                height: 22, width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Enregistrer',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
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

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _purple, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
      ],
    );
  }
}
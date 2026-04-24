// lib/features/auth/screens/signup_form_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/auth_header.dart';
import '../providers/auth_providers.dart';
import '../data/models/auth_state.dart';
import '../data/models/register_request.dart';
import '../data/models/signup_form_args.dart';

class SignupFormScreen extends ConsumerStatefulWidget {
  const SignupFormScreen({super.key});

  @override
  ConsumerState<SignupFormScreen> createState() => _SignupFormScreenState();
}

class _SignupFormScreenState extends ConsumerState<SignupFormScreen> {
  final TextEditingController _firstNameController       = TextEditingController();
  final TextEditingController _lastNameController        = TextEditingController();
  final TextEditingController _emailController           = TextEditingController();
  final TextEditingController _phoneController           = TextEditingController();
  final TextEditingController _passwordController        = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm  = true;
  bool _isLocalLoading  = false;

  // ── Profile photo ──────────────────────────────────────────────────────────
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Map<String, String?> _errors = {
    'firstName': null, 'lastName': null, 'email': null,
    'phone': null, 'password': null, 'confirm': null,
  };

  late SignupFormArgs _args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final raw = ModalRoute.of(context)?.settings.arguments;
    if (raw is SignupFormArgs) {
      _args = raw;
    } else {
      _args = SignupFormArgs(role: (raw as String?) ?? 'candidat');
    }

    if (_args.isGoogleSignUp) {
      final pending = ref.read(authProvider).pendingGoogleUser;
      if (pending != null) {
        _firstNameController.text = pending['prenom'] ?? '';
        _lastNameController.text  = pending['nom'] ?? '';
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
              leading: const Icon(Icons.camera_alt_outlined, color: Color(0xFF3A1B5E)),
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
              leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF3A1B5E)),
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
            if (_profileImage != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Supprimer la photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _profileImage = null);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Validation ─────────────────────────────────────────────────────────────
  bool _validate() {
    final errors = <String, String?>{};
    bool valid = true;

    if (_firstNameController.text.trim().isEmpty) {
      errors['firstName'] = 'Ce champ est obligatoire'; valid = false;
    } else { errors['firstName'] = null; }

    if (_lastNameController.text.trim().isEmpty) {
      errors['lastName'] = 'Ce champ est obligatoire'; valid = false;
    } else { errors['lastName'] = null; }

    if (!_args.isGoogleSignUp) {
      final email = _emailController.text.trim();
      final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
      if (email.isEmpty) {
        errors['email'] = 'Ce champ est obligatoire'; valid = false;
      } else if (!emailRegex.hasMatch(email)) {
        errors['email'] = 'Adresse email invalide'; valid = false;
      } else { errors['email'] = null; }

      final password = _passwordController.text;
      if (password.isEmpty) {
        errors['password'] = 'Ce champ est obligatoire'; valid = false;
      } else if (password.length < 8) {
        errors['password'] = 'Minimum 8 caractères'; valid = false;
      } else { errors['password'] = null; }

      final confirm = _confirmPasswordController.text;
      if (confirm.isEmpty) {
        errors['confirm'] = 'Ce champ est obligatoire'; valid = false;
      } else if (confirm != password) {
        errors['confirm'] = 'Les mots de passe ne correspondent pas'; valid = false;
      } else { errors['confirm'] = null; }
    }

    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      errors['phone'] = 'Ce champ est obligatoire'; valid = false;
    } else if (!RegExp(r'^\d{9,}$').hasMatch(phone)) {
      errors['phone'] = 'Numéro invalide (chiffres uniquement, min 9)'; valid = false;
    } else { errors['phone'] = null; }

    setState(() => _errors = errors);
    return valid;
  }

  // ── Signup ─────────────────────────────────────────────────────────────────
  Future<void> _handleSignup() async {
    if (!_validate()) return;
    setState(() => _isLocalLoading = true);

    final role = _args.role;

    if (_args.isGoogleSignUp) {
      await ref.read(authProvider.notifier).completeGoogleSignUp(
        role: role,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        telephone: _phoneController.text.trim(),
      );
    } else {
      if (role == 'candidat') {
        await ref.read(authProvider.notifier).registerCandidat(
          RegisterCandidatRequest(
            prenom:     _firstNameController.text.trim(),
            nom:        _lastNameController.text.trim(),
            email:      _emailController.text.trim(),
            telephone:  _phoneController.text.trim(),
            motDePasse: _passwordController.text,
          ),
        );
      } else {
        await ref.read(authProvider.notifier).registerRecruteur(
          RegisterRecruteurRequest(
            prenom:     _firstNameController.text.trim(),
            nom:        _lastNameController.text.trim(),
            email:      _emailController.text.trim(),
            telephone:  _phoneController.text.trim(),
            motDePasse: _passwordController.text,
          ),
        );
      }
    }

    // TODO: upload _profileImage to backend when endpoint is ready
    // if (_profileImage != null) {
    //   await ApiClient.instance.patch(ApiEndpoints.me, data: FormData.fromMap({
    //     'photo': await MultipartFile.fromFile(_profileImage!.path),
    //   }));
    // }

    if (mounted) setState(() => _isLocalLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.otpRequired) {
        Navigator.pushNamed(context, '/verify-email');
      } else if (next.status == AuthStatus.authenticated) {
        final route = next.role == 'candidat'
            ? '/signup-profile'
            : '/recruiter-profile';
        Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
      } else if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? 'Erreur lors de l\'inscription')),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AuthHeader(onBackPressed: () => Navigator.pop(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        _args.isGoogleSignUp ? 'Complétez votre profil' : 'Créer votre compte',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                      ),
                    ),

                    if (_args.isGoogleSignUp) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0EBFA),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.network(
                                'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                width: 16, height: 16,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.g_mobiledata, size: 18, color: Color(0xFF6B35D9)),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                ref.read(authProvider).pendingGoogleUser?['email'] ?? 'Google',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF6B35D9)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // ── Profile photo ─────────────────────────────────────
                    Center(
                      child: GestureDetector(
                        onTap: _pickProfilePhoto,
                        child: Stack(
                          children: [
                            Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade200,
                                image: _profileImage != null
                                    ? DecorationImage(
                                        image: FileImage(_profileImage!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: _profileImage == null
                                  ? const Icon(Icons.person, size: 40, color: Colors.grey)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0, right: 0,
                              child: Container(
                                width: 26, height: 26,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle, color: Color(0xFF3A1B5E)),
                                child: const Icon(Icons.add, color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Name fields ───────────────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildTextField(
                            controller: _firstNameController,
                            hint: 'Prénom', error: _errors['firstName'])),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField(
                            controller: _lastNameController,
                            hint: 'Nom', error: _errors['lastName'])),
                      ],
                    ),
                    const SizedBox(height: 14),

                    if (!_args.isGoogleSignUp) ...[
                      _buildTextField(
                          controller: _emailController,
                          hint: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          error: _errors['email']),
                      const SizedBox(height: 14),
                    ],

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(children: [
                            Text('🇩🇿', style: TextStyle(fontSize: 18)),
                            SizedBox(width: 4),
                            Text('+213', style: TextStyle(fontSize: 13, color: Colors.black87)),
                          ]),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                              controller: _phoneController,
                              hint: 'Numéro de téléphone',
                              keyboardType: TextInputType.phone,
                              error: _errors['phone']),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    if (!_args.isGoogleSignUp) ...[
                      _buildTextField(
                        controller: _passwordController,
                        hint: 'Mot de passe',
                        obscureText: _obscurePassword,
                        error: _errors['password'],
                        suffixIcon: IconButton(
                          icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey, size: 20),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        hint: 'Confirmer le mot de passe',
                        obscureText: _obscureConfirm,
                        error: _errors['confirm'],
                        suffixIcon: IconButton(
                          icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey, size: 20),
                          onPressed: () =>
                              setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                        children: [
                          TextSpan(text: "En vous inscrivant, vous acceptez nos "),
                          TextSpan(text: "Conditions Générales d'Utilisation",
                              style: TextStyle(color: Color(0xFF6B35D9))),
                          TextSpan(text: " et notre "),
                          TextSpan(text: "Politique de Confidentialité",
                              style: TextStyle(color: Color(0xFF6B35D9))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity, height: 52,
                      child: ElevatedButton(
                        onPressed: _isLocalLoading ? null : _handleSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3A1B5E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                        child: _isLocalLoading
                            ? const SizedBox(width: 22, height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(
                                _args.isGoogleSignUp ? 'Continuer' : "S'inscrire",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Déjà un compte? ",
                              style: TextStyle(color: Colors.grey, fontSize: 13)),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/login'),
                            child: const Text('Se connecter',
                                style: TextStyle(color: Color(0xFF3A1B5E),
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? error,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
            border: error != null ? Border.all(color: Colors.red.shade300) : null,
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
}
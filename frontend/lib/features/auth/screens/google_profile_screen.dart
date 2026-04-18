// lib/features/auth/screens/google_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../data/models/auth_state.dart';

class GoogleProfileScreen extends ConsumerStatefulWidget {
  const GoogleProfileScreen({super.key});

  @override
  ConsumerState<GoogleProfileScreen> createState() => _GoogleProfileScreenState();
}

class _GoogleProfileScreenState extends ConsumerState<GoogleProfileScreen> {
  final TextEditingController _telephoneController   = TextEditingController();
  final TextEditingController _nomStructureController = TextEditingController();
  String _typeStructure = 'entreprise';

  String? _nomStructureError;

  @override
  void dispose() {
    _telephoneController.dispose();
    _nomStructureController.dispose();
    super.dispose();
  }

  void _handleSubmit(String role) {
    if (role == 'recruteur') {
      if (_nomStructureController.text.trim().isEmpty) {
        setState(() => _nomStructureError = 'Ce champ est obligatoire');
        return;
      }
      setState(() => _nomStructureError = null);
    }

    ref.read(authProvider.notifier).completeGoogleSignUp(
      role:          role,
      nomStructure:  role == 'recruteur' ? _nomStructureController.text.trim() : null,
      typeStructure: role == 'recruteur' ? _typeStructure : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = ModalRoute.of(context)?.settings.arguments as String? ?? 'candidat';

    // ── React to auth state ──────────────────────────────────────────────────
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        final route = next.role == 'candidat' ? '/home-candidat' : '/home-recruteur';
        Navigator.pushReplacementNamed(context, route);
      } else if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? 'Erreur')),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 18),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                  ),
                  const Spacer(),
                  const Row(children: [
                    Icon(Icons.directions_walk, color: Color(0xFF6B35D9), size: 20),
                    SizedBox(width: 4),
                    Text('Jobiha',
                        style: TextStyle(
                            color: Color(0xFF6B35D9),
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ]),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                role == 'candidat'
                    ? 'Complétez votre profil candidat'
                    : 'Complétez votre profil recruteur',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ces informations pourront être modifiées plus tard',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              if (role == 'candidat') ...[
                _buildLabel('Téléphone (optionnel)'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _telephoneController,
                  hint: 'Ex: 0555123456',
                  keyboardType: TextInputType.phone,
                ),
              ],

              if (role == 'recruteur') ...[
                _buildLabel('Nom de la structure *'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _nomStructureController,
                  hint: 'Ex: Jobiha SPA',
                  error: _nomStructureError,
                ),
                const SizedBox(height: 20),
                _buildLabel('Type de structure *'),
                const SizedBox(height: 8),
                Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _typeStructure,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                      items: const [
                        DropdownMenuItem(value: 'entreprise',  child: Text('Entreprise')),
                        DropdownMenuItem(value: 'startup',     child: Text('Startup')),
                        DropdownMenuItem(value: 'association', child: Text('Association')),
                        DropdownMenuItem(value: 'particulier', child: Text('Particulier')),
                      ],
                      onChanged: (v) => setState(() => _typeStructure = v!),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => _handleSubmit(role),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A1B5E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Continuer',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A2E),
        ),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
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
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(error,
                style: const TextStyle(color: Colors.red, fontSize: 11)),
          ),
      ],
    );
  }
}

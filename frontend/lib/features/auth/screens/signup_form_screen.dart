import 'package:flutter/material.dart';
import '../widgets/social_login_button.dart';

class SignupFormScreen extends StatefulWidget {
  const SignupFormScreen({super.key});

  @override
  State<SignupFormScreen> createState() => _SignupFormScreenState();
}

class _SignupFormScreenState extends State<SignupFormScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // ── Error messages for each field ─────────────────────────────────────────
  Map<String, String?> _errors = {
    'firstName': null,
    'lastName': null,
    'email': null,
    'phone': null,
    'password': null,
    'confirm': null,
  };

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

  // ── Validation logic ──────────────────────────────────────────────────────
  bool _validate() {
    final errors = <String, String?>{};
    bool valid = true;

    // Prénom
    if (_firstNameController.text.trim().isEmpty) {
      errors['firstName'] = 'Ce champ est obligatoire';
      valid = false;
    } else {
      errors['firstName'] = null;
    }

    // Nom
    if (_lastNameController.text.trim().isEmpty) {
      errors['lastName'] = 'Ce champ est obligatoire';
      valid = false;
    } else {
      errors['lastName'] = null;
    }

    // Email — check format with regex
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (email.isEmpty) {
      errors['email'] = 'Ce champ est obligatoire';
      valid = false;
    } else if (!emailRegex.hasMatch(email)) {
      errors['email'] = 'Adresse email invalide';
      valid = false;
    } else {
      errors['email'] = null;
    }

    // Phone — must be digits only, at least 9 digits
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      errors['phone'] = 'Ce champ est obligatoire';
      valid = false;
    } else if (!RegExp(r'^\d{9,}$').hasMatch(phone)) {
      errors['phone'] = 'Numéro invalide (chiffres uniquement, min 9)';
      valid = false;
    } else {
      errors['phone'] = null;
    }

    // Password — at least 8 characters
    final password = _passwordController.text;
    if (password.isEmpty) {
      errors['password'] = 'Ce champ est obligatoire';
      valid = false;
    } else if (password.length < 8) {
      errors['password'] = 'Minimum 8 caractères';
      valid = false;
    } else {
      errors['password'] = null;
    }

    // Confirm password — must match
    final confirm = _confirmPasswordController.text;
    if (confirm.isEmpty) {
      errors['confirm'] = 'Ce champ est obligatoire';
      valid = false;
    } else if (confirm != password) {
      errors['confirm'] = 'Les mots de passe ne correspondent pas';
      valid = false;
    } else {
      errors['confirm'] = null;
    }

    setState(() => _errors = errors);
    return valid;
  }

  void _handleSignup() {
    if (!_validate()) return; // stop if any field is invalid

    final String role =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'employe';

    if (role == 'employe') {
      Navigator.pushNamed(context, '/signup-profile');
    } else {
      // Recruteur — go to recruiter profile completion screen
      Navigator.pushNamed(context, '/recruiter-profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // ── Back arrow + Logo ─────────────────────────────────────
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
                        style: TextStyle(color: Color(0xFF6B35D9), fontWeight: FontWeight.bold, fontSize: 16)),
                  ]),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),

              const SizedBox(height: 24),

              const Text('Créer votre compte',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),

              const SizedBox(height: 24),

              // ── Profile photo placeholder ─────────────────────────────
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
                      child: const Icon(Icons.person, size: 40, color: Colors.grey),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        width: 26, height: 26,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF6B35D9)),
                        child: const Icon(Icons.add, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Prénom + Nom ──────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildTextField(controller: _firstNameController, hint: 'Prénom', error: _errors['firstName'])),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField(controller: _lastNameController, hint: 'Nom', error: _errors['lastName'])),
                ],
              ),

              const SizedBox(height: 14),

              // ── Email ─────────────────────────────────────────────────
              _buildTextField(
                controller: _emailController,
                hint: 'Email',
                keyboardType: TextInputType.emailAddress,
                error: _errors['email'],
              ),

              const SizedBox(height: 14),

              // ── Phone ─────────────────────────────────────────────────
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
                      error: _errors['phone'],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Password ──────────────────────────────────────────────
              _buildTextField(
                controller: _passwordController,
                hint: 'Mot de passe',
                obscureText: _obscurePassword,
                error: _errors['password'],
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey, size: 20),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),

              const SizedBox(height: 14),

              // ── Confirm password ──────────────────────────────────────
              _buildTextField(
                controller: _confirmPasswordController,
                hint: 'Confirmer le mot de passe',
                obscureText: _obscureConfirm,
                error: _errors['confirm'],
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey, size: 20),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),

              const SizedBox(height: 20),

              // ── Terms ─────────────────────────────────────────────────
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

              // ── S'inscrire button ─────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _handleSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A1B5E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: const Text("S'inscrire",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 16),

              // ── Already have account ──────────────────────────────────
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Déjà un compte? ", style: TextStyle(color: Colors.grey, fontSize: 13)),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/login'),
                      child: const Text('Se connecter',
                          style: TextStyle(color: Color(0xFF6B35D9), fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
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
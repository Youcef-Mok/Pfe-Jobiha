import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _pageController = PageController();

  // Step 1
  final _emailCtrl = TextEditingController();
  // Step 2
  final _otpCtrl = TextEditingController();
  // Step 3
  final _newPassCtrl     = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscureNew     = true;
  bool _obscureConfirm = true;

  bool _loading = false;
  String? _email; // carried across steps

  static const _purple = Color(0xFF401E66);
  static const _bg     = Color(0xFFF6F3F8);

  void _goTo(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // ── Step 1: request OTP ───────────────────────────────────────────────────
  Future<void> _sendOtp() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) return;

    setState(() => _loading = true);
    try {
      await ApiClient.instance.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
      _email = email;
      _goTo(1);
    } on DioException catch (e) {
      _showError(e.response?.data?['detail'] ?? 'Erreur réseau.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Step 2: verify OTP (just advance — actual check happens on reset) ─────
  void _verifyOtp() {
    if (_otpCtrl.text.trim().length < 6) {
      _showError('Entrez le code à 6 chiffres.');
      return;
    }
    _goTo(2);
  }

  // ── Step 3: reset password ────────────────────────────────────────────────
  Future<void> _resetPassword() async {
    final newPass     = _newPassCtrl.text;
    final confirmPass = _confirmPassCtrl.text;

    if (newPass.length < 8) {
      _showError('Minimum 8 caractères.');
      return;
    }
    if (newPass != confirmPass) {
      _showError('Les mots de passe ne correspondent pas.');
      return;
    }

    setState(() => _loading = true);
    try {
      await ApiClient.instance.post(
        ApiEndpoints.resetPassword,
        data: {
          'email':               _email,
          'otp':                 _otpCtrl.text.trim(),
          'nouveau_mot_de_passe': newPass,
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mot de passe réinitialisé !')),
        );
        Navigator.pop(context); // back to login
      }
    } on DioException catch (e) {
      final detail = e.response?.data?['detail'];
      // OTP was wrong — send user back to OTP step
      if (e.response?.statusCode == 400 && detail != null) {
        _showError(detail.toString());
        _goTo(1);
      } else {
        _showError(detail ?? 'Erreur lors de la réinitialisation.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
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
          'Mot de passe oublié',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // user can't swipe
        children: [_stepEmail(), _stepOtp(), _stepNewPassword()],
      ),
    );
  }

  // ── Step 1 ────────────────────────────────────────────────────────────────
  Widget _stepEmail() {
    return _stepShell(
      title: 'Entrez votre email',
      subtitle: 'Si un compte existe avec cet email, vous recevrez un code de vérification.',
      child: Column(
        children: [
          _field(
            controller: _emailCtrl,
            label: 'ADRESSE EMAIL',
            hint: 'exemple@mail.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 36),
          _primaryButton(
            label: 'Envoyer le code',
            onPressed: _sendOtp,
          ),
        ],
      ),
    );
  }

  // ── Step 2 ────────────────────────────────────────────────────────────────
  Widget _stepOtp() {
    return _stepShell(
      title: 'Vérification',
      subtitle: 'Entrez le code à 6 chiffres envoyé à votre email.',
      child: Column(
        children: [
          _field(
            controller: _otpCtrl,
            label: 'CODE OTP',
            hint: '------',
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _loading ? null : _sendOtp,
              child: const Text(
                'Renvoyer le code',
                style: TextStyle(color: _purple, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _primaryButton(
            label: 'Vérifier',
            onPressed: _verifyOtp,
          ),
        ],
      ),
    );
  }

  // ── Step 3 ────────────────────────────────────────────────────────────────
  Widget _stepNewPassword() {
    return _stepShell(
      title: 'Nouveau mot de passe',
      subtitle: 'Choisissez un mot de passe sécurisé (8 caractères minimum).',
      child: Column(
        children: [
          _passwordField(
            controller: _newPassCtrl,
            label: 'NOUVEAU MOT DE PASSE',
            obscure: _obscureNew,
            toggle: () => setState(() => _obscureNew = !_obscureNew),
          ),
          const SizedBox(height: 16),
          _passwordField(
            controller: _confirmPassCtrl,
            label: 'CONFIRMER LE MOT DE PASSE',
            obscure: _obscureConfirm,
            toggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
          const SizedBox(height: 36),
          _primaryButton(
            label: 'Réinitialiser',
            onPressed: _resetPassword,
          ),
        ],
      ),
    );
  }

  // ── Shared layout ─────────────────────────────────────────────────────────
  Widget _stepShell({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          Text(subtitle,
              style: const TextStyle(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 32),
          child,
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
                letterSpacing: 0.5)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCDCDCD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCDCDCD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _purple, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback toggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
                letterSpacing: 0.5)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCDCDCD)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCDCDCD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _purple, width: 1.5),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.grey.shade400,
                size: 20,
              ),
              onPressed: toggle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _purple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
          elevation: 0,
        ),
        child: _loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
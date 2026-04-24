// lib/features/settings/screens/deactivate_account_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/core/theme/app_theme.dart';

class DeactivateAccountScreen extends ConsumerStatefulWidget {
  const DeactivateAccountScreen({super.key});

  @override
  ConsumerState<DeactivateAccountScreen> createState() =>
      _DeactivateAccountScreenState();
}

class _DeactivateAccountScreenState
    extends ConsumerState<DeactivateAccountScreen> {
  // 'deactivate' = temporary, 'delete' = permanent
  String _selectedOption = 'deactivate';
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  static const _purple = Color(0xFF401E66);
  static const _bg = Color(0xFFF6F3F8);

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer votre mot de passe.')),
      );
      return;
    }

    final isDelete = _selectedOption == 'delete';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isDelete ? 'Supprimer le compte ?' : 'Désactiver le compte ?',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Text(
          isDelete
              ? 'Votre compte et toutes vos données seront supprimés définitivement. Cette action est irréversible.'
              : 'Votre compte sera désactivé temporairement. Vous pourrez le réactiver en vous reconnectant.',
          style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler', style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              isDelete ? 'Supprimer' : 'Désactiver',
              style: TextStyle(
                color: isDelete ? Colors.red : _purple,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _loading = false);

    if (mounted) {
      // TODO: replace with real API call when backend is ready
      // For deactivate: await ApiClient.instance.post(ApiEndpoints.deactivateAccount, data: {'password': _passwordCtrl.text});
      // For delete:     await ApiClient.instance.delete(ApiEndpoints.deleteAccount, data: {'password': _passwordCtrl.text});
      // Then: await ref.read(authProvider.notifier).logout();
      // Then: Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (_) => false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cette fonctionnalité sera disponible prochainement.'),
          backgroundColor: Color(0xFF401E66),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDelete = _selectedOption == 'delete';

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: Text(
          'Désactiver le compte',
          style: AppTextStyles.heading1.copyWith(fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Option selector ──────────────────────────────────────────
            const Text(
              'CHOISIR UNE OPTION',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            _OptionCard(
              title: 'Désactivation temporaire',
              subtitle: 'Votre compte sera masqué. Vous pourrez le réactiver en vous reconnectant.',
              icon: Icons.pause_circle_outline,
              iconColor: _purple,
              selected: _selectedOption == 'deactivate',
              onTap: () => setState(() => _selectedOption = 'deactivate'),
            ),
            const SizedBox(height: 10),
            _OptionCard(
              title: 'Suppression définitive',
              subtitle: 'Toutes vos données seront effacées. Cette action est irréversible.',
              icon: Icons.delete_outline,
              iconColor: Colors.red,
              selected: _selectedOption == 'delete',
              onTap: () => setState(() => _selectedOption = 'delete'),
            ),
            const SizedBox(height: 24),

            // ── Warning ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDelete
                    ? const Color(0xFFFFF3F3)
                    : const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDelete
                      ? const Color(0xFFFFCDD2)
                      : const Color(0xFFFFE082),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isDelete ? Icons.warning_amber_rounded : Icons.info_outline,
                    color: isDelete ? Colors.red : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isDelete
                          ? 'Vos candidatures, messages et données seront supprimés définitivement.'
                          : 'Votre profil sera masqué aux recruteurs jusqu\'à votre prochaine connexion.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDelete ? Colors.red.shade700 : Colors.orange.shade800,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Password field ───────────────────────────────────────────
            const Text(
              'CONFIRMER VOTRE MOT DE PASSE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              decoration: InputDecoration(
                hintText: '••••••••',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
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
                  borderSide: BorderSide(
                    color: isDelete ? Colors.red : _purple,
                    width: 1.5,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Confirm button ───────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _loading ? null : _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDelete ? Colors.red : _purple,
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
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        isDelete
                            ? 'Supprimer mon compte'
                            : 'Désactiver mon compte',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Option Card ───────────────────────────────────────────────────────────────
class _OptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool selected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? iconColor : const Color(0xFFCDCDCD),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black45, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? iconColor : Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_app/core/theme/app_theme.dart';

class AccessibilityScreen extends StatefulWidget {
  const AccessibilityScreen({super.key});

  @override
  State<AccessibilityScreen> createState() => _AccessibilityScreenState();
}

class _AccessibilityScreenState extends State<AccessibilityScreen> {
  double _fontSize = 1.0; // 1.0 = normal
  bool _highContrast = false;
  bool _reduceAnimations = false;

  static const _purple = Color(0xFF401E66);
  static const _bg = Color(0xFFF6F3F8);

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize       = prefs.getDouble('a11y_font_size')      ?? 1.0;
      _highContrast   = prefs.getBool('a11y_high_contrast')    ?? false;
      _reduceAnimations = prefs.getBool('a11y_reduce_anim')    ?? false;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('a11y_font_size', _fontSize);
    await prefs.setBool('a11y_high_contrast', _highContrast);
    await prefs.setBool('a11y_reduce_anim', _reduceAnimations);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Préférences sauvegardées.'),
          backgroundColor: _purple,
        ),
      );
    }
  }

  String get _fontSizeLabel {
    if (_fontSize <= 0.85) return 'Petite';
    if (_fontSize <= 1.0) return 'Normale';
    if (_fontSize <= 1.15) return 'Grande';
    return 'Très grande';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: Text('Accessibilité', style: AppTextStyles.heading1.copyWith(fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Font size
            const Text('TAILLE DU TEXTE',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                    color: Colors.black54, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCDCDCD)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('A', style: TextStyle(fontSize: 13, color: Colors.black45)),
                      Text(_fontSizeLabel,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: _purple)),
                      const Text('A', style: TextStyle(fontSize: 20, color: Colors.black45)),
                    ],
                  ),
                  Slider(
                    value: _fontSize,
                    min: 0.8,
                    max: 1.3,
                    divisions: 4,
                    activeColor: _purple,
                    inactiveColor: Colors.grey.shade200,
                    onChanged: (v) => setState(() => _fontSize = v),
                  ),
                  Text(
                    'Voici un aperçu de la taille du texte.',
                    style: TextStyle(
                        fontSize: 14 * _fontSize, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Toggles
            const Text('OPTIONS VISUELLES',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                    color: Colors.black54, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            _Toggle(
              title: 'Contraste élevé',
              subtitle: 'Améliore la lisibilité avec des couleurs plus contrastées.',
              icon: Icons.contrast,
              value: _highContrast,
              onChanged: (v) => setState(() => _highContrast = v),
            ),
            const SizedBox(height: 10),
            _Toggle(
              title: 'Réduire les animations',
              subtitle: 'Désactive les transitions et animations de l\'interface.',
              icon: Icons.animation,
              value: _reduceAnimations,
              onChanged: (v) => setState(() => _reduceAnimations = v),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999)),
                  elevation: 0,
                ),
                child: const Text('Enregistrer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _Toggle({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCDCDCD)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF401E66), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black45, height: 1.3)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF401E66),
          ),
        ],
      ),
    );
  }
}
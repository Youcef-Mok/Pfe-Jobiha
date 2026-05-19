import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Constantes de style basées sur le CSS fourni
const Color _kViolet = Color(0xFF401E66);
const Color _kSlate900 = Color(0xFF0F172A);
const Color _kSlate700 = Color(0xFF334155);
const Color _kSlate500 = Color(0xFF64748B);
const Color _kSlate400 = Color(0xFF94A3B8);
const Color _kSlate300 = Color(0xFFCBD5E1);
const Color _kSlate200 = Color(0xFFE2E8F0);
const Color _kSlate50 = Color(0xFFF8FAFC);

/// Modal pour ajouter une expérience (Public Sans)
class AddExperienceOverlay extends StatelessWidget {
  const AddExperienceOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return _BaseModal(
      title: 'Ajouter une expérience',
      subtitle: 'Partagez votre parcours professionnel.',
      fontFamily: 'Public Sans',
      children: [
        _buildLabel('Poste', 'Public Sans'),
        _buildInput('Ex: Animateur professionnel', 'Public Sans'),
        const SizedBox(height: 12),
        _buildLabel('Société/Établissement', 'Public Sans'),
        _buildInput('Ex: Nch Animation', 'Public Sans'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Date Embauche', 'Public Sans'),
                  _buildDateInput('mm / dd / yyyy', 'Public Sans'),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Date Fin activité', 'Public Sans'),
                  _buildDateInput('mm / dd / yyyy', 'Public Sans'),
                ],
              ),
            ),
          ],
        ),
      ],
      onConfirm: () => Navigator.pop(context),
      onCancel: () => Navigator.pop(context),
    );
  }
}

/// Modal pour ajouter une formation (Public Sans)
class AddFormationOverlay extends StatelessWidget {
  const AddFormationOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return _BaseModal(
      title: 'Ajouter une formation',
      subtitle: 'Détaillez votre cursus académique.',
      fontFamily: 'Public Sans',
      children: [
        _buildLabel('Nom de la formation', 'Public Sans'),
        _buildInput('Ex: Master en Design Graphique', 'Public Sans'),
        const SizedBox(height: 12),
        _buildLabel('Établissement / École', 'Public Sans'),
        _buildInput('Ex: École de Design Nantes Atlantique', 'Public Sans'),
        const SizedBox(height: 12),
        _buildLabel('Date d\'obtention', 'Public Sans'),
        _buildDateInput('mm / dd / yyyy', 'Public Sans'),
        const SizedBox(height: 12),
        _buildLabel('Insérer votre diplôme scanné (Optionnel)', 'Public Sans'),
        _buildUploadArea('Public Sans'),
      ],
      onConfirm: () => Navigator.pop(context),
      onCancel: () => Navigator.pop(context),
    );
  }
}

/// Modal pour ajouter une langue (Spline Sans)
class AddLanguageOverlay extends StatelessWidget {
  const AddLanguageOverlay({super.key});
  @override
  Widget build(BuildContext context) {
    return _BaseModal(
      title: 'Ajouter une langue',
      subtitle: 'Précisez votre niveau de maîtrise pour cette langue.',
      fontFamily: 'Spline Sans',
      onConfirm: () => Navigator.pop(context),
      onCancel: null, // Pas de bouton annuler dans le CSS langue, juste un bouton fermer en haut
      children: [
        _buildLabel('Langue', 'Spline Sans', icon: Icons.language),
        _buildSelectionInput('Sélectionner une langue', 'Spline Sans'),
        const SizedBox(height: 20),
        _buildLabel('Niveau', 'Spline Sans', icon: Icons.bar_chart),
        _buildSelectionInput('Sélectionner votre niveau', 'Spline Sans'),
      ],
    );
  }
}

/// Modal pour ajouter une compétence (Spline Sans)
class AddSkillOverlay extends StatelessWidget {
  const AddSkillOverlay({super.key});
  @override
  Widget build(BuildContext context) {
    return _BaseModal(
      title: 'Ajouter une compétence',
      subtitle: 'Indiquez vos compétences clés et votre niveau de maîtrise.',
      fontFamily: 'Spline Sans',
      onConfirm: () => Navigator.pop(context),
      onCancel: null,
      children: [
        _buildLabel('Nom de la compétence', 'Spline Sans', icon: Icons.bolt),
        _buildInput('Ex: Service en salle, Management...', 'Spline Sans'),
        const SizedBox(height: 24),
        _buildLabel('Niveau de maîtrise', 'Spline Sans', icon: Icons.trending_up),
        const SizedBox(height: 16),
        _buildSliderControl(),
        const SizedBox(height: 20),
        _buildSegmentedControlAlternative(),
      ],
    );
  }
}

/// Modal pour visualiser un certificat
class CertificateViewerOverlay extends StatelessWidget {
  final String title;
  final String institution;

  const CertificateViewerOverlay({
    super.key,
    required this.title,
    required this.institution,
  });
  @override
  Widget build(BuildContext context) {
    return _BaseModal(
      title: 'Certificat de formation',
      subtitle: 'Attestation officielle d\'obtention de diplôme.',
      fontFamily: 'Public Sans',
      onConfirm: () => Navigator.pop(context),
      onCancel: null,
      children: [
        Center(
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: _kSlate50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kSlate200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.description_outlined, size: 64, color: _kViolet),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.publicSans(fontWeight: FontWeight.w700, color: _kSlate900),
                  textAlign: TextAlign.center,
                ),
                Text(
                  institution,
                  style: GoogleFonts.publicSans(fontSize: 12, color: _kSlate500),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Téléchargement du certificat lancé...')),
            );
          },
          icon: const Icon(Icons.download),
          label: const Text('Télécharger le certificat (PDF)'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            foregroundColor: _kViolet,
            side: const BorderSide(color: _kViolet),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Helpers de construction (basés sur le CSS)
// ══════════════════════════════════════════════════════════════════

class _BaseModal extends StatelessWidget {
  final String title;
  final String subtitle;
  final String fontFamily;
  final List<Widget> children;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const _BaseModal({
    required this.title,
    required this.subtitle,
    required this.fontFamily,
    required this.children,
    required this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {


    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
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
                        title,
                        style: (fontFamily == 'Spline Sans' 
                            ? GoogleFonts.splineSans(fontSize: 24, fontWeight: FontWeight.w700)
                            : GoogleFonts.publicSans(fontSize: 20, fontWeight: FontWeight.w700)).copyWith(color: _kSlate900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: (fontFamily == 'Spline Sans'
                            ? GoogleFonts.splineSans(fontSize: 14)
                            : GoogleFonts.publicSans(fontSize: 12)).copyWith(color: _kSlate500),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20, color: _kSlate400),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...children,
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kViolet,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text(
                'Confirmer',
                style: (fontFamily == 'Spline Sans'
                    ? GoogleFonts.splineSans(fontSize: 16, fontWeight: FontWeight.w700)
                    : GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ),
            if (onCancel != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                  foregroundColor: _kViolet,
                ),
                child: Text(
                  'Annuler',
                  style: GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Widget _buildLabel(String label, String fontFamily, {IconData? icon}) {
  final style = (fontFamily == 'Spline Sans'
      ? GoogleFonts.splineSans(fontSize: 14, fontWeight: FontWeight.w600)
      : GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w600)).copyWith(color: _kSlate700);
  
  return Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: _kViolet),
          const SizedBox(width: 8),
        ],
        Text(label, style: style),
      ],
    ),
  );
}

Widget _buildInput(String placeholder, String fontFamily) {
  return Container(
    height: 42,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: _kSlate50,
      border: Border.all(color: _kSlate200),
      borderRadius: BorderRadius.circular(8),
    ),
    child: TextField(
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: (fontFamily == 'Spline Sans' 
            ? GoogleFonts.splineSans(fontSize: 14) 
            : GoogleFonts.publicSans(fontSize: 14)).copyWith(color: const Color(0xFF6B7280)),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 11),
      ),
    ),
  );
}

Widget _buildDateInput(String placeholder, String fontFamily) {
  return Container(
    height: 42,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: _kSlate50,
      border: Border.all(color: _kSlate200),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            placeholder,
            style: GoogleFonts.publicSans(fontSize: 14, color: _kSlate900),
          ),
        ),
        const Icon(Icons.calendar_today_outlined, size: 14, color: _kSlate400),
      ],
    ),
  );
}

Widget _buildSelectionInput(String placeholder, String fontFamily) {
  return Container(
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: _kViolet.withValues(alpha: 0.2)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            placeholder,
            style: GoogleFonts.splineSans(fontSize: 16, color: _kSlate900),
          ),
        ),
        const Icon(Icons.expand_more, color: _kViolet),
      ],
    ),
  );
}

Widget _buildUploadArea(String fontFamily) {
  return Container(
    height: 81,
    decoration: BoxDecoration(
      color: _kSlate50.withValues(alpha: 0.5),
      border: Border.all(color: _kSlate300, style: BorderStyle.none), // Border dashed non supporté en natif facile
      borderRadius: BorderRadius.circular(8),
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_upload_outlined, size: 20, color: _kSlate400),
          const SizedBox(height: 4),
          Text(
            'Cliquer pour uploader',
            style: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
          ),
          Text(
            'PNG, JPG up to 10MB',
            style: GoogleFonts.publicSans(fontSize: 10, color: _kSlate400),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSliderControl() {
  return Column(
    children: [
      SliderTheme(
        data: SliderThemeData(
          trackHeight: 8,
          activeTrackColor: _kViolet,
          inactiveTrackColor: _kSlate200,
          thumbColor: _kViolet,
          overlayColor: _kViolet.withValues(alpha: 0.2),
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        ),
        child: Slider(
          value: 0.5,
          onChanged: (v) {},
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sliderLabel('DÉBUTANT'),
            _sliderLabel('INTERMÉDIAIRE', isActive: true),
            _sliderLabel('AVANCÉ'),
            _sliderLabel('EXPERT'),
          ],
        ),
      ),
    ],
  );
}

Widget _sliderLabel(String text, {bool isActive = false}) {
  return Text(
    text,
    style: GoogleFonts.splineSans(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      color: isActive ? _kViolet : _kSlate400,
    ),
  );
}

Widget _buildSegmentedControlAlternative() {
  return Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        _segmentedTab('Beg', false),
        _segmentedTab('Int', true),
        _segmentedTab('Adv', false),
        _segmentedTab('Exp', false),
      ],
    ),
  );
}

Widget _segmentedTab(String label, bool isSelected) {
  return Expanded(
    child: Container(
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        boxShadow: isSelected ? [const BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))] : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.splineSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isSelected ? _kViolet : _kSlate500,
        ),
      ),
    ),
  );
}

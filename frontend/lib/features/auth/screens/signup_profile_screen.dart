import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_app/features/profile/data/providers/profile_provider.dart';
import 'package:job_app/features/profile/widgets/profile_add_overlays.dart';
import '../widgets/auth_header.dart';

class SignupProfileScreen extends ConsumerStatefulWidget {
  const SignupProfileScreen({super.key});

  @override
  ConsumerState<SignupProfileScreen> createState() => _SignupProfileScreenState();
}

const _algerianWilayas = [
  'Adrar', 'Chlef', 'Laghouat', 'Oum El Bouaghi', 'Batna', 'Béjaïa', 'Biskra',
  'Béchar', 'Blida', 'Bouira', 'Tamanrasset', 'Tébessa', 'Tlemcen', 'Tiaret',
  'Tizi Ouzou', 'Alger', 'Djelfa', 'Jijel', 'Sétif', 'Saïda', 'Skikda',
  'Sidi Bel Abbès', 'Annaba', 'Guelma', 'Constantine', 'Médéa', 'Mostaganem',
  'MSila', 'Mascara', 'Ouargla', 'Oran', 'El Bayadh', 'Illizi',
  'Bordj Bou Arréridj', 'Boumerdès', 'El Tarf', 'Tindouf', 'Tissemsilt',
  'El Oued', 'Khenchela', 'Souk Ahras', 'Tipaza', 'Mila', 'Aïn Defla',
  'Naâma', 'Aïn Témouchent', 'Ghardaïa', 'Relizane', 'El MGhair', 'El Meniaa',
  'Ouled Djellal', 'Bordj Badji Mokhtar', 'Béni Abbès', 'Timimoun',
  'Touggourt', 'Djanet', 'In Salah', 'In Guezzam',
];

class _SignupProfileScreenState extends ConsumerState<SignupProfileScreen> {
  final _bioController = TextEditingController();
  String? _selectedWilaya;
  bool _isSaving = false;

  static const _violet = Color(0xFF401E66);

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    setState(() => _isSaving = true);
    try {
      final bio = _bioController.text.trim();
      final wilaya = _selectedWilaya;
      if (bio.isNotEmpty || wilaya != null) {
        final user = await ref.read(profileControllerProvider).fetchCurrentUser();
        final updated = await ref.read(profileControllerProvider).updateProfile(
          user.copyWith(
            bio: bio.isNotEmpty ? bio : user.bio,
            location: wilaya ?? user.location,
          ),
        );
        ref.read(candidateCurrentUserProvider.notifier).updateUser(updated);
      }
    } catch (_) {
      // save failure doesn't block navigation
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
    if (mounted) {
      navigator.pushNamedAndRemoveUntil('/candidate-home', (r) => false);
    }
  }

  void _skip() =>
      Navigator.pushNamedAndRemoveUntil(context, '/candidate-home', (r) => false);

  void _openExperiences() =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExperienceOverlay()));

  void _openFormations() =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFormationOverlay()));

  void _openSkillsAndLanguages() =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddSkillsAndLanguagesOverlay()));

  @override
  Widget build(BuildContext context) {
    final cv = ref.watch(cvNotifierProvider);
    final experiences = cv.valueOrNull?.experiences ?? [];
    final formations = cv.valueOrNull?.formations ?? [];
    final skills = cv.valueOrNull?.skills ?? [];
    final languages = cv.valueOrNull?.languages ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AuthHeader(onBackPressed: () => Navigator.pop(context)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // 3-step progress bar
                  Row(
                    children: [
                      Expanded(child: _progressBar(done: true)),
                      const SizedBox(width: 4),
                      Expanded(child: _progressBar(done: true)),
                      const SizedBox(width: 4),
                      Expanded(child: _progressBar(done: true)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Complétez votre profil',
                    style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A2E)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ces informations apparaîtront sur votre profil public.',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildBioCard(),
                  const SizedBox(height: 12),
                  _buildWilayaCard(),
                  const SizedBox(height: 12),
                  _buildListCard(
                    icon: Icons.work_outline,
                    label: 'Expériences',
                    onAdd: _openExperiences,
                    items: experiences
                        .map((e) => _itemRow(
                              primary: e.title,
                              secondary:
                                  '${e.company}${e.period != null ? " · ${e.period}" : ""}',
                              icon: Icons.work_outline,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  _buildListCard(
                    icon: Icons.school_outlined,
                    label: 'Formations',
                    onAdd: _openFormations,
                    items: formations
                        .map((f) => _itemRow(
                              primary: f.title,
                              secondary: '${f.institution} · ${f.year}',
                              icon: Icons.school_outlined,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  _buildListCard(
                    icon: Icons.bolt,
                    label: 'Compétences & Langues',
                    onAdd: _openSkillsAndLanguages,
                    items: [
                      ...skills.map((s) => _itemRow(
                            primary: s.name,
                            secondary: s.levelLabel ?? '',
                            icon: Icons.bolt,
                          )),
                      ...languages.map((l) => _itemRow(
                            primary: l.name,
                            secondary: l.level,
                            icon: Icons.language,
                          )),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _violet,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              'Enregistrer et continuer',
                              style: GoogleFonts.inter(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                  TextButton(
                    onPressed: _skip,
                    child: Text(
                      'Passer pour l\'instant',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Widget _progressBar({required bool done}) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: done ? _violet : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildWilayaCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.location_on_outlined, color: _violet, size: 22),
            const SizedBox(width: 12),
            Text('Wilaya / Ville',
                style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedWilaya,
            isExpanded: true,
            hint: Text('Choisir votre wilaya',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _violet),
              ),
            ),
            items: _algerianWilayas
                .map((w) => DropdownMenuItem(
                      value: w,
                      child: Text(w,
                          style: GoogleFonts.inter(fontSize: 13)),
                    ))
                .toList(),
            onChanged: (val) => setState(() => _selectedWilaya = val),
          ),
        ],
      ),
    );
  }

  Widget _buildBioCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.person_outline, color: _violet, size: 22),
            const SizedBox(width: 12),
            Text('Bio',
                style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 12),
          TextField(
            controller: _bioController,
            maxLines: 3,
            style: GoogleFonts.inter(fontSize: 13),
            decoration: InputDecoration(
              hintText:
                  'Décrivez votre parcours et vos aspirations professionnelles...',
              hintStyle:
                  GoogleFonts.inter(fontSize: 12, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _violet),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard({
    required IconData icon,
    required String label,
    required VoidCallback onAdd,
    required List<Widget> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(children: [
              Icon(icon, color: _violet, size: 22),
              const SizedBox(width: 12),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              const Spacer(),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _violet.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.add, color: _violet, size: 18),
                ),
              ),
            ]),
          ),
          if (items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items),
            ),
        ],
      ),
    );
  }

  Widget _itemRow({
    required String primary,
    required String secondary,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, color: _violet, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(primary,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                if (secondary.isNotEmpty)
                  Text(secondary,
                      style: GoogleFonts.inter(
                          fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

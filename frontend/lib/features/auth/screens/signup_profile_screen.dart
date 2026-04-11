import 'package:flutter/material.dart';

class LanguageItem {
  String name;
  String level;
  LanguageItem({required this.name, required this.level});
}

class SkillItem {
  String name;
  String level;
  SkillItem({required this.name, required this.level});
}

class FormationItem {
  String name;
  String school;
  DateTime date;
  FormationItem({required this.name, required this.school, required this.date});
}

class ExperienceItem {
  String poste;
  String societe;
  DateTime dateDebut;
  DateTime dateFin;
  ExperienceItem({
    required this.poste,
    required this.societe,
    required this.dateDebut,
    required this.dateFin,
  });
}

class SignupProfileScreen extends StatefulWidget {
  const SignupProfileScreen({super.key});

  @override
  State<SignupProfileScreen> createState() => _SignupProfileScreenState();
}

class _SignupProfileScreenState extends State<SignupProfileScreen> {
  final List<LanguageItem> _languages = [];
  final List<SkillItem> _skills = [];
  final List<FormationItem> _formations = [];
  final List<ExperienceItem> _experiences = [];
  String? _description;

  final Color primaryColor = const Color(0xFF3A1B5E);

  // ── Date picker — max is always TODAY ────────────────────────────────────
  Future<DateTime?> _pickDate(BuildContext ctx,
      {DateTime? initial, DateTime? firstDate, DateTime? lastDate}) async {
    return showDatePicker(
      context: ctx,
      initialDate: initial ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1970),
      lastDate: lastDate ?? DateTime.now(), // default max = today
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: primaryColor),
        ),
        child: child!,
      ),
    );
  }

  // ── POPUPS ────────────────────────────────────────────────────────────────

  void _showAddLanguage() {
    final nameCtrl = TextEditingController();
    String selectedLevel = 'A1';
    final levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    String? nameError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: _dialogTitle('Ajouter une langue', ctx),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dialogField(nameCtrl, 'Ex: Anglais, Français...', 'Nom de la langue',
                  error: nameError),
              const SizedBox(height: 16),
              Text('Niveau',
                  style: TextStyle(fontWeight: FontWeight.w600, color: primaryColor, fontSize: 13)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: levels.map((l) => GestureDetector(
                  onTap: () => setS(() => selectedLevel = l),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selectedLevel == l ? primaryColor : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(l, style: TextStyle(
                        color: selectedLevel == l ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500, fontSize: 13)),
                  ),
                )).toList(),
              ),
            ],
          ),
          actions: [_dialogButton('Ajouter', () {
            final name = nameCtrl.text.trim();
            if (name.isEmpty) { setS(() => nameError = 'Ce champ est obligatoire'); return; }
            if (name.length < 2) { setS(() => nameError = 'Minimum 2 caractères'); return; }
            setState(() => _languages.add(LanguageItem(name: name, level: selectedLevel)));
            Navigator.pop(ctx);
          })],
        ),
      ),
    );
  }

  void _showAddSkill() {
    final nameCtrl = TextEditingController();
    int levelIndex = 1;
    final levels = ['Débutant', 'Intermédiaire', 'Avancé', 'Expert'];
    final levelShort = ['Beg', 'Int', 'Adv', 'Exp'];
    String? nameError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: _dialogTitle('Ajouter une compétence', ctx),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Quelle nouvelle expertise souhaitez-vous mettre en avant ?',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 16),
              _dialogField(nameCtrl, 'Ex: Photoshop, Excel, Python...', 'Nom de la compétence',
                  error: nameError),
              const SizedBox(height: 16),
              Text('Niveau de maîtrise',
                  style: TextStyle(fontWeight: FontWeight.w600, color: primaryColor, fontSize: 13)),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(ctx).copyWith(
                  activeTrackColor: primaryColor,
                  thumbColor: primaryColor,
                  inactiveTrackColor: Colors.grey.shade200,
                  overlayColor: primaryColor.withValues(alpha: 0.1),
                ),
                child: Slider(
                  value: levelIndex.toDouble(), min: 0, max: 3, divisions: 3,
                  onChanged: (v) => setS(() => levelIndex = v.round()),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (i) => Text(levelShort[i],
                    style: TextStyle(fontSize: 11,
                        fontWeight: i == levelIndex ? FontWeight.bold : FontWeight.normal,
                        color: i == levelIndex ? primaryColor : Colors.grey))),
              ),
              const SizedBox(height: 4),
              Center(child: Text(levels[levelIndex],
                  style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 13))),
            ],
          ),
          actions: [_dialogButton('Ajouter', () {
            final name = nameCtrl.text.trim();
            if (name.isEmpty) { setS(() => nameError = 'Ce champ est obligatoire'); return; }
            if (name.length < 2) { setS(() => nameError = 'Minimum 2 caractères'); return; }
            setState(() => _skills.add(SkillItem(name: name, level: levels[levelIndex])));
            Navigator.pop(ctx);
          })],
        ),
      ),
    );
  }

  void _showAddFormation() {
    final nameCtrl = TextEditingController();
    final schoolCtrl = TextEditingController();
    DateTime? selectedDate;
    Map<String, String?> errors = {'name': null, 'school': null, 'date': null};

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: _dialogTitle('Ajouter une formation', ctx),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Complétez votre parcours académique',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 16),
                _dialogField(nameCtrl, 'Ex: Master en Design Graphique', 'Nom de la formation',
                    error: errors['name']),
                const SizedBox(height: 12),
                _dialogField(schoolCtrl, 'Ex: École de Design Nantes Atlantique',
                    'Établissement / École', error: errors['school']),
                const SizedBox(height: 12),
                _dateField(
                  label: "Date d'obtention",
                  selected: selectedDate,
                  error: errors['date'],
                  onTap: () async {
                    final picked = await _pickDate(ctx); // max = today
                    if (picked != null) setS(() { selectedDate = picked; errors['date'] = null; });
                  },
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryColor.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(12),
                      color: primaryColor.withValues(alpha: 0.03),
                    ),
                    child: Column(children: [
                      Icon(Icons.upload_file, color: primaryColor, size: 28),
                      const SizedBox(height: 6),
                      Text('Cliquez pour téléverser',
                          style: TextStyle(color: primaryColor, fontWeight: FontWeight.w500, fontSize: 13)),
                      const Text('PDF, JPG ou PNG (max. 5MB)',
                          style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          actions: [_dialogButton('Enregistrer', () {
            bool valid = true;
            if (nameCtrl.text.trim().isEmpty) { errors['name'] = 'Ce champ est obligatoire'; valid = false; }
            else if (nameCtrl.text.trim().length < 2) { errors['name'] = 'Minimum 2 caractères'; valid = false; }
            if (schoolCtrl.text.trim().isEmpty) { errors['school'] = 'Ce champ est obligatoire'; valid = false; }
            else if (schoolCtrl.text.trim().length < 2) { errors['school'] = 'Minimum 2 caractères'; valid = false; }
            if (selectedDate == null) { errors['date'] = 'Veuillez sélectionner une date'; valid = false; }
            if (!valid) { setS(() {}); return; }
            setState(() => _formations.add(FormationItem(
                name: nameCtrl.text.trim(), school: schoolCtrl.text.trim(), date: selectedDate!)));
            Navigator.pop(ctx);
          })],
        ),
      ),
    );
  }

  void _showAddExperience() {
    final posteCtrl = TextEditingController();
    final societeCtrl = TextEditingController();
    DateTime? dateDebut;
    DateTime? dateFin;
    Map<String, String?> errors = {'poste': null, 'societe': null, 'debut': null, 'fin': null};

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: _dialogTitle('Ajouter une expérience', ctx),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(posteCtrl, 'Ex: Animateur professionnel', 'Poste',
                    error: errors['poste']),
                const SizedBox(height: 12),
                _dialogField(societeCtrl, 'Ex: Nch Animation', 'Société / Établissement',
                    error: errors['societe']),
                const SizedBox(height: 12),
                _dateField(
                  label: 'Date Embauche',
                  selected: dateDebut,
                  error: errors['debut'],
                  onTap: () async {
                    // Start date: can't be in the future
                    final picked = await _pickDate(ctx, lastDate: DateTime.now());
                    if (picked != null) {
                      setS(() {
                        dateDebut = picked;
                        errors['debut'] = null;
                        // Reset end date if it's now before the new start date
                        if (dateFin != null && dateFin!.isBefore(dateDebut!)) {
                          dateFin = null;
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                _dateField(
                  label: 'Date Fin activité',
                  selected: dateFin,
                  error: errors['fin'],
                  onTap: () async {
                    // End date: must be after start date AND can't be in the future
                    final picked = await _pickDate(
                      ctx,
                      initial: dateFin ?? dateDebut,
                      firstDate: dateDebut ?? DateTime(1970), // can't be before start
                      lastDate: DateTime.now(), // can't be in the future
                    );
                    if (picked != null) setS(() { dateFin = picked; errors['fin'] = null; });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
            ),
            _dialogButton('Enregistrer', () {
              bool valid = true;
              if (posteCtrl.text.trim().isEmpty) { errors['poste'] = 'Ce champ est obligatoire'; valid = false; }
              else if (posteCtrl.text.trim().length < 2) { errors['poste'] = 'Minimum 2 caractères'; valid = false; }
              if (societeCtrl.text.trim().isEmpty) { errors['societe'] = 'Ce champ est obligatoire'; valid = false; }
              else if (societeCtrl.text.trim().length < 2) { errors['societe'] = 'Minimum 2 caractères'; valid = false; }
              if (dateDebut == null) { errors['debut'] = 'Veuillez sélectionner une date'; valid = false; }
              if (dateFin == null) { errors['fin'] = 'Veuillez sélectionner une date'; valid = false; }
              if (!valid) { setS(() {}); return; }
              setState(() => _experiences.add(ExperienceItem(
                  poste: posteCtrl.text.trim(), societe: societeCtrl.text.trim(),
                  dateDebut: dateDebut!, dateFin: dateFin!)));
              Navigator.pop(ctx);
            }),
          ],
        ),
      ),
    );
  }

  void _showDescriptionDialog({String? existing}) {
    final ctrl = TextEditingController(text: existing ?? '');
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: _dialogTitle('Description', ctx),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bio professionnelle',
                  style: TextStyle(fontWeight: FontWeight.w600, color: primaryColor, fontSize: 13)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: error != null ? Border.all(color: Colors.red.shade300) : null,
                ),
                child: TextField(
                  controller: ctrl,
                  maxLines: 5,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Décrivez votre projet professionnel\net vos aspirations...',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(14),
                  ),
                ),
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text(error!, style: const TextStyle(color: Colors.red, fontSize: 11)),
                ),
            ],
          ),
          actions: [_dialogButton('Enregistrer', () {
            final text = ctrl.text.trim();
            if (text.isEmpty) { setS(() => error = 'Ce champ est obligatoire'); return; }
            if (text.length < 10) { setS(() => error = 'Minimum 10 caractères'); return; }
            setState(() => _description = text);
            Navigator.pop(ctx);
          })],
        ),
      ),
    );
  }

  // ── Widget helpers ────────────────────────────────────────────────────────

  Widget _dialogTitle(String title, BuildContext ctx) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        GestureDetector(onTap: () => Navigator.pop(ctx),
            child: const Icon(Icons.close, size: 20, color: Colors.grey)),
      ],
    );
  }

  Widget _dialogField(TextEditingController ctrl, String hint, String label,
      {TextInputType keyboardType = TextInputType.text, String? error}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: primaryColor, fontSize: 13)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(10),
            border: error != null ? Border.all(color: Colors.red.shade300) : null,
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

  Widget _dateField({required String label, required DateTime? selected,
      required String? error, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: primaryColor, fontSize: 13)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
              border: error != null ? Border.all(color: Colors.red.shade300) : null,
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  selected != null
                      ? '${selected.day}/${selected.month}/${selected.year}'
                      : 'Sélectionner une date',
                  style: TextStyle(
                      color: selected != null ? Colors.black87 : Colors.grey, fontSize: 14),
                ),
              ],
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

  Widget _dialogButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18),
                      onPressed: () => Navigator.pop(context), padding: EdgeInsets.zero),
                  const Spacer(),
                  Row(children: [
                    Icon(Icons.directions_walk, color: primaryColor, size: 20),
                    const SizedBox(width: 4),
                    Text('Jobiha', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                  ]),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            const Text('Complétez votre profil',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),

            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildSection(
                    icon: Icons.translate,
                    label: 'Langues',
                    onAdd: _showAddLanguage,
                    hasItems: _languages.isNotEmpty,
                    children: List.generate(_languages.length,
                        (i) => _deletableChip('${_languages[i].name}  (${_languages[i].level})',
                            () => setState(() => _languages.removeAt(i)))),
                  ),
                  const SizedBox(height: 12),
                  _buildSection(
                    icon: Icons.auto_awesome_outlined,
                    label: 'Skills',
                    onAdd: _showAddSkill,
                    hasItems: _skills.isNotEmpty,
                    children: List.generate(_skills.length,
                        (i) => _deletableSkillChip(_skills[i].name, _skills[i].level,
                            () => setState(() => _skills.removeAt(i)))),
                  ),
                  const SizedBox(height: 12),
                  _buildSection(
                    icon: Icons.school_outlined,
                    label: 'Formations',
                    onAdd: _showAddFormation,
                    hasItems: _formations.isNotEmpty,
                    children: List.generate(_formations.length,
                        (i) => _deletableFormationTile(_formations[i],
                            () => setState(() => _formations.removeAt(i)))),
                  ),
                  const SizedBox(height: 12),
                  _buildSection(
                    icon: Icons.work_outline,
                    label: 'Experiences',
                    onAdd: _showAddExperience,
                    hasItems: _experiences.isNotEmpty,
                    children: List.generate(_experiences.length,
                        (i) => _deletableExperienceTile(_experiences[i],
                            () => setState(() => _experiences.removeAt(i)))),
                  ),
                  const SizedBox(height: 12),
                  _buildSection(
                    icon: Icons.person_outline,
                    label: 'Description',
                    onAdd: () => _showDescriptionDialog(existing: _description),
                    addIcon: _description != null ? Icons.edit_outlined : Icons.add,
                    hasItems: _description != null,
                    children: _description != null
                        ? [_deletableDescriptionTile(_description!,
                            () => setState(() => _description = null))]
                        : [],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/preferences'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: const Text('Enregistrer mon profil',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section card ──────────────────────────────────────────────────────────
  Widget _buildSection({
    required IconData icon,
    required String label,
    required VoidCallback onAdd,
    required bool hasItems,
    required List<Widget> children,
    IconData addIcon = Icons.add,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                Icon(icon, color: primaryColor, size: 22),
                const SizedBox(width: 12),
                Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const Spacer(),
                GestureDetector(onTap: onAdd, child: Icon(addIcon, color: primaryColor, size: 22)),
              ],
            ),
          ),
          if (hasItems)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
            ),
        ],
      ),
    );
  }

  // ── Item tiles WITH delete button ─────────────────────────────────────────

  Widget _deletableChip(String text, VoidCallback onDelete) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close, size: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _deletableSkillChip(String name, String level, VoidCallback onDelete) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(level, style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(Icons.close, size: 16, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: _skillValue(level),
            backgroundColor: Colors.grey.shade200,
            color: primaryColor,
            minHeight: 4,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _deletableFormationTile(FormationItem f, VoidCallback onDelete) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.school_outlined, color: primaryColor, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(f.school, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text('${f.date.day}/${f.date.month}/${f.date.year}',
                    style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close, size: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _deletableExperienceTile(ExperienceItem e, VoidCallback onDelete) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.poste, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(e.societe, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text('${e.dateDebut.day}/${e.dateDebut.month}/${e.dateDebut.year} → ${e.dateFin.day}/${e.dateFin.month}/${e.dateFin.year}',
                    style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close, size: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _deletableDescriptionTile(String text, VoidCallback onDelete) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87))),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close, size: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  double _skillValue(String level) {
    switch (level) {
      case 'Débutant': return 0.25;
      case 'Intermédiaire': return 0.5;
      case 'Avancé': return 0.75;
      case 'Expert': return 1.0;
      default: return 0.5;
    }
  }
}
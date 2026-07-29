import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/features/profile/data/providers/profile_provider.dart';
import 'package:job_app/features/profile/domain/cv_entity.dart';
import 'package:job_app/core/widgets/searchable_dropdown.dart';
import 'dart:io';

// Constantes de style basées sur le CSS fourni
const Color _kViolet = Color(0xFF401E66);
const Color _kSlate900 = Color(0xFF0F172A);
const Color _kSlate700 = Color(0xFF334155);
const Color _kSlate500 = Color(0xFF475569);
const Color _kSlate400 = Color(0xFF94A3B8);
const Color _kSlate300 = Color(0xFFCBD5E1);
const Color _kSlate200 = Color(0xFFE2E8F0);
const Color _kSlate50 = Color(0xFFF8FAFC);
const Color _kJobCardGray = Color(0xFFEFEDF2);

/// Modal pour ajouter une expérience (Full-page)
class AddExperienceOverlay extends ConsumerStatefulWidget {
  const AddExperienceOverlay({super.key});

  @override
  ConsumerState<AddExperienceOverlay> createState() => _AddExperienceOverlayState();
}

class _AddExperienceOverlayState extends ConsumerState<AddExperienceOverlay> {
  String? _selectedTitle;
  final _companyController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  String? _startDateError;
  String? _endDateError;

  final List<String> _jobTitles = [
    'Animateur professionnel',
    'Serveur / Serveuse',
    'Chef de rang',
    'Barman / Barmaid',
    'Cuisinier / Cuisinière',
    'Chef de cuisine',
    'Pâtissier / Pâtissière',
    'Commis de cuisine',
    'Plongeur / Plongeuse',
    'Réceptionniste',
    'Manager de restaurant',
    'Sommelier / Sommelière',
    'Hôte / Hôtesse d\'accueil',
    'Responsable de salle',
  ];

  final List<String> _algerianCompanies = [
    'Sonatrach',
    'Cevital',
    'Air Algérie',
    'Algérie Télécom',
    'Sonelgaz',
    'ENIEM',
    'Saidal',
    'Cosider',
    'Groupe Benamor',
    'Danone Djurdjura',
    'Tchin-Tchin',
    'Ifri',
    'Hamoud Boualem',
    'Groupe Sim',
    'Condor Electronics',
    'Iris',
    'Tonic Industrie',
    'Groupe Benhamadi',
    'Laiterie Soummam',
    'Groupe Amor Benamor',
  ];

  @override
  void dispose() {
    _companyController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _saveExperience() {
    // Validation des dates
    setState(() {
      _startDateError = null;
      _endDateError = null;
    });

    bool hasError = false;

    if (_startDateController.text.isNotEmpty && !_isValidDate(_startDateController.text)) {
      setState(() {
        _startDateError = 'Date invalide';
      });
      hasError = true;
    }

    if (_endDateController.text.isNotEmpty && !_isValidDate(_endDateController.text)) {
      setState(() {
        _endDateError = 'Date invalide';
      });
      hasError = true;
    }

    // Vérification que la date de fin est après la date de début
    if (_startDateController.text.isNotEmpty && _endDateController.text.isNotEmpty && 
        _isValidDate(_startDateController.text) && _isValidDate(_endDateController.text)) {
      final startParts = _startDateController.text.split(' / ');
      final endParts = _endDateController.text.split(' / ');
      
      final startDate = DateTime(
        int.parse(startParts[2]), 
        int.parse(startParts[1]), 
        int.parse(startParts[0])
      );
      final endDate = DateTime(
        int.parse(endParts[2]), 
        int.parse(endParts[1]), 
        int.parse(endParts[0])
      );
      
      if (endDate.isBefore(startDate)) {
        setState(() {
          _endDateError = 'La date de fin doit être après la date de début';
        });
        hasError = true;
      }
    }

    if (hasError) return;

    if (_selectedTitle != null && _companyController.text.isNotEmpty) {
      final startDate = _startDateController.text.isNotEmpty ? _startDateController.text : '';
      final endDate = _endDateController.text.isNotEmpty ? _endDateController.text : 'Présent';
      final period = startDate.isNotEmpty ? '$startDate - $endDate' : endDate;
      
      final experience = CvExperienceEntity(
        title: _selectedTitle!,
        company: _companyController.text,
        location: 'Alger',
        period: period,
        endDate: endDate,
      );
      ref.read(cvNotifierProvider.notifier).addExperience(experience);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Annuler',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF262626),
                      ),
                    ),
                  ),
                  Text(
                    'Ajouter une expérience',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF262626),
                    ),
                  ),
                  const SizedBox(width: 60), // Placeholder for symmetry
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SearchableDropdown(
                      value: _selectedTitle,
                      placeholder: 'Sélectionner un poste',
                      items: _jobTitles,
                      onChanged: (value) => setState(() => _selectedTitle = value),
                      label: 'Poste',
                      icon: Icons.work_outline,
                      heightFactor: 0.65,
                    ),
                    const SizedBox(height: 12),
                    SearchableDropdown(
                      value: _companyController.text.isEmpty ? null : _companyController.text,
                      placeholder: 'Sélectionner ou saisir une société',
                      items: _algerianCompanies,
                      onChanged: (value) => setState(() => _companyController.text = value ?? ''),
                      label: 'Société/Établissement',
                      icon: Icons.business_outlined,
                      heightFactor: 0.65,
                      showSectorIcon: true, // Nouveau paramètre pour afficher l'icône du secteur
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Date d\'embauche'),
                              _buildDateInputField(_startDateController, errorText: _startDateError),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Date fin d\'activité'),
                              _buildDateInputField(_endDateController, errorText: _endDateError),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Fixed confirm button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                ),
              ),
              child: ElevatedButton(
                onPressed: _selectedTitle != null && _companyController.text.isNotEmpty ? _saveExperience : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kViolet,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Text(
                  'Confirmer',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modal pour ajouter une formation (Full-page)
class AddFormationOverlay extends ConsumerStatefulWidget {
  const AddFormationOverlay({super.key});

  @override
  ConsumerState<AddFormationOverlay> createState() => _AddFormationOverlayState();
}

class _AddFormationOverlayState extends ConsumerState<AddFormationOverlay> {
  String? _selectedFormation;
  final _institutionController = TextEditingController();
  final _dateController = TextEditingController();
  String? _uploadedFileName;
  String? _uploadedFilePath;
  String? _dateError;

  final List<String> _formations = [
    'Licence en Informatique',
    'Master en Génie Logiciel',
    'Doctorat en Sciences',
    'BTS Hôtellerie-Restauration',
    'DUT Génie Civil',
    'Licence Professionnelle Commerce',
    'Master Management',
    'Diplôme d\'Ingénieur',
    'CAP Cuisine',
    'Baccalauréat',
    'Master en Marketing Digital',
    'Licence en Droit',
    'Master en Finance',
    'BTS Tourisme',
    'Licence en Économie',
    'Master en Ressources Humaines',
    'Diplôme de Technicien Supérieur',
    'Licence en Gestion',
  ];

  final List<String> _algerianInstitutions = [
    'Université d\'Alger 1',
    'Université d\'Alger 2',
    'Université d\'Alger 3',
    'École Nationale Polytechnique (ENP)',
    'École Supérieure de Commerce (ESC)',
    'Université de Constantine 1',
    'Université de Constantine 2',
    'Université d\'Oran 1',
    'Université d\'Oran 2',
    'Université de Tizi Ouzou',
    'Université de Béjaïa',
    'Université de Sétif 1',
    'Université de Sétif 2',
    'École Nationale d\'Administration (ENA)',
    'Institut National de Formation Professionnelle',
    'Centre de Formation Professionnelle d\'Alger',
    'École Supérieure de Technologie',
    'Institut de Technologie Appliquée',
    'Université de Blida 1',
    'Université de Blida 2',
  ];

  String _getInstitutionLocation(String institution) {
    final locationMap = {
      'Université d\'Alger 1': 'Alger',
      'Université d\'Alger 2': 'Alger',
      'Université d\'Alger 3': 'Alger',
      'École Nationale Polytechnique (ENP)': 'Alger',
      'École Supérieure de Commerce (ESC)': 'Alger',
      'Université de Constantine 1': 'Constantine',
      'Université de Constantine 2': 'Constantine',
      'Université d\'Oran 1': 'Oran',
      'Université d\'Oran 2': 'Oran',
      'Université de Tizi Ouzou': 'Tizi Ouzou',
      'Université de Béjaïa': 'Béjaïa',
      'Université de Sétif 1': 'Sétif',
      'Université de Sétif 2': 'Sétif',
      'École Nationale d\'Administration (ENA)': 'Alger',
      'Institut National de Formation Professionnelle': 'Alger',
      'Centre de Formation Professionnelle d\'Alger': 'Alger',
      'École Supérieure de Technologie': 'Alger',
      'Institut de Technologie Appliquée': 'Alger',
      'Université de Blida 1': 'Blida',
      'Université de Blida 2': 'Blida',
    };
    return locationMap[institution] ?? 'Alger';
  }

  @override
  void dispose() {
    _institutionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _saveFormation() {
    // Validation de la date
    setState(() {
      _dateError = null;
    });

    if (_dateController.text.isNotEmpty && !_isValidDate(_dateController.text)) {
      setState(() {
        _dateError = 'Date invalide';
      });
      return;
    }

    if (_selectedFormation != null && _institutionController.text.isNotEmpty) {
      final year = _dateController.text.isNotEmpty 
          ? int.tryParse(_dateController.text.split(' / ').last) ?? DateTime.now().year
          : DateTime.now().year;
      
      final formation = CvFormationEntity(
        title: _selectedFormation!,
        institution: _institutionController.text,
        location: _getInstitutionLocation(_institutionController.text),
        year: year,
        isActive: _uploadedFileName != null,
        fileName: _uploadedFileName,
        filePath: _uploadedFilePath,
      );
      ref.read(cvNotifierProvider.notifier).addFormation(formation);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Annuler',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF262626),
                      ),
                    ),
                  ),
                  Text(
                    'Ajouter une formation',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF262626),
                    ),
                  ),
                  const SizedBox(width: 60), // Placeholder for symmetry
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SearchableDropdown(
                      value: _selectedFormation,
                      placeholder: 'Sélectionner une formation',
                      items: _formations,
                      onChanged: (value) => setState(() => _selectedFormation = value),
                      label: 'Nom de la formation',
                      icon: Icons.school_outlined,
                      heightFactor: 0.65,
                    ),
                    const SizedBox(height: 12),
                    SearchableDropdown(
                      value: _institutionController.text.isEmpty ? null : _institutionController.text,
                      placeholder: 'Sélectionner ou saisir un établissement',
                      items: _algerianInstitutions,
                      onChanged: (value) => setState(() => _institutionController.text = value ?? ''),
                      label: 'Nom de l\'établissement',
                      icon: Icons.school_outlined,
                      heightFactor: 0.65,
                      showGraduationIcon: true, // Nouveau paramètre pour afficher l'icône de graduation
                    ),
                    const SizedBox(height: 12),
                    _buildLabel('Date d\'obtention'),
                    _buildDateInputField(_dateController, errorText: _dateError),
                    const SizedBox(height: 12),
                    _buildLabel('Insérer votre diplôme scanné (Optionnel)'),
                    _buildUploadArea(
                      fileName: _uploadedFileName,
                      onTap: () async {
                        try {
                          FilePickerResult? result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
                          );
                          
                          if (result != null) {
                            final file = result.files.single;
                            print('Fichier sélectionné: ${file.name}');
                            print('Chemin du fichier: ${file.path}');
                            print('Taille du fichier: ${file.size} bytes');
                            
                            if (file.path != null) {
                              // Vérifier si le fichier existe
                              final fileExists = File(file.path!).existsSync();
                              print('Le fichier existe: $fileExists');
                              
                              if (fileExists) {
                                setState(() {
                                  _uploadedFileName = file.name;
                                  _uploadedFilePath = file.path;
                                });
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Fichier "${file.name}" sélectionné avec succès'),
                                      backgroundColor: const Color(0xFF401E66),
                                    ),
                                  );
                                }
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Le fichier sélectionné n\'est pas accessible'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            } else {
                              // Path is null (peut arriver sur web ou certaines plateformes)
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Impossible d\'accéder au fichier sur cette plateforme'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        } catch (e) {
                          print('Erreur lors de la sélection du fichier: $e');
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erreur lors de la sélection du fichier: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Fixed confirm button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                ),
              ),
              child: ElevatedButton(
                onPressed: _selectedFormation != null && _institutionController.text.isNotEmpty ? _saveFormation : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kViolet,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Text(
                  'Confirmer',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modal pour ajouter une langue (Spline Sans)
class AddLanguageOverlay extends ConsumerStatefulWidget {
  const AddLanguageOverlay({super.key});

  @override
  ConsumerState<AddLanguageOverlay> createState() => _AddLanguageOverlayState();
}

class _AddLanguageOverlayState extends ConsumerState<AddLanguageOverlay> {
  String? _selectedLanguage;
  String? _selectedLevel;

  final Map<String, bool> _languages = {
    'Français': false,
    'Anglais': false,
    'Espagnol': false,
    'Allemand': false,
    'Italien': false,
    'Arabe': false,
    'Chinois': false,
    'Japonais': false,
    'Portugais': false,
    'Russe': false,
  };

  final Map<String, bool> _levels = {
    'Débutant (A1)': false,
    'Élémentaire (A2)': false,
    'Intermédiaire (B1)': false,
    'Intermédiaire avancé (B2)': false,
    'Avancé (C1)': false,
    'Courant (C2)': false,
    'Natif': false,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ajouter une langue',
                          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)
                              .copyWith(color: const Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Précisez votre niveau de maîtrise pour cette langue.',
                          style: GoogleFonts.inter(fontSize: 12).copyWith(color: const Color(0xFF334155)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Section Langue
              Row(
                children: [
                  const Icon(Icons.language, size: 16, color: Color(0xFF401E66)),
                  const SizedBox(width: 8),
                  Text(
                    'Langue',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Checkboxes pour les langues
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: _languages.keys.map((language) {
                    final isLast = language == _languages.keys.last;
                    return Column(
                      children: [
                        CheckboxListTile(
                          title: Text(
                            language,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          value: _languages[language],
                          activeColor: const Color(0xFF401E66),
                          onChanged: (value) {
                            setState(() {
                              // Décocher toutes les autres langues
                              _languages.updateAll((key, _) => false);
                              // Cocher celle sélectionnée
                              _languages[language] = value ?? false;
                              _selectedLanguage = value == true ? language : null;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        if (!isLast)
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      ],
                    );
                  }).toList(),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Section Niveau
              Row(
                children: [
                  const Icon(Icons.bar_chart, size: 16, color: Color(0xFF401E66)),
                  const SizedBox(width: 8),
                  Text(
                    'Niveau',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Checkboxes pour les niveaux
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: _levels.keys.map((level) {
                    final isLast = level == _levels.keys.last;
                    return Column(
                      children: [
                        CheckboxListTile(
                          title: Text(
                            level,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          value: _levels[level],
                          activeColor: const Color(0xFF401E66),
                          onChanged: (value) {
                            setState(() {
                              // Décocher tous les autres niveaux
                              _levels.updateAll((key, _) => false);
                              // Cocher celui sélectionné
                              _levels[level] = value ?? false;
                              _selectedLevel = value == true ? level : null;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        if (!isLast)
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      ],
                    );
                  }).toList(),
                ),
              ),
              
              // Preview card
              if (_selectedLanguage != null && _selectedLevel != null) ...[
                const SizedBox(height: 20),
                _buildLanguagePreviewCard(_selectedLanguage!, _selectedLevel!),
              ],
              
              const SizedBox(height: 32),
              
              // Bouton Confirmer
              ElevatedButton(
                onPressed: () {
                  if (_selectedLanguage != null && _selectedLevel != null) {
                    final language = CvLanguageEntity(
                      name: _selectedLanguage!,
                      level: _selectedLevel!,
                    );
                    ref.read(cvNotifierProvider.notifier).addLanguage(language);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF401E66),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Text(
                  'Confirmer',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modal combiné pour ajouter langues et compétences (Full-page)
class AddSkillsAndLanguagesOverlay extends ConsumerStatefulWidget {
  const AddSkillsAndLanguagesOverlay({super.key});

  @override
  ConsumerState<AddSkillsAndLanguagesOverlay> createState() => _AddSkillsAndLanguagesOverlayState();
}

class _AddSkillsAndLanguagesOverlayState extends ConsumerState<AddSkillsAndLanguagesOverlay> {
  int _currentTab = 0; // 0: Skills, 1: Languages
  
  // Skills state
  String? _selectedSkill;
  double _skillLevel = 0.5;
  int _selectedSegment = 1;
  
  // Languages state
  String? _selectedLanguage;
  String? _selectedLevel;

  final List<String> _skills = [
    'Microsoft Excel',
    'Microsoft PowerPoint',
    'Microsoft Word',
    'Programmation Python',
    'Programmation JavaScript',
    'Communication',
    'Travail d\'équipe',
    'Leadership',
    'Gestion du temps',
    'Résolution de problèmes',
    'Créativité',
    'Adaptabilité',
    'Esprit critique',
    'Négociation',
    'Présentation orale',
    'Rédaction',
    'Analyse de données',
    'Gestion de projet',
    'Service client',
    'Vente',
  ];

  final Map<String, bool> _languages = {
    'Français': false,
    'Anglais': false,
    'Espagnol': false,
    'Allemand': false,
    'Italien': false,
    'Arabe': false,
    'Chinois': false,
    'Japonais': false,
    'Portugais': false,
    'Russe': false,
  };

  final Map<String, bool> _levels = {
    'Débutant (A1)': false,
    'Élémentaire (A2)': false,
    'Intermédiaire (B1)': false,
    'Intermédiaire avancé (B2)': false,
    'Avancé (C1)': false,
    'Courant (C2)': false,
    'Natif': false,
  };

  String get _levelLabel {
    if (_skillLevel < 0.25) return 'DÉBUTANT';
    if (_skillLevel < 0.5) return 'INTERMÉDIAIRE';
    if (_skillLevel < 0.75) return 'AVANCÉ';
    return 'EXPERT';
  }

  void _updateFromSegment(int segment) {
    setState(() {
      _selectedSegment = segment;
      _skillLevel = (segment + 0.5) / 4;
    });
  }

  void _updateFromSlider(double value) {
    setState(() {
      _skillLevel = value;
      if (value < 0.25) {
        _selectedSegment = 0;
      } else if (value < 0.5) {
        _selectedSegment = 1;
      } else if (value < 0.75) {
        _selectedSegment = 2;
      } else {
        _selectedSegment = 3;
      }
    });
  }

  void _confirmSkill() {
    if (_selectedSkill != null) {
      final skill = CvSkillEntity(
        name: _selectedSkill!,
        levelLabel: _levelLabel,
        progress: _skillLevel,
      );
      ref.read(cvNotifierProvider.notifier).addSkill(skill);
      Navigator.pop(context);
    }
  }

  void _confirmLanguage() {
    if (_selectedLanguage != null && _selectedLevel != null) {
      final language = CvLanguageEntity(
        name: _selectedLanguage!,
        level: _selectedLevel!,
      );
      ref.read(cvNotifierProvider.notifier).addLanguage(language);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Annuler',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF262626),
                      ),
                    ),
                  ),
                  Text(
                    _currentTab == 0 ? 'Ajouter une compétence' : 'Ajouter une langue',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF262626),
                    ),
                  ),
                  const SizedBox(width: 60), // Placeholder for symmetry
                ],
              ),
            ),
            
            // Tab selector
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _currentTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _currentTab == 0 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: _currentTab == 0
                              ? [const BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))]
                              : null,
                        ),
                        child: Text(
                          'Compétences',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _currentTab == 0 ? _kViolet : _kSlate500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _currentTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _currentTab == 1 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: _currentTab == 1
                              ? [const BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))]
                              : null,
                        ),
                        child: Text(
                          'Langues',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _currentTab == 1 ? _kViolet : _kSlate500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _currentTab == 0 ? _buildSkillsContent() : _buildLanguagesContent(),
              ),
            ),
            
            // Fixed confirm button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                ),
              ),
              child: ElevatedButton(
                onPressed: _currentTab == 0 
                    ? (_selectedSkill != null ? _confirmSkill : null)
                    : (_selectedLanguage != null && _selectedLevel != null ? _confirmLanguage : null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kViolet,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Text(
                  'Confirmer',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchableDropdown(
          value: _selectedSkill,
          placeholder: 'Sélectionner une compétence',
          items: _skills,
          onChanged: (value) => setState(() => _selectedSkill = value),
          label: 'Nom de la compétence',
          icon: Icons.bolt,
          heightFactor: 0.65,
        ),
        const SizedBox(height: 24),
        _buildLabel('Niveau de maîtrise', icon: Icons.trending_up),
        const SizedBox(height: 16),
        _buildSliderControl(_skillLevel, _updateFromSlider, _levelLabel),
        const SizedBox(height: 20),
        _buildSegmentedControl(_selectedSegment, _updateFromSegment),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildLanguagesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Langue
        Row(
          children: [
            const Icon(Icons.language, size: 16, color: _kViolet),
            const SizedBox(width: 8),
            Text(
              'Langue',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _kSlate700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Checkboxes pour les langues
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: _kSlate200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: _languages.keys.map((language) {
              final isLast = language == _languages.keys.last;
              return Column(
                children: [
                  CheckboxListTile(
                    title: Text(
                      language,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: _kSlate900,
                      ),
                    ),
                    value: _languages[language],
                    activeColor: _kViolet,
                    onChanged: (value) {
                      setState(() {
                        // Décocher toutes les autres langues
                        _languages.updateAll((key, _) => false);
                        // Cocher celle sélectionnée
                        _languages[language] = value ?? false;
                        _selectedLanguage = value == true ? language : null;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  if (!isLast)
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ],
              );
            }).toList(),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Section Niveau
        Row(
          children: [
            const Icon(Icons.bar_chart, size: 16, color: _kViolet),
            const SizedBox(width: 8),
            Text(
              'Niveau',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _kSlate700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Checkboxes pour les niveaux
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: _kSlate200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: _levels.keys.map((level) {
              final isLast = level == _levels.keys.last;
              return Column(
                children: [
                  CheckboxListTile(
                    title: Text(
                      level,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: _kSlate900,
                      ),
                    ),
                    value: _levels[level],
                    activeColor: _kViolet,
                    onChanged: (value) {
                      setState(() {
                        // Décocher tous les autres niveaux
                        _levels.updateAll((key, _) => false);
                        // Cocher celui sélectionné
                        _levels[level] = value ?? false;
                        _selectedLevel = value == true ? level : null;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  if (!isLast)
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ],
              );
            }).toList(),
          ),
        ),
        
        // Preview card
        if (_selectedLanguage != null && _selectedLevel != null) ...[
          const SizedBox(height: 20),
          _buildLanguagePreviewCard(_selectedLanguage!, _selectedLevel!),
        ],
        
        const SizedBox(height: 32),
      ],
    );
  }
}

/// Modal pour ajouter une compétence (Spline Sans)
class AddSkillOverlay extends ConsumerStatefulWidget {
  const AddSkillOverlay({super.key});

  @override
  ConsumerState<AddSkillOverlay> createState() => _AddSkillOverlayState();
}

class _AddSkillOverlayState extends ConsumerState<AddSkillOverlay> {
  String? _selectedSkill;
  double _skillLevel = 0.5;
  int _selectedSegment = 1; // 0: Beg, 1: Int, 2: Adv, 3: Exp

  final List<String> _skills = [
    'Microsoft Excel',
    'Microsoft PowerPoint',
    'Microsoft Word',
    'Programmation Python',
    'Programmation JavaScript',
    'Communication',
    'Travail d\'équipe',
    'Leadership',
    'Gestion du temps',
    'Résolution de problèmes',
    'Créativité',
    'Adaptabilité',
    'Esprit critique',
    'Négociation',
    'Présentation orale',
    'Rédaction',
    'Analyse de données',
    'Gestion de projet',
    'Service client',
    'Vente',
  ];

  String get _levelLabel {
    if (_skillLevel < 0.25) return 'DÉBUTANT';
    if (_skillLevel < 0.5) return 'INTERMÉDIAIRE';
    if (_skillLevel < 0.75) return 'AVANCÉ';
    return 'EXPERT';
  }

  void _updateFromSegment(int segment) {
    setState(() {
      _selectedSegment = segment;
      _skillLevel = (segment + 0.5) / 4;
    });
  }

  void _updateFromSlider(double value) {
    setState(() {
      _skillLevel = value;
      if (value < 0.25) {
        _selectedSegment = 0;
      } else if (value < 0.5) {
        _selectedSegment = 1;
      } else if (value < 0.75) {
        _selectedSegment = 2;
      } else {
        _selectedSegment = 3;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _BaseModal(
      title: 'Ajouter une compétence',
      subtitle: 'Indiquez vos compétences clés et votre niveau de maîtrise.',
      children: [
        SearchableDropdown(
          value: _selectedSkill,
          placeholder: 'Sélectionner une compétence',
          items: _skills,
          onChanged: (value) => setState(() => _selectedSkill = value),
          label: 'Nom de la compétence',
          icon: Icons.bolt,
          heightFactor: 0.65,
        ),
        const SizedBox(height: 24),
        _buildLabel('Niveau de maîtrise', icon: Icons.trending_up),
        const SizedBox(height: 16),
        _buildSliderControl(_skillLevel, _updateFromSlider, _levelLabel),
        const SizedBox(height: 20),
        _buildSegmentedControl(_selectedSegment, _updateFromSegment),
      ],
      onConfirm: () {
        if (_selectedSkill != null) {
          final skill = CvSkillEntity(
            name: _selectedSkill!,
            levelLabel: _levelLabel,
            progress: _skillLevel,
          );
          ref.read(cvNotifierProvider.notifier).addSkill(skill);
          Navigator.pop(context);
        }
      },
      onCancel: () => Navigator.pop(context),
    );
  }
}

/// Modal pour visualiser un certificat
class CertificateViewerOverlay extends StatelessWidget {
  final String title;
  final String institution;
  final String? fileName;
  final String? filePath;

  const CertificateViewerOverlay({
    super.key,
    required this.title,
    required this.institution,
    this.fileName,
    this.filePath,
  });

  @override
  Widget build(BuildContext context) {
    // Vérifier si le fichier existe avant de tenter de l'afficher
    final bool fileExists = filePath != null && File(filePath!).existsSync();
    final bool isImage = filePath != null && 
        (filePath!.toLowerCase().endsWith('.png') || 
         filePath!.toLowerCase().endsWith('.jpg') || 
         filePath!.toLowerCase().endsWith('.jpeg'));
    
    return _BaseModal(
      title: 'Certificat de formation',
      subtitle: 'Attestation officielle d\'obtention de diplôme.',
      children: [
        Center(
          child: Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: _kSlate50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kSlate200),
            ),
            child: fileExists && isImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(filePath!),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        print('Erreur lors du chargement de l\'image: $error');
                        print('Chemin du fichier: $filePath');
                        return _buildPlaceholder();
                      },
                    ),
                  )
                : _buildPlaceholder(),
          ),
        ),
        if (!fileExists && filePath != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Le fichier n\'est plus accessible',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.red),
              textAlign: TextAlign.center,
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

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.description_outlined, size: 64, color: _kViolet),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: _kSlate900),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          institution,
          style: GoogleFonts.inter(fontSize: 12, color: _kSlate700),
        ),
        if (fileName != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              fileName!,
              style: GoogleFonts.inter(fontSize: 10, color: _kSlate400),
              textAlign: TextAlign.center,
            ),
          ),
        ],
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
  final List<Widget> children;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const _BaseModal({
    required this.title,
    required this.subtitle,
    required this.children,
    this.onConfirm,
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
      child: SingleChildScrollView(
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
                          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)
                              .copyWith(color: _kSlate900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(fontSize: 12).copyWith(color: _kSlate700),
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
                onPressed: onConfirm ?? () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kViolet,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Text(
                  'Confirmer',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
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
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildLabel(String label, {IconData? icon}) {
  final style = GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600).copyWith(color: const Color(0xFF6B7280));

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

Widget _buildDateInputField(TextEditingController controller, {String? errorText}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          border: Border.all(
            color: errorText != null ? Colors.red : _kSlate200,
            width: errorText != null ? 1.5 : 1, // Bordure plus fine pour les erreurs
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.left,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _DateInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    hintText: 'jj / mm / aaaa',
                    hintStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF475569)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) {
                    // Validation en temps réel pourrait être ajoutée ici si nécessaire
                  },
                ),
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 14, color: _kSlate400),
          ],
        ),
      ),
      if (errorText != null) ...[
        const SizedBox(height: 4),
        Text(
          errorText,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ],
  );
}

Widget _buildUploadArea({String? fileName, required Future<void> Function() onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 81,
      decoration: BoxDecoration(
        color: _kSlate50.withOpacity(0.5),
        border: Border.all(color: _kSlate300, width: 1.5, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: fileName == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_upload_outlined, size: 20, color: _kSlate400),
                  const SizedBox(height: 4),
                  Text(
                    'Cliquer pour uploader',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: _kSlate700),
                  ),
                  Text(
                    'PNG, JPG, PDF up to 10MB',
                    style: GoogleFonts.inter(fontSize: 10, color: _kSlate400),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, size: 20, color: Colors.green),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      fileName,
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: _kSlate700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    ),
  );
}

Widget _buildSliderControl(double value, ValueChanged<double> onChanged, String levelLabel) {
  return Column(
    children: [
      SliderTheme(
        data: SliderThemeData(
          trackHeight: 8,
          activeTrackColor: _kViolet,
          inactiveTrackColor: _kSlate200,
          thumbColor: _kViolet,
          overlayColor: _kViolet.withOpacity(0.2),
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        ),
        child: Slider(
          value: value,
          onChanged: onChanged,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sliderLabel('DÉBUTANT', levelLabel == 'DÉBUTANT'),
            _sliderLabel('INTERMÉDIAIRE', levelLabel == 'INTERMÉDIAIRE'),
            _sliderLabel('AVANCÉ', levelLabel == 'AVANCÉ'),
            _sliderLabel('EXPERT', levelLabel == 'EXPERT'),
          ],
        ),
      ),
    ],
  );
}

Widget _sliderLabel(String text, bool isActive) {
  return Text(
    text,
    style: GoogleFonts.inter(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      color: isActive ? _kViolet : _kSlate400,
    ),
  );
}

Widget _buildSegmentedControl(int selectedIndex, ValueChanged<int> onChanged) {
  return Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        _segmentedTab('Beg', 0, selectedIndex, onChanged),
        _segmentedTab('Int', 1, selectedIndex, onChanged),
        _segmentedTab('Adv', 2, selectedIndex, onChanged),
        _segmentedTab('Exp', 3, selectedIndex, onChanged),
      ],
    ),
  );
}

Widget _segmentedTab(String label, int index, int selectedIndex, ValueChanged<int> onChanged) {
  final isSelected = index == selectedIndex;
  return Expanded(
    child: GestureDetector(
      onTap: () => onChanged(index),
      child: Container(
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [const BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? _kViolet : _kSlate500,
          ),
        ),
      ),
    ),
  );
}

Widget _buildLanguagePreviewCard(String language, String level) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: _kJobCardGray,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          language,
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: _kSlate900),
        ),
        const SizedBox(height: 4),
        Text(
          level,
          style: GoogleFonts.inter(fontSize: 12, color: _kSlate700),
        ),
      ],
    ),
  );
}

// Formatter pour les dates (JJ/MM/AAAA)
class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    final buffer = StringBuffer();
    int selectionIndex = newValue.selection.end;

    for (int i = 0; i < text.length && i < 8; i++) {
      buffer.write(text[i]);
      if ((i == 1 || i == 3) && i < text.length - 1) {
        buffer.write(' / ');
        if (i < selectionIndex) selectionIndex += 3;
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex.clamp(0, formatted.length)),
    );
  }
}

// Validateur de dates
bool _isValidDate(String dateStr) {
  if (dateStr.isEmpty) return true; // Les dates vides sont autorisées
  
  final parts = dateStr.split(' / ');
  if (parts.length != 3) return false;
  
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  
  if (day == null || month == null || year == null) return false;
  if (day < 1 || day > 31) return false;
  if (month < 1 || month > 12) return false;
  if (year < 1950 || year > DateTime.now().year + 1) return false;
  
  // Vérification plus précise des jours selon le mois
  final daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  if (month == 2 && _isLeapYear(year)) {
    if (day > 29) return false;
  } else if (day > daysInMonth[month - 1]) {
    return false;
  }
  
  return true;
}

bool _isLeapYear(int year) {
  return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
}

// ══════════════════════════════════════════════════════════════════
// Overlays de sélection pour sociétés et établissements
// ══════════════════════════════════════════════════════════════════

class _CompanySelectorOverlay extends StatefulWidget {
  final List<String> companies;
  final Function(String) onCompanySelected;

  const _CompanySelectorOverlay({
    required this.companies,
    required this.onCompanySelected,
  });

  @override
  State<_CompanySelectorOverlay> createState() => _CompanySelectorOverlayState();
}

class _CompanySelectorOverlayState extends State<_CompanySelectorOverlay> {
  String? _selectedCompany;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
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
                          'Choisir une société',
                          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)
                              .copyWith(color: _kSlate900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sélectionnez votre entreprise ou ajoutez-en une nouvelle.',
                          style: GoogleFonts.inter(fontSize: 12).copyWith(color: _kSlate700),
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
              
              // Label pour saisie manuelle
              _buildLabel('Rechercher ou saisir le nom de la société'),
              
              // Barre de recherche
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: _kSlate50,
                  border: Border.all(color: _kSlate200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 16, color: _kSlate400),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Rechercher une société...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: _kSlate400,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: _kSlate900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Saisie directe du nom de société
              _buildLabel('Nom de la société'),
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: _kSlate50,
                  border: Border.all(color: _kSlate200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _customController,
                  decoration: InputDecoration(
                    hintText: 'Ex: Sonatrach, Cevital, Air Algérie...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: _kSlate400,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: _kSlate900,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedCompany = value.isNotEmpty ? value : null;
                    });
                  },
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Bouton Confirmer
              ElevatedButton(
                onPressed: _selectedCompany != null ? () {
                  widget.onCompanySelected(_selectedCompany!);
                  Navigator.pop(context);
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kViolet,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Text(
                  'Confirmer',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstitutionSelectorOverlay extends StatefulWidget {
  final List<String> institutions;
  final Function(String) onInstitutionSelected;

  const _InstitutionSelectorOverlay({
    required this.institutions,
    required this.onInstitutionSelected,
  });

  @override
  State<_InstitutionSelectorOverlay> createState() => _InstitutionSelectorOverlayState();
}

class _InstitutionSelectorOverlayState extends State<_InstitutionSelectorOverlay> {
  String? _selectedInstitution;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
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
                          'Choisir un établissement',
                          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)
                              .copyWith(color: _kSlate900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sélectionnez votre école ou ajoutez-en une nouvelle.',
                          style: GoogleFonts.inter(fontSize: 12).copyWith(color: _kSlate700),
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
              
              // Label pour saisie manuelle
              _buildLabel('Rechercher ou saisir le nom de l\'établissement'),
              
              // Barre de recherche
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: _kSlate50,
                  border: Border.all(color: _kSlate200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 16, color: _kSlate400),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Rechercher un établissement...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: _kSlate400,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: _kSlate900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Saisie directe du nom d'établissement
              _buildLabel('Nom de l\'établissement'),
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: _kSlate50,
                  border: Border.all(color: _kSlate200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _customController,
                  decoration: InputDecoration(
                    hintText: 'Ex: Université d\'Alger, École Polytechnique...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: _kSlate400,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: _kSlate900,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedInstitution = value.isNotEmpty ? value : null;
                    });
                  },
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Bouton Confirmer
              ElevatedButton(
                onPressed: _selectedInstitution != null ? () {
                  widget.onInstitutionSelected(_selectedInstitution!);
                  Navigator.pop(context);
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kViolet,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Text(
                  'Confirmer',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
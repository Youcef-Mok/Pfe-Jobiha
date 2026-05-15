import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers/jobs_provider.dart';
import '../domain/job_entity.dart';
import '../../../core/theme/app_theme.dart';

class CreateJobScreen extends ConsumerStatefulWidget {
  const CreateJobScreen({super.key});

  @override
  ConsumerState<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends ConsumerState<CreateJobScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _candidatesCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _candidatesCtrl.dispose();
    _salaryCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final submitStatus = ref.watch(submitStatusProvider);
    final isLoading = submitStatus == SubmitStatus.loading;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCFE),
      body: SafeArea(
        child: Column(
          children: [
            _TopAppBar(onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollCtrl,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section title
                    Text("Détails de l'opportunité",
                        style: AppTextStyles.sectionTitle),
                    const SizedBox(height: 16),

                    // Titre du poste
                    _FieldWrapper(
                      label: 'Titre du poste / Objet',
                      child: _TextInput(
                        controller: _titleCtrl,
                        hint: 'ex: Développeur Fullstack Senior',
                        onChanged: (v) =>
                            ref.read(createJobFormProvider.notifier).updateTitle(v),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Type de contrat
                    _ContractTypeSegment(),
                    const SizedBox(height: 16),

                    // Description
                    _FieldWrapper(
                      label: 'Description du poste',
                      child: _TextAreaInput(
                        controller: _descCtrl,
                        hint: 'Décrivez les missions, le profil recherché...',
                        onChanged: (v) => ref
                            .read(createJobFormProvider.notifier)
                            .updateDescription(v),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Candidats recherchés
                    _FieldWrapper(
                      label: 'Candidats recherchés',
                      child: _TextInput(
                        controller: _candidatesCtrl,
                        hint: 'ex: 3',
                        keyboardType: TextInputType.number,
                        suffixIcon: const Icon(Icons.people_outline,
                            size: 22, color: AppColors.slate400),
                        onChanged: (v) {
                          final n = int.tryParse(v);
                          ref
                              .read(createJobFormProvider.notifier)
                              .updateCandidateCount(n);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Horaires
                    _HoraireRow(),
                    const SizedBox(height: 16),

                    // Date de début
                    _DateField(),
                    const SizedBox(height: 16),

                    // Salaire (optionnel)
                    _FieldWrapper(
                      label: 'Salaire',
                      isOptional: true,
                      child: _TextInput(
                        controller: _salaryCtrl,
                        hint: 'ex: 45 000',
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        suffix: Text('€',
                            style: AppTextStyles.inputValue
                                .copyWith(color: AppColors.slate400)),
                        onChanged: (v) {
                          final d = double.tryParse(v.replaceAll(' ', ''));
                          ref
                              .read(createJobFormProvider.notifier)
                              .updateSalary(d);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Image upload (optionnel)
                    _ImageUploadField(),

                    // Espace pour le footer
                    const SizedBox(height: 148),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Footer flottant
      bottomSheet: _ActionFooter(
        isLoading: isLoading,
        onSaveDraft: () => _handleSaveDraft(context),
        onPublish: () => _handlePublish(context),
      ),
    );
  }

  Future<void> _handleSaveDraft(BuildContext context) async {
    ref.read(submitStatusProvider.notifier).state = SubmitStatus.loading;
    final job =
        await ref.read(createJobFormProvider.notifier).saveDraft();
    if (!mounted) return;
    ref.read(submitStatusProvider.notifier).state =
        job != null ? SubmitStatus.success : SubmitStatus.error;

    if (job != null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Brouillon sauvegardé ✓'),
        backgroundColor: AppColors.violet,
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.of(context).pop();
    }
  }

  Future<void> _handlePublish(BuildContext context) async {
    final form = ref.read(createJobFormProvider);
    if (!form.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Veuillez renseigner le titre du poste'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    ref.read(submitStatusProvider.notifier).state = SubmitStatus.loading;
    final job =
        await ref.read(createJobFormProvider.notifier).publish();
    if (!mounted) return;
    ref.read(submitStatusProvider.notifier).state =
        job != null ? SubmitStatus.success : SubmitStatus.error;

    if (job != null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Annonce publiée avec succès 🚀"),
        backgroundColor: AppColors.violet,
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.of(context).pop();
    }
  }
}

// ─────────────────────────────────────────────
// Top App Bar
// ─────────────────────────────────────────────
class _TopAppBar extends StatelessWidget {
  final VoidCallback onBack;
  const _TopAppBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 41,
      decoration: const BoxDecoration(
        color: Color(0xCCFDFCFE),
        border: Border(
          bottom: BorderSide(color: Color(0x1A8B5CF6)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 16, color: AppColors.slate900),
            onPressed: onBack,
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 48),
                child: Text('Créer une annonce',
                    style: AppTextStyles.heading2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Field Wrapper (label + child)
// ─────────────────────────────────────────────
class _FieldWrapper extends StatelessWidget {
  final String label;
  final Widget child;
  final bool isOptional;

  const _FieldWrapper({
    required this.label,
    required this.child,
    this.isOptional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTextStyles.fieldLabel),
            if (isOptional) ...[
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    Text('OPTIONNEL', style: AppTextStyles.optionalBadge),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Text Input
// ─────────────────────────────────────────────
class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;

  const _TextInput({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.suffixIcon,
    this.suffix,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppTextStyles.inputValue,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.inputText,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 17.5),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
          suffix: suffix,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Textarea Input
// ─────────────────────────────────────────────
class _TextAreaInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  const _TextAreaInput({
    required this.controller,
    required this.hint,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 130),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: TextField(
        controller: controller,
        maxLines: null,
        minLines: 4,
        keyboardType: TextInputType.multiline,
        style: AppTextStyles.inputValue,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.inputText,
          contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 64),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Contract Type Segment Control
// ─────────────────────────────────────────────
class _ContractTypeSegment extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
        createJobFormProvider.select((f) => f.contractType));

    const options = [
      (ContractType.cdi, 'CDI'),
      (ContractType.mission, 'Mission'),
      (ContractType.freelance, 'Freelance'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Type de contrat', style: AppTextStyles.fieldLabel),
        const SizedBox(height: 8),
        Container(
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.slate100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: options.map((opt) {
              final (value, label) = opt;
              final isActive = selected == value;
              return Expanded(
                child: GestureDetector(
                  onTap: () => ref
                      .read(createJobFormProvider.notifier)
                      .updateContractType(value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.surface : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isActive
                          ? [
                              const BoxShadow(
                                color: Color(0x0D000000),
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: isActive
                            ? AppTextStyles.segmentActive
                            : AppTextStyles.segmentInactive,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Horaire Row (début + fin)
// ─────────────────────────────────────────────
class _HoraireRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(createJobFormProvider);

    return Row(
      children: [
        Expanded(
          child: _TimeField(
            label: 'Heure de début',
            time: form.startTime,
            onTap: () async {
              final t = await showTimePicker(
                context: context,
                initialTime: form.startTime ?? const TimeOfDay(hour: 9, minute: 0),
                builder: (ctx, child) => _timePickerTheme(ctx, child),
              );
              if (t != null) {
                ref.read(createJobFormProvider.notifier).updateStartTime(t);
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _TimeField(
            label: 'Heure de fin',
            time: form.endTime,
            onTap: () async {
              final t = await showTimePicker(
                context: context,
                initialTime: form.endTime ?? const TimeOfDay(hour: 18, minute: 0),
                builder: (ctx, child) => _timePickerTheme(ctx, child),
              );
              if (t != null) {
                ref.read(createJobFormProvider.notifier).updateEndTime(t);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _timePickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(primary: AppColors.violet),
      ),
      child: child!,
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;

  const _TimeField({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final display = time != null ? time!.format(context) : '--:-- --';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.fieldLabel),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: AppColors.inputBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(display,
                    style: time != null
                        ? AppTextStyles.inputValue
                        : AppTextStyles.inputText),
                const Icon(Icons.access_time_outlined,
                    size: 18, color: AppColors.slate400),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Date Field
// ─────────────────────────────────────────────
class _DateField extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date =
        ref.watch(createJobFormProvider.select((f) => f.startDate));

    final display = date != null
        ? '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}'
        : 'mm/jj/aaaa';

    return _FieldWrapper(
      label: 'Date de début prévue',
      child: GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: date ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
            builder: (ctx, child) => Theme(
              data: Theme.of(ctx).copyWith(
                colorScheme: const ColorScheme.light(primary: AppColors.violet),
              ),
              child: child!,
            ),
          );
          if (picked != null) {
            ref.read(createJobFormProvider.notifier).updateStartDate(picked);
          }
        },
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14.5),
          decoration: BoxDecoration(
            color: AppColors.inputBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(display,
                  style: date != null
                      ? AppTextStyles.inputValue
                      : AppTextStyles.inputText),
              const Icon(Icons.calendar_today_outlined,
                  size: 18, color: AppColors.slate400),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Image Upload Field
// ─────────────────────────────────────────────
class _ImageUploadField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("Photo de l'annonce", style: AppTextStyles.fieldLabel),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.slate100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('OPTIONNEL', style: AppTextStyles.optionalBadge),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            // TODO: implémenter le sélecteur d'image (image_picker)
          },
          child: Container(
            height: 168,
            decoration: BoxDecoration(
              color: AppColors.uploadBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.uploadBorder,
                  width: 2,
                  style: BorderStyle.solid),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.uploadIconBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cloud_upload_outlined,
                      size: 22, color: AppColors.violet),
                ),
                const SizedBox(height: 12),
                Text(
                  'Cliquez pour télécharger',
                  style: AppTextStyles.fieldLabel,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'PNG, JPG, GIF jusqu\'à 10 MB',
                  style: AppTextStyles.captionLight,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Action Footer
// ─────────────────────────────────────────────
class _ActionFooter extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onSaveDraft;
  final VoidCallback onPublish;

  const _ActionFooter({
    required this.isLoading,
    required this.onSaveDraft,
    required this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 129,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: Color(0x1A8B5CF6)),
        ),
      ),
      child: Row(
        children: [
          // Sauvegarder brouillon
          Expanded(
            flex: 146,
            child: SizedBox(
              height: 80,
              child: OutlinedButton(
                onPressed: isLoading ? null : onSaveDraft,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.inputBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text('Sauvegarder', style: AppTextStyles.saveDraftBtn),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Publier l'annonce
          Expanded(
            flex: 179,
            child: SizedBox(
              height: 80,
              child: Stack(
                children: [
                  // Shadow décorative violet
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x4D8B5CF6),
                            blurRadius: 15,
                            offset: Offset(0, 10),
                            spreadRadius: -3,
                          ),
                          BoxShadow(
                            color: Color(0x4D8B5CF6),
                            blurRadius: 6,
                            offset: Offset(0, 4),
                            spreadRadius: -4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isLoading ? null : onPublish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.violet,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 80),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Publier\nl'annonce",
                                  style: AppTextStyles.publishBtn,
                                  textAlign: TextAlign.center),
                              const SizedBox(width: 8),
                              const Icon(Icons.send_outlined,
                                  size: 14, color: Colors.white),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
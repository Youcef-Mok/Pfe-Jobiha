import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:job_app/features/jobs/data/providers/jobs_provider.dart';
import 'package:job_app/features/jobs/domain/job_entity.dart';
import 'package:job_app/features/jobs/widgets/job_candidate_preferences_fields.dart';
import 'package:job_app/core/theme/app_theme.dart';


class EditJobScreen extends ConsumerStatefulWidget {
  final JobEntity job;
  const EditJobScreen({super.key, required this.job});

  @override
  ConsumerState<EditJobScreen> createState() => _EditJobScreenState();
}

class _EditJobScreenState extends ConsumerState<EditJobScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _candidatesCtrl;
  late final TextEditingController _salaryCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.job.title);
    _descCtrl = TextEditingController();
    _candidatesCtrl = TextEditingController(
        text: widget.job.candidateCount > 0
            ? widget.job.candidateCount.toString()
            : '');
    _salaryCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _candidatesCtrl.dispose();
    _salaryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(editJobFormProvider(widget.job));
    final notifier = ref.read(editJobFormProvider(widget.job).notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _EditHeader(
              isPrivate: form.isPrivate,
              onBack: () => Navigator.of(context).pop(),
              onTogglePrivate: notifier.togglePrivate,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cover image
                    _CoverImageSection(imageAsset: form.imageAsset),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Titre
                          _EditFieldWrapper(
                            label: 'Poste / Objet',
                            child: _EditTextInput(
                              controller: _titleCtrl,
                              onChanged: notifier.updateTitle,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Type de contrat — pill style
                          _EditFieldWrapper(
                            label: 'Type de contrat',
                            child: _ContractPills(
                              selected: form.contractType,
                              onSelect: notifier.updateContractType,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Description
                          _EditFieldWrapper(
                            label: 'Description du poste',
                            child: _EditTextArea(
                              controller: _descCtrl,
                              onChanged: notifier.updateDescription,
                            ),
                          ),
                          const SizedBox(height: 24),

                          JobCandidatePreferencesFields(
                            sectionTitleStyle: AppTextStyles.sectionTitle
                                .copyWith(fontSize: 20),
                          ),
                          const SizedBox(height: 24),

                          // Candidats + Salaire en grid
                          Row(
                            children: [
                              Expanded(
                                child: _EditFieldWrapper(
                                  label: 'Candidats requis',
                                  child: _EditTextInput(
                                    controller: _candidatesCtrl,
                                    keyboardType: TextInputType.number,
                                    onChanged: (v) => notifier
                                        .updateCandidateCount(int.tryParse(v)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _EditFieldWrapper(
                                  label: 'Salaire annuel (€)',
                                  child: _EditTextInput(
                                    controller: _salaryCtrl,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    onChanged: (v) => notifier.updateSalary(
                                        double.tryParse(
                                            v.replaceAll(' ', ''))),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Séparateur
                          const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                          const SizedBox(height: 16),

                          // Date de début
                          _EditFieldWrapper(
                            label: 'Date de début prévue',
                            child: _EditDateInput(
                              date: form.startDate,
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      form.startDate ?? DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 730)),
                                  builder: (ctx, child) => Theme(
                                    data: Theme.of(ctx).copyWith(
                                      colorScheme: const ColorScheme.light(
                                          primary: AppColors.violet),
                                    ),
                                    child: child!,
                                  ),
                                );
                                if (picked != null) {
                                  notifier.updateStartDate(picked);
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Horaires
                          Row(
                            children: [
                              Expanded(
                                child: _EditFieldWrapper(
                                  label: 'Heure de début',
                                  child: _EditTimeInput(
                                    time: form.startTime,
                                    onTap: () async {
                                      final t = await showTimePicker(
                                        context: context,
                                        initialTime: form.startTime ??
                                            const TimeOfDay(hour: 9, minute: 0),
                                        builder: (ctx, child) => Theme(
                                          data: Theme.of(ctx).copyWith(
                                            colorScheme: const ColorScheme.light(
                                                primary: AppColors.violet),
                                          ),
                                          child: child!,
                                        ),
                                      );
                                      if (t != null) notifier.updateStartTime(t);
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _EditFieldWrapper(
                                  label: 'Heure de fin',
                                  child: _EditTimeInput(
                                    time: form.endTime,
                                    onTap: () async {
                                      final t = await showTimePicker(
                                        context: context,
                                        initialTime: form.endTime ??
                                            const TimeOfDay(hour: 18, minute: 0),
                                        builder: (ctx, child) => Theme(
                                          data: Theme.of(ctx).copyWith(
                                            colorScheme: const ColorScheme.light(
                                                primary: AppColors.violet),
                                          ),
                                          child: child!,
                                        ),
                                      );
                                      if (t != null) notifier.updateEndTime(t);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _EditFooter(
        isLoading: _isLoading,
        onSave: () => _handleSave(context),
        onDelete: () => _handleDelete(context),
      ),
    );
  }

  Future<void> _handleSave(BuildContext context) async {
    setState(() => _isLoading = true);
    final job =
        await ref.read(editJobFormProvider(widget.job).notifier).save();
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (job != null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Annonce mise à jour ✓'),
        backgroundColor: AppColors.violet,
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer l\'annonce ?',
            style: TextStyle(fontFamily: 'PublicSans', fontWeight: FontWeight.w700)),
        content: const Text('Cette action est irréversible.',
            style: TextStyle(fontFamily: 'PublicSans')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler',
                style: TextStyle(color: AppColors.slate600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer',
                style: TextStyle(color: Color(0xFFDC2626))),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    await ref.read(editJobFormProvider(widget.job).notifier).delete();
    if (!mounted) return;
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }
}

// ─────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────
class _EditHeader extends StatelessWidget {
  final bool isPrivate;
  final VoidCallback onBack;
  final VoidCallback onTogglePrivate;

  const _EditHeader({
    required this.isPrivate,
    required this.onBack,
    required this.onTogglePrivate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xCCFFFFFF),
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          // Back
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 32,
              height: 32,
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 16, color: AppColors.slate900),
            ),
          ),
          const SizedBox(width: 16),
          // Title
          Expanded(
            child: Text('Modifier l\'annonce',
                style: AppTextStyles.sectionTitle),
          ),
          // PRIVÉ label + toggle
          Row(
            children: [
              Text(
                'PRIVÉ',
                style: const TextStyle(
                  fontFamily: 'PublicSans',
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 0.6,
                  color: AppColors.slate600,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onTogglePrivate,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 24,
                  padding: EdgeInsets.only(
                      left: isPrivate ? 4 : 24, right: isPrivate ? 24 : 4),
                  decoration: BoxDecoration(
                    color: isPrivate
                        ? const Color(0x336B21A8)
                        : AppColors.slate200,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Center(
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: isPrivate
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: isPrivate ? AppColors.violet : AppColors.slate400,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Cover Image Section
// ─────────────────────────────────────────────
class _CoverImageSection extends StatelessWidget {
  final String? imageAsset;
  const _CoverImageSection({this.imageAsset});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image de couverture
        Container(
          width: double.infinity,
          height: 179,
          color: const Color(0xFFE2E8F0),
          child: imageAsset != null
              ? Image.asset(imageAsset!, fit: BoxFit.cover)
              : const Center(
                  child: Icon(Icons.image_outlined,
                      size: 40, color: AppColors.slate400),
                ),
        ),
        // Bouton modifier photo (centré)
        Positioned.fill(
          child: Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 15,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.edit_outlined,
                      size: 14, color: AppColors.violet),
                  const SizedBox(width: 8),
                  const Text(
                    'Modifier la photo',
                    style: TextStyle(
                      fontFamily: 'PublicSans',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.violet,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Bouton crayon (coin haut-droit)
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            width: 26.5,
            height: 26.5,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.edit_outlined,
                size: 12, color: AppColors.violet),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Field Wrapper
// ─────────────────────────────────────────────
class _EditFieldWrapper extends StatelessWidget {
  final String label;
  final Widget child;
  const _EditFieldWrapper({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: const Color(0xFF334155).withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                  fontFamily: 'PublicSans',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF334155),
                )),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Text Input (style édition — border #E2E8F0)
// ─────────────────────────────────────────────
class _EditTextInput extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const _EditTextInput({
    required this.controller,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppTextStyles.inputValue,
        onChanged: onChanged,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Text Area
// ─────────────────────────────────────────────
class _EditTextArea extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const _EditTextArea({required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 146),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        maxLines: null,
        minLines: 5,
        style: AppTextStyles.inputValue,
        onChanged: onChanged,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Contract Pill Selector (style pill, différent du create)
// ─────────────────────────────────────────────
class _ContractPills extends StatelessWidget {
  final ContractType selected;
  final ValueChanged<ContractType> onSelect;

  const _ContractPills({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final options = [
      (ContractType.cdi, 'CDI'),
      (ContractType.mission, 'Mission'),
      (ContractType.freelance, 'Freelance'),
    ];


    return Row(
      children: options.map((opt) {
        final (value, label) = opt;
        final isActive = selected == value;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onSelect(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
              decoration: BoxDecoration(
                color: isActive ? AppColors.violet : Colors.transparent,
                borderRadius: BorderRadius.circular(9999),
                border: isActive
                    ? null
                    : Border.all(color: const Color(0xFFE2E8F0)),
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
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'PublicSans',
                  fontWeight:
                      isActive ? FontWeight.w500 : FontWeight.w400,
                  fontSize: 16,
                  color: isActive ? Colors.white : AppColors.slate900,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────
// Date Input
// ─────────────────────────────────────────────
class _EditDateInput extends StatelessWidget {
  final DateTime? date;
  final VoidCallback onTap;

  const _EditDateInput({this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final display = date != null
        ? '${date!.month.toString().padLeft(2, '0')}/${date!.day.toString().padLeft(2, '0')}/${date!.year}'
        : 'mm/jj/aaaa';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.fromLTRB(44, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(display,
                  style: date != null
                      ? AppTextStyles.inputValue
                      : AppTextStyles.inputText),
            ),
            const Icon(Icons.calendar_today_outlined,
                size: 18, color: AppColors.slate400),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Time Input
// ─────────────────────────────────────────────
class _EditTimeInput extends StatelessWidget {
  final TimeOfDay? time;
  final VoidCallback onTap;

  const _EditTimeInput({this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final display = time != null ? time!.format(context) : '--:-- --';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(display,
                style: time != null
                    ? AppTextStyles.inputValue
                    : AppTextStyles.inputText),
            const Icon(Icons.access_time_outlined,
                size: 16, color: AppColors.slate400),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Footer
// ─────────────────────────────────────────────
class _EditFooter extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  const _EditFooter({
    required this.isLoading,
    required this.onSave,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          // Sauvegarder
          SizedBox(
            width: 179,
            height: 64,
            child: Stack(
              children: [
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
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.violet,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 64),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text('Sauvegarder',
                                style: TextStyle(
                                  fontFamily: 'PublicSans',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.white,
                                )),
                            SizedBox(width: 8),
                            Icon(Icons.send_outlined,
                                size: 12, color: Colors.white),
                          ],
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          // Supprimer
          Expanded(
            child: SizedBox(
              height: 64,
              child: OutlinedButton(
                onPressed: isLoading ? null : onDelete,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.inputBorder),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.delete_outline,
                        size: 16, color: Color(0xFFDC2626)),
                    SizedBox(width: 8),
                    Text('Supprimer',
                        style: TextStyle(
                          fontFamily: 'PublicSans',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFFDC2626),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


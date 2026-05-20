import 'package:flutter/material.dart';

import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/jobs/data/cv_preferences_catalog.dart';

/// Préférences annonce : mêmes jeux de valeurs que le CV candidat (listes, pas de texte libre).
class JobCandidatePreferencesFields extends StatelessWidget {
  final TextStyle? sectionTitleStyle;

  const JobCandidatePreferencesFields({super.key, this.sectionTitleStyle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Préférences candidat',
          style: sectionTitleStyle ?? AppTextStyles.sectionTitle,
        ),
        const SizedBox(height: 12),
        _OptionalDropdownField(
          label: 'Emplacement souhaité',
          hint: 'Choisir (optionnel)',
          items: kJobPreferredLocations,
        ),
        const SizedBox(height: 12),
        _OptionalDropdownField(
          label: 'Langue',
          hint: 'Choisir (optionnel)',
          items: kCvLanguageNames,
        ),
        const SizedBox(height: 12),
        _OptionalDropdownField(
          label: 'Niveau de langue',
          hint: 'Choisir (optionnel)',
          items: kCvLanguageLevels,
        ),
        const SizedBox(height: 12),
        _OptionalDropdownField(
          label: 'Compétence clé',
          hint: 'Choisir (optionnel)',
          items: kCvSkillTitles,
        ),
        const SizedBox(height: 12),
        _OptionalDropdownField(
          label: 'Niveau de compétence',
          hint: 'Choisir (optionnel)',
          items: kCvSkillLevelLabels,
        ),
        const SizedBox(height: 12),
        _OptionalDropdownField(
          label: 'Formation minimale',
          hint: 'Choisir (optionnel)',
          items: kCvFormationTitles,
        ),
        const SizedBox(height: 12),
        _OptionalDropdownField(
          label: 'Expérience requise',
          hint: 'Choisir (optionnel)',
          items: kJobExperienceRequiredOptions,
        ),
      ],
    );
  }
}

class _OptionalDropdownField extends StatefulWidget {
  final String label;
  final String hint;
  final List<String> items;

  const _OptionalDropdownField({
    required this.label,
    required this.hint,
    required this.items,
  });

  @override
  State<_OptionalDropdownField> createState() => _OptionalDropdownFieldState();
}

class _OptionalDropdownFieldState extends State<_OptionalDropdownField> {
  String? _value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(widget.label, style: AppTextStyles.fieldLabel),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.slate100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('OPTIONNEL', style: AppTextStyles.optionalBadge),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.inputBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _value,
              hint: Text(widget.hint, style: AppTextStyles.inputText),
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.slate400),
              dropdownColor: Colors.white,
              style: AppTextStyles.inputValue,
              items: widget.items
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(
                        e,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _value = v),
            ),
          ),
        ),
      ],
    );
  }
}

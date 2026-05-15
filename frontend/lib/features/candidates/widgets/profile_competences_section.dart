import 'package:flutter/material.dart';
import 'package:job_app/features/candidates/domain/skill_entity.dart';

class ProfileCompetencesSection extends StatelessWidget {
  final List<SkillGroupEntity> skillGroups;
  final List<LanguageEntity> languages;
  final List<String> tools;

  const ProfileCompetencesSection({
    super.key,
    required this.skillGroups,
    required this.languages,
    required this.tools,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in skillGroups) ...[
          _buildSkillCard(group),
          const SizedBox(height: 16),
        ],
        if (languages.isNotEmpty) ...[
          _buildLanguagesCard(),
          const SizedBox(height: 16),
        ],
        if (tools.isNotEmpty) _buildToolsCard(),
      ],
    );
  }

  Widget _buildSkillCard(SkillGroupEntity group) {
    return _SectionCard(
      title: group.title,
      child: Column(
        children: [
          for (int i = 0; i < group.skills.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEBF4)),
            _SkillRow(skill: group.skills[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildLanguagesCard() {
    return _SectionCard(
      title: 'Langues',
      child: Column(
        children: [
          for (int i = 0; i < languages.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEBF4)),
            _LanguageRow(language: languages[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildToolsCard() {
    return _SectionCard(
      title: 'Outils & Logiciels',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: tools.map((tool) => _ToolChip(label: tool)).toList(),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF0B1C30),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  final SkillEntity skill;

  const _SkillRow({required this.skill});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              skill.name,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xFF1B1B1B),
              ),
            ),
          ),
          Row(
            children: List.generate(5, (i) {
              final filled = i < skill.levelValue;
              return Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled
                        ? const Color(0xFF401E66)
                        : const Color(0xFFEEEBF4),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 88,
            child: Text(
              skill.levelLabel,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  final LanguageEntity language;

  const _LanguageRow({required this.language});

  @override
  Widget build(BuildContext context) {
    final isNatif = language.proficiency == 'Natif';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              language.name,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xFF1B1B1B),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isNatif
                  ? const Color(0xFF401E66)
                  : const Color(0xFFEEEBF4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              language.proficiency,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: isNatif ? Colors.white : const Color(0xFF4B444F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  final String label;

  const _ToolChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F0FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEBF4), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          fontSize: 13,
          color: Color(0xFF401E66),
        ),
      ),
    );
  }
}

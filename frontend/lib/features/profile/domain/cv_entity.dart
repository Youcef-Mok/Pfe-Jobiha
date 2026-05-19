/// Entité pour une formation académique dans le CV
class CvFormationEntity {
  final String title;
  final String institution;
  final String location;
  final int year;
  final bool isActive; // true → point violet, false → point gris

  const CvFormationEntity({
    required this.title,
    required this.institution,
    required this.location,
    required this.year,
    this.isActive = false,
  });
}

/// Entité pour une expérience professionnelle dans le CV
class CvExperienceEntity {
  final String title;
  final String company;
  final String location;
  final String? period; // ex: "Sep 2021 - Aug 2023"
  final String? endDate; // ex: "Aug 2021" (affiché à droite si app mission)
  final bool isAppMission;
  final bool isActive; // true → point violet, false → point gris

  const CvExperienceEntity({
    required this.title,
    required this.company,
    required this.location,
    this.period,
    this.endDate,
    this.isAppMission = false,
    this.isActive = false,
  });
}

/// Entité pour une langue dans le CV
class CvLanguageEntity {
  final String name;
  final String level; // ex: "Courant (C1)"

  const CvLanguageEntity({
    required this.name,
    required this.level,
  });
}

/// Entité pour un skill dans le CV
class CvSkillEntity {
  final String name;
  final String? levelLabel; // "Expert" | "Avancé" | null
  final double progress; // 0.0 à 1.0

  const CvSkillEntity({
    required this.name,
    this.levelLabel,
    required this.progress,
  });
}

/// Entité regroupant toutes les données CV
class CvEntity {
  final List<CvFormationEntity> formations;
  final List<CvExperienceEntity> experiences;
  final List<CvLanguageEntity> languages;
  final List<CvSkillEntity> skills;

  const CvEntity({
    required this.formations,
    required this.experiences,
    required this.languages,
    required this.skills,
  });
}

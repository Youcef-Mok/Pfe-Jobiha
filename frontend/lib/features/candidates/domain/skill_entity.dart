enum SkillLevel { debutant, intermediaire, avance, expert }

class SkillEntity {
  final String name;
  final SkillLevel level;

  const SkillEntity({required this.name, required this.level});

  int get levelValue {
    switch (level) {
      case SkillLevel.debutant:
        return 1;
      case SkillLevel.intermediaire:
        return 3;
      case SkillLevel.avance:
        return 4;
      case SkillLevel.expert:
        return 5;
    }
  }

  String get levelLabel {
    switch (level) {
      case SkillLevel.debutant:
        return 'Débutant';
      case SkillLevel.intermediaire:
        return 'Intermédiaire';
      case SkillLevel.avance:
        return 'Avancé';
      case SkillLevel.expert:
        return 'Expert';
    }
  }
}

class LanguageEntity {
  final String name;
  final String proficiency;

  const LanguageEntity({required this.name, required this.proficiency});
}

class SkillGroupEntity {
  final String title;
  final List<SkillEntity> skills;

  const SkillGroupEntity({required this.title, required this.skills});
}

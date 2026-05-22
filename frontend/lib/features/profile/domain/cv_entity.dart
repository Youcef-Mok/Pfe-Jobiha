import 'dart:typed_data';

/// Entite pour une formation academique dans le CV
class CvFormationEntity {
  final String title;
  final String institution;
  final String location;
  final int year;
  final bool isActive;
  final String? fileName;
  final String? filePath;
  final Uint8List? fileBytes;
  final String? fileMimeType;

  const CvFormationEntity({
    required this.title,
    required this.institution,
    required this.location,
    required this.year,
    this.isActive = false,
    this.fileName,
    this.filePath,
    this.fileBytes,
    this.fileMimeType,
  });
}

/// Entite pour une experience professionnelle dans le CV
class CvExperienceEntity {
  final String title;
  final String company;
  final String location;
  final String? period;
  final String? endDate;
  final bool isAppMission;
  final bool isActive;
  final String? missionId;
  final String? status;
  final String? startDate;
  final String? candidateName;
  final String? recruiterName;
  final double recruiterRating;
  final double candidateRating;
  final String? recruiterFeedback;
  final String? candidateFeedback;
  final String? description;
  final String? imageUrl;

  const CvExperienceEntity({
    required this.title,
    required this.company,
    required this.location,
    this.period,
    this.endDate,
    this.isAppMission = false,
    this.isActive = false,
    this.missionId,
    this.status,
    this.startDate,
    this.candidateName,
    this.recruiterName,
    this.recruiterRating = 0.0,
    this.candidateRating = 0.0,
    this.recruiterFeedback,
    this.candidateFeedback,
    this.description,
    this.imageUrl,
  });
}

/// Entite pour une langue dans le CV
class CvLanguageEntity {
  final String name;
  final String level;

  const CvLanguageEntity({
    required this.name,
    required this.level,
  });
}

/// Entite pour un skill dans le CV
class CvSkillEntity {
  final String name;
  final String? levelLabel;
  final double progress;

  const CvSkillEntity({
    required this.name,
    this.levelLabel,
    required this.progress,
  });
}

/// Entite regroupant toutes les donnees CV
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

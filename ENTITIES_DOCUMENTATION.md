# 📋 DOCUMENTATION COMPLÈTE DES ENTITÉS

## Vue d'ensemble
Cette documentation liste toutes les entités métier (domain entities) de l'application de plateforme d'emploi.

---

## 1. ENTITÉS JOBS (Offres d'emploi)

### 1.1 JobEntity
**Fichier**: `frontend/lib/features/jobs/domain/job_entity.dart`

Représente une offre d'emploi publiée par un recruteur.

**Attributs**:
- `id: String` - Identifiant unique
- `title: String` - Titre du poste (ex: "Chef de Produit")
- `companyName: String` - Nom de l'entreprise
- `contractType: ContractType` - Type de contrat (CDI, Mission, Freelance)
- `postedAt: DateTime` - Date de publication
- `status: JobStatus` - Statut (draft, searching, closed)
- `candidateCount: int` - Nombre de candidats
- `viewCount: int` - Nombre de vues
- `logoAsset: String?` - URL du logo/image
- `isPublished: bool` - Si l'offre est publiée
- `candidates: List<JobCandidateEntity>` - Liste des candidats
- `comments: List<JobCommentEntity>` - Liste des commentaires

**Enums**:
- `JobStatus`: draft, closed, searching
- `ContractType`: cdi, mission, freelance

---

### 1.2 JobCandidateEntity
**Fichier**: `frontend/lib/features/jobs/domain/job_entity.dart`

Représente un candidat pour une offre d'emploi.

**Attributs**:
- `initials: String` - Initiales du candidat
- `name: String` - Nom complet
- `role: String` - Poste/rôle
- `rating: double` - Note (0-5)
- `avatarUrl: String?` - URL de l'avatar

---

### 1.3 JobCommentEntity
**Fichier**: `frontend/lib/features/jobs/domain/job_entity.dart`

Représente un commentaire/question sur une offre d'emploi.

**Attributs**:
- `initials: String` - Initiales de l'auteur
- `authorName: String` - Nom de l'auteur
- `date: String` - Date du commentaire
- `question: String` - Texte de la question
- `recruitorLabel: String` - Label du recruteur
- `recruitorDate: String` - Date de la réponse
- `reply: String` - Réponse du recruteur

---

### 1.4 CreateJobForm
**Fichier**: `frontend/lib/features/jobs/domain/job_entity.dart`

Formulaire pour créer une nouvelle offre d'emploi.

**Attributs**:
- `title: String` - Titre du poste
- `contractType: ContractType` - Type de contrat
- `description: String` - Description
- `candidateCount: int?` - Nombre de candidats recherchés
- `startTime: TimeOfDay?` - Heure de début
- `endTime: TimeOfDay?` - Heure de fin
- `startDate: DateTime?` - Date de début
- `salary: double?` - Salaire
- `imageAsset: String?` - Image

---

### 1.5 EditJobForm
**Fichier**: `frontend/lib/features/jobs/domain/job_entity.dart`

Formulaire pour éditer une offre d'emploi existante.

**Attributs**:
- `id: String` - ID de l'offre
- `title: String` - Titre du poste
- `contractType: ContractType` - Type de contrat
- `description: String` - Description
- `candidateCount: int?` - Nombre de candidats
- `salary: double?` - Salaire
- `startTime: TimeOfDay?` - Heure de début
- `endTime: TimeOfDay?` - Heure de fin
- `startDate: DateTime?` - Date de début
- `imageAsset: String?` - Image
- `isPrivate: bool` - Si l'offre est privée

---

## 2. ENTITÉS MISSIONS (Missions complétées)

### 2.1 MissionEntity
**Fichier**: `frontend/lib/features/jobs/domain/mission_entity.dart`

Représente une mission complétée entre un candidat et un recruteur.

**Attributs**:
- `id: String` - Identifiant unique
- `jobTitle: String` - Titre du poste
- `companyName: String` - Nom de l'entreprise
- `startDate: DateTime` - Date de début
- `endDate: DateTime` - Date de fin
- `location: String` - Localisation
- `status: String` - Statut (in_progress, completed)
- `recruiterName: String` - Nom du recruteur
- `candidateName: String` - Nom du candidat
- `candidateRating: double` - Note du candidat (0-5)
- `recruiterRating: double` - Note du recruteur (0-5)
- `candidateFeedback: String` - Avis du candidat
- `recruiterFeedback: String` - Avis du recruteur
- `summary: String?` - Résumé
- `imageUrl: String?` - Image
- `team: List<MissionMemberEntity>` - Équipe

---

### 2.2 MissionMemberEntity
**Fichier**: `frontend/lib/features/jobs/domain/mission_entity.dart`

Représente un membre de l'équipe d'une mission.

**Attributs**:
- `name: String` - Nom
- `role: String` - Rôle
- `rating: double` - Note
- `avatarUrl: String?` - URL de l'avatar

---

### 2.3 MissionReview
**Fichier**: `frontend/lib/features/jobs/domain/mission_entity.dart`

Formulaire pour évaluer une mission.

**Attributs**:
- `missionId: String` - ID de la mission
- `rating: int` - Note (1-5)
- `comment: String` - Commentaire

---

## 3. ENTITÉS MESSAGERIE

### 3.1 MessageEntity
**Fichier**: `frontend/lib/features/messaging/domain/message_entity.dart`

Représente un message dans une conversation.

**Attributs**:
- `id: String` - Identifiant unique
- `senderId: String` - ID de l'expéditeur
- `content: String` - Contenu du message
- `timestamp: DateTime` - Date/heure
- `isRead: bool` - Si le message est lu
- `isMine: bool` - Si c'est mon message
- `type: MessageType` - Type (text, invitation, image, file)

**Enum**:
- `MessageType`: text, invitation, image, file

---

### 3.2 ConversationEntity
**Fichier**: `frontend/lib/features/messaging/domain/message_entity.dart`

Représente une conversation entre deux utilisateurs ou un groupe.

**Attributs**:
- `id: String` - Identifiant unique
- `contactName: String` - Nom du contact
- `contactRole: String` - Rôle du contact
- `contactAvatar: String?` - Avatar du contact
- `isOnline: bool` - Si le contact est en ligne
- `lastMessage: String` - Dernier message
- `lastMessageTime: DateTime` - Heure du dernier message
- `isUnread: bool` - Si la conversation a des messages non lus
- `isInvitation: bool` - Si c'est une invitation
- `messages: List<MessageEntity>` - Liste des messages
- `isGroup: bool` - Si c'est un groupe
- `groupName: String?` - Nom du groupe
- `memberAvatars: List<String>` - Avatars des membres
- `memberNames: List<String>` - Noms des membres

---

## 4. ENTITÉS PROFIL

### 4.1 UserEntity
**Fichier**: `frontend/lib/features/profile/domain/user_entity.dart`

Représente un utilisateur (candidat ou recruteur).

**Attributs**:
- `id: String` - Identifiant unique
- `name: String` - Nom complet
- `role: String` - Poste occupé
- `domain: String` - Domaine d'activité
- `company: String` - Entreprise
- `location: String` - Localisation
- `bio: String` - Biographie
- `avatarUrl: String?` - URL de l'avatar
- `followersCount: int` - Nombre de followers
- `missionsCount: int` - Nombre de missions
- `rating: double` - Note globale
- `accountType: String` - Type de compte (recruiter, candidate)

---

### 4.2 EmployeeReviewEntity
**Fichier**: `frontend/lib/features/profile/domain/user_entity.dart`

Représente un avis/évaluation d'un employé.

**Attributs**:
- `id: String` - Identifiant unique
- `authorName: String` - Nom de l'auteur
- `authorRole: String` - Rôle de l'auteur
- `authorAvatar: String?` - Avatar de l'auteur
- `rating: double` - Note (0-5)
- `comment: String` - Commentaire
- `recruiterReply: String?` - Réponse du recruteur
- `recruiterName: String?` - Nom du recruteur
- `recruiterReplyDate: String?` - Date de la réponse

---

### 4.3 CvEntity
**Fichier**: `frontend/lib/features/profile/domain/cv_entity.dart`

Représente le CV complet d'un candidat.

**Attributs**:
- `formations: List<CvFormationEntity>` - Formations
- `experiences: List<CvExperienceEntity>` - Expériences
- `languages: List<CvLanguageEntity>` - Langues
- `skills: List<CvSkillEntity>` - Compétences

---

### 4.4 CvFormationEntity
**Fichier**: `frontend/lib/features/profile/domain/cv_entity.dart`

Représente une formation académique.

**Attributs**:
- `title: String` - Titre de la formation
- `institution: String` - Institution
- `location: String` - Localisation
- `year: int` - Année
- `isActive: bool` - Si validée
- `fileName: String?` - Nom du fichier du certificat
- `filePath: String?` - Chemin du fichier

---

### 4.5 CvExperienceEntity
**Fichier**: `frontend/lib/features/profile/domain/cv_entity.dart`

Représente une expérience professionnelle.

**Attributs**:
- `title: String` - Titre du poste
- `company: String` - Entreprise
- `location: String` - Localisation
- `period: String?` - Période (ex: "Sep 2021 - Aug 2023")
- `endDate: String?` - Date de fin
- `isAppMission: bool` - Si c'est une mission via l'app
- `isActive: bool` - Si validée

---

### 4.6 CvLanguageEntity
**Fichier**: `frontend/lib/features/profile/domain/cv_entity.dart`

Représente une langue parlée.

**Attributs**:
- `name: String` - Nom de la langue
- `level: String` - Niveau (ex: "Courant (C1)")

---

### 4.7 CvSkillEntity
**Fichier**: `frontend/lib/features/profile/domain/cv_entity.dart`

Représente une compétence.

**Attributs**:
- `name: String` - Nom de la compétence
- `levelLabel: String?` - Label du niveau (Expert, Avancé, etc.)
- `progress: double` - Progression (0.0 à 1.0)

---

## 5. ENTITÉS CANDIDATS

### 5.1 CandidateEntity
**Fichier**: `frontend/lib/features/candidates/domain/candidate_entity.dart`

Représente un candidat.

**Attributs**:
- `id: String` - Identifiant unique
- `name: String` - Nom
- `title: String` - Titre/poste
- `photoUrl: String` - URL de la photo
- `rating: double` - Note
- `reviewsCount: int` - Nombre d'avis
- `isTopRated: bool` - Si top-rated
- `coverLetter: String` - Lettre de motivation
- `status: CandidateStatus` - Statut (nouveau, examiné, archivé)

**Enum**:
- `CandidateStatus`: nouveau, examine, archive

---

### 5.2 SkillEntity
**Fichier**: `frontend/lib/features/candidates/domain/skill_entity.dart`

Représente une compétence d'un candidat.

**Attributs**:
- `name: String` - Nom de la compétence
- `level: SkillLevel` - Niveau

**Enum**:
- `SkillLevel`: debutant, intermediaire, avance, expert

---

### 5.3 LanguageEntity
**Fichier**: `frontend/lib/features/candidates/domain/skill_entity.dart`

Représente une langue parlée par un candidat.

**Attributs**:
- `name: String` - Nom de la langue
- `proficiency: String` - Niveau de maîtrise

---

### 5.4 SkillGroupEntity
**Fichier**: `frontend/lib/features/candidates/domain/skill_entity.dart`

Représente un groupe de compétences.

**Attributs**:
- `title: String` - Titre du groupe
- `skills: List<SkillEntity>` - Liste des compétences

---

### 5.5 FeedbackEntity
**Fichier**: `frontend/lib/features/candidates/domain/feedback_entity.dart`

Représente un avis/feedback sur un candidat.

**Attributs**:
- `id: String` - Identifiant unique
- `reviewerName: String` - Nom du reviewer
- `reviewerRole: String` - Rôle du reviewer
- `reviewerAvatar: String?` - Avatar du reviewer
- `starCount: int` - Nombre d'étoiles
- `reviewText: String` - Texte de l'avis
- `response: FeedbackResponseEntity?` - Réponse
- `cardType: FeedbackCardType` - Type de carte

**Enum**:
- `FeedbackCardType`: collapsed, replyInput, expanded

---

### 5.6 FeedbackResponseEntity
**Fichier**: `frontend/lib/features/candidates/domain/feedback_entity.dart`

Représente une réponse à un feedback.

**Attributs**:
- `authorName: String` - Nom de l'auteur
- `responseText: String` - Texte de la réponse

---

## 6. ENTITÉS CANDIDATURES

### 6.1 ApplicationEntity
**Fichier**: `frontend/lib/features/applications/domain/application_entity.dart`

Représente une candidature à une offre d'emploi.

**Attributs**:
- `id: String` - Identifiant unique
- `jobId: String` - ID de l'offre
- `jobTitle: String` - Titre du poste
- `companyName: String` - Nom de l'entreprise
- `logoAsset: String?` - Logo/image
- `status: ApplicationStatus` - Statut (pending, accepted, rejected)
- `appliedAt: DateTime` - Date de candidature
- `location: String` - Localisation
- `contractType: ContractType` - Type de contrat
- `scheduleLabel: String?` - Horaires (ex: "10h-17h")
- `interviewDate: String?` - Date d'entretien

**Enum**:
- `ApplicationStatus`: pending, accepted, rejected

---

## 7. ENTITÉS NOTIFICATIONS

### 7.1 NotificationEntity
**Fichier**: `frontend/lib/features/notifications/domain/notification_entity.dart`

Représente une notification.

**Attributs**:
- `id: String` - Identifiant unique
- `title: String` - Titre
- `message: String?` - Message
- `type: NotificationType` - Type de notification
- `timestamp: DateTime` - Date/heure
- `isRead: bool` - Si lue
- `jobTitle: String?` - Titre du poste (si applicable)
- `senderName: String?` - Nom de l'expéditeur
- `avatarUrl: String?` - Avatar
- `contextImageUrl: String?` - Image de contexte
- `count: int?` - Nombre (ex: nombre de candidatures)

**Enums**:
- `NotificationType`: newApplicants, newMessage, jobQuestion, missionExpiring, interviewAccepted, missionCompleted, announcementCreated, applicationAccepted, applicationRejected, applicationViewed, newNearbyOffer, jobMatchingPreferences, savedJobExpiring, newJobInCategory, profileViewed, profileIncomplete, system
- `NotificationCategory`: jobs, candidatures, messagerie, system
- `NotificationFilter`: all, jobs, messagerie, candidatures

---

## 📊 DIAGRAMME DE RELATIONS

```
┌─────────────────────────────────────────────────────────────┐
│                    UTILISATEUR (UserEntity)                 │
│  - Candidat ou Recruteur                                    │
└────────────┬────────────────────────────────────────────────┘
             │
             ├─────────────────────────────────────────────────┐
             │                                                 │
    ┌────────▼──────────┐                          ┌──────────▼────────┐
    │  CANDIDAT         │                          │  RECRUTEUR        │
    │  (CandidateEntity)│                          │  (UserEntity)     │
    └────────┬──────────┘                          └──────────┬────────┘
             │                                                 │
             ├─ CV (CvEntity)                                  │
             │  ├─ Formations                                  │
             │  ├─ Expériences                                 │
             │  ├─ Langues                                     │
             │  └─ Compétences                                 │
             │                                                 │
             ├─ Compétences (SkillEntity)                      │
             │                                                 │
             ├─ Avis (FeedbackEntity)                          │
             │                                                 │
             └─ Candidatures (ApplicationEntity)               │
                                                               │
                                                    ┌──────────▼────────┐
                                                    │  OFFRES D'EMPLOI  │
                                                    │  (JobEntity)      │
                                                    └──────────┬────────┘
                                                               │
                                                    ┌──────────▼────────┐
                                                    │  MISSIONS         │
                                                    │  (MissionEntity)  │
                                                    └───────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    COMMUNICATION                             │
├─────────────────────────────────────────────────────────────┤
│  Conversations (ConversationEntity)                         │
│  ├─ Messages (MessageEntity)                               │
│  └─ Participants                                           │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    NOTIFICATIONS                             │
├─────────────────────────────────────────────────────────────┤
│  Notifications (NotificationEntity)                         │
│  ├─ Jobs                                                   │
│  ├─ Candidatures                                           │
│  ├─ Messagerie                                             │
│  └─ Système                                                │
└─────────────────────────────────────────────────────────────┘
```

---

## 📈 RÉSUMÉ STATISTIQUE

| Catégorie | Nombre d'entités | Fichiers |
|-----------|------------------|----------|
| Jobs | 5 | 1 |
| Missions | 3 | 1 |
| Messagerie | 2 | 1 |
| Profil | 7 | 2 |
| Candidats | 5 | 2 |
| Candidatures | 1 | 1 |
| Notifications | 1 | 1 |
| **TOTAL** | **24 entités** | **9 fichiers** |

---

## 🔗 RELATIONS PRINCIPALES

1. **UserEntity** ↔ **CandidateEntity** : Un utilisateur peut être un candidat
2. **CandidateEntity** → **CvEntity** : Un candidat a un CV
3. **CandidateEntity** → **SkillEntity** : Un candidat a des compétences
4. **CandidateEntity** → **FeedbackEntity** : Un candidat reçoit des avis
5. **CandidateEntity** → **ApplicationEntity** : Un candidat postule à des offres
6. **UserEntity** → **JobEntity** : Un recruteur crée des offres
7. **JobEntity** → **JobCandidateEntity** : Une offre a des candidats
8. **JobEntity** → **JobCommentEntity** : Une offre a des commentaires
9. **CandidateEntity** → **MissionEntity** : Un candidat complète des missions
10. **UserEntity** → **ConversationEntity** : Un utilisateur a des conversations
11. **ConversationEntity** → **MessageEntity** : Une conversation contient des messages
12. **UserEntity** → **NotificationEntity** : Un utilisateur reçoit des notifications

---

**Dernière mise à jour**: 15 Mai 2026

# Database Changes Applied - Summary

This document summarizes all database changes applied based on `DB-CHANGES.md`.

## Migration Order Followed

As specified in section 15 of DB-CHANGES.md:
1. ✅ users app
2. ✅ jobs app  
3. ✅ applications app
4. ✅ messaging app
5. ✅ notifications app
6. ✅ reviews app

---

## 1. USERS APP (Migration: 0006)

### Utilisateur Model
**Added fields:**
- `avatar_url` - CharField(max_length=500, blank=True, null=True)
- `location` - CharField(max_length=200, blank=True)
- `bio` - TextField(blank=True)

### Recruteur Model
**Added fields:**
- `titre_poste` - CharField(max_length=100, blank=True) - Personal job title (e.g., "Responsable RH")
- `domain` - CharField(max_length=100, blank=True)

### Candidat Model
**Added fields:**
- `titre_poste` - CharField(max_length=100, blank=True) - Personal job title (e.g., "Barman", "UX Designer")
- `domain` - CharField(max_length=100, blank=True)

### New Models Created

#### RestrictedUser
- `restricteur` - FK to Utilisateur
- `restreint` - FK to Utilisateur
- `date_restriction` - DateTimeField(auto_now_add=True)
- Unique constraint on (restricteur, restreint)

#### CandidateSkillGroup
- `candidat` - FK to Candidat
- `title` - CharField(max_length=100)
- `order` - IntegerField(default=0)

#### CandidateSkill
- `group` - FK to CandidateSkillGroup
- `name` - CharField(max_length=100)
- `level` - CharField with choices: debutant, intermediaire, avance, expert

#### CandidateLanguage
- `candidat` - FK to Candidat
- `name` - CharField(max_length=50)
- `proficiency` - CharField(max_length=50)

#### CandidateTool
- `candidat` - FK to Candidat
- `name` - CharField(max_length=100)

#### CvFormation
- `candidat` - FK to Candidat
- `title` - CharField(max_length=200)
- `institution` - CharField(max_length=200)
- `location` - CharField(max_length=200)
- `year` - IntegerField
- `is_active` - BooleanField(default=False)
- `file_name` - CharField(max_length=200, blank=True, null=True)
- `file_path` - CharField(max_length=500, blank=True, null=True)

#### CvExperience
- `candidat` - FK to Candidat
- `title` - CharField(max_length=200)
- `company` - CharField(max_length=200)
- `location` - CharField(max_length=200)
- `period` - CharField(max_length=100, blank=True, null=True)
- `end_date` - CharField(max_length=50, blank=True, null=True)
- `is_app_mission` - BooleanField(default=False)
- `is_active` - BooleanField(default=False)

---

## 2. JOBS APP (Migration: 0005)

### Offre Model
**Added fields:**
- `created_at` - DateTimeField(auto_now_add=True) - Publication date
- `logo_url` - CharField(max_length=500, blank=True, null=True)
- `location` - CharField(max_length=200, blank=True) - Text location
- `schedule_label` - CharField(max_length=50, blank=True, null=True) - e.g., "9h-17h"

### Mission Model
**Added fields:**
- `summary` - TextField(blank=True, null=True)

### Interview Model
**Added fields:**
- `candidature` - FK to Candidature (SET_NULL, null=True, blank=True) - Links interview to application

### New Models Created

#### JobComment
- `offre` - FK to Offre
- `auteur` - FK to Utilisateur
- `question` - TextField
- `reponse` - TextField(blank=True)
- `date_question` - DateTimeField(auto_now_add=True)
- `date_reponse` - DateTimeField(blank=True, null=True)

#### MissionTeamMember
- `mission` - FK to Mission
- `name` - CharField(max_length=200)
- `role` - CharField(max_length=100)
- `rating` - FloatField(default=0.0)
- `avatar_url` - CharField(max_length=500, blank=True, null=True)

---

## 3. APPLICATIONS APP (Migration: 0003)

### Candidature Model
**Modified fields:**
- `date_postulation` - Changed from DateField to DateTimeField(auto_now_add=True)
- `statut` - Added choices: en_attente, acceptee, refusee

---

## 4. MESSAGING APP (Migration: 0006)

### Message Model
**Added fields:**
- `type` - CharField with choices: text, image, file (default='text')

---

## 5. NOTIFICATIONS APP (Migration: 0003)

### Notification Model
**Modified fields:**
- `count` - Changed from IntegerField(default=1) to IntegerField(blank=True, null=True)

**Added fields:**
- `context_image_url` - CharField(max_length=500, blank=True, null=True)

---

## 6. REVIEWS APP (Migration: 0003)

### Evaluation Model
**Added fields:**
- `recruiter_reply` - TextField(blank=True, null=True)
- `recruiter_name` - CharField(max_length=200, blank=True, null=True)
- `recruiter_reply_date` - DateTimeField(blank=True, null=True)

### Signalement Model (Option A implementation)
**Added fields:**
- `target_type` - CharField(max_length=20, default='user')
- `message` - FK to Message (CASCADE, null=True, blank=True)

---

## Status Mapping Reference

### Mission Status (for serializers)
| Database Value | API Value |
|---|---|
| en_attente | unconfirmed |
| en_cours | in_progress |
| terminee | completed |
| annulee | cancelled |

### Candidature Status (for serializers)
| Database Value | API Value |
|---|---|
| en_attente | pending |
| acceptee | accepted |
| refusee | rejected |

### Account Type (for serializers)
| Database Value | API Value |
|---|---|
| candidat | candidate |
| recruteur | recruiter |

---

## Notes for Serializer Implementation

### Calculated Fields (not in DB, compute in serializers)

**Utilisateur:**
- `name` = f"{prenom} {nom}"
- `followers_count` = 0 (or implement Follow model)
- `missions_count` = count from Mission via Candidature
- `rating` = from candidat.note_globale or recruteur.note_globale
- `account_type` = map role property to "candidate"/"recruiter"

**Offre:**
- `company_name` = offre.recruteur.nom_structure
- `recruiter_name` = from offre.recruteur
- `recruiter_role` = offre.recruteur.titre_poste
- `recruiter_avatar_asset` = offre.recruteur.avatar_url
- `department` = map categorie field

**Mission:**
- `job_id` = mission.candidature.offre_id
- `job_title` = mission.candidature.offre.titre
- `company_name` = mission.candidature.offre.recruteur.nom_structure
- `department` = mission.candidature.offre.categorie
- `recruiter_name` = from mission.candidature.offre.recruteur
- `candidate_name` = from mission.candidature.candidat
- `candidate_rating` = from Evaluation
- `recruiter_rating` = from Evaluation
- `candidate_feedback` = from Evaluation.commentaire
- `recruiter_feedback` = from Evaluation.commentaire

**Candidature:**
- `job_title` = candidature.offre.titre
- `company_name` = candidature.offre.recruteur.nom_structure
- `department` = candidature.offre.categorie
- `logo_asset` = candidature.offre.logo_url
- `location` = candidature.offre.location
- `contract_type` = candidature.offre.type_contrat
- `schedule_label` = candidature.offre.schedule_label
- `interview_date` = from Interview via candidature.interviews
- `candidate_name` = from candidature.candidat
- `candidate_avatar` = candidature.candidat.avatar_url
- `candidate_domain` = candidature.candidat.domain
- `candidate_rating` = candidature.candidat.note_globale

**Interview:**
- `candidate_name` = from interview.candidate
- `candidate_avatar` = interview.candidate.avatar_url
- `job_title` = interview.job.titre
- `department` = interview.job.categorie

**Message:**
- `is_mine` = sender == request.user

**Evaluation:**
- `author_name` = from evaluation.evaluateur
- `author_role` = evaluateur.recruteur.titre_poste or evaluateur.candidat.titre_poste
- `author_avatar` = evaluation.evaluateur.avatar_url
- `rating` = cast note to float

---

## Section 12.7 Note

As specified in the requirements, we are **reusing the existing Mission model** for profile missions instead of creating a separate ProfileMission model. The serializer should calculate the necessary fields from the existing Mission and Evaluation models.

---

## All Migrations Applied Successfully ✅

Run `python manage.py showmigrations` to verify all migrations are applied.

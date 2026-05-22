# Changements BD requis avant branchement frontend

> Issu du diff entre `API_SPEC.md` et les modèles Django existants.
> Chaque section indique le fichier modèle concerné, ce qui manque,
> et le type de changement (nouveau champ, nouveau modèle, migration requise).
>
> Convention priorité :
> 🔴 Bloquant — le frontend plantera sans ce champ
> 🟡 Partiel — l'API répond mais avec des données incomplètes/fausses
> 🟢 OK — le modèle couvre déjà le besoin

---

## 1. UTILISATEUR (`apps/users/models/utilisateur.py`)

| Champ API | Champ modèle | État | Changement requis |
|---|---|---|---|
| `id` | `id` (PK auto) | 🟢 | — |
| `name` | `nom` + `prenom` | 🟡 | Aucun champ DB — calculer `f"{prenom} {nom}"` dans le serializer |
| `role` (recruteur: "Responsable RH") | `@property role` retourne `"candidat"\|"recruteur"` | 🔴 | Le `role` de l'API désigne le **titre de poste personnel** (ex: "Responsable RH"), pas le type de compte. Voir champs à ajouter sur Recruteur/Candidat |
| `domain` | — | 🔴 | Champ absent — ajouter sur Recruteur + Candidat (voir ci-dessous) |
| `avatar_url` | — | 🔴 | Champ absent partout — ajouter sur **Utilisateur** (profite à tous) |
| `location` (texte) | `latitude` + `longitude` | 🔴 | GPS ≠ texte lieu. Ajouter `location = CharField(max_length=200, blank=True)` sur Utilisateur |
| `bio` | — | 🔴 | Recruteur a `description`, Candidat n'a rien. Ajouter `bio = TextField(blank=True)` sur **Utilisateur** |
| `followers_count` | — | 🟡 | Pas de système de follow en BD. Retourner `0` en dur dans le serializer pour l'instant, ou créer un modèle `Follow` |
| `missions_count` | — | 🟡 | Calculer via `Mission.objects.filter(candidature__candidat=user)` ou annoter |
| `rating` | `note_globale` (sur Candidat/Recruteur) | 🟡 | Existe mais sur les sous-modèles. Le serializer doit aller chercher `user.candidat.note_globale` ou `user.recruteur.note_globale` |
| `account_type` | `@property role` retourne `"candidat"\|"recruteur"` | 🟡 | Renommer la valeur `"candidat"` → `"candidate"` et `"recruteur"` → `"recruiter"` dans le serializer |

**Migration requise sur `utilisateur` :**
```python
avatar_url = models.CharField(max_length=500, blank=True, null=True)
location   = models.CharField(max_length=200, blank=True)
bio        = models.TextField(blank=True)
```

---

## 2. RECRUTEUR (`apps/users/models/recruteur.py`)

| Champ API | Champ modèle | État | Changement requis |
|---|---|---|---|
| `company` | `nom_structure` | 🟡 | Mapper `nom_structure` → `company` dans le serializer |
| `role` (ex: "Responsable RH") | — | 🔴 | Recruteur n'a pas de titre de poste personnel. Ajouter `titre_poste = CharField(max_length=100, blank=True)` |
| `domain` | — | 🔴 | Ajouter `domain = CharField(max_length=100, blank=True)` |

**Migration requise sur `recruteur` :**
```python
titre_poste = models.CharField(max_length=100, blank=True)
domain      = models.CharField(max_length=100, blank=True)
```

---

## 3. CANDIDAT (`apps/users/models/candidat.py`)

| Champ API | Champ modèle | État | Changement requis |
|---|---|---|---|
| `title` (ex: "Barman", "UX Designer") | — | 🔴 | Candidat n'a pas de titre de poste. Ajouter `titre_poste = CharField(max_length=100, blank=True)` |
| `domain` | — | 🔴 | Ajouter `domain = CharField(max_length=100, blank=True)` |
| `competences` (pour profile public) | `competences = JSONField(default=list)` | 🟡 | Existe mais non structuré. La spec attend un format `[{ title, skills: [{ name, level }] }]`. Soit structurer le JSONField, soit créer des modèles dédiés (voir section 9) |
| `cover_letter` (bio candidat) | `experience = TextField` | 🟡 | `experience` est le bon endroit, mais il s'appelle différemment. Mapper dans le serializer OU utiliser `bio` sur Utilisateur |

**Migration requise sur `candidat` :**
```python
titre_poste = models.CharField(max_length=100, blank=True)
domain      = models.CharField(max_length=100, blank=True)
```

---

## 4. OFFRE (`apps/jobs/models/offre.py`)

| Champ API | Champ modèle | État | Changement requis |
|---|---|---|---|
| `title` | `titre` | 🟡 | Mapper dans le serializer |
| `company_name` | — | 🔴 | Pas de champ direct — calculer via `offre.recruteur.nom_structure` dans le serializer |
| `recruiter_id` | `recruteur_id` | 🟢 | — |
| `recruiter_name` | — | 🔴 | Calculer via `offre.recruteur` dans le serializer |
| `recruiter_role` | — | 🔴 | Calculer via `offre.recruteur.titre_poste` (champ à créer sur Recruteur) |
| `recruiter_avatar_asset` | — | 🔴 | Calculer via `offre.recruteur.avatar_url` (champ à créer sur Utilisateur) |
| `department` | `categorie` | 🟡 | Même concept, nom différent. Mapper `categorie` → `department` dans le serializer. Ou renommer la colonne |
| `contract_type` | `type_contrat` | 🟡 | Mapper dans le serializer |
| `posted_at` | — | 🔴 | Offre n'a pas de date de création/publication. `date_debut` est la date de démarrage du poste (différent). **Ajouter `created_at`** |
| `status` | `statut` | 🟢 | Valeurs déjà identiques (`searching\|draft\|closed`) |
| `candidate_count` | `candidate_count` | 🟢 | — |
| `view_count` | `view_count` | 🟢 | — |
| `logo_asset` | — | 🟡 | Pas de champ logo sur Offre. Ajouter `logo_url = CharField(max_length=500, blank=True, null=True)` |
| `is_published` | `is_published` | 🟢 | — |
| `location` (texte) | — | 🔴 | Offre a `latitude`/`longitude` GPS mais pas de texte lieu. Ajouter `location = CharField(max_length=200, blank=True)` |
| `schedule_label` (ex: "9h-17h") | — | 🟡 | Absent. Ajouter `schedule_label = CharField(max_length=50, blank=True, null=True)` |

**Migration requise sur `offre` :**
```python
created_at     = models.DateTimeField(auto_now_add=True)
logo_url       = models.CharField(max_length=500, blank=True, null=True)
location       = models.CharField(max_length=200, blank=True)
schedule_label = models.CharField(max_length=50, blank=True, null=True)
```

**Pour GET /jobs/:id — `candidates[]` et `comments[]` :**
- `candidates[]` : données calculées depuis `Candidature → Candidat`. OK avec les champs ajoutés.
- `comments[]` : **aucun modèle `JobComment` n'existe** (voir section 9).

---

## 5. MISSION (`apps/jobs/models/mission.py`)

| Champ API | Champ modèle | État | Changement requis |
|---|---|---|---|
| `job_id` | — | 🔴 | Aller chercher via `mission.candidature.offre_id` dans le serializer |
| `job_title` | — | 🔴 | Calculer via `mission.candidature.offre.titre` |
| `company_name` | — | 🔴 | Calculer via `mission.candidature.offre.recruteur.nom_structure` |
| `department` | — | 🔴 | Calculer via `mission.candidature.offre.categorie` |
| `start_date` | `date_debut` (nullable) | 🟡 | Nullable actuellement — OK car `unconfirmed` missions n'ont pas encore de date. Mapper dans le serializer |
| `end_date` | `date_fin` (nullable) | 🟡 | Idem |
| `location` | `location` | 🟢 | — |
| `recruiter_name` | — | 🔴 | Calculer via `mission.candidature.offre.recruteur` |
| `candidate_name` | — | 🔴 | Calculer via `mission.candidature.candidat` |
| `candidate_rating` | — | 🔴 | Calculer depuis `Evaluation.objects.filter(mission=mission, evaluateur=candidat).first().note` |
| `recruiter_rating` | — | 🔴 | Idem côté recruteur |
| `candidate_feedback` | — | 🔴 | Calculer depuis `Evaluation.commentaire` côté candidat |
| `recruiter_feedback` | — | 🔴 | Calculer depuis `Evaluation.commentaire` côté recruteur |
| `status` | `statut` | 🟡 | **Valeurs incompatibles** — voir tableau de mapping ci-dessous |
| `summary` | — | 🟡 | Champ absent. Ajouter `summary = TextField(blank=True, null=True)` |
| `image_url` | `image_url` | 🟢 | — |
| `team[]` | — | 🔴 | **Aucun modèle team** — voir section 9 |

**Mapping des statuts Mission (serializer) :**
| Valeur BD | Valeur API |
|---|---|
| `en_attente` | `unconfirmed` |
| `en_cours` | `in_progress` |
| `terminee` | `completed` |
| `annulee` | `cancelled` |

**Migration requise sur `mission` :**
```python
summary = models.TextField(blank=True, null=True)
```

---

## 6. CANDIDATURE (`apps/applications/models/candidature.py`)

| Champ API | Champ modèle | État | Changement requis |
|---|---|---|---|
| `job_id` | `offre_id` | 🟢 | Mapper dans le serializer |
| `job_title` | — | 🔴 | Calculer via `candidature.offre.titre` |
| `company_name` | — | 🔴 | Calculer via `candidature.offre.recruteur.nom_structure` |
| `department` | — | 🔴 | Calculer via `candidature.offre.categorie` |
| `logo_asset` | — | 🔴 | Calculer via `candidature.offre.logo_url` (champ à créer sur Offre) |
| `status` | `statut` | 🟡 | **Valeurs incompatibles** — voir mapping ci-dessous |
| `applied_at` | `date_postulation = DateField` | 🔴 | `DateField` → manque l'heure. Le frontend affiche `"jj/mm/aaaa à HH:mm"`. **Changer en `DateTimeField`** |
| `location` | — | 🔴 | Calculer via `candidature.offre.location` (champ à créer sur Offre) |
| `contract_type` | — | 🔴 | Calculer via `candidature.offre.type_contrat` |
| `schedule_label` | — | 🟡 | Calculer via `candidature.offre.schedule_label` (champ à créer sur Offre) |
| `interview_date` | — | 🟡 | Calculer depuis `Interview.objects.filter(candidature=...)` — nécessite un lien entre Interview et Candidature (voir section 7) |
| `candidate_name` | — | 🔴 | Calculer via `candidature.candidat` |
| `candidate_avatar` | — | 🔴 | Calculer via `candidature.candidat.avatar_url` |
| `candidate_domain` | — | 🔴 | Calculer via `candidature.candidat.domain` |
| `candidate_rating` | — | 🔴 | Calculer via `candidature.candidat.note_globale` |
| `motivation_letter` | `message_personnalise` | 🟢 | Mapper dans le serializer |

**Mapping des statuts Candidature (serializer) :**
| Valeur BD | Valeur API |
|---|---|
| `en_attente` | `pending` |
| `acceptee` | `accepted` |
| `refusee` | `rejected` |

⚠️ Actuellement `statut` n'a que `default="en_attente"` sans `choices`. **Ajouter les choices** pour éviter des valeurs fantaisistes.

**Migration requise sur `candidature` :**
```python
# Changer DateField → DateTimeField
date_postulation = models.DateTimeField(auto_now_add=True)

# Ajouter les choices sur statut
STATUT_CHOICES = [
    ("en_attente", "Pending"),
    ("acceptee",   "Accepted"),
    ("refusee",    "Rejected"),
]
statut = models.CharField(max_length=50, choices=STATUT_CHOICES, default="en_attente")
```

---

## 7. INTERVIEW (`apps/jobs/models/interview.py`)

| Champ API | Champ modèle | État | Changement requis |
|---|---|---|---|
| `candidate_id` | `candidate_id` (FK Utilisateur) | 🟡 | OK mais c'est un FK vers `Utilisateur` — le serializer doit récupérer le profil complet |
| `candidate_name` | — | 🔴 | Calculer via `interview.candidate` |
| `candidate_avatar` | — | 🔴 | Calculer via `interview.candidate.avatar_url` |
| `job_id` | `job_id` | 🟢 | — |
| `job_title` | — | 🔴 | Calculer via `interview.job.titre` |
| `department` | — | 🔴 | Calculer via `interview.job.categorie` |
| `scheduled_date` | `scheduled_date` | 🟢 | — |
| `status` | `status` | 🟢 | Valeurs identiques (`scheduled\|completed\|cancelled`) |
| `notes` | `notes` | 🟢 | — |

**Lien Interview ↔ Candidature manquant :**
La spec permet de retrouver `interview_date` dans l'application. Actuellement `Interview` n'a pas de FK vers `Candidature` — seulement `candidate` + `job`. Pour relier proprement (et retrouver l'interview depuis une candidature) :
```python
# Optionnel mais recommandé
candidature = models.ForeignKey(
    "applications.Candidature",
    on_delete=models.SET_NULL,
    null=True, blank=True,
    related_name="interviews"
)
```

---

## 8. MESSAGE (`apps/messaging/models/message.py`)

| Champ API | Champ modèle | État | Changement requis |
|---|---|---|---|
| `id` | `id` | 🟢 | — |
| `sender_id` | `expediteur_id` | 🟡 | Mapper dans le serializer |
| `content` | `contenu` | 🟡 | Mapper dans le serializer |
| `timestamp` | `date_envoi` | 🟡 | Mapper dans le serializer |
| `is_read` | `est_lu` | 🟡 | Legacy field — utiliser `ReadCursor` pour les nouvelles conversations. Garder `est_lu` pour compatibilité temporaire |
| `is_mine` | — | 🟡 | Calculer en serializer : `sender == request.user` |
| `type` | — | 🔴 | **Champ absent** — le frontend distingue text/image/file pour afficher correctement |

**Migration requise sur `message` :**
```python
TYPE_CHOICES = [
    ('text',     'Text'),
    ('image',    'Image'),
    ('file',     'File'),
]
type = models.CharField(max_length=10, choices=TYPE_CHOICES, default='text')
```

---

## 9. NOTIFICATION (`apps/notifications/models/notification.py`)

| Champ API | Champ modèle | État | Changement requis |
|---|---|---|---|
| `title` | `title` | 🟢 | — |
| `message` | `contenu` | 🟡 | Mapper `contenu` → `message` dans le serializer |
| `type` | `type` | 🟡 | Vérifier que les valeurs correspondent aux types de l'API (`newApplicants`, `newMessage`, etc.) |
| `timestamp` | `date_envoi` | 🟡 | Mapper dans le serializer |
| `is_read` | `est_lue` | 🟡 | Mapper dans le serializer |
| `job_title` | `job_title` | 🟢 | — |
| `sender_name` | `sender_name` | 🟢 | — |
| `avatar_url` | `avatar_url` | 🟢 | — |
| `context_image_url` | — | 🔴 | **Champ absent** |
| `count` | `count` | 🟡 | Existe mais `default=1` — la spec accepte `null`. Changer en `null=True` |

**Migration requise sur `notification` :**
```python
context_image_url = models.CharField(max_length=500, blank=True, null=True)
# Optionnel mais propre :
count = models.IntegerField(blank=True, null=True)
```

---

## 10. EVALUATION (`apps/reviews/models/evaluation.py`)

| Champ API | Champ modèle | État | Changement requis |
|---|---|---|---|
| `author_name` | — | 🔴 | Calculer via `evaluation.evaluateur` |
| `author_role` | — | 🔴 | **Absent** — le rôle de l'auteur (ex: "Chef de rang") n'est pas stocké dans Evaluation ni dans le profil évaluateur de façon accessible. Calculer via `evaluateur.recruteur.titre_poste` ou `evaluateur.candidat.titre_poste` |
| `author_avatar` | — | 🔴 | Calculer via `evaluation.evaluateur.avatar_url` |
| `rating` | `note` (IntegerField 1-5) | 🟡 | L'API retourne `5.0` (float). Caster dans le serializer |
| `comment` | `commentaire` | 🟡 | Mapper dans le serializer |
| `recruiter_reply` | — | 🔴 | **Champ absent** — pas de système de réponse aux avis |
| `recruiter_name` | — | 🔴 | **Champ absent** — lié à `recruiter_reply` |
| `recruiter_reply_date` | — | 🔴 | **Champ absent** |

**Migration requise sur `evaluation` :**
```python
recruiter_reply      = models.TextField(blank=True, null=True)
recruiter_name       = models.CharField(max_length=200, blank=True, null=True)
recruiter_reply_date = models.DateTimeField(blank=True, null=True)
```

---

## 11. SIGNALEMENT (`apps/reviews/models/signalement.py`)

| Champ API | Champ modèle | État | Changement requis |
|---|---|---|---|
| `target_type` (`user\|message\|comment`) | — | 🔴 | `cible` est une FK user-only. La spec supporte aussi les messages et commentaires |
| `target_id` | `cible_id` | 🟡 | OK si target_type == "user", sinon ne pointe pas vers le bon modèle |
| `reason` | `raison` | 🟢 | — |
| `context` | `description` | 🟡 | Mapper dans le serializer |

**Option A (simple) :** garder `cible` user-only + ajouter FK optionnels pour message/comment.
**Option B (flexible) :** remplacer par un GenericForeignKey.

**Migration recommandée (Option A) :**
```python
# Garder cible (user) + ajouter :
target_type  = models.CharField(max_length=20, default='user')
message      = models.ForeignKey('messaging.Message', on_delete=models.CASCADE, null=True, blank=True, related_name='signalements')
```

---

## 12. MODÈLES ENTIÈREMENT MANQUANTS (à créer)

### 12.1 `JobComment` — Questions/réponses sur une annonce
Affiché dans l'onglet détail annonce (`comments[]` dans `GET /jobs/:id`).

```python
# apps/jobs/models/job_comment.py
class JobComment(models.Model):
    offre       = models.ForeignKey("jobs.Offre", on_delete=models.CASCADE, related_name="comments")
    auteur      = models.ForeignKey("users.Utilisateur", on_delete=models.CASCADE, related_name="job_comments")
    question    = models.TextField()
    reponse     = models.TextField(blank=True)
    date_question = models.DateTimeField(auto_now_add=True)
    date_reponse  = models.DateTimeField(blank=True, null=True)

    class Meta:
        db_table = "job_comment"
        ordering = ["-date_question"]
```

### 12.2 `MissionTeamMember` — Équipe d'une mission
Affiché dans le détail mission (`team[]`).

```python
# apps/jobs/models/mission_team_member.py
class MissionTeamMember(models.Model):
    mission    = models.ForeignKey("jobs.Mission", on_delete=models.CASCADE, related_name="team")
    name       = models.CharField(max_length=200)
    role       = models.CharField(max_length=100)
    rating     = models.FloatField(default=0.0)
    avatar_url = models.CharField(max_length=500, blank=True, null=True)

    class Meta:
        db_table = "mission_team_member"
```

### 12.3 `RestrictedUser` — Contacts restreints
Analogue à `BlockedUser`, permet `GET/POST/DELETE /users/me/restricted`.

```python
# apps/users/models/restricted_user.py
class RestrictedUser(models.Model):
    restricteur = models.ForeignKey("users.Utilisateur", on_delete=models.CASCADE, related_name="utilisateurs_restreints")
    restreint   = models.ForeignKey("users.Utilisateur", on_delete=models.CASCADE, related_name="restreint_par")
    date_restriction = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "restricted_user"
        unique_together = [("restricteur", "restreint")]
```

### 12.4 `CandidateSkillGroup` + `CandidateSkill` — Compétences structurées
Pour `GET /candidates/:id/profile` → `skill_groups[]`.

```python
# apps/users/models/candidate_skill.py
class CandidateSkillGroup(models.Model):
    candidat = models.ForeignKey("users.Candidat", on_delete=models.CASCADE, related_name="skill_groups")
    title    = models.CharField(max_length=100)
    order    = models.IntegerField(default=0)

    class Meta:
        db_table = "candidate_skill_group"

class CandidateSkill(models.Model):
    LEVEL_CHOICES = [
        ("debutant",      "Débutant"),
        ("intermediaire", "Intermédiaire"),
        ("avance",        "Avancé"),
        ("expert",        "Expert"),
    ]
    group  = models.ForeignKey(CandidateSkillGroup, on_delete=models.CASCADE, related_name="skills")
    name   = models.CharField(max_length=100)
    level  = models.CharField(max_length=20, choices=LEVEL_CHOICES)

    class Meta:
        db_table = "candidate_skill"
```

### 12.5 `CandidateLanguage` — Langues du profil candidat
Pour `GET /candidates/:id/profile` → `languages[]`.

```python
# apps/users/models/candidate_language.py
class CandidateLanguage(models.Model):
    candidat    = models.ForeignKey("users.Candidat", on_delete=models.CASCADE, related_name="languages")
    name        = models.CharField(max_length=50)
    proficiency = models.CharField(max_length=50)  # ex: "Natif", "Avancé"

    class Meta:
        db_table = "candidate_language"
```

### 12.6 `CandidateTool` — Outils maîtrisés (profil candidat)
Pour `GET /candidates/:id/profile` → `tools[]`.

```python
# apps/users/models/candidate_tool.py
class CandidateTool(models.Model):
    candidat = models.ForeignKey("users.Candidat", on_delete=models.CASCADE, related_name="tools")
    name     = models.CharField(max_length=100)

    class Meta:
        db_table = "candidate_tool"
```

### 12.7 `ProfileMission` — Missions sur profil public candidat
Pour `GET /candidates/:id/profile` → `missions[]`. Distinct de `Mission` (vue résumée).

> **Alternative :** ne pas créer ce modèle et le calculer depuis `Mission` existant.
> La `Mission` contient `job_title`, `company_name`, dates (donc `duration` calculable), `statut`.
> L'`Evaluation` donne le `rating`. Réutiliser ces modèles directement dans le serializer.

### 12.8 `CvFormation` — Formations du CV
Pour `GET /users/:userId/cv` → `formations[]`.

```python
# apps/users/models/cv_formation.py
class CvFormation(models.Model):
    candidat    = models.ForeignKey("users.Candidat", on_delete=models.CASCADE, related_name="formations")
    title       = models.CharField(max_length=200)
    institution = models.CharField(max_length=200)
    location    = models.CharField(max_length=200)
    year        = models.IntegerField()
    is_active   = models.BooleanField(default=False)
    file_name   = models.CharField(max_length=200, blank=True, null=True)
    file_path   = models.CharField(max_length=500, blank=True, null=True)

    class Meta:
        db_table = "cv_formation"
        ordering = ["-year"]
```

### 12.9 `CvExperience` — Expériences du CV
Pour `GET /users/:userId/cv` → `experiences[]`.

```python
# apps/users/models/cv_experience.py
class CvExperience(models.Model):
    candidat      = models.ForeignKey("users.Candidat", on_delete=models.CASCADE, related_name="experiences")
    title         = models.CharField(max_length=200)
    company       = models.CharField(max_length=200)
    location      = models.CharField(max_length=200)
    period        = models.CharField(max_length=100, blank=True, null=True)  # ex: "Sep 2021 - Août 2023"
    end_date      = models.CharField(max_length=50, blank=True, null=True)   # ex: "Août 2021"
    is_app_mission = models.BooleanField(default=False)
    is_active     = models.BooleanField(default=False)

    class Meta:
        db_table = "cv_experience"
```

---

## 13. RÉCAPITULATIF MIGRATIONS PAR APPLICATION

### `apps/users/migrations/`
| Modèle | Changement |
|---|---|
| `Utilisateur` | +`avatar_url`, +`location`, +`bio` |
| `Recruteur` | +`titre_poste`, +`domain` |
| `Candidat` | +`titre_poste`, +`domain` |
| **Nouveau** `RestrictedUser` | Nouveau fichier + migration |
| **Nouveau** `CandidateSkillGroup` | Nouveau fichier + migration |
| **Nouveau** `CandidateSkill` | Nouveau fichier + migration |
| **Nouveau** `CandidateLanguage` | Nouveau fichier + migration |
| **Nouveau** `CandidateTool` | Nouveau fichier + migration |
| **Nouveau** `CvFormation` | Nouveau fichier + migration |
| **Nouveau** `CvExperience` | Nouveau fichier + migration |

### `apps/jobs/migrations/`
| Modèle | Changement |
|---|---|
| `Offre` | +`created_at`, +`logo_url`, +`location`, +`schedule_label` |
| `Mission` | +`summary` |
| `Interview` | +`candidature` FK (optionnel) |
| **Nouveau** `JobComment` | Nouveau fichier + migration |
| **Nouveau** `MissionTeamMember` | Nouveau fichier + migration |

### `apps/applications/migrations/`
| Modèle | Changement |
|---|---|
| `Candidature` | `date_postulation` DateField → DateTimeField, +`STATUT_CHOICES` |

### `apps/messaging/migrations/`
| Modèle | Changement |
|---|---|
| `Message` | +`type` (`text\|image\|file`) |

### `apps/notifications/migrations/`
| Modèle | Changement |
|---|---|
| `Notification` | +`context_image_url`, `count` nullable |

### `apps/reviews/migrations/`
| Modèle | Changement |
|---|---|
| `Evaluation` | +`recruiter_reply`, +`recruiter_name`, +`recruiter_reply_date` |
| `Signalement` | +`target_type`, +`message` FK |

---

## 14. CHOSES OK — AUCUNE MIGRATION REQUISE

Ces modèles couvrent déjà les besoins de l'API spec :

| Modèle | Endpoints couverts |
|---|---|
| `SavedJob` | `GET/POST/DELETE /users/me/saved-jobs` |
| `BlockedUser` | `GET/POST/DELETE /users/me/blocked` |
| `UserSettings` | `GET/PUT /settings/...` |
| `RecentSearch` | `GET/POST/DELETE /users/me/recent-searches` |
| `Interview.status` | `scheduled\|completed\|cancelled` — valeurs identiques |
| `Conversation` | Type direct/group, nom groupe, created_by — tout est là |
| `ConversationMember` | `is_invitation`, `role`, `left_at` — complet |
| `ReadCursor` | Lu/non-lu par conversation — mécanisme solide |

---

## 15. ORDRE DE MIGRATION RECOMMANDÉ

1. `users` — Utilisateur, Recruteur, Candidat (autres modèles dépendent de ces FK)
2. `jobs` — Offre (dépend de Recruteur), puis Mission, JobComment, MissionTeamMember
3. `applications` — Candidature (dépend d'Offre et Candidat)
4. `messaging` — Message (dépend de Conversation et Utilisateur)
5. `notifications` — Notification (dépend d'Utilisateur)
6. `reviews` — Evaluation, Signalement (dépend de Mission et Utilisateur)

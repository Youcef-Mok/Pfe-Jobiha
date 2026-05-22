# API Specification — Job App

> Ce fichier documente tous les endpoints REST que le backend devra exposer.
> Chaque endpoint correspond à une méthode dans un `*RepositoryMock` à remplacer
> par un `*RepositoryHttp` lors du branchement.
>
> Convention :
> - Toutes les routes sont préfixées par `/api/v1`
> - Auth via Bearer token JWT dans le header `Authorization`
> - Réponses JSON, erreurs au format `{ "error": "message" }`

---

## Filtrage — convention frontend / branchement API

**Règle** : aucun filtrage métier dans les `screens/`. Chaîne obligatoire :

```
Screen  →  watch *Provider filtré (ex. filteredJobsProvider)
Provider  →  Controller.filterXxx(liste brute, état filtre UI)
Controller  →  logique pure (mappe vers query params documentés ci-dessous)
Notifier  →  fetch brut via Repository (sans filtre côté mock, sauf simulation)
Repository Http  →  GET …?status=&department=&…
```

| État filtre UI (Riverpod) | Provider calculé | Controller | Endpoint + query params (futur Http) |
|---------------------------|------------------|------------|--------------------------------------|
| `recruiterFiltersProvider` | `filteredJobsProvider` | `JobsController.filterJobs` | `GET /jobs/mine?status=&posted_within=&department=` |
| `recruiterFiltersProvider` | `filteredMissionsProvider` | `JobsController.filterMissions` | `GET /missions?status=&max_duration=&department=` |
| `recruiterFiltersProvider` | `recruiterFilteredApplicationsProvider` | `ApplicationsController.filterByRecruiterFilters` | `GET /applications?status=&applied_within=&department=&job_id=` |
| `recruiterFiltersProvider` | `filteredInterviewsProvider` | `InterviewsController.filterByRecruiterFilters` | `GET /interviews?status=&scheduled_within=&department=&job_id=` |
| `applicationsTabProvider` + `applicationsOverlayFilterProvider` | `candidateApplicationsListProvider` | `ApplicationsController.applyCandidateListFilters` | `GET /applications?status=&sort=` |
| `candidatesTabProvider` + `candidatesSortModeProvider` | `filteredCandidatesProvider` | `CandidatesController.filterAndSort` | `GET /jobs/:jobId/candidates?status=&sort=` |
| — | `jobNouveauCandidatesProvider` | `CandidatesController.filterByStatus` | `GET /jobs/:jobId/candidates?status=nouveau` |
| `candidateFiltersProvider` + `mapFiltersProvider` + `mapSearchQueryProvider` | `filteredMapJobsProvider` | `MapController.applyMapFilters` | `GET /map/jobs?q=&category=&contract_type=&…` |
| `savedJobsFilterValuesProvider` + `savedJobsActiveChipProvider` | `savedJobsDisplayProvider` | `JobsController.filterSavedJobs` + `sortSavedJobs` | `GET /users/me/saved-jobs?…` |
| `candidateJobSearchQueryProvider` | `candidateJobSearchResultsProvider` | `JobsController.searchPublished` | `GET /jobs?published=true&q=` |
| — | `publishedJobsProvider` | `JobsController.filterPublished` | `GET /jobs?published=true` |

**Écrans corrigés** (filtrage retiré du UI) : `applications_screen`, `candidates_screen`, `saved_jobs_screen`, `candidate_home_screen`, `candidate_search_screen`, `job_details_screen` (`_CandidaturesTab`).

**Au branchement** : passer les query params dans `*RepositoryHttp` ; les controllers peuvent rester en fallback client ou être simplifiés si le backend filtre tout.

---

## Note — clés JSON camelCase vs snake_case

Certains modèles Flutter ont été écrits avec des clés camelCase dans `fromJson` (erreur héritée du mock). **Le backend doit impérativement retourner du snake_case.** Les modèles concernés à corriger lors du branchement :

| Modèle | Clés camelCase à corriger vers snake_case |
|---|---|
| `InterviewModel` | `candidateId` → `candidate_id`, `candidateName` → `candidate_name`, `candidateAvatar` → `candidate_avatar`, `jobId` → `job_id`, `jobTitle` → `job_title`, `scheduledDate` → `scheduled_date` |
| `CandidateModel` | `photoUrl` → `photo_url`, `reviewsCount` → `reviews_count`, `isTopRated` → `is_top_rated`, `coverLetter` → `cover_letter` |

---

## AUTH

### POST /api/v1/auth/login
Connexion avec email + mot de passe.

**Body**
```json
{ "email": "string", "password": "string" }
```
**Response 200**
```json
{ "access_token": "string", "refresh_token": "string", "user": { "id": "string", "name": "string", "account_type": "recruiter|candidate" } }
```
**Notes** : Stocker les tokens en secure storage. `account_type` détermine quel flow afficher (recruiter ou candidate).

---

### POST /api/v1/auth/register
Création de compte (candidat ou recruteur).

**Body**
```json
{ "email": "string", "password": "string", "name": "string", "account_type": "recruiter|candidate", "role": "string", "domain": "string" }
```
**Response 201**
```json
{ "access_token": "string", "user": { "id": "string", "name": "string", "account_type": "recruiter|candidate" } }
```

---

### POST /api/v1/auth/logout
Invalide le token côté serveur.

**Header** : `Authorization: Bearer <token>`
**Response 204** : No content

---

### POST /api/v1/auth/refresh
Renouvelle le access_token via le refresh_token.

**Body** `{ "refresh_token": "string" }`
**Response 200** `{ "access_token": "string" }`

---

## USERS / PROFILE

### GET /api/v1/users/me
Retourne le profil de l'utilisateur authentifié.

**Response 200**
```json
{
  "id": "string",
  "name": "string",
  "role": "string",
  "domain": "string",
  "company": "string",
  "location": "string",
  "bio": "string",
  "avatar_url": "string|null",
  "followers_count": 0,
  "missions_count": 0,
  "rating": 4.8,
  "account_type": "recruiter|candidate"
}
```
**Notes** : Remplace `UserRepositoryMock.getCurrentUser()`.

---

### GET /api/v1/users/:userId
Retourne le profil public d'un utilisateur (ex: recruteur depuis une annonce).

**Response 200**
```json
{
  "id": "string",
  "name": "string",
  "role": "string",
  "domain": "string",
  "company": "string",
  "location": "string",
  "bio": "string",
  "avatar_url": "string|null",
  "followers_count": 0,
  "missions_count": 0,
  "rating": 4.8,
  "account_type": "recruiter|candidate"
}
```
**Notes** : utilisé pour la page profil public recruteur. Remplace `UserRepositoryMock.getUserById()`.

---

### PUT /api/v1/users/me
Met à jour le profil de l'utilisateur authentifié.

**Body**
```json
{
  "name": "string",
  "role": "string",
  "domain": "string",
  "company": "string",
  "location": "string",
  "bio": "string",
  "avatar_url": "string|null"
}
```
**Response 200** : Profil mis à jour (même format que GET /users/me).
**Notes** : Tous les champs sont optionnels (PATCH sémantique). Remplace `UserRepositoryMock.updateProfile()`.

---

### GET /api/v1/users/:userId/reviews
Retourne les avis laissés sur un utilisateur (recruteur ou candidat).

**Response 200**
```json
[{
  "id": "string",
  "author_name": "string",
  "author_role": "string",
  "author_avatar": "string|null",
  "rating": 5.0,
  "comment": "string",
  "recruiter_reply": "string|null",
  "recruiter_name": "string|null",
  "recruiter_reply_date": "string|null"
}]
```
**Notes** : Remplace `UserRepositoryMock.getEmployeeReviews()`.
Utilisé à la fois pour le profil recruteur ET candidat (même endpoint, userId différent).

---

### GET /api/v1/users/:userId/cv
Retourne les données CV d'un candidat.

**Response 200**
```json
{
  "formations": [
    {
      "title": "string",
      "institution": "string",
      "location": "string",
      "year": 2021,
      "is_active": true,
      "file_name": "string|null",
      "file_path": "string|null"
    }
  ],
  "experiences": [
    {
      "title": "string",
      "company": "string",
      "location": "string",
      "period": "string|null",
      "end_date": "string|null",
      "is_app_mission": false,
      "is_active": false
    }
  ],
  "languages": [
    {
      "name": "string",
      "level": "string"
    }
  ],
  "skills": [
    {
      "name": "string",
      "level_label": "EXPERT|AVANCÉ|null",
      "progress": 0.9
    }
  ]
}
```
**Notes** :
- `period` : période texte libre, ex: `"Sep 2021 - Août 2023"` (utilisé si `is_app_mission = false`)
- `end_date` : date de fin texte, ex: `"Août 2021"` (affiché à droite si `is_app_mission = true`)
- `is_app_mission` : `true` si l'expérience est une mission de l'application (badge violet)
- `is_active` : `true` si le point timeline est actif (violet), `false` sinon (gris)
- `progress` : valeur entre `0.0` et `1.0` pour la barre de compétence
Remplace `UserRepositoryMock.getCvData()`.

---

### GET /api/v1/users/me/saved-jobs
Retourne les IDs des offres sauvegardées par le candidat connecté.

**Response 200**
```json
{
  "saved_job_ids": ["string"]
}
```
**Notes** : Remplace `SavedJobsNotifier` (hardcodé `{'4', '5'}` dans le mock). Appelé au démarrage pour initialiser l'état local.

---

### POST /api/v1/users/me/saved-jobs
Sauvegarder une offre.

**Body** `{ "job_id": "string" }`
**Response 201** `{ "job_id": "string" }`
**Notes** : Remplace `SavedJobsNotifier.toggle()` (côté add).

---

### DELETE /api/v1/users/me/saved-jobs/:jobId
Retirer une offre des sauvegardées.

**Response 204** : No content.
**Notes** : Remplace `SavedJobsNotifier.toggle()` (côté remove).

---

### GET /api/v1/users/me/blocked
Retourne les IDs des contacts bloqués par l'utilisateur connecté.

**Response 200** `{ "blocked_ids": ["string"] }`
**Notes** : Remplace `MessagingRepositoryMock.getBlockedIds()`.

---

### GET /api/v1/users/me/restricted
Retourne les IDs des contacts restreints par l'utilisateur connecté.

**Response 200** `{ "restricted_ids": ["string"] }`
**Notes** : Remplace `MessagingRepositoryMock.getRestrictedIds()`.

---

### POST /api/v1/users/me/blocked
Bloquer un contact.

**Body** `{ "contact_id": "string" }`
**Response 200** : OK.
**Notes** : Remplace `MessagingRepositoryMock.blockContact()`. Le `contact_id` est l'ID de l'utilisateur à bloquer (pas l'ID de la conversation).

---

### DELETE /api/v1/users/me/blocked/:contactId
Débloquer un contact.

**Response 204** : No content.
**Notes** : Remplace `MessagingRepositoryMock.unblockContact()`.

---

### POST /api/v1/users/me/restricted
Restreindre un contact.

**Body** `{ "contact_id": "string" }`
**Response 200** : OK.
**Notes** : Remplace `MessagingRepositoryMock.restrictContact()`.

---

### DELETE /api/v1/users/me/restricted/:contactId
Retirer la restriction sur un contact.

**Response 204** : No content.
**Notes** : Remplace `MessagingRepositoryMock.unrestrictContact()`.

---

## CANDIDATES — Profil public

### GET /api/v1/candidates/:candidateId/profile
Retourne le profil public complet d'un candidat (vu par un recruteur).
Contient identité + compétences + missions + feedbacks.

**Response 200**
```json
{
  "id": "string",
  "name": "string",
  "title": "string",
  "photo_url": "string|null",
  "location": "string",
  "domain": "string",
  "missions_count": 0,
  "rating": 4.9,
  "reviews_count": 12,
  "is_top_rated": true,
  "cover_letter": "string",
  "skill_groups": [
    {
      "title": "string",
      "skills": [
        {
          "name": "string",
          "level": "debutant|intermediaire|avance|expert"
        }
      ]
    }
  ],
  "languages": [
    {
      "name": "string",
      "proficiency": "string"
    }
  ],
  "tools": ["string"],
  "missions": [
    {
      "id": "string",
      "job_title": "string",
      "company_name": "string",
      "duration": "string",
      "rating": 4.5,
      "status": "termine|en_cours|annule"
    }
  ],
  "feedbacks": [
    {
      "id": "string",
      "reviewer_name": "string",
      "reviewer_role": "string",
      "reviewer_avatar": "string|null",
      "star_count": 5,
      "review_text": "string",
      "response": {
        "author_name": "string",
        "response_text": "string"
      }
    }
  ]
}
```
**Notes** :
- `response` dans `feedbacks[]` est `null` si le candidat n'a pas encore répondu au feedback
- `skill_groups[]` regroupe les compétences par catégorie métier (ex: `"Compétences métier"`)
- `duration` est une chaîne libre, ex: `"3 mois"`, `"2 semaines"`
- Données actuellement hardcodées dans `CandidateProfileScreen` — à remplacer par cet endpoint

---

## REPORTS

### POST /api/v1/reports
Signaler un utilisateur, un message ou un commentaire.

**Body**
```json
{
  "target_type": "user|message|comment",
  "target_id": "string",
  "reason": "string",
  "context": "string|null"
}
```
**Response 201** : `{ "report_id": "string" }`
**Notes** :
- `target_type: "user"` : signalement depuis `ReportScreen` (messagerie)
- `target_type: "comment"` : signalement depuis `ReportCommentScreen` (avis sur profil)
- `reason` : raison sélectionnée dans l'UI (ex: `"Fraude / Arnaque - Offre suspecte"`)
- `context` : texte libre additionnel optionnel

---

## JOBS (côté recruteur)

### GET /api/v1/jobs/mine
Retourne les annonces du recruteur connecté.

**Query params** (filtres homepage recruteur — optionnels) :
- `status` : `Brouillon|Publié|Terminé` (mappe `draft|searching|closed`)
- `posted_within` : `3d|7d|30d|90d|180d` (publié il y a ≤ N jours)
- `department` : `Marketing|IT|Ventes|RH|Finance|Opérations|Support Client|Design`

**Response 200**
```json
[{
  "id": "string",
  "title": "string",
  "company_name": "string",
  "recruiter_id": "string",
  "recruiter_name": "string",
  "recruiter_role": "string",
  "recruiter_avatar_asset": "string|null",
  "department": "string",
  "contract_type": "cdi|freelance|mission",
  "posted_at": "ISO8601",
  "status": "searching|draft|closed",
  "candidate_count": 0,
  "view_count": 0,
  "logo_asset": "string|null",
  "is_published": true
}]
```
**Notes** : Remplace `JobsRepositoryMock.getMyJobs()`. Filtrage client via `JobsController.filterJobs()` + `filteredJobsProvider` tant que l'API n'est pas branchée.

---

### GET /api/v1/jobs/:id
Retourne une annonce par ID avec ses candidats et commentaires.

**Response 200**
```json
{
  "id": "string",
  "title": "string",
  "company_name": "string",
  "recruiter_id": "string",
  "recruiter_name": "string",
  "recruiter_role": "string",
  "recruiter_avatar_asset": "string|null",
  "department": "string",
  "contract_type": "cdi|freelance|mission",
  "posted_at": "ISO8601",
  "status": "searching|draft|closed",
  "candidate_count": 0,
  "view_count": 0,
  "logo_asset": "string|null",
  "is_published": true,
  "candidates": [
    {
      "initials": "AL",
      "name": "string",
      "role": "string",
      "rating": 4.9,
      "avatar_url": "string|null"
    }
  ],
  "comments": [
    {
      "initials": "SM",
      "author_name": "string",
      "date": "string",
      "question": "string",
      "recruitor_label": "string",
      "recruitor_date": "string",
      "reply": "string"
    }
  ]
}
```
**Notes** :
- `candidates[]` : aperçu des candidats (nom, rôle, note, avatar) affiché dans l'onglet détail annonce. Différent de `GET /jobs/:jobId/candidates` qui retourne la liste complète avec `cover_letter` et `status`
- `comments[]` : questions posées par des candidats sur l'annonce + réponses du recruteur
- `date` : chaîne libre, ex: `"14 Oct."` — date de la question
- `recruitor_date` : chaîne libre, ex: `"Il y a 10 min"` — date de la réponse (`""` si pas encore répondu)
- `reply` : `""` si le recruteur n'a pas encore répondu
Remplace `JobsRepositoryMock.getJobById()`.

---

### POST /api/v1/jobs
Crée une nouvelle annonce (brouillon ou publiée).

**Body**
```json
{
  "title": "string",
  "contract_type": "cdi|freelance|mission",
  "description": "string",
  "candidate_count": 1,
  "salary": 0.0,
  "is_published": false
}
```
**Response 201** : Annonce créée (même format que GET /jobs/mine item).
**Notes** : Remplace `JobsRepositoryMock.saveJob()` en mode création.
Le backend doit utiliser la société du recruteur connecté par défaut (`company_name`) et renseigner les champs recruteur (`recruiter_id`, `recruiter_name`, `recruiter_role`, `recruiter_avatar_asset`) dans la réponse.

---

### PUT /api/v1/jobs/:id
Met à jour une annonce existante.

**Body** : Mêmes champs que POST.
**Response 200** : Annonce mise à jour (même format que GET /jobs/mine item).
**Notes** : Remplace `JobsRepositoryMock.saveJob()` en mode update.

---

### DELETE /api/v1/jobs/:id
Supprime une annonce.

**Response 204** : No content.
**Notes** : Remplace `JobsRepositoryMock.deleteJob()`.

---

## MISSIONS

### GET /api/v1/missions
Retourne les missions de l'utilisateur connecté (recruteur = missions créées, candidat = missions effectuées).

**Query params** (filtres homepage recruteur — optionnels) :
- `status` : `Non confirmée|En cours|Terminé` (mappe `unconfirmed|in_progress|completed`)
- `job_id` : filtre par annonce (candidatures / entretiens)
- `max_duration` : `7d|14d|30d|90d|180d` (durée mission ≤ N jours)
- `department` : voir liste `GET /jobs/mine`

**Response 200**
```json
[{
  "id": "string",
  "job_id": "string",
  "job_title": "string",
  "company_name": "string",
  "department": "string",
  "start_date": "ISO8601",
  "end_date": "ISO8601",
  "location": "string",
  "recruiter_name": "string",
  "candidate_name": "string",
  "candidate_rating": 0.0,
  "recruiter_rating": 0.0,
  "candidate_feedback": "string",
  "recruiter_feedback": "string",
  "status": "unconfirmed|in_progress|completed",
  "summary": "string|null",
  "image_url": "string|null",
  "team": [
    {
      "name": "string",
      "role": "string",
      "rating": 4.8,
      "avatar_url": "string|null"
    }
  ]
}]
```
**Notes** :
- `candidate_feedback` / `recruiter_feedback` : avis texte laissé à la fin de mission (`""` si pas encore soumis)
- `candidate_rating` / `recruiter_rating` : note donnée à l'autre partie (`0.0` si pas encore soumise)
- `summary` : résumé optionnel de la mission (`null` si non renseigné)
- `team[]` : membres de l'équipe associés à la mission
Remplace `JobsRepositoryMock.getMissions()`. Les missions `unconfirmed` non validées avant `start_date` sont supprimées côté serveur (mock : purge au `getMissions()`).
Côté candidat, le backend filtre automatiquement par l'utilisateur connecté.

---

### POST /api/v1/missions
Crée une mission (lancement depuis une candidature acceptée). Statut initial : `unconfirmed`.

**Body**
```json
{
  "job_id": "string",
  "job_title": "string",
  "company_name": "string",
  "department": "string",
  "candidate_name": "string",
  "start_date": "ISO8601",
  "end_date": "ISO8601",
  "location": "string",
  "image_url": "string|null"
}
```
**Response 201** : Mission créée (même format que GET /missions item, status `unconfirmed`).
**Notes** : Remplace `JobsRepositoryMock.createMission()`. Le `recruiter_name` est déduit de l'utilisateur connecté côté backend.

---

### PATCH /api/v1/missions/:id/confirm
Confirme une mission `unconfirmed` → passe en `in_progress`.

**Response 200** : Mission mise à jour (même format que GET /missions item).
**Notes** : Remplace `JobsRepositoryMock.confirmMission()`.

---

### PUT /api/v1/missions/:id/review
Soumet l'avis de fin de mission (rating + commentaire).

**Body** `{ "rating": 4.5, "feedback": "string" }`
**Response 200** : Mission mise à jour avec le review.
**Notes** : Remplace `JobsRepositoryMock.updateMissionReview()`.

---

## CANDIDATES (côté recruteur)

### GET /api/v1/jobs/:jobId/candidates
Retourne les candidats ayant postulé à une annonce.

**Query params** : `?status=nouveau|examine|archive`, `?sort=recent|best`
**Response 200**
```json
[{
  "id": "string",
  "name": "string",
  "title": "string",
  "photo_url": "string",
  "rating": 4.9,
  "reviews_count": 12,
  "is_top_rated": true,
  "cover_letter": "string",
  "status": "nouveau|examine|archive"
}]
```
**Notes** : Remplace `CandidatesRepositoryMock.getCandidates()`.
Le filtrage/tri se fait côté client via `CandidatesController.filterAndSort()`,
mais on peut aussi passer les query params pour pré-filtrer côté serveur.
⚠️ `CandidateModel.fromJson` utilise actuellement des clés camelCase — à corriger lors du branchement (voir table en début de spec).

---

### PUT /api/v1/candidates/:candidateId/status
Met à jour le statut d'un candidat (examine, archive...).

**Body** `{ "status": "examine|archive" }`
**Response 200** : OK.
**Notes** : Remplace `CandidatesRepositoryMock.updateCandidateStatus()`.

---

## APPLICATIONS (candidatures)

### GET /api/v1/applications
Retourne les candidatures de l'utilisateur connecté.
- Si recruteur : toutes les candidatures reçues sur ses annonces.
- Si candidat : ses propres candidatures.

**Query params** :
- `status` : `pending|accepted|rejected` ou libellés UI `En attente|Acceptée|Refusée`
- `applied_within` : `today|3d|7d|30d` (date de dépôt)
- `department` : voir liste `GET /jobs/mine`

**Response 200**
```json
[{
  "id": "string",
  "job_id": "string",
  "job_title": "string",
  "company_name": "string",
  "department": "string",
  "logo_asset": "string|null",
  "status": "pending|accepted|rejected",
  "applied_at": "ISO8601",
  "location": "string",
  "contract_type": "cdi|freelance|mission",
  "schedule_label": "string|null",
  "interview_date": "string|null",
  "candidate_name": "string",
  "candidate_avatar": "string|null",
  "candidate_domain": "string|null",
  "candidate_rating": 4.5,
  "motivation_letter": "string"
}]
```
**Notes** : Remplace `ApplicationsRepositoryMock.getMyApplications()`.
- `candidate_name` : Nom complet du candidat (obligatoire)
- `candidate_avatar` : URL ou chemin vers la photo de profil
- `candidate_domain` : Domaine d'expertise du candidat (ex: `"Développement Web"`)
- `candidate_rating` : Note moyenne du candidat (0.0 à 5.0)
- `motivation_letter` : Lettre de motivation complète du candidat
- `interview_date` : Chaîne libre affichée telle quelle, ex: `"Entretien prévu le 18 Oct."` (`null` si pas d'entretien)
- `applied_at` : Date/heure de candidature au format ISO8601, affichée `"jj/mm/aaaa à HH:mm"`

---

### POST /api/v1/applications
Candidater à une offre.

**Body** `{ "job_id": "string" }`
**Response 201** : Candidature créée (même format qu'un item de GET /applications).
**Notes** : Remplace `ApplicationsRepositoryMock.applyToJob()`.

---

### DELETE /api/v1/applications/:id
Annuler une candidature.

**Response 204** : No content.
**Notes** : Remplace `ApplicationsRepositoryMock.cancelApplication()`.

---

### PUT /api/v1/applications/:id/accept
Accepter une candidature (recruteur uniquement).

**Response 200** : Candidature mise à jour avec `status: "accepted"`.
**Notes** : Remplace `ApplicationsRepositoryMock.acceptApplication()`.
- Après acceptation, le statut passe à `"accepted"`, le bouton "Accepter" devient inactif dans l'UI

---

### PUT /api/v1/applications/:id/reject
Refuser une candidature (recruteur uniquement).

**Response 200** : Candidature mise à jour avec `status: "rejected"`.
**Notes** : Remplace `ApplicationsRepositoryMock.rejectApplication()`.

---

## INTERVIEWS (entretiens)

### GET /api/v1/interviews
Retourne tous les entretiens de l'utilisateur connecté.

**Query params** :
- `upcoming=true` : entretiens à venir uniquement
- `status` : `scheduled|completed|cancelled` ou libellés UI `Planifié|Terminé|Annulé`
- `scheduled_within` : `today|this_week|this_month|next_month`
- `department` : voir liste `GET /jobs/mine`

**Response 200**
```json
[{
  "id": "string",
  "candidate_id": "string",
  "candidate_name": "string",
  "candidate_avatar": "string|null",
  "job_id": "string",
  "job_title": "string",
  "department": "string",
  "scheduled_date": "ISO8601",
  "status": "scheduled|completed|cancelled",
  "notes": "string|null"
}]
```
**Notes** : Remplace `InterviewsRepositoryMock.getInterviews()` et `getUpcomingInterviews()`.
⚠️ `InterviewModel.fromJson` utilise actuellement des clés camelCase — à corriger lors du branchement (voir table en début de spec).

---

### GET /api/v1/interviews/:id
Retourne un entretien par ID.

**Response 200** : Même format que l'item de GET /interviews.
**Notes** : Remplace `InterviewsRepositoryMock.getInterviewById()`.

---

### POST /api/v1/interviews
Planifier un entretien.

**Body**
```json
{
  "candidate_id": "string",
  "job_id": "string",
  "scheduled_date": "ISO8601",
  "notes": "string|null"
}
```
**Response 201** : Entretien créé (même format que GET /interviews item).
**Notes** : Remplace `InterviewsRepositoryMock.createInterview()` et `CandidatesRepositoryMock.scheduleInterview()`.

---

### PUT /api/v1/interviews/:id
Mettre à jour un entretien (reprogrammer).

**Body** `{ "scheduled_date": "ISO8601", "notes": "string|null" }`
**Response 200** : Entretien mis à jour.
**Notes** : Remplace `InterviewsRepositoryMock.updateInterview()`.

---

### DELETE /api/v1/interviews/:id
Annuler un entretien.

**Response 204** : No content.
**Notes** : Remplace `InterviewsRepositoryMock.cancelInterview()`.

---

### PUT /api/v1/interviews/:id/complete
Marquer un entretien comme terminé.

**Body** `{ "notes": "string|null" }`
**Response 200** : Entretien mis à jour avec `status: "completed"`.
**Notes** : Remplace `InterviewsRepositoryMock.completeInterview()`.

---

## NOTIFICATIONS

### GET /api/v1/notifications
Retourne les notifications de l'utilisateur connecté.

**Query params** : `?filter=jobs|messagerie|candidatures` (optionnel)
**Response 200**
```json
[{
  "id": "string",
  "title": "string",
  "message": "string|null",
  "type": "newApplicants|newMessage|jobQuestion|missionExpiring|missionCompleted|announcementCreated|interviewAccepted|applicationAccepted|applicationRejected|applicationViewed|newNearbyOffer|jobMatchingPreferences|savedJobExpiring|newJobInCategory|profileViewed|profileIncomplete|system",
  "timestamp": "ISO8601",
  "is_read": false,
  "job_title": "string|null",
  "sender_name": "string|null",
  "avatar_url": "string|null",
  "context_image_url": "string|null",
  "count": 3
}]
```
**Notes** :
- `context_image_url` : image contextuelle de l'annonce associée à la notif (ex: pour `newMessage` lié à une annonce)
- `count` : nombre d'éléments agrégés (ex: `3` pour "3 nouveaux candidats") — `null` si non applicable
- Le regroupement par date (Aujourd'hui / Hier / …) et le filtrage par catégorie se font dans `NotificationsController`
Remplace `NotificationsRepositoryMock.getNotifications()`.

---

### PUT /api/v1/notifications/:id/read
Marquer une notification comme lue.

**Response 200** : OK.
**Notes** : Remplace `NotificationsRepositoryMock.markAsRead()`.

---

### DELETE /api/v1/notifications/:id
Supprimer une notification.

**Response 204** : No content.
**Notes** : Remplace `NotificationsRepositoryMock.deleteNotification()`.

---

## MESSAGING

### GET /api/v1/conversations
Retourne la liste des conversations de l'utilisateur (sans les messages complets).

**Response 200**
```json
[{
  "id": "string",
  "contact_name": "string",
  "contact_role": "string",
  "contact_avatar": "string|null",
  "is_online": false,
  "last_message": "string",
  "last_message_time": "ISO8601",
  "is_unread": true,
  "is_invitation": false,
  "is_group": false,
  "group_name": "string|null",
  "member_avatars": ["string"],
  "member_names": ["string"]
}]
```
**Notes** :
- `is_group` : `true` si la conversation est un groupe
- `group_name` : nom personnalisé du groupe (peut être `null` — afficher `member_names` à la place)
- `member_avatars` / `member_names` : liste des membres (pour l'avatar groupe et le nom affiché)
- Ne pas inclure `messages[]` dans cette liste — appeler `GET /conversations/:id` pour les messages
Remplace `MessagingRepositoryMock.getConversations()`.

---

### GET /api/v1/conversations/invitations
Retourne les invitations de conversation en attente.

**Response 200** : Même format que GET /conversations (avec `is_invitation: true`).
**Notes** : Remplace `MessagingRepositoryMock.getInvitations()`.

---

### GET /api/v1/conversations/:id
Retourne une conversation avec l'historique complet des messages.

**Response 200**
```json
{
  "id": "string",
  "contact_name": "string",
  "contact_role": "string",
  "contact_avatar": "string|null",
  "is_online": false,
  "last_message": "string",
  "last_message_time": "ISO8601",
  "is_unread": false,
  "is_invitation": false,
  "is_group": false,
  "group_name": "string|null",
  "member_avatars": ["string"],
  "member_names": ["string"],
  "messages": [
    {
      "id": "string",
      "sender_id": "string",
      "content": "string",
      "timestamp": "ISO8601",
      "is_read": true,
      "is_mine": true,
      "type": "text|image|file"
    }
  ]
}
```
**Notes** :
- `is_mine` : `true` si le message a été envoyé par l'utilisateur connecté
- `type: "image"` → `content` est l'URL de l'image
- `type: "file"` → `content` est l'URL du fichier (nom affiché : `content.split('/').last`)

---

### POST /api/v1/conversations/:id/messages
Envoyer un message texte.

**Body** `{ "content": "string", "type": "text" }`
**Response 201**
```json
{
  "id": "string",
  "sender_id": "string",
  "content": "string",
  "timestamp": "ISO8601",
  "is_read": false,
  "is_mine": true,
  "type": "text"
}
```
**Notes** : Remplace `MessagingRepositoryMock.sendMessage()`.

---

### POST /api/v1/conversations/:id/messages/image
Envoyer un message image.

**Body** : `multipart/form-data` avec champ `file` (image) + `type: "image"`
**Response 201** : Message envoyé (même format que POST /messages, `type: "image"`, `content` = URL de l'image).
**Notes** : Remplace `MessagingRepositoryMock.sendImageMessage()`.

---

### POST /api/v1/conversations/:id/messages/file
Envoyer un fichier (PDF, document, etc.).

**Body** : `multipart/form-data` avec champ `file` (document) + `type: "file"`
**Response 201** : Message envoyé (même format que POST /messages, `type: "file"`, `content` = URL du fichier).
**Notes** : Remplace `MessagingRepositoryMock.sendFileMessage()`.

---

### POST /api/v1/conversations
Créer ou récupérer une conversation avec un contact.

**Body** `{ "contact_id": "string" }`
**Response 200|201** : Conversation existante ou créée (format GET /conversations item + `messages: []`).
**Notes** : Remplace `MessagingRepositoryMock.getOrCreateConversation()`. Utiliser `contact_id` plutôt que le nom (le backend récupère le profil).

---

### POST /api/v1/conversations/group
Créer un groupe de conversation.

**Body** `{ "group_name": "string", "member_ids": ["string"] }`
**Response 201** : Conversation groupe créée (format GET /conversations item, `is_group: true`).
**Notes** : Remplace `MessagingRepositoryMock.createGroup()`.

---

### PUT /api/v1/conversations/:id/accept
Accepter une invitation de conversation.

**Response 200** : OK.
**Notes** : Remplace `MessagingRepositoryMock.acceptInvitation()`.

---

### DELETE /api/v1/conversations/:id/invitation
Refuser une invitation de conversation.

**Response 204** : No content.
**Notes** : Remplace `MessagingRepositoryMock.declineInvitation()`.

---

### DELETE /api/v1/conversations
Supprimer plusieurs conversations.

**Body** `{ "ids": ["string"] }`
**Response 204** : No content.
**Notes** : Remplace `MessagingRepositoryMock.deleteConversations()`.

---

## MAP / OFFRES GÉOLOCALISÉES

### GET /api/v1/jobs/map
Retourne les offres d'emploi avec coordonnées GPS pour la carte.

**Query params** : `?q=search`, `?category=string`, `?contract_type=string`, `?hours=string`, `?max_distance_km=10`
**Response 200**
```json
[{
  "id": "string",
  "title": "string",
  "company": "string",
  "category": "string",
  "distance": "2.5 km",
  "hours": "9h - 17h",
  "salary": 45.0,
  "contract_type": "CDI|CDD|Mission|Freelance",
  "rating": 4.8,
  "lat": 36.765,
  "lng": 3.048,
  "image_asset": "string|null",
  "recruiter_avatar": "string|null"
}]
```
**Notes** :
- `distance` : chaîne libre calculée par le backend par rapport à la position de l'utilisateur (ou centre carte)
- `recruiter_avatar` : avatar du recruteur affiché sur le marker carte
Remplace `MapRepositoryMock.getMapJobs()`. Le filtrage supplémentaire se fait côté client via `filteredMapJobsProvider`.

---

### GET /api/v1/users/me/recent-searches
Retourne les recherches récentes de l'utilisateur.

**Response 200** `{ "searches": ["string"] }`
**Notes** : Remplace `MapRepositoryMock.getRecentSearches()`. Peut également être stocké en local (SharedPreferences) si le backend ne gère pas cet historique.

---

### POST /api/v1/users/me/recent-searches
Ajouter une recherche récente.

**Body** `{ "query": "string" }`
**Response 201** : OK.
**Notes** : Remplace `MapRepositoryMock.saveRecentSearch()`.

---

### DELETE /api/v1/users/me/recent-searches
Effacer l'historique de recherche.

**Response 204** : No content.
**Notes** : Remplace `MapRepositoryMock.clearRecentSearches()`.

---

## SETTINGS

### GET /api/v1/settings
Retourne les paramètres de l'utilisateur.

**Response 200**
```json
{ "notifications_enabled": true, "dark_mode": false, "language_code": "fr" }
```

---

### PUT /api/v1/settings/notifications
Active/désactive les notifications.

**Body** `{ "enabled": true }`
**Response 200** : OK.

---

### PUT /api/v1/settings/theme
Active/désactive le mode sombre.

**Body** `{ "dark_mode": false }`
**Response 200** : OK.

---

### PUT /api/v1/settings/language
Change la langue de l'application.

**Body** `{ "language_code": "fr|en|ar" }`
**Response 200** : OK.

---

### DELETE /api/v1/account
Supprime le compte de l'utilisateur et toutes ses données.

**Response 204** : No content.
**Notes** : Action irréversible — confirmer côté frontend avant d'appeler.

---

## Récapitulatif des remplacements Mock → Http

| Repository Mock | Provider | Remplacer par |
|---|---|---|
| `JobsRepositoryMock` | `jobs_provider.dart` | `JobsRepositoryHttp` |
| `CandidatesRepositoryMock` | `candidates_provider.dart` | `CandidatesRepositoryHttp` |
| `ApplicationsRepositoryMock` | `applications_provider.dart` | `ApplicationsRepositoryHttp` |
| `InterviewsRepositoryMock` | `interviews_provider.dart` | `InterviewsRepositoryHttp` |
| `NotificationsRepositoryMock` | `notifications_provider.dart` | `NotificationsRepositoryHttp` |
| `CandidateNotificationsRepositoryMock` | `notifications_provider.dart` | `NotificationsRepositoryHttp` (même endpoint, filtre par rôle) |
| `MessagingRepositoryMock` | `messaging_provider.dart` | `MessagingRepositoryHttp` |
| `MapRepositoryMock` | `map_providers.dart` | `MapRepositoryHttp` |
| `UserRepositoryMock` | `profile_provider.dart` | `UserRepositoryHttp` |
| `SettingsRepositoryMock` | `settings_provider.dart` | `SettingsRepositoryHttp` |
| `SavedJobsNotifier` (état local) | `applications_provider.dart` | Initialiser depuis `GET /users/me/saved-jobs` |
| *(hardcodé dans `CandidateProfileScreen`)* | — | `CandidateProfileRepositoryHttp` → `GET /candidates/:id/profile` |

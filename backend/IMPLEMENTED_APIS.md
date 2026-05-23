# Backend — APIs implémentées et à venir

> Référence pour les agents suivants.
> Préfixe commun : `/api/v1/`
> Auth : `Authorization: Bearer <access_token>` (JWT)
> Erreurs : `{ "detail": "message" }`
> CSRF : désactivé (`CsrfViewMiddleware` retiré) — API JWT pure, pas de session browser
> Packages requis : voir `requirements.txt` (`google-auth`, `requests`, `channels` requis en plus du core)
>
> **Seed DB** : `python manage.py seed_db` — peuple la BDD avec 5 recruteurs, 8 candidats, 10 offres, 10 candidatures, 3 missions, 5 entretiens, 5 commentaires.
> Option `--flush` pour vider d'abord. Mot de passe universel : `Test1234!`
> Emails recruteurs : `karim.benali@lezitoun.dz`, `sonia.rahmani@elaurassi.dz`, `mohamed.khelifi@tafna.dz`, `amira.boukhelifa@literati.dz`, `yacine.messaoudi@soleil-dor.dz`
> Emails candidats : `amine.brahimi@gmail.com`, `nadia.ouali@gmail.com`, `sofiane.merad@gmail.com`, `yasmine.hadjadj@gmail.com`, `bilal.kaced@gmail.com`, `meriem.benzitouni@gmail.com`, `rami.slimani@gmail.com`, `lina.cherif@gmail.com`

---

## ✅ AUTH

| Méthode | Endpoint | Réponse |
|---------|----------|---------|
| POST | `/auth/register` | `{ access_token, user: { id, name, account_type } }` 201 |
| POST | `/auth/register/candidat` | `{ verification_required: true, role: "candidat" }` 201 |
| POST | `/auth/register/recruteur` | `{ verification_required: true, role: "recruteur" }` 201 |
| POST | `/auth/login` | `{ access, refresh, role, user: UtilisateurResponse }` |
| POST | `/auth/logout` | 204 |
| POST | `/auth/refresh` | `{ access }` |
| POST | `/auth/token/refresh` | `{ access }` (alias) |
| POST | `/auth/password/change` | 204 (body: `{ ancien_mot_de_passe, nouveau_mot_de_passe }`) |
| POST | `/auth/password/forgot` | `{ detail: "..." }` (body: `{ email }`) |
| POST | `/auth/password/reset` | 204 (body: `{ email, otp, nouveau_mot_de_passe }`) |
| POST | `/auth/verify-email` | `{ access, refresh, role, user }` (body: `{ email, otp }`) |
| POST | `/auth/resend-otp` | `{ detail: "OTP sent." }` (body: `{ email }`) |
| POST | `/auth/google` | `{ access, refresh, role, user }` ou `{ requires_role_selection: true, email, nom, prenom }` |
| POST | `/auth/google/complete` | `{ access, refresh, role, user }` (body: `{ email, nom, prenom, role, telephone? }`) |

---

## ✅ USERS / PROFIL

| Méthode | Endpoint | Réponse |
|---------|----------|---------|
| GET | `/users/me` | `UserMeResponse` — inclut `latitude` et `longitude` (float, nullable) en plus de `location` (string) |
| PUT/PATCH | `/users/me` | `UserMeResponse` (body: champs `nom, prenom, telephone, location, latitude, longitude, bio, avatar_url, domain, role, company, ...`) |
| GET | `/users/:id` | `UserMeResponse` |
| GET | `/users/:id/reviews` | `ReviewResponse[]` |
| GET | `/users/:id/cv` | `{ formations, experiences, languages: [{name, proficiency}], skills: [{name, level}] }` — languages from CandidateLanguage, skills from CandidateSkillGroup/CandidateSkill |
| PUT | `/users/:userId/reviews/:reviewId/reply` | `ReviewResponse` (body: `{ reply, recruiter_name? }`) |
| GET | `/users/me/saved-jobs` | `{ saved_job_ids: ["string"] }` — lecture seule (pour état cœur) |
| GET | `/users/me/blocked` | `{ blocked_ids: ["string"] }` |
| POST | `/users/me/blocked` | 204 (body: `{ user_id }`) |
| DELETE | `/users/me/blocked/:id` | 204 |
| GET | `/users/me/restricted` | `{ restricted_ids: ["string"] }` |
| POST | `/users/me/restricted` | 204 (body: `{ contact_id }`) |
| DELETE | `/users/me/restricted/:id` | 204 |
| POST | `/users/me/deactivate` | 204 |
| GET | `/users/me/preferences` | `{ push_notif_enabled: bool }` |
| PATCH | `/users/me/preferences` | `{ push_notif_enabled: bool }` (body: `{ push_notif_enabled: bool }`) |
| GET | `/users/me/recent-searches` | `{ searches: ["string"] }` |
| POST | `/users/me/recent-searches` | `{ query }` 201 (body: `{ query }`) |
| DELETE | `/users/me/recent-searches` | 204 — clear all |
| DELETE | `/users/me/recent-searches?query=x` | 204 — supprime une seule entrée |
| DELETE | `/account` | 204 |

**Shape UserMeResponse :**
```json
{
  "id": "string",
  "name": "string",
  "role": "candidat|recruteur|null",
  "domain": "string|null",
  "company": "string|null",
  "location": "string|null",
  "bio": "string|null",
  "avatar_url": "string|null",
  "followers_count": 0,
  "missions_count": 0,
  "rating": 4.8,
  "account_type": "recruiter|candidate"
}
```

**Shape ReviewResponse :**
```json
{
  "id": "integer",
  "note": 5,
  "commentaire": "string|null",
  "recruiter_reply": "string|null",
  "recruiter_reply_date": "ISO8601|null",
  "recruiter_name": "string|null",
  "evaluateur": "integer",
  "evalue": "integer",
  "date_evaluation": "YYYY-MM-DD"
}
```

---

## ✅ CANDIDAT — PROFIL PUBLIC

| Méthode | Endpoint | Réponse |
|---------|----------|---------|
| GET | `/candidates/:id/profile` | Profil public complet |

**Shape réponse :**
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
  "skill_groups": [{ "title": "string", "skills": [{ "name": "string", "level": "expert" }] }],
  "languages": [{ "name": "string", "proficiency": "string" }],
  "tools": ["string"],
  "missions": [{ "id": "string", "job_title": "string", "company_name": "string", "duration": "3 jours", "rating": 4.5, "status": "string" }],
  "feedbacks": [{ "id": "string", "reviewer_name": "string", "reviewer_role": "string", "reviewer_avatar": "string|null", "star_count": 5, "review_text": "string", "response": { "author_name": "string", "response_text": "string" } }]
}
```

---

## ✅ CANDIDAT — COMPÉTENCES, LANGUES, OUTILS, CV

| Méthode | Endpoint | Réponse |
|---------|----------|---------|
| GET | `/candidates/me/skill-groups` | `[{ id, title, order, skills: [{ id, name, level }] }]` |
| POST | `/candidates/me/skill-groups` | `{ id, title, order, skills: [] }` 201 (body: `{ title, order? }`) |
| DELETE | `/candidates/me/skill-groups/:id` | 204 |
| POST | `/candidates/me/skill-groups/:groupId/skills` | `{ id, name, level }` 201 (body: `{ name, level? }`) |
| DELETE | `/candidates/me/skill-groups/:groupId/skills/:skillId` | 204 |
| GET | `/candidates/me/languages` | `[{ id, name, proficiency }]` |
| POST | `/candidates/me/languages` | `{ id, name, proficiency }` 201 (body: `{ name, proficiency }`) |
| DELETE | `/candidates/me/languages/:id` | 204 |
| GET | `/candidates/me/tools` | `[{ id, name }]` |
| POST | `/candidates/me/tools` | `{ id, name }` 201 (body: `{ name }`) |
| DELETE | `/candidates/me/tools/:id` | 204 |
| GET | `/candidates/me/cv/formations` | `[{ id, title, institution, location, year, is_active, file_name, file_path }]` |
| POST | `/candidates/me/cv/formations` | `{ id, title, institution, location, year, is_active, file_name, file_path }` 201 |
| PUT | `/candidates/me/cv/formations/:id` | `{ id, title, institution, location, year, is_active, file_name, file_path }` |
| DELETE | `/candidates/me/cv/formations/:id` | 204 |
| Alias | `/candidats/me/cv/formations` | Alias FR compatible (`GET/POST/PUT/DELETE`, avec et sans trailing slash) |
| GET | `/candidates/me/cv/experiences` | `[{ id, title, company, location, period, end_date, is_app_mission, is_active }]` |
| POST | `/candidates/me/cv/experiences` | `{ id, title, company, location, period, end_date, is_app_mission, is_active }` 201 |
| PUT | `/candidates/me/cv/experiences/:id` | `{ id, title, company, location, period, end_date, is_app_mission, is_active }` |
| DELETE | `/candidates/me/cv/experiences/:id` | 204 |
| POST | `/candidates/me/cv/skills` | `{ id, name, level }` 201 — auto-creates "Compétences" group if needed (body: `{ name, level }`) |
| Alias | `/candidats/me/cv/experiences`, `/candidats/me/cv/skills` | Alias FR compatibles (avec et sans trailing slash) |

**Valeurs `level` pour CandidateSkill :** `debutant | intermediaire | avance | expert`

---

## ✅ JOBS (offres)

| Méthode | Endpoint | Réponse |
|---------|----------|---------|
| GET | `/jobs` | `PaginatedResponse<OffreResponse>` (filtres: `q, category, contract_type, lat, lng, max_distance_km, location`) |
| GET | `/jobs/mine` | `PaginatedResponse<OffreResponse>` (filtres: `status`) |
| GET | `/jobs/map` | `[MapJobItem]` (filtres: `q, category, contract_type, lat, lng, max_distance_km, location`) |
| GET | `/jobs/:id` | `OffreResponse` (inclut `candidates[]` et `comments[]`) |
| POST | `/jobs` | `OffreResponse` 201 (body: `{ title, contract_type, description, start_date, category?, salary?, latitude?, longitude? }`) |
| PUT/PATCH | `/jobs/:id` | `OffreResponse` |
| DELETE | `/jobs/:id` | 204 |
| POST | `/jobs/:id/close` | `OffreResponse` |
| GET | `/jobs/:id/candidates` | `PaginatedResponse<ApplicationResponse>` (filtres: `status, sort=recent\|best`) |
| POST | `/jobs/:id/candidates` | `ApplicationResponse` 201 (body: `{ motivation_letter? }`) |
| GET | `/jobs/:id/comments` | `[CommentResponse]` |
| POST | `/jobs/:id/comments` | `CommentResponse` 201 (body: `{ question }`) |
| POST | `/jobs/:jobId/comments/:commentId/reply` | `CommentResponse` (body: `{ reply }`) |
| GET | `/jobs/:id/statistics` | `{ job_id, view_count, total_applications, pending_applications, accepted_applications, rejected_applications }` |

**Shape OffreResponse :**
```json
{
  "id": "string",
  "title": "string",
  "company_name": "string",
  "contract_type": "string",
  "posted_at": "ISO8601|null",
  "status": "string",
  "candidate_count": 0,
  "view_count": 0,
  "logo_asset": "string|null",
  "is_published": true,
  "salary": 0.0,
  "recruiter_id": "string",
  "recruiter_name": "string",
  "recruiter_avatar_asset": "string|null",
  "department": "string|null",
  "location": "string|null",
  "schedule_label": "string|null",
  "candidates": [{ "initials": "AB", "name": "string", "role": "string", "rating": 4.5, "avatar_url": "string|null" }],
  "comments": [{ "id": 1, "initials": "AB", "author_name": "string", "date": "ISO8601", "question": "string", "recruitor_label": "string", "recruitor_date": "ISO8601", "reply": "string" }]
}
```

**Shape CommentResponse :**
```json
{
  "id": 1,
  "initials": "AB",
  "author_name": "string",
  "date": "ISO8601",
  "question": "string",
  "recruitor_label": "string",
  "recruitor_date": "ISO8601|\"\"",
  "reply": "string"
}
```

---

## ✅ MISSIONS

| Méthode | Endpoint | Réponse |
|---------|----------|---------|
| GET | `/missions` | `PaginatedResponse<MissionResponse>` (filtres: `status`) |
| POST | `/missions` | `MissionResponse` 201 (body: `{ job_id, start_date, end_date, location, image_url?, summary?, candidature_id? }`) |
| GET | `/missions/:id` | `MissionResponse` |
| PATCH | `/missions/:id/confirm` | `MissionResponse` |
| PUT | `/missions/:id/review` | `{ detail: "Review submitted." }` (body: `{ rating, feedback? }`) |
| POST | `/missions/:id/valider-debut` | `MissionResponse` (body: `{ date_debut? }`) |
| POST | `/missions/:id/valider-fin` | `MissionResponse` (body: `{ date_fin? }`) |
| GET | `/missions/:id/attestation` | `{ ... }` (données de l'attestation) |
| GET | `/missions/:id/team` | `[{ id, name, role, rating, avatar_url }]` |
| POST | `/missions/:id/team` | `{ id, name, role, rating, avatar_url }` 201 (body: `{ name, role, rating?, avatar_url? }`) |
| DELETE | `/missions/:id/team/:memberId` | 204 |

**Shape MissionResponse :**
```json
{
  "id": "string",
  "job_title": "string",
  "company_name": "string",
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
  "team": [{ "name": "string", "role": "string", "rating": 0.0, "avatar_url": "string|null" }]
}
```

---

## ✅ CANDIDATURES

| Méthode | Endpoint | Réponse |
|---------|----------|---------|
| GET | `/applications` | `PaginatedResponse<ApplicationResponse>` (filtres: `status`) |
| POST | `/applications` | `ApplicationResponse` 201 (body: `{ job_id, motivation_letter? }`) |
| DELETE | `/applications/:id` | 204 |
| PUT | `/applications/:id/accept` | `ApplicationResponse` — recruteur uniquement, `statut → acceptee` |
| PUT | `/applications/:id/reject` | `ApplicationResponse` — recruteur uniquement, `statut → refusee` |

---

## ✅ ENTRETIENS

| Méthode | Endpoint | Réponse |
|---------|----------|---------|
| GET | `/interviews` | `[InterviewResponse]` (filtre: `upcoming=true`) |
| GET | `/interviews/:id` | `InterviewResponse` |
| POST | `/interviews` | `InterviewResponse` 201 (body: `{ candidate_id, job_id, scheduled_date, notes? }`) |
| PUT | `/interviews/:id` | `InterviewResponse` (body: `{ scheduled_date?, notes? }`) |
| DELETE | `/interviews/:id` | 204 (passe `status` à `cancelled`) |
| PUT | `/interviews/:id/complete` | `InterviewResponse` (body: `{ notes? }`) |

---

## ✅ NOTIFICATIONS

| Méthode | Endpoint | Réponse |
|---------|----------|---------|
| GET | `/notifications` | `PaginatedResponse<NotificationResponse>` (filtres: `filter=jobs\|messaging\|applications`, `est_lue`, `type`) |
| PUT | `/notifications/:id/read` | `NotificationResponse` |
| PUT | `/notifications/read-all` | `{ detail: "..." }` |
| DELETE | `/notifications/:id` | 204 |
| GET | `/notifications/non-lues/count` | `{ count: integer }` |
| POST | `/notifications/push/token` | `{ detail: "Token registered." }` (body: `{ token }`) |

**Shape NotificationResponse :**
```json
{
  "id": "integer",
  "title": "string",
  "message": "string",
  "type": "candidature|mission|message|evaluation|signalement",
  "date_creation": "ISO8601",
  "is_read": false,
  "job_title": "string|null",
  "sender_name": "string|null",
  "avatar_url": "string|null",
  "context_image_url": "string|null",
  "count": "integer|null"
}
```

---

## ✅ MESSAGERIE

| Méthode | Endpoint | Réponse |
|---------|----------|---------|
| GET | `/conversations` | Liste des conversations actives |
| GET | `/conversations/invitations` | Invitations en attente |
| POST | `/conversations` | Créer/récupérer DM `{ contact_id }` |
| POST | `/conversations/group` | Créer groupe `{ group_name, member_ids }` |
| DELETE | `/conversations/delete` | 204 (body: `{ ids: [...] }`) |
| GET | `/conversations/:id` | Conversation + historique messages |
| POST | `/conversations/:id/read-all` | Marquer tout lu |
| POST | `/conversations/:id/messages` | `{ content }` → 201 |
| POST | `/conversations/:id/messages/image` | multipart `file` → 201 |
| POST | `/conversations/:id/messages/file` | multipart `file` → 201 |
| PUT | `/conversations/:id/accept` | Accepter invitation |
| DELETE | `/conversations/:id/decline` | 204 |
| POST | `/conversations/:id/block` | Bloquer contact |
| DELETE | `/conversations/:id/unblock` | Débloquer contact |

---

## ✅ PARAMÈTRES

| Méthode | Endpoint | Réponse |
|---------|----------|---------|
| GET | `/settings` | `UserSettingsResponse` |
| PUT | `/settings` | `UserSettingsResponse` |
| PUT | `/settings/notifications` | `UserSettingsResponse` (body: `{ enabled: bool }`) |
| PUT | `/settings/theme` | `UserSettingsResponse` (body: `{ dark_mode: bool }`) |
| PUT | `/settings/language` | `UserSettingsResponse` (body: `{ language_code: "fr|en|ar" }`) |

---

## ✅ SIGNALEMENTS

| Méthode | Endpoint | Réponse |
|---------|----------|---------|
| POST | `/reports` | `{ report_id: "string|null" }` 201 (body: `{ target_type: "user|message|comment", target_id, reason, description? }`) |

---

## ✅ PROFIL CANDIDAT (routes candidats/me)

| Méthode | Endpoint | Réponse |
|---------|----------|---------|
| GET | `/candidats/me` | `CandidatResponse` |
| PATCH | `/candidats/me` | `CandidatResponse` |
| GET | `/candidats/:id` | `CandidatPublicResponse` |
| GET/POST | `/candidats/me/disponibilites` | `[DisponibiliteResponse]` / 201 |
| PUT/DELETE | `/candidats/me/disponibilites/:id` | `DisponibiliteResponse` / 204 |
| GET/POST | `/candidats/me/portfolio` | `[MediaResponse]` / 201 |
| DELETE | `/candidats/me/portfolio/:id` | 204 |
| GET | `/candidats/me/historique` | `PaginatedResponse<MissionResponse>` |
| GET/POST/DELETE | `/candidats/me/saved` | Offres sauvegardées — DELETE prend `?offre_id=` en query param |
| GET/POST | `/candidats/me/alertes` | `[AlerteResponse]` / 201 |
| PATCH/DELETE | `/candidats/me/alertes/:id` | `AlerteResponse` / 204 |

---

## ✅ PROFIL RECRUTEUR

| Méthode | Endpoint | Réponse |
|---------|----------|---------|
| GET | `/recruteurs/me` | `RecruteurResponse` |
| PATCH | `/recruteurs/me` | `RecruteurResponse` |
| GET | `/recruteurs/:id` | `RecruteurPublicResponse` |

---

## ✅ ADMIN

| Méthode | Endpoint | Réponse |
|---------|----------|---------|
| GET | `/admin/utilisateurs` | `PaginatedResponse<UtilisateurResponse>` (filtres: `statut_compte, est_verifie`) |
| POST | `/admin/utilisateurs/:id/sanctionner` | `UtilisateurResponse` (body: `{ action: "suspendre|bloquer|reactiver" }`) |

---

## BASE DE DONNÉES — Migrations appliquées

| App | Migration | Contenu |
|-----|-----------|---------|
| users | 0006 | `avatar_url`, `location` sur Utilisateur ; `titre_poste`, `logo_url` sur Recruteur ; `titre_poste` sur Candidat ; `RestrictedUser` |
| users | 0007 | `bio` sur Utilisateur ; `domain` sur Candidat et Recruteur ; `CandidateSkillGroup`, `CandidateSkill`, `CandidateLanguage`, `CandidateTool`, `CvFormation`, `CvExperience` |
| users | 0008 | `push_token` sur Utilisateur |
| jobs | 0005 | `created_at`, `image_url`, `location` sur Offre |
| jobs | 0006 | `schedule_label` sur Offre ; `summary` sur Mission ; `JobComment` ; `MissionTeamMember` |
| applications | 0003 | `date_postulation` DateField → DateTimeField |
| messaging | 0006 | `type` sur Message |
| notifications | 0003 | `context_image_url` sur Notification |
| reviews | 0003 | `recruiter_reply`, `recruiter_reply_date` sur Evaluation |
| reviews | 0004 | `recruiter_name` sur Evaluation |

> ✅ **Toutes les migrations ont été appliquées** (`python manage.py migrate` — 51 migrations OK)

---

## 🔄 Alignement Frontend (TODO/API)

Routes demandées par le frontend (compatibilité) à garder comme alias ou à normaliser:

| Méthode | Endpoint frontend observé | Statut recommandé |
|---------|----------------------------|-------------------|
| POST | `/jobs/:jobId/apply` | Alias vers `POST /applications` (ou `POST /jobs/:id/candidates`) |
| PATCH | `/interviews/:id/cancel` | Alias vers `DELETE /interviews/:id` |
| PATCH | `/notifications/:id/read` | Alias vers `PUT /notifications/:id/read` |
| POST | `/conversations/:id/accept` | Alias vers `PUT /conversations/:id/accept` |
| DELETE | `/conversations/:id/invitation` | Alias vers `DELETE /conversations/:id/decline` |
| DELETE | `/conversations` (body `{ ids }`) | Alias vers `DELETE /conversations/delete` |
| PATCH | `/candidates/:candidateId/status` | À spécifier (workflow statut candidat) |

Notes d’alignement:
- Map: garder `/jobs/map` comme route canonique (éviter `/map/jobs` côté frontend).
- Messaging média: choisir une seule convention:
  - soit `POST /conversations/:id/messages` multipart + champ `type`
  - soit routes dédiées `/messages/image` et `/messages/file`.
 
## Update 2026-05-22 
- Saved Jobs screen branche sur GET /candidats/me/saved pour la liste reelle des offres enregistrees. 
- Regle d'equipe: toute modification backend/frontend liee aux endpoints doit mettre a jour ce fichier dans le meme changement.
 
## Update 2026-05-22 (Map/Home filtres) 
- Map search/frontend utilise l'endpoint GET /jobs/map avec q, category, contract_type, lat, lng, max_distance_km, location. 
- Homepage candidat alignee sur la logique de recherche/filtres (jobs concernes seulement). 
- Regle d'equipe appliquee: toute modif liee aux endpoints implique update de ce fichier.
 
## Update 2026-05-22 (Profile/Home fix) 
- Profile: carte info utilisateur affiche Localisation au lieu de Secteur (frontend only). 
- Homepage: le filtre Localisation choisi est maintenant prioritaire dans la requete jobs (GET /jobs avec location), avec mapping contrat vers l'API.
 
## Update 2026-05-22 (Create Job payload fix) 
- Frontend POST /jobs: ajout de start_date (obligatoire backend) et description non vide pour eviter les 400 sur creation d'annonce recruteur.
 
## Update 2026-05-22 (Create Job stability) 
- POST /jobs: start_date accepte cote backend (fallback date du jour si absent). 
- Frontend create job: start_date envoye et description non vide; durcissement UI contre RenderFlex overflow sur JobCard.

## Update 2026-05-22 (Edit Profile wiring candidat/recruteur)
- Ecran `Modifier profil` candidat: bouton `Modifier` de la section competences branche vers l'ecran de completion candidat pour modifier CV/competences (flows `/users/me`, `/candidates/me/cv/*`, `/candidates/me/languages`).
- Ecran `Modifier profil` recruteur ajoute et relie depuis le header recruteur; le bouton `Modifier` des informations entreprise ouvre l'ecran de completion recruteur.
- Endpoints verifies/branches pour modification profil:
  - Base profil (commun): `PATCH /users/me`
  - Profil recruteur (structure): `PATCH /recruteurs/me`

## Update 2026-05-22 (Saved Jobs affichage)
- Frontend Saved Jobs aligne sur la vraie reponse paginee de `GET /candidats/me/saved`:
  chaque item est un `SavedJob` avec l'offre dans `offre`.
- Mapping frontend corrige pour parser `item.offre` (et fallback ancien format direct).
- Rafraichissement auto de la page Saved Jobs apres bookmark/unbookmark via dependance sur `savedJobsProvider`.

## Update 2026-05-22 (Saved Jobs bug fix)
- Corrige race condition: `savedJobsRemoteProvider` re-fetchait depuis le backend AVANT que l'appel API POST/DELETE soit termine, retournant l'ancienne liste.
- Fix: suppression du `ref.watch(savedJobsProvider)` dans `savedJobsRemoteProvider`; `SavedJobsNotifier.toggle()` appelle desormais `ref.invalidate(savedJobsRemoteProvider)` apres chaque appel API reussi.
- Fix: `JobModel.fromJson` — `posted_at` null (possible si ni `created_at` ni `date_debut` n'est renseignee sur le backend) ne crash plus (fallback `DateTime.now()`).
- Aucun changement backend.

## Update 2026-05-22 (Candidature overlay motivation)
- Ecran detail annonce candidat: ajout d'un overlay pour saisir la lettre de motivation avant envoi.
- Envoi backend branche sur `POST /applications` avec payload:
  - `job_id`
  - `motivation_letter` (si renseignee)
- Ajustement UI: suppression des libelles de localisation hardcodes dans le detail annonce.

## Update 2026-05-22 (Retrait candidature depuis detail offre)
- Ecran detail offre candidat: quand une candidature existe, le bouton en haut a droite devient `Retirer` (remplace `Candidater`).
- Action branchee sur l'endpoint existant `DELETE /applications/:id` (frontend: `cancelApplication`).

## Update 2026-05-22 (Homepage filtres => recherche)
- Homepage candidat: validation des filtres declenche explicitement le rafraichissement de la recherche jobs (`nearbyJobsProvider`).
- Filtrage frontend renforce pour appliquer tous les filtres selectionnes (contrat multi-valeurs, localisation, disponibilite) sur les resultats de `GET /jobs`.

## Update 2026-05-22 (Stabilite affichage homepage jobs)
- Homepage candidat: fallback automatique sur `GET /jobs` (jobs publies) quand la requete "nearby" est en loading/erreur/vide au demarrage.
- Objectif: eviter l'affichage vide intermittent au lancement avant que les donnees de localisation/profil soient resolues.

## Update 2026-05-22 (Home jobs + filtres data-driven)
- Homepage candidat: invalidation automatique de la recherche jobs (`nearbyJobsProvider`) quand le profil candidat ou la position GPS change, pour eviter le cas "les jobs apparaissent seulement apres passage par la map".
- Cartes d'annonces (home/liste): suppression des valeurs hardcodees de localisation/horaires; affichage branche sur les champs API `location` et `schedule_label`.
- Mapping frontend `OffreResponse` aligne: `JobModel/JobEntity` expose maintenant `location` et `schedule_label`.
- Filtres candidat alignes avec les types de contrat supportes par l'API jobs: `CDI`, `Mission`, `Freelance` (suppression des options hors scope `CDD`, `Stage`).
- Filtrage client des annonces renforce pour utiliser les vrais champs annonces:
  - localisation => match sur `job.location`
  - horaires/disponibilite => match sur `job.schedule_label`

## Update 2026-05-22 (Stabilite auth 401 frontend)
- Interceptor HTTP frontend durci pour eviter les 401 intermittents:
  - serialisation des erreurs via `QueuedInterceptor`
  - refresh token mutualise (une seule tentative partagee entre requetes concurrentes)
  - retry unique par requete (`__retried__`) pour eviter les boucles
  - exclusion des routes auth (`/auth/*`) du mecanisme de refresh automatique
- Impact: reduction des cas ou certaines requetes partent sans session valide apres un pic de 401.

## Update 2026-05-22 (Map jobs parsing fix)
- Frontend map: parsing de `GET /jobs/map` rendu tolerant aux deux formats backend:
  - liste directe `[...]`
  - reponse paginee `{ results: [...] }`
- Mapping des champs map aligne avec variantes backend:
  - `company` ou `company_name`
  - `hours` ou `schedule_label`
  - `lat/lng` ou `latitude/longitude`
  - `image_asset` ou `logo_asset`
  - `recruiter_avatar` ou `recruiter_avatar_asset`
- Les items sans coordonnees valides sont ignores pour eviter le crash silencieux et la liste vide.

## Update 2026-05-22 (Map city display + nearest-first sorting)
- Affichage carte annonces: la ville est affichee (`location/city/wilaya`) a la place d'une valeur de distance/coordonnees dans les cartes map.
- Conversion map->job detail alignee: `location` et `schedule_label` sont propages vers l'entite job.
- Requete `GET /jobs/map`: suppression de la limitation serveur `max_distance_km` dans l'appel frontend pour ne pas tronquer la liste.
- Tri proximity preserve cote frontend: les annonces sont ordonnees par distance croissante depuis la position utilisateur (plus proches en premier).

## Update 2026-05-22 (Attribut city sur annonces frontend)
- Modele d'annonce frontend enrichi avec l'attribut `city`:
  - `JobModel.city` parse `city` (ou `ville`) depuis la reponse API jobs
  - `JobEntity.city` expose cet attribut au domaine/UI
- Fallback automatique: si `city` absent, derive depuis `location` (premiere partie avant virgule).
- Affichage UI annonces candidat priorise `city` puis fallback `location`.

## Update 2026-05-22 (Affichage ville strict depuis BDD)
- Suppression des fallbacks UI qui affichaient `location` (pouvant contenir des coordonnees GPS).
- Affichage annonces (home + cards) force sur `city` uniquement; si absent => `Ville non precisee`.
- Map parsing aligne: `city` map prend uniquement `city/wilaya` (plus de fallback sur `location`).

## Update 2026-05-22 (Jobs data normalization + homepage filter results)
- Backend `OffreSerializer` aligne:
  - `location` renvoie uniquement le champ texte BDD (plus de fallback `latitude,longitude`).
  - ajout du champ `city` derive de `offre.location` (prefixe avant la virgule).
- Backend `GET /jobs/map`: ajout de `city` dans chaque item, `hours` aligne sur `schedule_label`.
- Donnees BDD `offre` normalisees pour les tests filtres:
  - `type_contrat` force dans l'ensemble `cdi|mission|freelance`
  - `schedule_label` force dans l'ensemble `Temps plein|Temps partiel|Flexible`
  - `location` forcee en texte ville (`<Ville>, Algerie`) pour toutes les offres existantes.
- Homepage candidat: selection d'un filtre ouvre l'ecran de resultats (comme la map) et affiche les annonces correspondantes meme sans texte dans la barre de recherche.

## Update 2026-05-22 (Details posts: donnees reelles + map preview reel)
- Backend `OffreResponse` enrichi pour la page detail:
  - ajout de `description`, `latitude`, `longitude` dans le serializer read jobs.
  - `location` renvoie le texte BDD (plus de coordonnees stringifiees).
- Frontend detail annonce candidat:
  - suppression du texte description hardcode.
  - tags caracteristiques alimentes par les vraies donnees annonce (`contract_type`, `schedule_label`, `city`).
  - preview map utilise maintenant les vraies coordonnees annonce (`latitude`, `longitude`) pour le marker et l'ouverture Google Maps.
- Frontend detail annonce/map:
  - suppression d'un libelle localisation hardcode (`Lyon, FR`) remplace par `job.city`.

## Update 2026-05-22 (CV Formation bool parsing fix)
- Endpoint `POST/PUT /candidates/me/cv/formations`: normalisation backend du champ `is_active` pour accepter les formats HTTP usuels (`true/false`, `1/0`, bool natif) et eviter l'erreur 500 due a un string non converti.

## Update 2026-05-22 (Frontend certificat formation preview/download)
- Frontend overlay certificat (page profil):
  - resolution de `file_path` relatif (`/media/...`) vers URL absolue backend.
  - affichage image certificat actif quand le fichier est `png/jpg/jpeg`.
  - bouton `Télécharger le certificat (PDF)` branche pour ouvrir/telecharger le vrai fichier (URL backend) au lieu d'un snackbar mock.

## Update 2026-05-22 (Map stale data refresh)
- Frontend Map:
  - `allMapJobsProvider` passe en `AutoDisposeFutureProvider` pour eviter la conservation de donnees perimees entre navigations.
  - `recentSearchesProvider` map passe en `AutoDisposeStateNotifierProvider` pour recharger l'historique recemment.
  - `MapScreen` invalide explicitement `allMapJobsProvider` au montage de l'ecran, a l'ouverture de la recherche map et a la soumission d'une recherche.
- Impact: la section "emplois a proximite" et la page de recherche map affichent des donnees fraiches.

## Update 2026-05-22 (Map unified base + separate search logic)
- Refactor providers map pour unifier les sources:
  - `baseMapJobsProvider`: dataset de base (suggestions + proximite), sans query texte.
  - `searchedMapJobsProvider`: dataset recherche map, avec `mapSearchQueryProvider`.
  - `filteredMapJobsProvider`: tri proximity sur la base.
  - `filteredMapSearchResultsProvider`: tri proximity sur les resultats recherche.
- `MapScreen` aligne l'UI:
  - suggestions / proximite / overlay suggestions utilisent la base unifiee.
  - feuille "resultat" utilise les resultats de recherche (logique query conservee).
  - filtres restent appliques des deux cotes via la meme construction de requete map.

## Update 2026-05-22 (Map rollback + map endpoint freshness)
- Rollback frontend map recherche a la logique precedente:
  - retour au provider unique `allMapJobsProvider` pour suggestions/proximite/recherche map (comme avant le dernier refactor).
- Verification backend endpoint `GET /jobs/map`:
  - ajout du filtre `statut='searching'` en plus de `is_published=True` pour eviter de remonter des offres publiees mais non actives (source potentielle de jobs outdated).

## Update 2026-05-22 (DB jobs status for map visibility)
- Donnees BDD ajustees: 3 offres supplementaires passees en `statut='searching'` et `is_published=True` pour etre visibles dans `GET /jobs/map` sans changer la logique de filtre backend.
- Ajustement complementaire: 1 offre repassee en `draft` avec `is_published=False` pour conserver un jeu de donnees mixte (brouillon + publiees).

## Update 2026-05-22 (Map no hardcoded data in proximite cards)
- `GET /jobs/map` enrichi avec champs reels:
  - `status`, `posted_at`, `candidate_count`, `view_count`.
- Frontend map:
  - `MapJobEntity` et parser HTTP alignes sur ces champs.
  - conversion `MapJobEntity -> JobEntity` (section emplois a proximite) supprime les valeurs hardcodees (`contractType`, `postedAt`, `status`, `candidateCount`, `viewCount`) et utilise les donnees API.

## Update 2026-05-22 (Map candidature + detail reel + media parity)
- `GET /jobs/map` renvoie maintenant `image_asset` depuis `offre.image_url` (URL absolue si chemin relatif) pour aligner l'affichage photo avec la Home.
- Ecran map:
  - labels boutons changes de `Candidater` vers `Postuler`.
  - bouton `Postuler` branche avec saisie de lettre de motivation (overlay) puis appel endpoint candidature via `applicationsNotifierProvider.apply(jobId, motivationLetter)`.
  - action `Voir details` depuis la carte map ouvre l'ecran detail offre candidat reel (`CandidateJobDetailsScreen`) au lieu d'un detail map mocke.
  - rendu image map durci: support `http(s)` et assets locaux.

## Update 2026-05-22 (Map page clean provider architecture)
- Backend `GET /jobs/map`: implemention effective du filtre `max_distance_km` (deja documente mais non code).
- Frontend Map — architecture providers propre et isolee:
  - `allMapJobsProvider`: toutes les offres GPS (statut=searching), sans restriction distance → pins carte + suggestions overlay recherche + resultats recherche.
  - `filteredMapJobsProvider`: tri par proximite sur `allMapJobsProvider` → markers carte.
  - `mapNearbyJobsProvider` (NOUVEAU, dedie): offres GPS dans 30 km, triees par proximite → section "Emplois a proximite" (bottom sheet uniquement). Appelle `GET /jobs/map?max_distance_km=30&lat=&lng=`. Aucun partage avec les providers homepage ou search screen.
  - `_BottomSheetContent` converti en `ConsumerStatefulWidget` pour acceder directement a `mapNearbyJobsProvider`.
- Homepage/search screen non modifies: leurs providers restent independants.
- Sections map resumees:
  - Pins carte → `filteredMapJobsProvider` (tous GPS jobs, tri proximite)
  - Suggestions (horizontal) → `widget.allJobs` = `filteredMapJobsProvider`
  - Emplois a proximite → `mapNearbyJobsProvider` (30 km)
  - Overlay recherche suggestions → `allMapJobsProvider` (tous, sans limite)
  - Feuille resultats recherche → `filteredMapJobsProvider` avec `mapSearchQueryProvider`

## Update 2026-05-22 (Recent searches fixes)
- Backend `DELETE /users/me/recent-searches`: ajoute methode `delete` a `RecentSearchListView`.
  - Sans param: efface tout l'historique (clear-all).
  - Avec `?query=x`: supprime uniquement cette entree.
- Backend `POST /users/me/recent-searches` → corrige `MapRepositoryHttp.saveRecentSearch` qui appelait la mauvaise URL; utilise desormais `POST /searches`.
- Frontend `RecentSearchNotifier.removeSearch()`: persiste maintenant la suppression via `DELETE /users/me/recent-searches?query=x` (avant: local seulement).
- Frontend `JobsRepositoryHttp`: ajout de `removeRecentSearch(query)`.
- Frontend `candidate_search_screen.dart`: la section recherches recentes s'affiche toujours quand le champ est vide (avant: les filtres actifs declenchaient l'affichage des offres a la place).

## Update 2026-05-22 (Home/Map filters + sorting behavior)
- Frontend Home:
  - section haute des annonces triee de la plus recente a la plus ancienne (tri par `postedAt` descendant).
- Frontend Map:
  - appliquer un filtre depuis la barre de filtres map ouvre maintenant directement la feuille de resultats.
  - la feuille de resultats map n'est plus vide quand la requete texte est vide: elle charge les offres via `GET /jobs` avec les filtres actifs.
  - filtrage localisation conserve le comportement "exact location" cote home/candidate filters (filtre sur `city/location` des annonces).
- Alignement des options de filtres:
  - options map normalisees sur les memes choix contractuels/disponibilite utilises par les filtres candidats:
    - Horaires: `Temps plein`, `Temps partiel`, `Flexible`
    - Categorie (contrat): `CDI`, `Mission`, `Freelance`
  - categories candidat (ecran filtres) alignees sur les categories map (`Restauration`, `Technologie`, `Commerce`, `Sante`, `Education`, `Transport`).

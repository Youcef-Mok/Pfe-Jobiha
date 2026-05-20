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

## AUTH

### POST /api/v1/auth/login
Connexion avec email + mot de passe.

**Body**
```json
{ "email": "string", "password": "string" }
```
**Response 200**
```json
{ "access_token": "string", "refresh_token": "string", "user": { "id", "name", "account_type": "recruiter|candidate" } }
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
{ "access_token": "string", "user": { "id", "name", "account_type" } }
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

### PUT /api/v1/users/me
Met à jour le profil de l'utilisateur authentifié.

**Body** : Mêmes champs que GET /users/me (champs optionnels).
**Response 200** : Profil mis à jour.
**Notes** : Remplace `UserRepositoryMock.updateProfile()`.

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
  "formations": [{ "title", "institution", "location", "year", "is_active", "file_name" }],
  "experiences": [{ "title", "company", "location", "period", "is_app_mission", "is_active" }],
  "languages": [{ "name", "level" }],
  "skills": [{ "name", "level_label", "progress" }]
}
```
**Notes** : Remplace `UserRepositoryMock.getCvData()`.

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
Retourne une annonce par ID.

**Response 200** : Même format que ci-dessus + `candidates[]` + `comments[]`.
**Notes** : Remplace `JobsRepositoryMock.getJobById()`.

---

### POST /api/v1/jobs
Crée une nouvelle annonce (brouillon ou publiée).

**Body**
```json
{ "title": "string", "contract_type": "string", "description": "string", "candidate_count": 1, "salary": 0.0, "is_published": false }
```
**Response 201** : Annonce créée.
**Notes** : Remplace `JobsRepositoryMock.saveJob()` en mode création.

---

### PUT /api/v1/jobs/:id
Met à jour une annonce existante.

**Body** : Mêmes champs que POST.
**Response 200** : Annonce mise à jour.
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
  "job_id": "string",
  "status": "unconfirmed|in_progress|completed",
  "image_url": "string|null"
}]
```
**Notes** : Remplace `JobsRepositoryMock.getMissions()`. Les missions `unconfirmed` non validées avant `start_date` sont supprimées côté serveur (mock : purge au `getMissions()`).
Côté candidat, le backend filtre automatiquement par l'utilisateur connecté
(ne pas filtrer par `candidate_name` côté client — voir profile_provider.dart TODO).

---

### POST /api/v1/missions
Crée une mission (lancement depuis une candidature acceptée). Statut initial : `unconfirmed`.

**Body** `{ "job_id", "candidate_name", "start_date", "end_date", "location", … }`
**Response 201** : Mission créée.
**Notes** : Remplace `JobsRepositoryMock.createMission()`.

---

### PATCH /api/v1/missions/:id/confirm
Confirme une mission `unconfirmed` → passe en `in_progress`.

**Response 200** : Mission mise à jour.
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
  "contract_type": "string",
  "schedule_label": "string|null",
  "candidate_name": "string",
  "candidate_avatar": "string|null",
  "candidate_domain": "string|null",
  "candidate_rating": 4.5,
  "motivation_letter": "string"
}]
```
**Notes** : Remplace `ApplicationsRepositoryMock.getMyApplications()`.
- `candidate_name` : Nom complet du candidat (obligatoire)
- `candidate_avatar` : Chemin vers la photo de profil (ex: "assets/images/pdp_1.png")
- `candidate_domain` : Domaine d'expertise du candidat (ex: "Développement Web")
- `candidate_rating` : Note moyenne du candidat (0.0 à 5.0)
- `motivation_letter` : Lettre de motivation complète du candidat
- `applied_at` : Date/heure de candidature au format ISO8601, utilisée pour afficher "jj/mm/aaaa à HH:mm"

---

### POST /api/v1/applications
Candidater à une offre.

**Body** `{ "job_id": "string" }`
**Response 201** : Candidature créée.
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
- Après acceptation, le statut de la candidature passe à "accepted"
- La candidature reste visible dans la liste mais le bouton "Accepter" devient grisé et non-cliquable
- L'interface affiche "Acceptée" au lieu de "Accepter"

---

### PUT /api/v1/applications/:id/reject
Refuser une candidature (recruteur uniquement).

**Response 200** : Candidature mise à jour avec `status: "rejected"`.
**Notes** : Remplace `ApplicationsRepositoryMock.rejectApplication()`.
- Après refus, la candidature peut être supprimée de la liste (swipe-to-delete dans l'UI)

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
Le filtrage "à venir" et le tri par date se font via `InterviewsController.filterUpcoming()`.

---

### GET /api/v1/interviews/:id
Retourne un entretien par ID.

**Response 200** : Même format que ci-dessus.
**Notes** : Remplace `InterviewsRepositoryMock.getInterviewById()`.

---

### POST /api/v1/interviews
Planifier un entretien.

**Body**
```json
{ "candidate_id": "string", "job_id": "string", "scheduled_date": "ISO8601", "notes": "string|null" }
```
**Response 201** : Entretien créé.
**Notes** : Remplace `InterviewsRepositoryMock.createInterview()` et `CandidatesRepositoryMock.scheduleInterview()`.

---

### PUT /api/v1/interviews/:id
Mettre à jour un entretien (reprogrammer).

**Body** : `{ "scheduled_date": "ISO8601", "notes": "string|null" }`
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
**Response 200** : Entretien mis à jour avec status `completed`.
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
  "type": "newApplicants|newMessage|jobQuestion|...",
  "timestamp": "ISO8601",
  "is_read": false,
  "job_title": "string|null",
  "sender_name": "string|null",
  "avatar_url": "string|null",
  "count": 3
}]
```
**Notes** : Remplace `NotificationsRepositoryMock.getNotifications()`.
Le filtrage par catégorie et le regroupement par date se font via `NotificationsController` (déjà implémenté).

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
Retourne la liste des conversations de l'utilisateur.

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
  "messages": []
}]
```
**Notes** : Remplace `MessagingRepositoryMock.getConversations()`.

---

### GET /api/v1/conversations/invitations
Retourne les invitations de conversation en attente.

**Response 200** : Même format que GET /conversations.
**Notes** : Remplace `MessagingRepositoryMock.getInvitations()`.

---

### POST /api/v1/conversations/:id/messages
Envoyer un message texte.

**Body** `{ "content": "string" }`
**Response 201** : Message envoyé.
**Notes** : Remplace `MessagingRepositoryMock.sendMessage()`.
Pour les images/fichiers, utiliser multipart/form-data.

---

### POST /api/v1/conversations/:id/messages/image
Envoyer un message image.

**Body** : `multipart/form-data` avec champ `file`.
**Response 201** : Message envoyé.

---

### POST /api/v1/conversations
Créer ou récupérer une conversation avec un contact.

**Body** `{ "contact_name": "string", "contact_role": "string", "contact_avatar": "string|null" }`
**Response 200|201** : Conversation existante ou créée.
**Notes** : Remplace `MessagingRepositoryMock.getOrCreateConversation()`.

---

### POST /api/v1/conversations/group
Créer un groupe de conversation.

**Body** `{ "group_name": "string", "member_ids": ["string"] }`
**Response 201** : Conversation groupe créée.
**Notes** : Remplace `MessagingRepositoryMock.createGroup()`.

---

### PUT /api/v1/conversations/:id/accept
Accepter une invitation de conversation.

**Response 200** : OK.

---

### DELETE /api/v1/conversations/:id/decline
Refuser une invitation de conversation.

**Response 204** : No content.

---

### DELETE /api/v1/conversations
Supprimer plusieurs conversations.

**Body** `{ "ids": ["string"] }`
**Response 204** : No content.

---

### POST /api/v1/conversations/:id/block
Bloquer un contact.

**Response 200** : OK.

---

### DELETE /api/v1/conversations/:id/block
Débloquer un contact.

**Response 200** : OK.

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
  "image_asset": "string|null"
}]
```
**Notes** : Remplace `MapRepositoryMock.getMapJobs()`.
Le filtrage supplémentaire se fait côté client via `filteredMapJobsProvider`.
À terme, passer les filtres en query params pour alléger le client.

---

### GET /api/v1/searches/recent
Retourne les recherches récentes de l'utilisateur.

**Response 200** `{ "searches": ["string"] }`
**Notes** : Remplace `MapRepositoryMock.getRecentSearches()`.

---

### POST /api/v1/searches
Ajouter une recherche récente.

**Body** `{ "query": "string" }`
**Response 201** : OK.
**Notes** : Remplace `MapRepositoryMock.addRecentSearch()`.

---

### DELETE /api/v1/searches
Effacer l'historique de recherche.

**Response 204** : No content.
**Notes** : Remplace `MapRepositoryMock.clearHistory()`.

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

# Rapport de branchement — Frontend → Backend

> Date : 2026-05-21
> Branche : `pulling-branch`
> Objectif : Remplacer tous les `*RepositoryMock` par des `*RepositoryHttp` appelant le vrai backend Django REST.

---

## Résumé

| Statut | Module |
|--------|--------|
| ✅ Branché | Jobs & Missions |
| ✅ Branché | Applications (Candidatures) |
| ✅ Branché | Profile (Utilisateur + CV + Avis) |
| ✅ Branché | Notifications |
| ✅ Branché | Map (Offres géolocalisées + Recherches récentes) |
| ✅ Branché | Settings (Paramètres + Logout + Suppression compte) |
| ✅ Branché | Interviews (Entretiens) |
| ✅ Branché | Candidates (Liste candidats d'une offre) |
| ⏳ Différé | Messaging (WebSocket + HTTP — complexité élevée) |

---

## Repositories HTTP créés

### 1. Jobs & Missions
**Fichier :** `lib/features/jobs/data/repositories/jobs_repository_http.dart`

| Méthode | Endpoint |
|---------|----------|
| `getMyJobs()` | `GET /jobs/mine` |
| `getJobById(id)` | `GET /jobs/:id` |
| `saveJob(job)` | `POST /jobs` (création si temp ID) / `PATCH /jobs/:id` (mise à jour) |
| `deleteJob(id)` | `DELETE /jobs/:id` |
| `getMissions()` | `GET /missions` |
| `createMission(params)` | `POST /missions` |
| `confirmMission(id)` | `PATCH /missions/:id/confirm` |
| `updateMissionReview(id, rating, feedback)` | `PUT /missions/:id/review` + re-fetch |

**Notes :**
- Temp ID détecté si `> 999999999` (13 chiffres = `DateTime.now().millisecondsSinceEpoch`)
- `_parseMission` gère les dates nulles avec fallback `DateTime.now()`

---

### 2. Applications (Candidatures)
**Fichier :** `lib/features/applications/data/repositories/applications_repository_http.dart`

| Méthode | Endpoint |
|---------|----------|
| `getMyApplications()` | `GET /applications` |
| `applyToJob(jobId)` | `POST /applications` body: `{ job_id }` |
| `cancelApplication(id)` | `DELETE /applications/:id` |
| `acceptApplication(id)` | `PUT /applications/:id/accept` |
| `rejectApplication(id)` | `PUT /applications/:id/reject` |

**Notes :**
- `ApplicationModel.fromJson` ajouté au modèle (n'existait pas)
- Chaîne statuts : DB `en_attente/acceptee/refusee` → serializer `pending/accepted/rejected` → enum `ApplicationStatus`

---

### 3. Profile
**Fichier :** `lib/features/profile/data/repositories/user_repository_http.dart`

| Méthode | Endpoint |
|---------|----------|
| `getCurrentUser()` | `GET /users/me` |
| `getUserById(id)` | `GET /users/:id` |
| `updateProfile(user)` | `PATCH /users/me` |
| `getEmployeeReviews(userId)` | `GET /users/:id/reviews` |
| `getCvData(userId)` | `GET /users/:id/cv` |

**Notes :**
- Normalisation `account_type` : `candidat` → `candidate`, `recruteur` → `recruiter`
- Fallback `''` sur les champs nullable `company`, `location`, `bio`
- Mapping niveaux compétences : `debutant→0.25`, `intermediaire→0.5`, `avance→0.75`, `expert→1.0`

---

### 4. Notifications
**Fichier :** `lib/features/notifications/data/repositories/notifications_repository_http.dart`

| Méthode | Endpoint |
|---------|----------|
| `getNotifications()` | `GET /notifications` |
| `markAsRead(id)` | `PUT /notifications/:id/read` |
| `deleteNotification(id)` | `DELETE /notifications/:id` |

**Notes :**
- Recruteur et candidat utilisent la même implémentation HTTP (le backend filtre par rôle JWT)
- Les IDs backend sont des entiers — normalisés en `String` pour l'entité

---

### 5. Map
**Fichier :** `lib/features/map/data/repositories/map_repository_http.dart`

| Méthode | Endpoint |
|---------|----------|
| `getAllMapJobs()` | `GET /jobs/map` |
| `getRecentSearches()` | `GET /users/me/recent-searches` |
| `saveRecentSearch(query)` | `POST /users/me/recent-searches` body: `{ query }` |
| `clearRecentSearches()` | `DELETE /users/me/recent-searches` |

**Notes :**
- `distance` : `N/A` (backend sans coordonnées utilisateur) → chaîne vide ; sinon `"2.5 km"`
- `categoryIcon` (`IconData`) dérivé de la chaîne `category` côté client (ne vient pas du backend)
- Réponse `MapJobItem` : `{ id, title, company, category, distance, salary, contract_type, rating, recruiter_avatar, lat, lng }`

---

### 6. Settings
**Fichier :** `lib/features/settings/data/repositories/settings_repository_http.dart`

| Méthode | Endpoint |
|---------|----------|
| `getSettings()` | `GET /settings` |
| `updateNotificationsEnabled(enabled)` | `PUT /settings/notifications` body: `{ enabled }` |
| `updateDarkMode(enabled)` | `PUT /settings/theme` body: `{ dark_mode }` |
| `updateLanguage(code)` | `PUT /settings/language` body: `{ language_code }` |
| `logout()` | `POST /auth/logout` + `TokenStorage.clear()` |
| `deleteAccount()` | `DELETE /account` + `TokenStorage.clear()` |

**Notes :**
- `logout()` efface les tokens locaux même si l'appel serveur échoue (best-effort)

---

### 7. Interviews
**Fichier :** `lib/features/interviews/data/repositories/interviews_repository_http.dart`

| Méthode | Endpoint |
|---------|----------|
| `getInterviews()` | `GET /interviews` |
| `getUpcomingInterviews()` | `GET /interviews?upcoming=true` |
| `getInterviewById(id)` | `GET /interviews/:id` |
| `createInterview(interview)` | `POST /interviews` body: `{ candidate_id, job_id, scheduled_date, notes? }` |
| `updateInterview(interview)` | `PUT /interviews/:id` body: `{ scheduled_date?, notes? }` |
| `cancelInterview(id)` | `DELETE /interviews/:id` |
| `completeInterview(id, notes)` | `PUT /interviews/:id/complete` |

**Notes :**
- Le backend retourne du snake_case (`candidate_id`, `scheduled_date`, etc.)
- `InterviewModel.fromJson` attend du camelCase → normalisation effectuée dans le repo HTTP

---

### 8. Candidates
**Fichier :** `lib/features/candidates/data/repositories/candidates_repository_http.dart`

| Méthode | Endpoint |
|---------|----------|
| `getCandidates(jobId)` | `GET /jobs/:jobId/candidates` |
| `updateCandidateStatus(appId, status)` | `PUT /applications/:id/accept` ou `PUT /applications/:id/reject` |
| `scheduleInterview(candidateId, date, timeSlot)` | `POST /interviews` |

**Notes :**
- Le backend retourne des `ApplicationResponse` — mapping vers `CandidateModel` :
  - `candidate_name` → `name`
  - `candidate_domain` → `title`
  - `candidate_avatar` → `photoUrl`
  - `candidate_rating` → `rating`
  - `motivation_letter` → `coverLetter`
- Mapping statut : `pending→nouveau`, `accepted→examine`, `rejected→archive`
- `scheduleInterview` parse le `timeSlot` `"HH:mm-HH:mm"` pour extraire l'heure de début

---

## Providers mis à jour

| Provider | Avant | Après |
|----------|-------|-------|
| `jobsRepositoryProvider` | `JobsRepositoryMock()` | `JobsRepositoryHttp()` |
| `applicationsRepositoryProvider` | `ApplicationsRepositoryMock()` | `ApplicationsRepositoryHttp()` |
| `userRepositoryProvider` | `UserRepositoryMock()` | `UserRepositoryHttp()` |
| `notificationsRepositoryProvider` | `NotificationsRepositoryMock()` | `NotificationsRepositoryHttp()` |
| `candidateNotificationsRepositoryProvider` | `CandidateNotificationsRepositoryMock()` | `NotificationsRepositoryHttp()` |
| `mapRepositoryProvider` | `MapRepositoryMock()` | `MapRepositoryHttp()` |
| `settingsRepositoryProvider` | `SettingsRepositoryMock()` | `SettingsRepositoryHttp()` |
| `interviewsRepositoryProvider` | `InterviewsRepositoryMock()` | `InterviewsRepositoryHttp()` |
| `candidatesRepositoryProvider` | `CandidatesRepositoryMock()` | `CandidatesRepositoryHttp()` |

---

## Endpoints ajoutés à `api_endpoints.dart`

```dart
// Notifications
static String notificationRead(int id)   => '$_base/notifications/$id/read';
static String notificationDelete(int id) => '$_base/notifications/$id';
static const String notificationsReadAll = '$_base/notifications/read-all';

// Users
static String userReviews(int id)        => '$_base/users/$id/reviews';
static String savedJobIds                =  '$_base/users/me/saved-jobs';
static String deleteAccount              =  '$_base/account';

// Settings
static const String settings             = '$_base/settings';
static const String settingsNotifs       = '$_base/settings/notifications';
static const String settingsTheme        = '$_base/settings/theme';
static const String settingsLanguage     = '$_base/settings/language';

// Map
static const String mapJobs              = '$_base/jobs/map';
static const String recentSearches       = '$_base/users/me/recent-searches';

// Interviews
static const String interviews           = '$_base/interviews';
static String interviewDetail(int id)    => '$_base/interviews/$id';
static String interviewComplete(int id)  => '$_base/interviews/$id/complete';
```

---

## Corrections effectuées en parallèle

| Fichier | Correction |
|---------|-----------|
| `application_model.dart` | Ajout du `factory ApplicationModel.fromJson(...)` manquant |
| `job_model.dart` | Fix `JobCandidateModel.fromJson` : `avatarUrl` → `avatar_url` + null safety |
| `job_model.dart` | Fix `JobCommentModel.fromJson` : camelCase → snake_case avec fallbacks |
| `user_repository_http.dart` | Fix interpolation inutile ligne 37 (`'${...}'` → `...`) |
| `backend/apps/users/views.py` | Suppression du POST dupliqué sur `SavedJobIdsView` |
| `backend/apps/applications/views.py` | Suppression de `UpdateCandidateStatusView` (statuts invalides, pas de vérif rôle) |
| `token_storage.dart` | Remplacement `SharedPreferences` par `dart:js_interop` (fix `MissingPluginException` sur web) |
| `backend/IMPLEMENTED_APIS.md` | Mis à jour après chaque changement backend |

---

## Module restant — Messaging (différé)

Le module messaging n'a **pas** été branché car il combine :
- **HTTP** : `GET /conversations`, `POST /conversations`, `POST /conversations/:id/messages`, etc.
- **WebSocket** : `ws://host/ws/chat/:convId/?token=...` (temps réel, reconnexion, gestion d'état)

Il nécessite une implémentation dédiée avec `web_socket_channel` et une gestion d'état plus complexe.

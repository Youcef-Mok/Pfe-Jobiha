# Architecture — Job App (Flutter)

> Document de référence pour tous les agents et développeurs.
> **À mettre à jour** à chaque ajout de module, endpoint ou changement structurel.
> Voir aussi `API_SPEC.md` pour le détail des endpoints REST.

---

## Stack technique

| Élément | Choix |
|---------|-------|
| Framework | Flutter (Dart) |
| State management | Riverpod (`StateNotifierProvider`, `FutureProvider`, `Provider`) |
| Architecture | Clean Architecture feature-first |
| Navigation | GoRouter (`app/router.dart`) |
| Mock data | `*RepositoryMock` → remplacé par `*RepositoryHttp` au branchement API |
| Auth | JWT Bearer token (non encore branché) |

---

## Règle d'or : la chaîne obligatoire

```
Screen / Widget
    ↓  watch/read
Provider  (data/providers/)
    ↓  délègue TOUT
Controller  (domain/)
    ↓  appelle
Repository interface  (data/repositories/)
    ↓  implémenté par
*RepositoryMock  ←→  *RepositoryHttp  (swap au branchement)
```

### Ce qui est INTERDIT

| Où | Ce qu'on ne fait PAS |
|----|----------------------|
| Screen / Widget | Appel direct au provider du repository ou au controller repository |
| Provider | Logique métier inline (filtrage, tri, transformation) — ça va dans le Controller |
| Provider | Appel direct `_repo.methode()` — passer par `_controller.methode()` |
| Controller | Import de Riverpod ou de Flutter — le controller est pur Dart |
| Repository Mock | Logique autre que simulation de délai + données statiques |

### Ce qui EST acceptable dans le Provider

- Combiner plusieurs streams Riverpod (`ref.watch(a)` + `ref.watch(b)`)
- État UI pur : onglet actif, filtre sélectionné, query de recherche
- `StateNotifier` pour la gestion du state local (ex. formulaires)
- Providers **calculés** (`filteredJobsProvider`, `candidateApplicationsListProvider`, …) qui délèguent au **Controller** — jamais de `.where()` / tri métier inline dans le provider

### Ce qui est INTERDIT dans les Screens

- Filtrage ou tri de listes (`apps.where`, `controller.filterAndSort` dans le `build`, etc.)
- Voir `API_SPEC.md` → section **Filtrage — convention frontend / branchement API**

---

## Structure des dossiers

```
lib/
├── app/
│   ├── app.dart                    # ProviderScope + MaterialApp
│   ├── router.dart                 # GoRouter — toutes les routes
│   ├── recruiter_shell.dart        # Shell recruteur (bottom nav)
│   └── candidate_shell.dart        # Shell candidat (bottom nav)
│
├── core/
│   ├── theme/app_theme.dart        # AppColors, TextStyles, AppTheme
│   │                               # Couleurs clés : violet=#401E66, bg=#FCFBFB, slate900=#0F172A
│   ├── utils/
│   │   ├── color_utils.dart
│   │   └── icon_utils.dart
│   └── widgets/                    # Widgets partagés (nav bars, overlays globaux)
│
├── routes/app_routes.dart          # Constantes de noms de routes
│
└── features/
    └── <module>/
        ├── domain/                 # Pur Dart — zéro dépendance Flutter/Riverpod
        │   ├── *_entity.dart       # Entités immuables (const constructors)
        │   └── *_controller.dart   # Logique métier (filtrage, tri, orchestration)
        │
        └── data/
            ├── models/             # *Model (JSON ↔ Entity) — extends ou contient Entity
            ├── repositories/
            │   ├── *_repository.dart       # Interface abstraite (abstract class)
            │   └── *_repository_mock.dart  # Implémentation mock (Future.delayed + données statiques)
            └── providers/
                └── *_provider.dart         # Providers Riverpod — câblage Repository → Controller → State
```

---

## Modules et leur état

### applications
| Fichier | Rôle |
|---------|------|
| `domain/application_entity.dart` | `ApplicationEntity`, `ApplicationStatus` enum |
| `domain/applications_controller.dart` | `fetchApplications`, `apply`, `cancel`, `accept`, `reject`, `filterByStatus`, `filterRecent`, `filterByRecruiterFilters` |
| `data/repositories/applications_repository.dart` | Interface abstraite |
| `data/repositories/applications_repository_mock.dart` | TODO(API) sur chaque méthode |
| `data/providers/applications_provider.dart` | `applicationsRepositoryProvider`, `applicationsControllerProvider`, `ApplicationsNotifier`, `applicationsNotifierProvider`, `filteredApplicationsProvider`, `recentApplicationsProvider`, `SavedJobsNotifier`, `savedJobsProvider`, `CandidateFiltersNotifier`, `candidateFiltersProvider` |

### candidates
| Fichier | Rôle |
|---------|------|
| `domain/candidate_entity.dart` | `CandidateEntity`, `CandidateStatus` enum |
| `domain/candidates_controller.dart` | `filterAndSort(candidates, tab, sortMode)` |
| `data/models/candidate_model.dart` | `CandidateModel extends CandidateEntity` (héritage direct — pas de `.toEntity()`) |
| `data/repositories/candidates_repository.dart` | Interface — retourne `List<CandidateModel>` (covariant safe) |
| `data/repositories/candidates_repository_mock.dart` | TODO(API) sur chaque méthode |
| `data/providers/candidates_provider.dart` | `candidatesRepositoryProvider`, `candidatesControllerProvider`, `CandidatesNotifier`, `candidatesNotifierProvider` |

> **Note importante** : `CandidateModel extends CandidateEntity` (contrairement aux autres modules où Model et Entity sont séparés). Pas besoin de `.toEntity()`.

### interviews
| Fichier | Rôle |
|---------|------|
| `domain/interview_entity.dart` | `InterviewEntity` |
| `domain/interviews_controller.dart` | `fetchAll`, `fetchById`, `create`, `update`, `cancel`, `complete`, `filterUpcoming(interviews, limit)`, `filterByRecruiterFilters` |
| `data/models/interview_model.dart` | `InterviewModel` + `.toEntity()` + `.fromEntity()` |
| `data/repositories/interviews_repository.dart` | Interface abstraite |
| `data/repositories/interviews_repository_mock.dart` | TODO(API) sur chaque méthode |
| `data/providers/interviews_provider.dart` | `interviewsRepositoryProvider`, `interviewsControllerProvider`, `InterviewsNotifier`, `interviewsNotifierProvider`, `filteredInterviewsProvider`, `upcomingInterviewsProvider` |

### jobs
| Fichier | Rôle |
|---------|------|
| `domain/job_entity.dart` | `JobEntity` (+ `recruiterId`, `recruiterName`, `recruiterRole`, `recruiterAvatarAsset`), `ContractType`, `CreateJobForm`, `EditJobForm` |
| `domain/mission_entity.dart` | `MissionEntity`, `MissionReview` |
| `domain/recruiter_filters.dart` | `RecruiterFilters`, `RecruiterFilterDates` (intervalles date) |
| `domain/jobs_controller.dart` | `fetchMyJobs`, `fetchMissions`, `createJob`, `publishJob`, `updateJob`, `deleteJob`, `updateMissionReview`, `filterActive`, `filterDrafts`, `filterJobs`, `filterMissions` |
| `data/repositories/jobs_repository.dart` | Interface abstraite |
| `data/repositories/jobs_repository_mock.dart` | TODO(API) sur chaque méthode |
| `data/providers/jobs_provider.dart` | `jobsRepositoryProvider`, `jobsControllerProvider`, `JobsNotifier`, `MissionsNotifier`, `recruiterFiltersProvider`, `filteredJobsProvider`, `filteredMissionsProvider`, `recruiterPublishedJobsProvider`, `recruiterFilteredPublishedJobsProvider`, `recruiterFilteredMissionsByNameProvider`, `combinedJobsAndMissionsProvider`, `CreateJobFormNotifier`, `EditJobFormNotifier`, `MissionReviewNotifier`, `CandidateMissionsNotifier`, `candidateMissionsProvider` |
| `widgets/recruiter_filter_bar.dart` | Chips Statut / Date / Département (homepage recruteur) |
| `widgets/recruiter_filter_sheets.dart` | Overlays statut (liste), date (chips), département (chips) |

> **Note** : `candidateMissionsProvider` vit dans `jobs_provider.dart` (pas dans `profile_provider.dart`) pour éviter une dépendance circulaire.

### map
| Fichier | Rôle |
|---------|------|
| `domain/map_job_entity.dart` | `MapJobEntity` |
| `domain/map_controller.dart` | `fetchMapJobs`, `fetchRecentSearches`, `addRecentSearch`, `clearHistory`, `filterJobs(jobs, query)` |
| `data/repositories/map_repository.dart` | Interface abstraite |
| `data/repositories/map_repository_mock.dart` | TODO(API) sur chaque méthode |
| `data/providers/map_providers.dart` | `mapRepositoryProvider`, `mapControllerProvider`, `allMapJobsProvider`, `filteredMapJobsProvider`, `RecentSearchesNotifier`, `recentSearchesProvider`, `selectedMapJobProvider`, `mapFiltersProvider` |

### messaging
| Fichier | Rôle |
|---------|------|
| `domain/message_entity.dart` | `ConversationEntity`, `MessageEntity`, `MessageType` |
| `domain/chat_controller.dart` | `MessagingController extends StateNotifier<MessagingState>` — toutes les opérations de messagerie |
| `data/models/chat_model.dart` | `ConversationModel`, `MessageModel` + `.toEntity()` |
| `data/repositories/messaging_repository.dart` | Interface abstraite (fichier actif) |
| `data/repositories/messaging_repository_mock.dart` | TODO(API) sur chaque méthode |
| `data/providers/messaging_provider.dart` | `messagingRepositoryProvider`, `messagingControllerProvider` (fichier actif) |
| `data/providers/chat_provider.dart` | `export 'messaging_provider.dart'` — alias de compatibilité, à supprimer au branchement |

> **Note** : `MessagingController` est un `StateNotifier` (pas un simple controller), car la messagerie a un état réactif complexe (`MessagingState`). Pattern accepté.

### notifications
| Fichier | Rôle |
|---------|------|
| `domain/notification_entity.dart` | `NotificationEntity`, `NotificationType`, `NotificationCategory`, `NotificationFilter` |
| `domain/notifications_controller.dart` | `NotificationsController extends StateNotifier<NotificationsState>` — fetch, markAsRead, markAllAsRead, setFilter, filteredNotifications, groupedNotifications |
| `data/models/notification_model.dart` | `NotificationModel` + `.fromJson()` + `.toEntity()` |
| `data/repositories/notifications_repository.dart` | Interface abstraite |
| `data/repositories/notifications_repository_mock.dart` | Deux classes : `NotificationsRepositoryMock` (recruteur) + `CandidateNotificationsRepositoryMock` (candidat) |
| `data/providers/notifications_provider.dart` | `notificationsRepositoryProvider` + `notificationsControllerProvider` (recruteur), `candidateNotificationsRepositoryProvider` + `candidateNotificationsControllerProvider` (candidat) |

> **Note** : Deux mocks distincts recruteur/candidat → au branchement, un seul `NotificationsRepositoryHttp` suffit (le backend filtre par rôle JWT).

### profile
| Fichier | Rôle |
|---------|------|
| `domain/user_entity.dart` | `UserEntity`, `EmployeeReviewEntity` |
| `domain/cv_entity.dart` | `CvEntity`, `CvFormationEntity`, `CvExperienceEntity`, `CvLanguageEntity`, `CvSkillEntity` |
| `domain/profile_controller.dart` | `fetchCurrentUser`, `fetchUserById(userId)`, `fetchEmployeeReviews(userId)`, `fetchCvData(userId)`, `updateProfile` |
| `data/models/user_model.dart` | `UserModel`, `EmployeeReviewModel` + `.toEntity()` |
| `data/repositories/user_repository.dart` | Interface abstraite (`getCurrentUser`, `getUserById`, `getEmployeeReviews`, `updateProfile`, `getCvData`) |
| `data/repositories/user_repository_mock.dart` | Données recruteur + candidat (`_reviews` / `_candidateReviews`), branch sur `userId` dans `getEmployeeReviews` |
| `data/providers/profile_provider.dart` | `userRepositoryProvider`, `profileControllerProvider`, `UserNotifier`, `publicRecruiterProvider(userId)`, `publicRecruiterReviewsProvider(userId)`, alias `publicUserProvider(userId)` / `publicUserReviewsProvider(userId)`, `candidateCurrentUserProvider`, `CvNotifier`, `cvNotifierProvider`, `candidateEmployeeReviewsProvider`, `candidateCvDataProvider`, `profileTabProvider`, `candidateProfileTabProvider` |

> **Note** : `candidateMissionsProvider` a été volontairement placé dans `jobs_provider.dart` (évite une dépendance circulaire profile ↔ jobs).

### settings
| Fichier | Rôle |
|---------|------|
| `domain/settings_controller.dart` | `SettingsController` — toggle notifications, dark mode, langue, delete account |
| `data/models/settings_model.dart` | `AppSettings` |
| `data/repositories/settings_repository.dart` | Interface abstraite |
| `data/repositories/settings_repository_mock.dart` | TODO(API) sur chaque méthode |
| `data/providers/settings_provider.dart` | `settingsRepositoryProvider`, `settingsControllerProvider` |

### auth
> Module non encore architecturé proprement — screens uniquement, pas de repository/controller.
> À créer lors du branchement : `auth_repository.dart`, `auth_controller.dart`, `auth_provider.dart`.

---

## Conventions de nommage

| Élément | Convention | Exemple |
|---------|-----------|---------|
| Entity | `PascalCase + Entity` | `JobEntity` |
| Model | `PascalCase + Model` | `JobModel` |
| Repository (interface) | `PascalCase + Repository` | `JobsRepository` |
| Repository mock | `PascalCase + RepositoryMock` | `JobsRepositoryMock` |
| Repository HTTP | `PascalCase + RepositoryHttp` | `JobsRepositoryHttp` |
| Controller | `PascalCase + Controller` | `JobsController` |
| Provider (repo) | `camelCase + RepositoryProvider` | `jobsRepositoryProvider` |
| Provider (controller) | `camelCase + ControllerProvider` | `jobsControllerProvider` |
| Provider (notifier) | `camelCase + NotifierProvider` | `jobsNotifierProvider` |
| Notifier | `PascalCase + Notifier` | `JobsNotifier` |

---

## Patterns de provider autorisés

### Pattern 1 — Simple (lecture seule)
```dart
// Provider simple qui délègue au controller
final activeJobsProvider = Provider<List<JobEntity>>((ref) {
  final jobs = ref.watch(jobsNotifierProvider);
  final controller = ref.watch(jobsControllerProvider);
  return jobs.whenOrNull(data: controller.filterActive) ?? [];
});
```

### Pattern 2 — StateNotifier (mutations)
```dart
class JobsNotifier extends StateNotifier<AsyncValue<List<JobEntity>>> {
  final JobsController _controller; // ← toujours le controller, jamais le repo

  JobsNotifier(this._controller) : super(const AsyncValue.loading()) {
    Future.microtask(() => fetch());
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _controller.fetchMyJobs());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
```

### Pattern 3 — StateNotifier dans domain (état complexe)
Utilisé par `NotificationsController` et `MessagingController` quand l'état est trop riche pour être dans le provider. Le controller hérite de `StateNotifier` et est directement utilisé comme `StateNotifierProvider`.

---

## Couleurs de référence (AppColors)

```dart
violet      = Color(0xFF401E66)   // primaire
background  = Color(0xFFFCFBFB)   // fond général
slate900    = Color(0xFF0F172A)   // texte principal  ← utiliser slate900, PAS textPrimary
```

---

## Checklist pour ajouter un module

- [ ] Créer `domain/*_entity.dart` (entités pures Dart)
- [ ] Créer `domain/*_controller.dart` (logique métier, zéro Flutter/Riverpod)
- [ ] Créer `data/models/*_model.dart` (JSON + `.toEntity()`)
- [ ] Créer `data/repositories/*_repository.dart` (interface abstraite)
- [ ] Créer `data/repositories/*_repository_mock.dart` (avec `TODO(API)` sur chaque méthode)
- [ ] Créer `data/providers/*_provider.dart` (repository → controller → notifier)
- [ ] Ajouter le mock dans le tableau récapitulatif de `API_SPEC.md`
- [ ] Documenter les endpoints dans `API_SPEC.md`

## Checklist pour brancher une API

- [ ] Créer `data/repositories/*_repository_http.dart` (implémente l'interface)
- [ ] Dans `*_provider.dart`, remplacer `*RepositoryMock()` par `*RepositoryHttp()`
- [ ] Supprimer le `*_repository_mock.dart` (ou le conserver en fallback)
- [ ] Mettre à jour `API_SPEC.md` : marquer l'endpoint comme "branché"

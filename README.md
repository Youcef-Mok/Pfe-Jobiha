

# Projet Flutter – Feature-First Architecture

## 🏗️ Architecture

Ce projet utilise une **architecture “Feature-First”**.
L’idée est d’organiser le code **autour des fonctionnalités** (login, jobs, profile, chat…), plutôt que par type de fichier (models, widgets, services).

Chaque **feature** est autonome et contient tout ce dont elle a besoin pour fonctionner :

* **data/** : modèles, repositories (API ou mock), providers.
* **domain/** : controllers ou logique métier.
* **screens/** : UI principale de la feature.
* **widgets/** : composants UI spécifiques à cette feature.

**Avantages :**

* Isolation des features → moins de risques de conflits en équipe.
* Facile à maintenir et à scaler.
* Les tests et les mocks sont simples à gérer.

---

## 📂 Structure du projet

lib/
│
├── core/                         
│   ├── constants/                # Constantes globales (API_URL, clés, etc.)
│   ├── theme/                    # Thème (colors, typography, styles)
│   ├── utils/                    # Fonctions utilitaires (formatters, helpers)
│   ├── services/                 # Services globaux (API client, storage, auth)
│   └── widgets/                  # Widgets réutilisables dans toute l'app
│
├── features/                     
│
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── user_model.dart              # Représentation des données utilisateur
│   │   │   │
│   │   │   ├── repositories/
│   │   │   │   ├── auth_repository.dart        # Appels API (login/register)
│   │   │   │   └── auth_repository_mock.dart   # Données mock pour dev/test
│   │   │   │
│   │   │   └── providers/
│   │   │       └── auth_provider.dart          # Gestion d’état (Riverpod/Provider)
│   │   │
│   │   ├── domain/
│   │   │   └── auth_controller.dart            # Logique métier (login, register)
│   │   │
│   │   ├── screens/
│   │   │   ├── login_screen.dart               # UI login
│   │   │   ├── register_screen.dart            # UI inscription
│   │   │   ├── role_selection_screen.dart      # Choix du rôle
│   │   │   ├── candidate_details_screen.dart   # Infos candidat
│   │   │   └── recruiter_details_screen.dart  # Infos recruteur
│   │   │
│   │   └── widgets/
│   │       ├── login_form.dart                 # Formulaire login
│   │       └── auth_button.dart                # Boutons spécifiques
│   │
│   ├── jobs/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── job_model.dart              # Données d’un job
│   │   │   ├── repositories/
│   │   │   │   ├── jobs_repository.dart
│   │   │   │   └── jobs_repository_mock.dart
│   │   │   └── providers/
│   │   │       └── jobs_provider.dart
│   │   ├── domain/
│   │   │   └── jobs_controller.dart            # Logique (fetch jobs, filter, save)
│   │   ├── screens/
│   │   │   ├── jobs_list_screen.dart           # Liste des jobs
│   │   │   ├── job_details_screen.dart         # Détails d’un job
│   │   │   ├── filters_screen.dart             # Filtres
│   │   │   └── saved_jobs_screen.dart          # Jobs sauvegardés
│   │   └── widgets/
│   │       └── job_card.dart                   # Carte d’un job
│   │
│   ├── map/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── location_model.dart
│   │   │   ├── repositories/
│   │   │   │   ├── map_repository.dart
│   │   │   │   └── map_repository_mock.dart
│   │   │   └── providers/
│   │   │       └── map_provider.dart
│   │   ├── domain/
│   │   │   └── map_controller.dart
│   │   ├── screens/
│   │   │   └── map_screen.dart                 # Carte avec jobs/localisation
│   │   └── widgets/
│   │       └── map_marker.dart
│   │
│   ├── applications/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── application_model.dart
│   │   │   ├── repositories/
│   │   │   │   ├── applications_repository.dart
│   │   │   │   └── applications_repository_mock.dart
│   │   │   └── providers/
│   │   │       └── applications_provider.dart
│   │   ├── domain/
│   │   │   └── applications_controller.dart
│   │   ├── screens/
│   │   │   └── applications_screen.dart        # Liste des candidatures
│   │   └── widgets/
│   │       └── application_card.dart
│   │
│   ├── profile/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── profile_model.dart
│   │   │   ├── repositories/
│   │   │   │   ├── profile_repository.dart
│   │   │   │   └── profile_repository_mock.dart
│   │   │   └── providers/
│   │   │       └── profile_provider.dart
│   │   ├── domain/
│   │   │   └── profile_controller.dart
│   │   ├── screens/
│   │   │   ├── candidate_profile_screen.dart
│   │   │   ├── recruiter_profile_screen.dart
│   │   │   └── edit_profile_screen.dart
│   │   └── widgets/
│   │       └── profile_header.dart
│   │
│   ├── chat/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── chat_model.dart
│   │   │   ├── repositories/
│   │   │   │   ├── chat_repository.dart
│   │   │   │   └── chat_repository_mock.dart
│   │   │   └── providers/
│   │   │       └── chat_provider.dart
│   │   ├── domain/
│   │   │   └── chat_controller.dart
│   │   ├── screens/
│   │   │   ├── chat_list_screen.dart
│   │   │   └── chat_screen.dart
│   │   └── widgets/
│   │       └── message_bubble.dart
│   │
│   ├── notifications/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── notification_model.dart
│   │   │   ├── repositories/
│   │   │   │   ├── notifications_repository.dart
│   │   │   │   └── notifications_repository_mock.dart
│   │   │   └── providers/
│   │   │       └── notifications_provider.dart
│   │   ├── domain/
│   │   │   └── notifications_controller.dart
│   │   ├── screens/
│   │   │   └── notifications_screen.dart
│   │   └── widgets/
│   │       └── notification_tile.dart
│   │
│   └── settings/
│       ├── data/
│       │   ├── models/
│       │   │   └── settings_model.dart
│       │   ├── repositories/
│       │   │   ├── settings_repository.dart
│       │   │   └── settings_repository_mock.dart
│       │   └── providers/
│       │       └── settings_provider.dart
│       ├── domain/
│       │   └── settings_controller.dart
│       ├── screens/
│       │   └── settings_screen.dart
│       └── widgets/
│           └── settings_item.dart
│
├── routes/                      
│   └── app_routes.dart           # Navigation entre les écrans
│
└── main.dart                     # Point d’entrée de l’application

## ⚙️ Détails des dossiers

### core/

Contient tout ce qui est **global** à l’application :

* **widgets/** → boutons, champs de texte réutilisables.
* **services/** → API, stockage local, gestion des tokens.
* **utils/** → fonctions utilitaires.
* **theme/** → couleurs, typographies.

### features/

Chaque feature suit le pattern **data → domain → presentation** :

1. **data/**

   * **models/** → classes Dart représentant les données.
   * **repositories/** → accès aux données réelles ou mocks.
   * **providers/** → gestion d’état (Riverpod / Provider).

2. **domain/**

   * Controllers / ViewModels / Logique métier spécifique à la feature.

3. **screens/**

   * Écrans principaux de la feature.

4. **widgets/**

   * Composants UI spécifiques à la feature.

### routes/

* Contient les **routes et la navigation** entre les écrans.

### main.dart

* Point d’entrée de l’application.

---

## 💡 Utilisation de Mock Data

Chaque feature peut avoir un **repository mock** pour le développement sans backend.
Exemple pour `auth` :

```dart
final loginController = LoginController(
  repository: useMock ? LoginRepositoryMock() : LoginRepository(baseUrl: 'https://api.example.com'),
);
```

* **useMock = true** → utilise des données fictives.
* Permet de développer l’UI même si le backend n’est pas prêt.

---

## 🔄 Bonnes pratiques

1. Chaque feature doit être **autonome** et isolée.
2. Les widgets spécifiques restent dans la feature.
3. Utiliser des **mocks** pour le développement front.
4. La logique métier est dans le **controller/domain**, jamais dans l’UI.
5. Les providers gèrent l’état et les données pour chaque feature.

---

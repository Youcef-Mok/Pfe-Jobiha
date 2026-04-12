

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

```
lib/
│
├── core/                         
│   ├── constants/                # Constantes globales
│   ├── theme/                    # Thèmes et styles
│   ├── utils/                    # Fonctions utilitaires
│   ├── services/                 # API, stockage, etc.
│   └── widgets/                  # widgets réutilisables
│
├── features/                     # Fonctionnalités
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/           # User, Role...
│   │   │   ├── repositories/     # login_repository.dart & login_repository_mock.dart
│   │   │   └── providers/        # auth_provider.dart
│   │   ├── domain/               # auth_controller.dart
│   │   ├── screens/              # login_screen.dart, register_screen.dart...
│   │   └── widgets/              # Widgets spécifiques à auth
│   │
│   ├── jobs/
│   │   ├── data/
│   │   ├── domain/
│   │   ├── screens/
│   │   └── widgets/
│   │
│   ├── map/
│   │   ├── data/
│   │   ├── domain/
│   │   ├── screens/
│   │   └── widgets/
│   │
│   ├── applications/
│   │   ├── data/
│   │   ├── domain/
│   │   ├── screens/
│   │   └── widgets/
│   │
│   ├── profile/
│   │   ├── data/
│   │   ├── domain/
│   │   ├── screens/
│   │   └── widgets/
│   │
│   ├── chat/
│   │   ├── data/
│   │   ├── domain/
│   │   ├── screens/
│   │   └── widgets/
│   │
│   ├── notifications/
│   │   ├── data/
│   │   ├── domain/
│   │   ├── screens/
│   │   └── widgets/
│   │
│   └── settings/
│       ├── data/
│       ├── domain/
│       ├── screens/
│       └── widgets/
│
├── routes/                      
│   └── app_routes.dart           # Gestion de la navigation
│
└── main.dart                     # Point d’entrée
```

---

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

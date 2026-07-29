# 📊 Section Activité - Homepage Recruteur

## Vue d'ensemble
Remplacement de la section "Brouillons" par une section "Activité" complète avec analytics, candidatures récentes et entretiens à venir.

---

## ✅ Modifications effectuées

### 1. **Nouvelle entité: InterviewEntity**
📁 `frontend/lib/features/interviews/domain/interview_entity.dart`

Entité métier pour gérer les entretiens planifiés entre recruteurs et candidats.

**Attributs**:
- ID, candidat (ID, nom, avatar)
- Offre d'emploi (ID, titre)
- Date/heure planifiée
- Statut (scheduled, completed, cancelled)
- Notes

**Méthodes utiles**:
- `formattedDate` → "15 Mai"
- `formattedTime` → "14:30"

---

### 2. **Modèle de données: InterviewModel**
📁 `frontend/lib/features/interviews/data/models/interview_model.dart`

Conversion entre entité métier et données persistées (JSON).

---

### 3. **Repository: InterviewsRepository**
📁 `frontend/lib/features/interviews/data/repositories/`

**Interface** (`interviews_repository.dart`):
- `getInterviews()` - Tous les entretiens
- `getUpcomingInterviews()` - Entretiens à venir
- `createInterview()` - Créer un entretien
- `updateInterview()` - Mettre à jour
- `cancelInterview()` - Annuler
- `completeInterview()` - Marquer comme complété

**Implémentation mock** (`interviews_repository_mock.dart`):
- 5 entretiens de démonstration
- Données triées par date
- Délais simulés (500ms)

---

### 4. **Providers Riverpod**
📁 `frontend/lib/features/interviews/data/providers/interviews_provider.dart`

**Providers créés**:
- `interviewsRepositoryProvider` - Repository
- `interviewsNotifierProvider` - État des entretiens
- `upcomingInterviewsProvider` - 3 prochains entretiens

---

### 5. **Provider Analytics**
📁 `frontend/lib/features/jobs/data/providers/analytics_provider.dart`

**RecruiterAnalytics**:
- `activeMissions` - Missions en cours
- `activeJobs` - Offres actives
- `pendingApplications` - Candidatures en attente
- `upcomingInterviews` - Entretiens à venir

Combine les données de 4 providers différents.

---

### 6. **Widget: AnalyticsCard**
📁 `frontend/lib/features/jobs/widgets/analytics_card.dart`

Carte analytics avec:
- Icône colorée dans un cercle
- Compteur (grand nombre)
- Label descriptif

**Props**:
- `icon: IconData`
- `label: String`
- `count: int`
- `iconColor: Color?`

---

### 7. **Widget: CompactApplicationCard**
📁 `frontend/lib/features/applications/widgets/compact_application_card.dart`

Carte candidature horizontale compacte avec:
- Photo de profil du candidat
- Nom et poste
- Extrait de lettre de motivation
- Boutons Accepter/Refuser

**Props**:
- `application: ApplicationEntity`
- `onAccept: VoidCallback?`
- `onReject: VoidCallback?`
- `onTap: VoidCallback?`

---

### 8. **Widget: CompactInterviewCard**
📁 `frontend/lib/features/interviews/widgets/compact_interview_card.dart`

Carte entretien horizontale compacte avec:
- Photo de profil du candidat
- Nom et poste
- Date et heure (à droite)

**Props**:
- `interview: InterviewEntity`
- `onTap: VoidCallback?`

---

### 9. **Mise à jour: JobsListScreen**
📁 `frontend/lib/features/jobs/screens/jobs_list_screen.dart`

**Modifications**:
- Onglet "Brouillons" → "Activité"
- Nouvelle méthode `_buildActivitySection()`
- Imports des nouveaux widgets et providers

**Structure de la section Activité**:
```
┌─────────────────────────────────────┐
│  ANALYTICS (Grille 2x2)             │
│  ┌──────────┐  ┌──────────┐        │
│  │ Missions │  │ Offres   │        │
│  │ actives  │  │ actives  │        │
│  └──────────┘  └──────────┘        │
│  ┌──────────┐  ┌──────────┐        │
│  │Candidat. │  │Entretiens│        │
│  └──────────┘  └──────────┘        │
├─────────────────────────────────────┤
│  CANDIDATURES RÉCENTES (max 3)     │
│  ┌─────────────────────────────┐   │
│  │ [Photo] Nom candidat        │   │
│  │ Poste                       │   │
│  │ Extrait lettre...      [✓][✗]│   │
│  └─────────────────────────────┘   │
├─────────────────────────────────────┤
│  ENTRETIENS À VENIR (max 3)        │
│  ┌─────────────────────────────┐   │
│  │ [Photo] Nom candidat  15 Mai│   │
│  │ Poste                 14:30 │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

---

### 10. **Mise à jour: Enum JobsTab**
📁 `frontend/lib/features/jobs/data/providers/jobs_provider.dart`

```dart
enum JobsTab { missions, myJobs, activity }
```

---

### 11. **Provider: recentApplicationsProvider**
📁 `frontend/lib/features/applications/data/providers/applications_provider.dart`

Provider pour les 3 candidatures récentes (status = pending, triées par date).

---

## 🎨 Design

### Couleurs des analytics
- **Missions actives**: `#7F13EC` (violet clair)
- **Offres actives**: `#401E66` (violet foncé)
- **Candidatures**: `#15803D` (vert)
- **Entretiens**: `#EA580C` (orange)

### Boutons d'action candidatures
- **Accepter**: Vert `#15803D` sur fond `#DCFCE7`
- **Refuser**: Rouge `#DC2626` sur fond `#FEE2E2`

### Cartes
- Fond blanc
- Bordure `#EEEBF4` (1.5px)
- Border radius: 12px
- Padding: 12px

---

## 📊 Données Mock

### Entretiens (5 exemples)
1. **Amélie Laurent** - Chef de Produit - Dans 2 jours à 10h
2. **Marc Dubois** - Chef de Produit - Dans 3 jours à 14h
3. **Lucas Petit** - Développeur Flutter - Dans 5 jours à 9h
4. **Sophie Martin** - Designer UX - Dans 7 jours à 15h
5. **Thomas Durand** - Développeur Flutter - Demain à 11h

---

## 🔄 Flux de données

```
JobsListScreen (Onglet Activité)
    │
    ├─→ recruiterAnalyticsProvider
    │   ├─→ jobsNotifierProvider
    │   ├─→ missionsNotifierProvider
    │   ├─→ applicationsNotifierProvider
    │   └─→ interviewsNotifierProvider
    │
    ├─→ recentApplicationsProvider
    │   └─→ applicationsNotifierProvider
    │
    └─→ upcomingInterviewsProvider
        └─→ interviewsNotifierProvider
```

---

## 🚀 Utilisation

### Accéder à la section Activité
1. Lancer l'app en mode recruteur
2. Cliquer sur l'onglet "Activité"
3. Voir les analytics, candidatures et entretiens

### Rafraîchir les données
Pull-to-refresh sur la section Activité rafraîchit:
- Jobs
- Missions
- Candidatures
- Entretiens

---

## 📝 TODO (Fonctionnalités futures)

### Candidatures
- [ ] Implémenter `onAccept` - Accepter une candidature
- [ ] Implémenter `onReject` - Refuser une candidature
- [ ] Navigation vers détails candidature

### Entretiens
- [ ] Navigation vers détails entretien
- [ ] Écran de création d'entretien
- [ ] Notifications d'entretiens à venir
- [ ] Intégration calendrier

### Analytics
- [ ] Graphiques d'évolution
- [ ] Filtres par période
- [ ] Export des données

---

## 🏗️ Architecture respectée

✅ **Clean Architecture**:
- Domain (entities)
- Data (models, repositories, providers)
- Presentation (widgets, screens)

✅ **Riverpod**:
- StateNotifier pour l'état
- Providers pour l'injection de dépendances
- AsyncValue pour les états async

✅ **Séparation des responsabilités**:
- Repository: Accès aux données
- Provider: Gestion d'état
- Widget: Affichage UI

---

## 📦 Fichiers créés

### Interviews Feature (7 fichiers)
1. `domain/interview_entity.dart`
2. `data/models/interview_model.dart`
3. `data/repositories/interviews_repository.dart`
4. `data/repositories/interviews_repository_mock.dart`
5. `data/providers/interviews_provider.dart`
6. `widgets/compact_interview_card.dart`
7. `README.md`

### Jobs Feature (2 fichiers)
1. `widgets/analytics_card.dart`
2. `data/providers/analytics_provider.dart`

### Applications Feature (1 fichier)
1. `widgets/compact_application_card.dart`

### Documentation (2 fichiers)
1. `RECRUITER_ACTIVITY_SECTION.md` (ce fichier)
2. `frontend/lib/features/interviews/README.md`

---

## ✨ Résultat final

La homepage recruteur dispose maintenant d'une section "Activité" complète qui offre:
- **Vue d'ensemble** des métriques clés (4 analytics)
- **Candidatures récentes** avec actions rapides
- **Entretiens à venir** pour une meilleure organisation

Le tout avec une architecture propre, des données mock réalistes et un design cohérent avec le reste de l'application ! 🎉

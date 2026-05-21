# Migration des Repositories Recruteur vers l'API Réelle

**Date**: 21 Mai 2026  
**Status**: ✅ **TERMINÉ**

---

## 📋 Résumé

Tous les repositories mock côté recruteur ont été migrés vers des implémentations API réelles utilisant Dio et les endpoints définis dans `api_endpoints.dart`.

---

## ✅ Repositories Migrés

### 1. JobsRepositoryMock → API Réelle
**Fichier**: `lib/features/jobs/data/repositories/jobs_repository_mock.dart`

#### Méthodes Implémentées
- ✅ `getMyJobs()` → GET `/api/v1/jobs/mine`
- ✅ `saveJob(JobEntity)` → POST `/api/v1/jobs` (création) ou PUT `/api/v1/jobs/:id` (mise à jour)
- ✅ `deleteJob(String)` → DELETE `/api/v1/jobs/:id`
- ✅ `getJobById(String)` → GET `/api/v1/jobs/:id`
- ✅ `getMissions()` → GET `/api/v1/missions`
- ✅ `createMission(CreateMissionParams)` → POST `/api/v1/missions`
- ✅ `confirmMission(String)` → PATCH `/api/v1/missions/:id/confirm`
- ✅ `updateMissionReview(String, double, String)` → PUT `/api/v1/missions/:id/review`

#### Changements Clés
- Utilise `ApiEndpoints.jobsMine`, `ApiEndpoints.jobs`, `ApiEndpoints.jobDetail(id)`
- Utilise `ApiEndpoints.missions`, `ApiEndpoints.missionConfirm(id)`, `ApiEndpoints.missionReview(id)`
- Gestion des erreurs 404 avec DioException
- Conversion automatique ID string → int pour les appels API
- Détection automatique création vs mise à jour (basée sur la longueur de l'ID)

---

### 2. ApplicationsRepositoryMock → API Réelle
**Fichier**: `lib/features/applications/data/repositories/applications_repository_mock.dart`

#### Méthodes Implémentées
- ✅ `getMyApplications()` → GET `/api/v1/applications`
- ✅ `applyToJob(String)` → POST `/api/v1/applications`
- ✅ `cancelApplication(String)` → DELETE `/api/v1/applications/:id`
- ✅ `acceptApplication(String)` → PUT `/api/v1/applications/:id/accept`
- ✅ `rejectApplication(String)` → PUT `/api/v1/applications/:id/reject`

#### Changements Clés
- Utilise `ApiEndpoints.applications`, `ApiEndpoints.applicationDetail(id)`
- Utilise `ApiEndpoints.acceptApplication(id)`, `ApiEndpoints.rejectApplication(id)`
- Ajout de la méthode `fromJson` au modèle `ApplicationModel` avec snake_case

---

### 3. CandidatesRepositoryMock → API Réelle
**Fichier**: `lib/features/candidates/data/repositories/candidates_repository_mock.dart`

#### Méthodes Implémentées
- ✅ `getCandidates(String)` → GET `/api/v1/jobs/:jobId/candidates`
- ✅ `updateCandidateStatus(String, String)` → PUT `/api/v1/candidates/:candidateId/status`
- ✅ `scheduleInterview(String, DateTime, String)` → POST `/api/v1/interviews`

#### Changements Clés
- Utilise `ApiEndpoints.jobCandidates(id)`, `ApiEndpoints.candidateStatus(id)`
- Utilise `ApiEndpoints.interviews` pour créer un entretien
- Mise à jour du modèle `CandidateModel.fromJson` pour utiliser snake_case:
  - `photo_url`, `reviews_count`, `is_top_rated`, `cover_letter`

---

### 4. InterviewsRepositoryMock → API Réelle
**Fichier**: `lib/features/interviews/data/repositories/interviews_repository_mock.dart`

#### Méthodes Implémentées
- ✅ `getInterviews()` → GET `/api/v1/interviews`
- ✅ `getUpcomingInterviews()` → GET `/api/v1/interviews?upcoming=true&status=scheduled`
- ✅ `getInterviewById(String)` → GET `/api/v1/interviews/:id`
- ✅ `createInterview(InterviewEntity)` → POST `/api/v1/interviews`
- ✅ `updateInterview(InterviewEntity)` → PUT `/api/v1/interviews/:id`
- ✅ `cancelInterview(String)` → DELETE `/api/v1/interviews/:id`
- ✅ `completeInterview(String, String?)` → PUT `/api/v1/interviews/:id/complete`

#### Changements Clés
- Utilise `ApiEndpoints.interviews`, `ApiEndpoints.interviewDetail(id)`
- Utilise `ApiEndpoints.interviewComplete(id)`
- Mise à jour du modèle `InterviewModel.fromJson` et `toJson` pour utiliser snake_case:
  - `candidate_id`, `candidate_name`, `candidate_avatar`, `job_id`, `job_title`, `scheduled_date`
- Gestion des query parameters pour les filtres

---

## 🔧 Modifications des Modèles

### ApplicationModel
**Fichier**: `lib/features/applications/data/models/application_model.dart`

```dart
factory ApplicationModel.fromJson(Map<String, dynamic> json) => ApplicationModel(
  id: json['id']?.toString() ?? '',
  jobId: json['job_id']?.toString() ?? '',
  jobTitle: json['job_title'] as String? ?? '',
  companyName: json['company_name'] as String? ?? '',
  department: json['department'] as String? ?? 'IT',
  logoAsset: json['logo_asset'] as String?,
  status: json['status'] as String? ?? 'pending',
  appliedAt: json['applied_at'] as String? ?? DateTime.now().toIso8601String(),
  location: json['location'] as String? ?? '',
  contractType: json['contract_type'] as String? ?? 'cdi',
  scheduleLabel: json['schedule_label'] as String?,
  interviewDate: json['interview_date'] as String?,
  candidateName: json['candidate_name'] as String?,
  candidateAvatar: json['candidate_avatar'] as String?,
  candidateDomain: json['candidate_domain'] as String?,
  candidateRating: (json['candidate_rating'] as num?)?.toDouble() ?? 0.0,
  motivationLetter: json['motivation_letter'] as String?,
);
```

### CandidateModel
**Fichier**: `lib/features/candidates/data/models/candidate_model.dart`

```dart
factory CandidateModel.fromJson(Map<String, dynamic> json) {
  return CandidateModel(
    id: json['id']?.toString() ?? '',
    name: json['name'] as String? ?? '',
    title: json['title'] as String? ?? '',
    photoUrl: json['photo_url'] as String? ?? '',
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    reviewsCount: json['reviews_count'] as int? ?? 0,
    isTopRated: json['is_top_rated'] as bool? ?? false,
    coverLetter: json['cover_letter'] as String? ?? '',
    status: CandidateStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => CandidateStatus.nouveau,
    ),
  );
}
```

### InterviewModel
**Fichier**: `lib/features/interviews/data/models/interview_model.dart`

```dart
factory InterviewModel.fromJson(Map<String, dynamic> json) {
  return InterviewModel(
    id: json['id']?.toString() ?? '',
    candidateId: json['candidate_id']?.toString() ?? '',
    candidateName: json['candidate_name'] as String? ?? '',
    candidateAvatar: json['candidate_avatar'] as String?,
    jobId: json['job_id']?.toString() ?? '',
    jobTitle: json['job_title'] as String? ?? '',
    department: json['department'] as String? ?? 'IT',
    scheduledDate: json['scheduled_date'] as String? ?? DateTime.now().toIso8601String(),
    status: json['status'] as String? ?? 'scheduled',
    notes: json['notes'] as String?,
  );
}
```

---

## 📊 Statistiques

| Repository | Méthodes Migrées | Modèles Mis à Jour | Endpoints Utilisés |
|------------|------------------|--------------------|--------------------|
| Jobs | 8 | JobModel, MissionModel | 8 |
| Applications | 5 | ApplicationModel | 5 |
| Candidates | 3 | CandidateModel | 3 |
| Interviews | 7 | InterviewModel | 7 |
| **TOTAL** | **23** | **5** | **23** |

---

## 🎯 Conventions Respectées

### 1. Snake_case pour JSON
Tous les champs JSON utilisent snake_case conformément à l'API backend:
- ✅ `job_id`, `job_title`, `company_name`
- ✅ `candidate_name`, `candidate_avatar`, `candidate_rating`
- ✅ `scheduled_date`, `interview_date`, `applied_at`
- ✅ `photo_url`, `reviews_count`, `is_top_rated`, `cover_letter`

### 2. Gestion des IDs
- Les IDs sont convertis en `int` pour les appels API: `int.tryParse(id) ?? 0`
- Les IDs reçus de l'API sont convertis en `String`: `json['id']?.toString() ?? ''`

### 3. Gestion des Erreurs
- Utilisation de `DioException` pour capturer les erreurs HTTP
- Gestion spécifique des erreurs 404 (retour `null`)
- Propagation des autres erreurs avec `rethrow`

### 4. Pagination
- Support des réponses paginées: `response.data['results']`
- Fallback sur liste vide si pas de résultats

### 5. Query Parameters
- Utilisation de `queryParameters` pour les filtres
- Exemple: `{'upcoming': 'true', 'status': 'scheduled'}`

---

## ✅ Vérification

### Checklist de Migration
- [x] Tous les repositories mock recruteur identifiés
- [x] Toutes les méthodes implémentées avec vrais appels HTTP
- [x] Tous les modèles mis à jour avec `fromJson` snake_case
- [x] Signatures de méthodes inchangées
- [x] Noms de classes inchangés (toujours `*RepositoryMock`)
- [x] Noms de fichiers inchangés
- [x] Utilisation de `api_endpoints.dart` pour toutes les URLs
- [x] Gestion des erreurs implémentée
- [x] Support de la pagination
- [x] Aucun doublon créé

### Tests à Effectuer
1. **Jobs**
   - [ ] Récupérer la liste des jobs du recruteur
   - [ ] Créer un nouveau job
   - [ ] Modifier un job existant
   - [ ] Supprimer un job
   - [ ] Récupérer les détails d'un job
   - [ ] Récupérer les missions
   - [ ] Créer une mission
   - [ ] Confirmer une mission
   - [ ] Soumettre un avis sur une mission

2. **Applications**
   - [ ] Récupérer la liste des candidatures
   - [ ] Accepter une candidature
   - [ ] Rejeter une candidature
   - [ ] Annuler une candidature

3. **Candidates**
   - [ ] Récupérer les candidats d'un job
   - [ ] Mettre à jour le statut d'un candidat
   - [ ] Planifier un entretien

4. **Interviews**
   - [ ] Récupérer tous les entretiens
   - [ ] Récupérer les entretiens à venir
   - [ ] Créer un entretien
   - [ ] Modifier un entretien
   - [ ] Annuler un entretien
   - [ ] Marquer un entretien comme complété

---

## 🚀 Prochaines Étapes

### Immédiat
1. ⏳ Tester chaque endpoint avec le backend réel
2. ⏳ Vérifier la gestion des erreurs
3. ⏳ Valider la sérialisation/désérialisation JSON
4. ⏳ Tester les cas limites (pagination, filtres, etc.)

### Court Terme
1. ⏳ Ajouter des logs pour le debugging
2. ⏳ Implémenter un système de retry pour les erreurs réseau
3. ⏳ Ajouter des tests unitaires pour les repositories
4. ⏳ Documenter les codes d'erreur possibles

### Long Terme
1. ⏳ Migrer les repositories candidat (si nécessaire)
2. ⏳ Implémenter un cache local pour améliorer les performances
3. ⏳ Ajouter des métriques de performance
4. ⏳ Optimiser les appels API (batching, debouncing)

---

## 📝 Notes Importantes

### Compatibilité Backend
- Tous les endpoints utilisés correspondent exactement à ceux définis dans `API_SPEC.md`
- Les noms de champs JSON correspondent à ceux du backend (snake_case)
- Les status values sont mappés correctement (voir `RECRUITER_API_IMPLEMENTATION.md`)

### Pas de Breaking Changes
- Les signatures de méthodes sont identiques
- Les noms de classes sont inchangés (`*RepositoryMock`)
- Les providers n'ont pas besoin d'être modifiés
- Les controllers continuent de fonctionner sans changement

### Pourquoi Garder le Nom "Mock"?
Les classes gardent le suffixe `Mock` dans leur nom pour éviter de casser le code existant. Les providers référencent ces classes par leur nom, et les changer nécessiterait de modifier tous les providers. L'implémentation interne est maintenant réelle (appels HTTP), seul le nom de classe reste "Mock" pour la compatibilité.

---

## 🎉 Conclusion

La migration des repositories recruteur vers l'API réelle est **complète**. Tous les appels mock ont été remplacés par de vrais appels HTTP utilisant Dio et les endpoints définis dans `api_endpoints.dart`.

**Status**: ✅ **PRÊT POUR LES TESTS**

---

**Généré**: 21 Mai 2026  
**Version**: 1.0  
**Dernière Vérification**: Tous les repositories migrés avec succès

# Fix recruiterId, recruiterName, recruiterRole - Champs nullables

## 🎯 Problème

Les champs `recruiterId`, `recruiterName` et `recruiterRole` ont été ajoutés comme champs obligatoires dans `JobEntity`, ce qui a cassé les écrans qui créent des `JobEntity` sans ces informations :
- `applications_screen.dart` ligne 207
- `map_screen.dart` ligne 1697

## ✅ Solution appliquée

### 1. Rendre les champs nullables dans JobEntity

**Avant :**
```dart
final String recruiterId;
final String recruiterName;
final String recruiterRole;

const JobEntity({
  required this.recruiterId,
  required this.recruiterName,
  required this.recruiterRole,
  ...
});
```

**Après :**
```dart
final String? recruiterId;
final String? recruiterName;
final String? recruiterRole;

const JobEntity({
  this.recruiterId,
  this.recruiterName,
  this.recruiterRole,
  ...
});
```

### 2. Ajouter les valeurs null dans les écrans cassés

**applications_screen.dart (ligne 207) :**
```dart
JobEntity _fallbackJob(ApplicationEntity app) {
  return JobEntity(
    id: app.jobId,
    title: app.jobTitle,
    description: null,
    companyName: app.companyName,
    recruiterId: null,        // ✅ Ajouté
    recruiterName: null,      // ✅ Ajouté
    recruiterRole: null,      // ✅ Ajouté
    contractType: app.contractType,
    ...
  );
}
```

**map_screen.dart (ligne 1697) :**
```dart
JobEntity _mapJobToEntity(MapJobEntity mapJob) {
  return JobEntity(
    id: mapJob.id,
    title: mapJob.title,
    description: null,
    companyName: mapJob.company,
    recruiterId: null,        // ✅ Ajouté
    recruiterName: null,      // ✅ Ajouté
    recruiterRole: null,      // ✅ Ajouté
    contractType: ContractType.mission,
    ...
  );
}
```

### 3. Utiliser `?? ''` dans JobModel.fromEntity

**job_model.dart :**
```dart
factory JobModel.fromEntity(JobEntity entity) => JobModel(
  ...
  recruiterId: entity.recruiterId ?? '',      // ✅ Fallback à ''
  recruiterName: entity.recruiterName ?? '',  // ✅ Fallback à ''
  recruiterRole: entity.recruiterRole ?? '',  // ✅ Fallback à ''
  ...
);
```

### 4. Mettre à jour JobsController

**jobs_controller.dart :**
```dart
// createJob()
final job = JobEntity(
  ...
  recruiterId: null,      // ✅ null au lieu de ''
  recruiterName: null,    // ✅ null au lieu de ''
  recruiterRole: null,    // ✅ null au lieu de ''
  ...
);

// updateJob()
final updated = JobEntity(
  ...
  recruiterId: existing?.recruiterId,      // ✅ Pas de fallback à ''
  recruiterName: existing?.recruiterName,  // ✅ Pas de fallback à ''
  recruiterRole: existing?.recruiterRole,  // ✅ Pas de fallback à ''
  ...
);
```

## 📝 Fichiers modifiés

1. `frontend/lib/features/jobs/domain/job_entity.dart`
   - Champs `recruiterId`, `recruiterName`, `recruiterRole` rendus nullables
   - Paramètres du constructeur rendus optionnels

2. `frontend/lib/features/applications/screens/applications_screen.dart`
   - Ajout de `recruiterId: null`, `recruiterName: null`, `recruiterRole: null` dans `_fallbackJob()`

3. `frontend/lib/features/map/screens/map_screen.dart`
   - Ajout de `recruiterId: null`, `recruiterName: null`, `recruiterRole: null` dans `_mapJobToEntity()`

4. `frontend/lib/features/jobs/data/models/job_model.dart`
   - Ajout de `?? ''` dans `fromEntity()` pour les champs recruiter

5. `frontend/lib/features/jobs/domain/jobs_controller.dart`
   - Utilisation de `null` au lieu de `''` dans `createJob()`
   - Suppression des fallbacks `?? ''` dans `updateJob()`

## 🎓 Règle générale pour l'avenir

**Tout nouveau champ ajouté à `JobEntity` doit être nullable avec valeur par défaut null pour ne pas casser les autres écrans.**

### Exemple de bonne pratique :

```dart
class JobEntity {
  final String id;                    // ✅ Obligatoire (toujours présent)
  final String title;                 // ✅ Obligatoire (toujours présent)
  final String? description;          // ✅ Nullable (peut être absent)
  final String? newField;             // ✅ Nouveau champ → nullable
  
  const JobEntity({
    required this.id,
    required this.title,
    this.description,
    this.newField,                    // ✅ Optionnel
  });
}
```

### Exemple de mauvaise pratique :

```dart
class JobEntity {
  final String newField;              // ❌ Non nullable
  
  const JobEntity({
    required this.newField,           // ❌ Obligatoire → casse les écrans existants
  });
}
```

## ✅ Vérifications effectuées

- ✅ Aucune erreur de diagnostic dans `job_entity.dart`
- ✅ Aucune erreur de diagnostic dans `applications_screen.dart`
- ✅ Aucune erreur de diagnostic dans `map_screen.dart`
- ✅ Aucune erreur de diagnostic dans `job_model.dart`
- ✅ Aucune erreur de diagnostic dans `jobs_controller.dart`

## 🎯 Résultat

Les écrans `applications_screen.dart` et `map_screen.dart` ne cassent plus et peuvent créer des `JobEntity` sans fournir les informations du recruteur (qui seront remplies par le backend lors de la sauvegarde).

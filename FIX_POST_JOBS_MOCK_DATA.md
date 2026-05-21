# Fix POST /api/v1/jobs - Suppression des données mockées

## Problèmes corrigés

### 1. Frontend envoie des données mockées ❌ → ✅

**Avant :**
Le frontend envoyait ces champs mockés hardcodés :
- `company_name: 'Le Petit Bistro'`
- `recruiter_id: 'recruiter_1'`
- `recruiter_name: 'Ahmed Bensalem'`
- `recruiter_role: 'Responsable RH'`
- `recruiter_avatar_asset: 'assets/images/pdp_1.png'`
- `posted_at`, `status`, `candidate_count`, `view_count`, `candidates`, `comments`

**Après :**
Le frontend envoie UNIQUEMENT :
- `title`
- `description`
- `contract_type`
- `candidate_count`
- `is_published`
- `department` (optionnel)

### 2. Le bouton "Publier" ne publiait pas ❌ → ✅

**Avant :**
- Le backend ne mettait pas automatiquement `statut='searching'` lors de la mise à jour avec `is_published=true`

**Après :**
- POST : `statut='draft'` si `is_published=false`, sinon `statut='searching'`
- PUT/PATCH : Met automatiquement à jour le statut quand `is_published` change

### 3. Données mockées hardcodées dans le code ❌ → ✅

**Fichiers corrigés :**

#### Frontend

1. **`job_model.dart`**
   - ✅ Constructeur : supprimé les valeurs par défaut mockées
   - ✅ `toJson()` : n'envoie plus les champs mockés (company_name, recruiter_*, posted_at, status, view_count, candidates, comments)
   - ✅ `fromJson()` : utilise des chaînes vides au lieu de valeurs mockées

2. **`job_entity.dart`**
   - ✅ Constructeur : supprimé les valeurs par défaut mockées pour `recruiterId`, `recruiterName`, `recruiterRole`, `recruiterAvatarAsset`

3. **`jobs_controller.dart`**
   - ✅ `createJob()` : n'envoie plus de données mockées (chaînes vides pour company_name, recruiter_*)
   - ✅ `updateJob()` : garde les valeurs existantes du backend sans ajouter de fallback mockés

#### Backend

4. **`serializers.py`**
   - ✅ `CreateOffreSerializer` : accepte mais ignore les champs mockés s'ils arrivent du frontend
   - ✅ Les champs mockés sont marqués comme `required=False` pour éviter les erreurs de validation

5. **`views.py`**
   - ✅ POST : crée l'offre avec `recruteur=request.user.recruteur` (déduit automatiquement)
   - ✅ PUT/PATCH : met à jour automatiquement le statut quand `is_published` change
   - ✅ Le serializer `OffreSerializer` déduit automatiquement :
     - `company_name` depuis `recruteur.nom_structure`
     - `recruiter_id` depuis `recruteur.id`
     - `recruiter_name` depuis `recruteur.prenom + nom`
     - `recruiter_role` depuis `recruteur.titre_poste`
     - `recruiter_avatar_asset` depuis `recruteur.avatar_url`

## Flux de données corrigé

### Création d'un job (POST)

```
Frontend (JobsController.createJob)
  ↓ Crée JobEntity avec champs vides pour recruiter_*
  ↓
Frontend (JobModel.toJson)
  ↓ Envoie UNIQUEMENT: title, description, contract_type, candidate_count, is_published
  ↓
Backend (CreateOffreSerializer)
  ↓ Valide les champs requis, ignore les champs mockés s'ils arrivent
  ↓
Backend (OffreListCreateView.post)
  ↓ Crée Offre avec recruteur=request.user.recruteur
  ↓ statut='draft' si is_published=false, sinon 'searching'
  ↓
Backend (OffreSerializer)
  ↓ Déduit company_name, recruiter_* depuis request.user.recruteur
  ↓
Frontend
  ✅ Reçoit les vraies données du recruteur connecté
```

### Publication d'un job (PUT/PATCH)

```
Frontend
  ↓ Envoie is_published=true
  ↓
Backend (OffreDetailView.put)
  ↓ Met à jour is_published=true
  ↓ Détecte le changement et met statut='searching'
  ↓
Frontend
  ✅ Le job est maintenant publié avec statut='searching'
```

## Tests à effectuer

1. ✅ Créer un brouillon → vérifier que company_name, recruiter_* viennent du user connecté
2. ✅ Publier un brouillon → vérifier que statut passe à 'searching'
3. ✅ Créer et publier directement → vérifier que statut='searching' dès la création
4. ✅ Vérifier qu'aucune donnée mockée n'apparaît dans les requêtes réseau

## Fichiers modifiés

### Frontend
- `frontend/lib/features/jobs/data/models/job_model.dart`
- `frontend/lib/features/jobs/domain/job_entity.dart`
- `frontend/lib/features/jobs/domain/jobs_controller.dart`

### Backend
- `backend/apps/jobs/serializers.py`
- `backend/apps/jobs/views.py`

## Notes importantes

- ⚠️ Le backend déduit TOUTES les informations du recruteur depuis `request.user.recruteur`
- ⚠️ Le frontend ne doit JAMAIS envoyer de données mockées
- ⚠️ Les valeurs par défaut dans les constructeurs ont été supprimées pour éviter les bugs silencieux
- ✅ Le statut est maintenant géré automatiquement par le backend selon `is_published`

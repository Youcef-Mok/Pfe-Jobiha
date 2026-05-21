# Résumé des corrections POST /api/v1/jobs

## 🎯 Objectif

Corriger le problème où le frontend envoyait des données mockées hardcodées lors de la création/modification d'annonces, et s'assurer que le bouton "Publier" fonctionne correctement.

## ✅ Problèmes résolus

### 1. Données mockées envoyées par le frontend

**Problème :** Le frontend envoyait ces champs mockés :
- `company_name: 'Le Petit Bistro'`
- `recruiter_id: 'recruiter_1'`
- `recruiter_name: 'Ahmed Bensalem'`
- `recruiter_role: 'Responsable RH'`
- `recruiter_avatar_asset: 'assets/images/pdp_1.png'`
- `posted_at`, `status`, `view_count`, `candidates`, `comments`

**Solution :** Le frontend envoie maintenant UNIQUEMENT les champs nécessaires :
- `title`, `description`, `contract_type`, `candidate_count`, `is_published`, `department`

### 2. Le bouton "Publier" ne publiait pas

**Problème :** Le backend ne mettait pas automatiquement `statut='searching'` lors de la mise à jour avec `is_published=true`.

**Solution :** 
- POST : `statut='draft'` si `is_published=false`, sinon `statut='searching'`
- PUT/PATCH : Met automatiquement à jour le statut quand `is_published` change

### 3. Valeurs par défaut mockées dans le code

**Problème :** Les constructeurs avaient des valeurs par défaut mockées qui créaient des bugs silencieux.

**Solution :** Suppression de toutes les valeurs par défaut mockées dans :
- `JobEntity` (constructeur)
- `JobModel` (constructeur)
- `JobsController` (méthodes `createJob` et `updateJob`)

## 📝 Fichiers modifiés

### Frontend (4 fichiers)

1. **`frontend/lib/features/jobs/data/models/job_model.dart`**
   - Constructeur : supprimé les valeurs par défaut mockées
   - `toJson()` : n'envoie plus les champs mockés
   - `fromJson()` : utilise des chaînes vides au lieu de valeurs mockées

2. **`frontend/lib/features/jobs/domain/job_entity.dart`**
   - Constructeur : supprimé les valeurs par défaut mockées pour `recruiterId`, `recruiterName`, `recruiterRole`, `recruiterAvatarAsset`

3. **`frontend/lib/features/jobs/domain/jobs_controller.dart`**
   - `createJob()` : n'envoie plus de données mockées
   - `updateJob()` : garde les valeurs existantes du backend sans fallback mockés

### Backend (2 fichiers)

4. **`backend/apps/jobs/serializers.py`**
   - `CreateOffreSerializer` : accepte mais ignore les champs mockés s'ils arrivent
   - Champs mockés marqués comme `required=False`

5. **`backend/apps/jobs/views.py`**
   - POST : crée l'offre avec `recruteur=request.user.recruteur`
   - PUT/PATCH : met à jour automatiquement le statut quand `is_published` change

## 🔄 Flux de données corrigé

### Création d'un job

```
Frontend (JobsController.createJob)
  ↓ Crée JobEntity avec champs vides pour recruiter_*
  ↓
Frontend (JobModel.toJson)
  ↓ Envoie UNIQUEMENT: title, description, contract_type, candidate_count, is_published
  ↓
Backend (CreateOffreSerializer)
  ↓ Valide les champs requis, ignore les champs mockés
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

### Publication d'un job

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

## 🧪 Tests à effectuer

Voir le fichier `TEST_POST_JOBS_FIX.md` pour la liste complète des tests.

**Tests critiques :**
1. ✅ Créer un brouillon → vérifier que les données du recruteur sont correctes
2. ✅ Publier un brouillon → vérifier que `status='searching'`
3. ✅ Créer et publier directement → vérifier que `status='searching'` dès la création
4. ✅ Vérifier qu'aucune donnée mockée n'apparaît dans les requêtes réseau

## 📊 Avant / Après

### Avant

**Requête POST :**
```json
{
  "title": "Serveur",
  "description": "...",
  "company_name": "Le Petit Bistro",  ❌ MOCK
  "recruiter_id": "recruiter_1",      ❌ MOCK
  "recruiter_name": "Ahmed Bensalem", ❌ MOCK
  "recruiter_role": "Responsable RH", ❌ MOCK
  "recruiter_avatar_asset": "assets/images/pdp_1.png", ❌ MOCK
  "contract_type": "cdi",
  "candidate_count": 1,
  "is_published": false,
  "posted_at": "...",                 ❌ NE DOIT PAS ÊTRE ENVOYÉ
  "status": "draft",                  ❌ NE DOIT PAS ÊTRE ENVOYÉ
  "view_count": 0,                    ❌ NE DOIT PAS ÊTRE ENVOYÉ
  "candidates": [],                   ❌ NE DOIT PAS ÊTRE ENVOYÉ
  "comments": []                      ❌ NE DOIT PAS ÊTRE ENVOYÉ
}
```

### Après

**Requête POST :**
```json
{
  "title": "Serveur",
  "description": "...",
  "contract_type": "cdi",
  "candidate_count": 1,
  "is_published": false,
  "department": "Restauration"
}
```

**Réponse :**
```json
{
  "id": "123",
  "title": "Serveur",
  "description": "...",
  "company_name": "Ma Vraie Entreprise",     ✅ DÉDUIT DU BACKEND
  "recruiter_id": "456",                     ✅ DÉDUIT DU BACKEND
  "recruiter_name": "Prénom Nom",            ✅ DÉDUIT DU BACKEND
  "recruiter_role": "DRH",                   ✅ DÉDUIT DU BACKEND
  "recruiter_avatar_asset": "https://...",   ✅ DÉDUIT DU BACKEND
  "contract_type": "cdi",
  "candidate_count": 1,
  "is_published": false,
  "status": "draft",                         ✅ CALCULÉ PAR LE BACKEND
  "posted_at": "2026-05-21T...",             ✅ GÉNÉRÉ PAR LE BACKEND
  "view_count": 0,
  "candidates": [],
  "comments": []
}
```

## ⚠️ Points d'attention

1. **Le backend déduit TOUTES les informations du recruteur** depuis `request.user.recruteur`
2. **Le frontend ne doit JAMAIS envoyer de données mockées**
3. **Les valeurs par défaut dans les constructeurs ont été supprimées** pour éviter les bugs silencieux
4. **Le statut est maintenant géré automatiquement** par le backend selon `is_published`

## 🚀 Prochaines étapes

1. Tester en local avec un vrai compte recruteur
2. Vérifier les logs backend pour confirmer que les données mockées n'apparaissent plus
3. Vérifier dans DevTools que les requêtes ne contiennent plus de données mockées
4. Tester tous les scénarios (création brouillon, publication, modification, dépublication)

## 📚 Documentation

- `FIX_POST_JOBS_MOCK_DATA.md` : Documentation détaillée des corrections
- `TEST_POST_JOBS_FIX.md` : Guide de test complet
- `RESUME_CORRECTIONS_POST_JOBS.md` : Ce fichier (résumé exécutif)

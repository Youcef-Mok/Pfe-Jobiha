# Tests pour vérifier le fix POST /api/v1/jobs

## Tests à effectuer

### 1. Test création brouillon (is_published=false)

**Action :**
1. Se connecter en tant que recruteur
2. Créer une nouvelle annonce
3. Remplir le formulaire (titre, description, type de contrat)
4. Sauvegarder comme brouillon (ne pas publier)

**Vérifications :**
- ✅ La requête POST ne contient PAS ces champs :
  - `company_name`
  - `recruiter_id`
  - `recruiter_name`
  - `recruiter_role`
  - `recruiter_avatar_asset`
  - `posted_at`
  - `status`
  - `view_count`
  - `candidates`
  - `comments`
- ✅ La requête POST contient UNIQUEMENT :
  - `title`
  - `description`
  - `contract_type`
  - `candidate_count`
  - `is_published: false`
  - `department` (si rempli)
- ✅ La réponse contient :
  - `company_name` = nom de la structure du recruteur connecté
  - `recruiter_id` = ID du recruteur connecté
  - `recruiter_name` = prénom + nom du recruteur connecté
  - `recruiter_role` = titre_poste du recruteur connecté
  - `recruiter_avatar_asset` = avatar_url du recruteur connecté
  - `status: "draft"`
  - `is_published: false`

### 2. Test publication d'un brouillon (is_published=false → true)

**Action :**
1. Ouvrir un brouillon existant
2. Cliquer sur "Publier"

**Vérifications :**
- ✅ La requête PUT/PATCH contient `is_published: true`
- ✅ La réponse contient :
  - `status: "searching"`
  - `is_published: true`
- ✅ L'annonce apparaît maintenant dans la liste des annonces publiées

### 3. Test création et publication directe (is_published=true)

**Action :**
1. Se connecter en tant que recruteur
2. Créer une nouvelle annonce
3. Remplir le formulaire
4. Cocher "Publier immédiatement" ou cliquer sur "Publier"

**Vérifications :**
- ✅ La requête POST contient `is_published: true`
- ✅ La réponse contient :
  - `status: "searching"`
  - `is_published: true`
  - Toutes les données du recruteur sont correctes (pas de données mockées)

### 4. Test modification d'une annonce publiée

**Action :**
1. Ouvrir une annonce publiée
2. Modifier le titre ou la description
3. Sauvegarder

**Vérifications :**
- ✅ La requête PUT/PATCH ne contient PAS de données mockées
- ✅ Les données du recruteur restent inchangées
- ✅ Le statut reste "searching"

### 5. Test dépublication (is_published=true → false)

**Action :**
1. Ouvrir une annonce publiée
2. Cliquer sur "Dépublier" ou décocher "Publié"

**Vérifications :**
- ✅ La requête PUT/PATCH contient `is_published: false`
- ✅ La réponse contient :
  - `status: "draft"`
  - `is_published: false`

## Vérification dans les logs backend

Vérifier dans les logs Django (console) :

```
================================================================================
DEBUG POST /api/v1/jobs - request.data:
{'title': '...', 'description': '...', 'contract_type': '...', 'candidate_count': 1, 'is_published': false}
================================================================================
```

**Ce qui NE DOIT PAS apparaître :**
- `company_name: 'Le Petit Bistro'`
- `recruiter_id: 'recruiter_1'`
- `recruiter_name: 'Ahmed Bensalem'`
- `recruiter_role: 'Responsable RH'`
- `recruiter_avatar_asset: 'assets/images/pdp_1.png'`

## Vérification dans le réseau (DevTools)

### Requête POST /api/v1/jobs

**Payload attendu :**
```json
{
  "title": "Serveur de café",
  "description": "Nous recherchons...",
  "contract_type": "cdi",
  "candidate_count": 1,
  "is_published": false,
  "department": "Restauration"
}
```

**Réponse attendue :**
```json
{
  "id": "123",
  "title": "Serveur de café",
  "description": "Nous recherchons...",
  "company_name": "Ma Vraie Entreprise",
  "recruiter_id": "456",
  "recruiter_name": "Prénom Nom",
  "recruiter_role": "DRH",
  "recruiter_avatar_asset": "https://...",
  "contract_type": "cdi",
  "candidate_count": 1,
  "is_published": false,
  "status": "draft",
  "posted_at": "2026-05-21T...",
  "view_count": 0,
  "candidates": [],
  "comments": []
}
```

### Requête PUT /api/v1/jobs/123 (publication)

**Payload attendu :**
```json
{
  "is_published": true
}
```

**Réponse attendue :**
```json
{
  "id": "123",
  "status": "searching",
  "is_published": true,
  ...
}
```

## Cas d'erreur à tester

### 1. Utilisateur non recruteur essaie de créer une annonce

**Vérification :**
- ✅ Erreur 403 Forbidden
- ✅ Message : "Only recruiters can create offres."

### 2. Champs requis manquants

**Vérification :**
- ✅ Erreur 400 Bad Request
- ✅ Message d'erreur indiquant les champs manquants

## Checklist finale

- [ ] Aucune donnée mockée dans les requêtes POST
- [ ] Aucune donnée mockée dans les requêtes PUT/PATCH
- [ ] Le backend déduit correctement les données du recruteur depuis `request.user`
- [ ] Le statut change automatiquement avec `is_published`
- [ ] Les brouillons ont `status: "draft"`
- [ ] Les annonces publiées ont `status: "searching"`
- [ ] Aucune erreur dans les logs backend
- [ ] Aucune erreur dans la console frontend
- [ ] Les données affichées dans l'UI correspondent au recruteur connecté

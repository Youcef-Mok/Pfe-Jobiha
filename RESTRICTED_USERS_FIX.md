# Fix: Restricted Users Endpoints + Error Handling

## Problèmes résolus

### 1. Endpoints /restricted manquants (404)

**Problème**: GET /api/v1/users/me/restricted retournait 404 car les endpoints n'existaient pas.

**Solution**: Implémentation de 3 endpoints suivant le même pattern que /blocked:

#### Backend (Django)

**Fichier**: `backend/apps/users/views.py`

Ajout de la classe `RestrictedUsersView`:

```python
class RestrictedUsersView(APIView):
    """GET /users/me/restricted  — list restricted users
       POST /users/me/restricted  — restrict a user
       DELETE /users/me/restricted/{id} — unrestrict a user
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        restricted = RestrictedUser.objects.filter(
            restricteur=request.user
        ).select_related('restreint')
        data = {
            'restricted_ids': [str(r.restreint.id) for r in restricted]
        }
        return Response(data)

    def post(self, request):
        contact_id = request.data.get('contact_id')
        # Validation et création...
        RestrictedUser.objects.get_or_create(restricteur=request.user, restreint=restreint)
        return Response(status=status.HTTP_204_NO_CONTENT)

    def delete(self, request, id):
        deleted, _ = RestrictedUser.objects.filter(
            restricteur=request.user, restreint_id=id
        ).delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
```

**Fichier**: `backend/apps/users/urls.py`

Ajout des routes:

```python
# --- Restricted users ---
path('users/me/restricted', views.RestrictedUsersView.as_view(), name='restricted-users'),
path('users/me/restricted/<int:id>', views.RestrictedUsersView.as_view(), name='restricted-users-delete'),
```

#### Endpoints implémentés

| Méthode | Endpoint | Body | Réponse |
|---------|----------|------|---------|
| GET | `/api/v1/users/me/restricted` | - | `{ "restricted_ids": ["1", "2", "3"] }` |
| POST | `/api/v1/users/me/restricted` | `{ "contact_id": "123" }` | 204 No Content |
| DELETE | `/api/v1/users/me/restricted/:id` | - | 204 No Content |

### 2. Page messagerie bloquée par erreur 404

**Problème**: Le `MessagingController._load()` appelait `getRestrictedIds()` sans gestion d'erreur. Si l'endpoint retournait 404, tout le chargement des conversations échouait.

**Solution**: Ajout de try/catch dans le repository Flutter pour que les erreurs sur /restricted et /blocked ne bloquent pas le chargement.

#### Frontend (Flutter)

**Fichier**: `frontend/lib/features/messaging/data/repositories/messaging_repository_mock.dart`

**Avant**:
```dart
@override
Future<Set<String>> getRestrictedIds() async {
  final response = await _dio.get(ApiEndpoints.userRestricted);
  // Si erreur 404, exception non gérée → crash
  final List<dynamic> data = response.data is List
      ? response.data as List<dynamic>
      : (response.data['results'] as List<dynamic>?) ?? [];
  return data.map((item) => item['id']?.toString() ?? '').toSet();
}
```

**Après**:
```dart
@override
Future<Set<String>> getRestrictedIds() async {
  try {
    final response = await _dio.get(ApiEndpoints.userRestricted);
    // Backend retourne: { "restricted_ids": ["1", "2", "3"] }
    final data = response.data as Map<String, dynamic>;
    final List<dynamic> ids = data['restricted_ids'] as List<dynamic>? ?? [];
    return ids.map((item) => item.toString()).toSet();
  } catch (e) {
    // Si l'endpoint échoue, retourner un set vide pour ne pas bloquer le chargement
    return <String>{};
  }
}
```

Même correction appliquée à `getBlockedIds()` pour cohérence.

## Changements effectués

### Backend

1. **`backend/apps/users/views.py`**:
   - Import de `RestrictedUser` ajouté
   - Classe `RestrictedUsersView` ajoutée (GET, POST, DELETE)

2. **`backend/apps/users/urls.py`**:
   - Routes `/users/me/restricted` et `/users/me/restricted/<int:id>` ajoutées

### Frontend

1. **`frontend/lib/features/messaging/data/repositories/messaging_repository_mock.dart`**:
   - `getRestrictedIds()`: ajout try/catch + correction du parsing JSON
   - `getBlockedIds()`: ajout try/catch pour cohérence

## Tests

### Backend

```bash
cd backend
python manage.py check
# System check identified no issues (0 silenced).
```

### Endpoints à tester

```bash
# 1. GET restricted users (doit retourner liste vide au début)
curl -H "Authorization: Bearer <token>" http://localhost:8000/api/v1/users/me/restricted

# 2. POST restrict a user
curl -X POST -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"contact_id": "123"}' \
  http://localhost:8000/api/v1/users/me/restricted

# 3. GET restricted users (doit maintenant contenir l'ID 123)
curl -H "Authorization: Bearer <token>" http://localhost:8000/api/v1/users/me/restricted

# 4. DELETE unrestrict a user
curl -X DELETE -H "Authorization: Bearer <token>" \
  http://localhost:8000/api/v1/users/me/restricted/123
```

### Frontend

La page messagerie doit maintenant charger correctement même si:
- L'endpoint /restricted retourne 404 (avant le fix backend)
- L'endpoint /restricted retourne une erreur réseau
- L'endpoint /blocked retourne une erreur

Dans tous ces cas, les conversations se chargent normalement et les sets `blockedIds` / `restrictedIds` sont simplement vides.

## Validation

- ✅ Endpoints /restricted implémentés suivant le pattern de /blocked
- ✅ Format JSON de réponse conforme à la spec: `{ "restricted_ids": ["string"] }`
- ✅ Gestion d'erreur dans le repository Flutter
- ✅ Les appels à getBlockedIds() et getRestrictedIds() sont indépendants
- ✅ Le chargement des conversations ne bloque plus sur erreur 404
- ✅ Aucun autre fichier modifié
- ✅ `python manage.py check` passe sans erreur

## Notes

- Le modèle `RestrictedUser` existait déjà dans `backend/apps/users/models/restricted_user.py`
- La structure est identique à `BlockedUser` (restricteur, restreint, date_restriction)
- Les endpoints suivent exactement le même pattern que `/blocked` pour cohérence
- La gestion d'erreur dans le repository permet une dégradation gracieuse: si les endpoints échouent, l'app continue de fonctionner avec des listes vides

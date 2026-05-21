# Contact Classification Fix - Complete

## Problem
The contact classification logic was incorrectly hardcoding `isRecruiter` values and fetching recruiters from published jobs instead of from the users database.

## Solution

### Backend Changes

#### 1. New Endpoint: `GET /users`
**File:** `backend/apps/users/views.py`

Added `UserListView` class that:
- Returns all active, verified users
- Excludes the requesting user
- Supports optional `role` query parameter (`?role=recruteur` or `?role=candidat`)
- Returns paginated results using `UtilisateurSerializer`

**File:** `backend/apps/users/urls.py`

Added route: `path('users', views.UserListView.as_view(), name='users-list')`

### Frontend Changes

#### 1. API Endpoint
**File:** `frontend/lib/core/api/api_endpoints.dart`

Added: `static const String users = '$_base/users';`

#### 2. User Model
**File:** `frontend/lib/features/auth/data/models/user_model.dart` (NEW)

Created `UserModel` class with fields:
- `id`, `nom`, `prenom`, `email`, `telephone`
- `role` (candidat/recruteur)
- `avatarUrl`, `location`, `bio`
- `estVerifie`, `statutCompte`

#### 3. Users Repository
**File:** `frontend/lib/features/auth/data/users_repository.dart` (NEW)

Created `UsersRepository` with method:
- `getUsers({String? role})` - fetches users with optional role filter

#### 4. Contacts Provider
**File:** `frontend/lib/features/messaging/data/providers/contacts_provider.dart`

**BEFORE:**
- Fetched recruiters from published jobs
- Hardcoded `isRecruiter: false` for conversation contacts
- Hardcoded `isRecruiter: true` for job recruiters
- `suggestions` was empty

**AFTER:**
- Fetches all users from `GET /users` for suggestions
- Fetches recruiters from `GET /users?role=recruteur`
- Excludes currently logged-in user from both lists
- Sets `isRecruiter` based on `user.role == 'recruteur'` (from backend data)
- Sets `isRecruiter` based on `conv.contactRole == 'recruteur'` for conversation contacts

#### 5. Create Group Screen
**File:** `frontend/lib/features/messaging/screens/create_group_screen.dart`

**NO CHANGES NEEDED** - Screen already had both sections:
- "suggestions" section with `_selectedSuggestions` tracking
- "recruteurs" section with `_selectedRecruiters` tracking
- Both sections properly wired to `contactsProvider`

## Testing

Backend endpoint tested successfully:
```bash
python test_users_endpoint.py
```

Results:
- ✅ `GET /users` returns all users (4 total)
- ✅ `GET /users?role=recruteur` returns only recruiters (2 total)
- ✅ `GET /users?role=candidat` returns only candidates (2 total)
- ✅ Current user is excluded from results
- ✅ Only active, verified users are returned

## Classification Logic (FINAL)

### Recents Section
- Source: Conversations from messaging API
- Classification: `isRecruiter = (contactRole == 'recruteur')`
- Excludes: Group conversations, invitations

### Suggestions Section
- Source: `GET /users` (all users)
- Classification: `isRecruiter = (user.role == 'recruteur')`
- Excludes: Currently logged-in user

### Recruteurs Section
- Source: `GET /users?role=recruteur`
- Classification: `isRecruiter = true` (always, by definition)
- Excludes: Currently logged-in user

## Files Modified

### Backend
1. `backend/apps/users/views.py` - Added `UserListView`
2. `backend/apps/users/urls.py` - Added `/users` route

### Frontend
1. `frontend/lib/core/api/api_endpoints.dart` - Added `users` endpoint
2. `frontend/lib/features/auth/data/models/user_model.dart` - NEW
3. `frontend/lib/features/auth/data/users_repository.dart` - NEW
4. `frontend/lib/features/messaging/data/providers/contacts_provider.dart` - Complete rewrite

### Testing
1. `backend/test_users_endpoint.py` - NEW (test script)

## Status
✅ **COMPLETE** - Both fixes implemented and tested successfully.
